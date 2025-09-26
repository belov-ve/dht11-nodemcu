--[[
 Скрипт загрузки конфигурации и подключения к MQTT брокеру
 ver 2.1
--]]

CF = require "comfun"

do
    if Config and Config.mode == "st" then

        QoS = 1

        -- Значения по умолчанию, если не указаны в конфиге
        local keepalive = 120           -- keepalive параметр mqtt (сек)
        local port = 1883               -- mqtt порт
        local interval = 300            -- период публикации состояния в mqtt (сек)


        if Config and Config.mqtt and Config.mqtt.enable and Config.mqtt.server then

            if Config.mqtt.interval then interval = Config.mqtt.interval end    -- период публикации в секундах (из конфигурации)

            local _t = (Config.sleeptime and Config.mqtt.interval) and
                (Config.sleeptime < Config.mqtt.interval and Config.sleeptime or Config.mqtt.interval) or
                Config.sleeptime or Config.mqtt.interval
            keepalive = _t and (_t + 60) or keepalive    -- время до lwt=offline (сон + минуту на первую публикацию) или по умолчанию
            -- print("keepalive = " .. keepalive)          -- test

            -- Список адресов для подключения (при каждом обращении следующий по порядку)
            local mqttGetServer = CF.getNext(Config.mqtt.server)
            local mqttServer = mqttGetServer()

            ---- Таймеры
            -- Ожидание подключения WiFi
            local _tmr = tmr.create()
            -- Публикации состояния
            local _tmrPubl  = tmr.create()

            -- Процедура подключение к MQTT брокерку
            local function mqttConnect()

                MQTT = mqtt.Client(Config.name, keepalive, Config.mqtt.user, Config.mqtt.pwd)

                if Config.mqtt.lwt then
                    MQTT:lwt(Config.mqtt.lwt, "offline", QoS, 1)     -- регистрация сообщения об отключении
                end

                -- Событие offline
                MQTT:on("offline", function(client)
                    print ("MQTT:on offline")

                    MQTT = nil
                    -- остановка публицкации статуса
                    _tmrPubl:unregister()

                    collectgarbage("collect")

                    -- пауза и повторное подключение к следующему серверу
                    _tmr:start()
                end)

                -- Событие message (опубликовано сообщение)
                MQTT:on("message", function(client, topic, data)
                    print(topic .. " :" )

                    if data ~= nil then
                        print("\t"..data)

                        --[[ Отключить, если данные от MQTT не получаем
                        data = string.lower(data)
                        do
                            local needsave

                            -- Обработка топиков "switch"
                            if Switch then      -- and Config.mqtt.switch
                                local n = CF.findInTable(Config.mqtt.switch, topic)

                                if n and Switch[n] and data~=State.switch[n] and CF.findInTable({"on","off"},data) then
                                    -- состояние не совпадает, требуется изменить состояние
                                    needsave = true

                                    -- сохранить статус
                                    State.switch[n] = data

                                    -- применить для реле
                                    gpio.write(Switch[n].pin, data=="on" and Switch[n].on or Switch[n].off)
                                end
                            end

                            -- Состояния устройства изменилось, требуется опубликовать в топик и сохранить статус
                            if needsave then
                                -- Публикация состояния устройства
                                CF.doluafile("publishMQTT")

                                -- Сохранение всех изменений в файл состояния устройства
                                local fl = file.open(State_file, "w+")
                                if fl then
                                    fl:write(sjson.encode(State))
                                    fl:close();
                                end
                            end

                        end
                        --]]

                    end

                end)


                -- подключение к mqtt брокеру
                print(string.format("Connect to %s MQTT server", mqttServer))
                MQTT:connect(mqttServer, Config.mqtt.port or port,
                    function(client)

                        print("MQTT connected")

                        if Config.mqtt.lwt then
                            MQTT:publish(Config.mqtt.lwt, "online", QoS, 1)
                        end

                        --- Подпись на топики
                        local _topics = {}
                        --[[ Отключить, если данные от MQTT не получаем
                        -- switch
                        if Config.mqtt.switch and type(Config.mqtt.switch)=="table" then
                            for i,v in pairs(Config.mqtt.switch) do
                                _topics[v] = QoS
                            end
                        end
                        --]]
                        -- Если топики есть подписываемся
                        local _contMQTT = (not next(_topics)) or MQTT:subscribe(_topics)

                        if _contMQTT then
                            -- интеграция с HomeAssisatnt
                            do
                                if Config.ha and Config.ha.enable then
                                    print("Start HA integration")
                                    CF.doluafile("integrHA")
                                end
                            end
                            collectgarbage()

                            -- публикация state устройства
                            CF.doluafile("publishMQTT")

                            -- создаем периодичный таймер публикации. настройка и запуск
                            _tmrPubl:alarm(interval * 1000, tmr.ALARM_AUTO, function() CF.doluafile("publishMQTT") end)
                        else
                            print("Subscribe failed")

                            MQTT:close()
                            mqttServer = mqttGetServer()    -- смена сервера
                            _tmr:start()                    -- пауза и повторное подключение
                        end
                    end,
                    function(client, reason)
                        print("Failed reason: " .. reason..".")

                        mqttServer = mqttGetServer()    -- смена сервера
                        _tmr:start()                    -- пауза и повторное подключение
                    end
                )

            end


            -- Настройка и запуск таймера
            _tmr:alarm(1000, tmr.ALARM_SEMI, function()
                if wifi.sta.status() == wifi.STA_GOTIP then
                    mqttConnect()       -- запуск подключения к mqtt
                else
                    _tmr:start()        -- повтор ожидания подключения WiFi
                end
            end)

            _tmr:start()  -- старт таймера

        else
            print("MQTT is disabled or not configured")
        end

    end

end