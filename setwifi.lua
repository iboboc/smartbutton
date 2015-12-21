--setwifi.lua

-- URL decode function
function unescape (s)
   s = string.gsub(s, "+", " ")
   s = string.gsub(s, "%%(%x%x)", function (h)
         return string.char(tonumber(h, 16))
       end)
   return s
end

-- if not set up in 60s then shutdown
tmr.alarm(0, 60000, 1, function()
 print("Button is on and nothing is happening.")
-- set GPIO00(3) to LOW linked to CH_PD (will shutdown the module)
 gpio.write(3, gpio.LOW)
    end)

print("Entering wifi setup..")
-- make sure red LED is on
gpio.write(red,gpio.HIGH)
gpio.write(green,gpio.LOW)
gpio.write(blue,gpio.LOW)

--change to hotspot mode
wifi.setmode(wifi.SOFTAP)
nodessid = "SmartButton" .. node.chipid()
cfg={}
    cfg.ssid=nodessid
  --cfg.password="12345678" --comment to leave open
wifi.ap.config(cfg)
ipcfg={}
    ipcfg.ip="192.168.1.1"
    ipcfg.netmask="255.255.255.0"
    ipcfg.gateway="192.168.1.1"
wifi.ap.setip(ipcfg)

-- starting webserver and set up the files to be served
local httpRequest={}
httpRequest["/"]="index.html";
httpRequest["/index.html"]="index.html";
httpRequest["/about.html"]="about.html";
httpRequest["/done.html"]="done.html";
httpRequest["/style.css"]="style.css";

local getContentType={};
getContentType["/"]="text/html";
getContentType["/index.html"]="text/html";
getContentType["/about.html"]="text/html";
getContentType["/done.html"]="text/html";
getContentType["/style.css"]="text/css";
local filePos=0;

if srv then srv:close() srv=nil end
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(conn,request)
        print("[New Request]");
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
         _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local formDATA = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "([^&=]+)=([^&=]+)") do
                print("["..k.."="..v.."]");
                k = unescape(k)
                v = unescape(v)
                formDATA[k] = v                
            end   
            if (formDATA.ssid) then
                --save URL in text file
                print("URL: ".. formDATA.customurl)
                file.remove("customurl.txt")
                tmr.delay(1000)
                file.open("customurl.txt", "w")
                file.write(formDATA.customurl)
                file.flush()
                file.close()
                print("Setting to: ".. formDATA.ssid)
                tmr.alarm(0, 5000, 1, function()
                wifi.setmode(wifi.STATION);
                wifi.sta.config(formDATA.ssid,formDATA.password);
                print("Settings saved, please restart.")         
                node.restart()       
                end)
            end            
        end
        if getContentType[path] then
            requestFile=httpRequest[path];
            print("[Sending file "..requestFile.."]");            
            filePos=0;
            conn:send("HTTP/1.1 200 OK\r\nContent-Type: "..getContentType[path].."\r\n\r\n");  
        else
            print("[File "..path.." not found]");
            conn:send("HTTP/1.1 404 Not Found\r\n\r\n")
            conn:close();
            collectgarbage();
        end
    end)
    conn:on("sent",function(conn)
        if requestFile then
            if file.open(requestFile,r) then
                file.seek("set",filePos);
                local partial_data=file.read(512);
                file.close();
                if partial_data then
                    filePos=filePos+#partial_data;
                    print("["..filePos.." bytes sent]");
                    conn:send(partial_data);
                    if (string.len(partial_data)==512) then
                        return;
                    end
                end
            else
                print("[Error opening file"..requestFile.."]");
            end
        end
        print("[Connection closed]");
        conn:close();
        collectgarbage();
    end)
end)
