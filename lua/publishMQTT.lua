--[[
 Скрипт публикации конфигурации в топик
 ver 2.3
--]]

CF = require "comfun"

do
    if Config and Config.mode ~= "st" then return nil
    elseif Config and State and Config.mqtt and Config.mqtt.enable and Config.mqtt.state and MQTT and wifi and (wifi.sta.status() == wifi.STA_GOTIP) then

        -- Если есть сенсоры, регистрация таймера считывания состояния к следующей публикации в mqtt
        ---[[
        if Sensor and State.sensor and type(State.sensor)=="table" then
            -- Интервал запуска измерения за 10 до публикации или за 290 сек (300 сек отправка по умолчанию)
            local interval = (Config.mqtt.interval and Config.mqtt.interval>10 and Config.mqtt.interval-10) or 290

            print(string.format("\t%g\tRegistering measurement start after %u seconds",tmr.time(),interval))

            tmr.create():alarm(interval*1000, tmr.ALARM_SINGLE, function()
                CF.doluafile("sensorDHT")
            end)

        end
        --]]

        local js = {}
        local canpub = true

        js.type = "device_announced"
        if Config.name then js.name = Config.name end
        if Config.friendly_name then js.friendly_name = Config.friendly_name end
        if Config.model then js.model = Config.model end
        js.ip = wifi.sta.getip()

        if wifi then js.linkquality =  100 + wifi.sta.getrssi() end

        -- switch
        --[[
        if Switch and State.switch and type(State.switch)=="table" then
            for i,v in pairs(State.switch) do
                    js["switch_"..i] = string.upper( v )
            end
        end
        --]]

        -- sensor
        ---[[
        -- Sensor ADC
        if adc then
            local adm = adc.readvdd33(0)  -- в mV
            -- напряжение в процентах
            local pmax = 3300  -- Нормальное напряжение: 3.3V
            local pmin = 2500  -- Минимальное рабочее напряжение: 2.5V
            local adp = (adm - pmin) / (pmax - pmin) * 100
            adp = math.floor(adp + 0.5)   -- округление
            print(string.format("\t%g\tSystem voltage (mV): %u \tPower level (%%): %u",tmr.time(),adm,adp))

            js.system_voltage = adm
            js.power_level = adp
        end
        --]]

        ---[[
        if Sensor and State.sensor and type(State.sensor)=="table" then
            for i,v in pairs(State.sensor) do

                if CF.findInTable({"dht-11","dht-22"}, Sensor[i].name) and v.temp and v.humi then
                    print(string.format("\t%g\tPublishing temp=%.1f \thumi=%.1f",tmr.time(),State.sensor[i].temp, State.sensor[i].humi))
                    js["temperature_"..i] = string.upper( v.temp )
                    js["humidity_"..i] = string.upper( v.humi )
                else
                    canpub = false
                    print("*** Sensor state unknown")
                end

            end
        end
        --]]

        if canpub then
            MQTT:publish(Config.mqtt.state, sjson.encode(js), QoS, 1)
            State.published = true    -- опубликовано. нужно для реализации режима sleep 
        end

        -- отладка. сколько памяти
        print("node.heap() = " .. node.heap() )


    else
        print("Publication in the topic is not possible")
    end
end