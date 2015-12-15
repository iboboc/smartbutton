--action.lua
--URL and host come out of customurl.txt file
print("Sending URL")
print("URL: " .. customurl)
print("Host: " .. customhost)
conn = nil
conn=net.createConnection(net.TCP, 0) 

conn:on("receive", function(conn, payload) 
-- show a green LED for 3 seconds before shutting down
    gpio.write(red,gpio.LOW)
    gpio.write(green,gpio.HIGH)
    gpio.write(blue,gpio.LOW)    
    tmr.delay(3000000) 
--Close all LED lights
    gpio.write(red,gpio.LOW)
    gpio.write(green,gpio.LOW)
    gpio.write(blue,gpio.LOW)
-- set GPIO00(3) to LOW linked to CH_PD (will shutdown the module)
    gpio.write(3, gpio.LOW)

--If ESP is enabled after 2 seconds that means the button is still pushed!
--in this case, will reset the configuration
    tmr.alarm(0, 2000, 1, function()
        print("Button is still pressed.")
        reset()
    end)
     
end) 
     
conn:on("connection", function(conn, payload) 
     conn:send("GET " .. customurl 
      .." HTTP/1.1\r\n" 
      .."Host: " .. customhost .. "\r\n"
      .."Accept: */*\r\n" 
      .."User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n" 
      .."\r\n") 
      print("URL request sent.") 
end) 
                                       
conn:dns(customhost,function(conn,ip) 
    if (ip) then
        print("We can connect to " .. ip)
        conn:connect(80,ip)
    else
        reset()
    end
end)

function reset()
    print("Resetting Wifi..")
    wifi.sta.disconnect()
    wifi.sta.config("","")
    file.remove('customurl.txt')
--all values are deleted, on next button press it will go into configuration mode
    print("Settings cleared, please restart.")
end
