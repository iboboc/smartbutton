--init.lua

-- set GPIO00(3) to HIGH linked to CH_PD 
gpio.mode(3, gpio.OUTPUT)
gpio.write(3, gpio.HIGH)

--define GPIO colors for RGB LED
red = 7
blue = 5
green = 6

--set the GPIO types
gpio.mode(red,gpio.OUTPUT)
gpio.mode(green,gpio.OUTPUT)
gpio.mode(blue,gpio.OUTPUT)

--power up the red led
gpio.write(red,gpio.HIGH)
gpio.write(green,gpio.LOW)
gpio.write(blue,gpio.LOW)

--variable for connecting retries
cnt = 0

print("Starting SmartButton")
--simple function to check for a file and content
function file_exists(name)
   fileresult=file.open(name,"r")
   if fileresult~=nil then file.close(fileresult) return true else return false end
end

-- count the button pushes and store in a local txt file
if file_exists("pushes.txt") then 
    file.open("pushes.txt", "r")
    psh = file.readline()
    file.close()
    psh = psh+1
    print("Button has been pushed "..psh.." times.")
else
   print("Button has been pushed for the first time.")
   psh = 1
end
    file.remove("pushes.txt")
    tmr.delay(1000)
    file.open("pushes.txt", "w")
    file.write(psh)
    file.flush()
    file.close()

-- if customurl file is set (exists) then we load the url
if file_exists("customurl.txt") then 
    print("Custom URL")
    file.open("customurl.txt", "r")
    customurl = file.readline()
    file.close()
    customhost = customurl:match('^%w+://([^/]+)')
    print(customurl)
    print(customhost)
-- try to connect to Wi-Fi ten times
-- if dont get a valid IP go to Wi-Fi set up
-- else do main stuff
tmr.alarm(1, 1000, 1, function()
if wifi.sta.getip()== nil then
    cnt = cnt + 1
    print("(" .. cnt .. ") Waiting for IP...")
    if cnt == 10 then
        tmr.stop(1)
        dofile("setwifi.lua")
    end
else
    tmr.stop(1)
-- change LED color to blue 
    gpio.write(red,gpio.LOW)
    gpio.write(green,gpio.LOW)
    gpio.write(blue,gpio.HIGH)
    print("Connected to Wifi")
    print(wifi.sta.getip())
    dofile("action.lua")
end
end)  
-- if custom url is not defined, then reset all Wi-Fi information and change to OTA config mode
    else
    wifi.sta.disconnect()
    wifi.sta.config("","")
    dofile("setwifi.lua")
end
