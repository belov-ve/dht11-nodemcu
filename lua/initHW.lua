--[[
 Инициализация переключателей, кнопок и индикаторов управления
 ver 3.1
--]]

CF = require "comfun"

do
    ---[[  Светодиоды
    if Led and type(Led)=="table"  then
        for i, val in pairs(Led) do
            gpio.mode(val.pin, val.mode);
            gpio.write(val.pin, val.off);       -- выключение

            -- как пример, таймера мигания индикатора
            -- Мигание светодиодом в зависимости от состояния
            --  выключен - нет Config
            --  0.5 сек - есть Config
            --  2 сек - есть соенидение с WiFi
            --  8 сек - есть соединение с MQTT
            local function ledSt(led)
                local t = (MQTT and 4000) or (wifi and (wifi.sta.status() == wifi.STA_GOTIP) and 1000) or (Config and 250)
                local s = gpio.write(led.pin, (t and gpio.read(led.pin) == led.off and led.on or led.off) or led.off)
                tmr.create():alarm(t or 1000, tmr.ALARM_SINGLE, function() ledSt(led) end)
            end

            tmr.create():alarm(1000, tmr.ALARM_SINGLE, function() ledSt(val) end)
         end
    end
    --]]

    ---[[ переключатели Switch
    if Switch and type(Switch)=="table" then

        for i, val in pairs(Switch) do
            gpio.mode(val.pin, val.mode)

            local _state
            if State and State.switch[i] and Config and Config.switch and Config.switch[i] then
                if (Config.switch[i].default ~= "last") then    -- default может {"on", "off", "last"}
                    State.switch[i] = Config.switch[i].default
                end
                _state = State.switch[i] == "on"
            end
            gpio.write(val.pin, _state and val.on or val.off)
        end

    end
    --]]

    ---[[ Сенсоры
    if Sensor and type(Sensor)=="table"  then

        -- Инициализация
        for i, val in pairs(Sensor) do
            gpio.mode(val.pin, val.mode);
        end

        -- вызов обработчика сенсоров
        CF.doluafile("sensorDHT")
    end
    --]]

    --[[ Кнопки
    if Btn and type(Btn)=="table" then

        -- Инициализация
        for i, val in pairs(Btn) do
            gpio.mode(Btn[1].pin, Btn[1].mode, gpio.PULLUP)

        end

        -- вызов обработчика кнопок
        CF.doluafile("button")
    end
    --]]

end
