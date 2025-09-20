local pinDHT = 7

local d_temp = 0
local d_humi = 0

-----------------
print("Start DHT")
-- gpio.mode(pinDHT, gpio.OUTPUT)
-- gpio.mode(pinDHT, gpio.INPUT)
gpio.mode(pinDHT, gpio.INPUT, gpio.PULLUP)

tmr.create():alarm(3000, tmr.ALARM_AUTO, function(t)

    for i = 1, 1 do

        -- local status, temp, humi, temp_dec, humi_dec = dht.read11(pinDHT)
        local status, temp, humi, temp_dec, humi_dec = dht.read(pinDHT)
        -- local status, temp, humi, temp_dec, humi_dec = dht.read11(pinDHT)
        -- local status, temp, humi, temp_dec, humi_dec = dht.read22(pinDHT)

        if status == dht.OK then
            print(string.format("temp: %g \thumi: %g \ttemp_dec: %g\thumi_dec: %g", temp, humi, temp_dec, humi_dec))

            -- temp = temp + d_temp
            -- humi = humi + d_humi

        elseif status == dht.ERROR_CHECKSUM then
            print("Sensor read error: ERROR_CHECKSUM")
        elseif status == dht.ERROR_TIMEOUT then
            print("Error reading from sensor: dth.ERROR_TIMEOUT")
        else
            print("Unknown sensor read error")
        end

     end;


end )
