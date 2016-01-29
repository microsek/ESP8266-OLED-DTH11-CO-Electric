WRITEKEY="19LG5I46KAQ92ZX0"    -- set your thingspeak.com key
dthpin = 2  
--methenpin = 5
--copin= 1           
humi=0
temp=0
ck=0
tmrsent=0
co=0
pin_power=1
serverip="192.168.1.16"
gpio.mode(pin_power,gpio.INPUT)

function ReadDHT()

  --gpio.write(copin,gpio.HIGH)
  --tmr.delay(100000)  
  co = adc.read(0)
  --gpio.write(copin,gpio.LOW)

if (gpio.read(pin_power))==1 then
   power="ON"
   sendpower=220
   print("on")
elseif(gpio.read(pin_power))==0 then
    power="OFF"
     sendpower=0
    print("off")
end 
print(gpio.read(pin_power))
  
  tmrsent=tmrsent+1
  if (tmrsent==31) then
      tmrsent=0
  end

    dht=require("dht")
    status,temp,humi,temp_decimial,humi_decimial = dht.read(dthpin)
        if( status == dht.OK ) then
            -- Float firmware using this example
            display(wifi.sta.getip(),humi,temp,co,power) 
            ck=0
        elseif( status == dht.ERROR_CHECKSUM ) then
            display('DHT11 Checksum error.',temp,humi,co,power) 
            ck=1
        elseif( status == dht.ERROR_TIMEOUT ) then
           display('DHT11 error.',temp,humi,co,power)
            ck=1 
        end
    -- release module
    dht=nil
    package.loaded["dht"]=nil
end

-- send to https://api.thingspeak.com

function sendTS(humi,temp)
 if( ck==0 ) then
   if ( tmrsent==30) then

-- conection to thingspeak.com
print("Sending data to local")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,serverip) 
conn:send("GET /sensor2/receive.php?temp="..temp.."&co="..co.." HTTP/1.1\r\n") 
conn:send("Host: "..serverip.."\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
          print("Got disconnection...")
  end)

print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 184.106.153.149
conn:connect(80,'184.106.153.149') 
conn:send("GET /update?key="..WRITEKEY.."&field1="..co.." HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
          print("Got disconnection...")
  end)

--http://192.168.1.16/sensor2/receive.php?temp=5&co=23
--https://api.thingspeak.com/update?api_key=XT6T4HSYWOK9ZBAY&field1=0
  
end
print("Wait 60 sec")
-- gpio.write(LED, gpio.LOW)
elseif( ck==1) then
print("dth22error")
end
end

--ReadDHT()
--sendTS(humi,temp)

tmr.alarm(1,2000,1,function()ReadDHT()sendTS(humi,temp)end)
--FileView done.
