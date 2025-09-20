--[[
 Тестовый скрипт работы с MQTT Module
 ver 1.0
--]]
pinDHT = 7
timDTH = 60     -- sec.
status, temp, humi = nil, nil, nil

dofile("loadNodeConf.lua")  -- загрузка конфигурации
-- mqtt_s = "192.168.225.101"
mqtt_s = "192.168.225.3"
mqtt_sp = "1883"
topicT = "/lab/sensor/dht11/temp"
topicH = "/lab/sensor/dht11/humi"
topiclwt = "/lab/sensor/dht11/status"
mqtt_u = "mqtt"
mqtt_p = "xxxxxxxxxx"
keepalive = 120
d_temp = 0
d_humi = 10

print("Parameters loaded:")

for k,v in pairs(config) do
    print("\tField: "..k.." = "..v)
end
----------------------------------

if (config.ssid) then
    -- загружаем в режиме STATION
    dofile("loadNodeAsST.lua")

    -- подписываемся на события через wifi.eventmon.register()
    -- STA_CONNECTED
    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
        print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
    end)
    -- STA_GOT_IP
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
        print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..T.netmask.."\n\tGateway IP: "..T.gateway)
        print("\tMAC address: "..wifi.sta.getmac())
        mqttConnect()
    end)
    -- STA_DISCONNECTED
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
        print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\treason: "..T.reason)
        if m then m = nil end
    end)
end


function mqttConnect()
    m = nil     -- очищаем старое соединение
    m = mqtt.Client(config.hostname, keepalive, mqtt_u, mqtt_p)
    m:lwt(topiclwt, "offline",0,1)     -- регистрация сообщения об отключении
    
    m:on("connect",
        function(client)
            print ("m:on connected")
            --[[ сюда после коннекта не попадаем и запуск не отрабатывает
            tmr.alarm(1, timDTH * 1000, tmr.ALARM_AUTO,
                function()
                    getTemp()
                end)
            --]]
        end)
        
    m:on("offline",
        function(client)
            mconnected = false
            print ("m:on offline \tMeasurement timer stopped. Reconnect after 10 sec.")
            ---[[ 
                -- из-за несрабатывания on:connect здесь таймер весегда отключается
                -- что является ошибкой
            if tmr1 then
                tmr1:unregister(1)
                tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, mqttConnect)  -- рестарт через 10 сек.
            end
            --]]
        end)
        
    m:on("message", 
        function(client, topic, data) 
            print(topic .. " :\t" .. (data or "") )
            --if data ~= nil then
            --    print("\t"..data)
            --end
        end)
    
    mconnected = m:connect(mqtt_s, mqtt_sp,
        function(client)
            ---[[
            print("mqtt connected")
            client:subscribe(topicT, 0)  --, function(client) print(topicT.." subscribe success") end)
            client:subscribe(topicH, 0, function(client) print("Subscribe success") end) -- по документации несколько раз срабатывает последний вызов
            -- client:publish(topicT, "DHT publush", 0, 0, function(client) print("mqtt sent") end)
            -- client:publish(topicH, "DHT publush", 0, 0, function(client) print("mqtt sent") end)
          
            -- старт таймера измерений. m:on("connect"... почему-то выше не отрабатывает
            --]]

            ---[[
            tmr1 = tmr.create():alarm(timDTH * 1000, tmr.ALARM_AUTO,
                    function()
                        getTemp()
                    end)
            --]]
            getTemp()

            -- m:publish(topiclwt, "online",0,1)
        end,
        function(client, reason)
            print("failed reason: " .. reason..". Reconnect after 10 сек.")
            tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, mqttConnect)  -- рестарт через 10 сек.
        end
    )
end

function getTemp()

    -- status, temp, humi = dht.read11(pinDHT)
    status, temp, humi = dht.read(pinDHT)

    if status == dht.OK and mconnected then
        --print(string.format("Temp: %g;\tHumi: %g", temp, humi))
        --print("Темпиратура: "..temp..";\tВлажность: "..humi)

        temp = temp + d_temp
        humi = humi + d_humi

        m:publish(topicT, temp, 0, 1)   -- "Temperature: "..temp
        m:publish(topicH, humi, 0, 1)   -- "Humidity: "..humi
    elseif not mconnected then 
        print ("No connection to MQTT broker")
    elseif status == dht.ERROR_CHECKSUM then
        print("Sensor read error: ERROR_CHECKSUM")
    elseif status == dht.ERROR_TIMEOUT then
        print("Error reading from sensor: dth.ERROR_TIMEOUT")
    else
        print("Unknown sensor read error")
    end

    -- print log
    if status == dht.OK then
        print(string.format("Temp: %g;\tHumi: %g", temp, humi))
    end

end
