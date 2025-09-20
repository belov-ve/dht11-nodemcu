--[[
 Обратока сенсоров DHT
 ver 1.0
--]]

CF = require "comfun"

do
    -- print("Start script sensorDHT")

    -- количество итераций чтения (для алгоритма определения среднего арифметического)
    local iterCount = 4

    if Sensor and Config and State and type(Sensor)=="table" and Config.sensor then

        -- функция математичесого округления
        local function round (num, idp)
            local mult = 10^(idp or 0)
            return math.floor(num * mult + 0.5) / mult
        end

    -----------------------

        for i, val in pairs(Sensor) do

            if Sensor[i].name and CF.findInTable({"dht-11","dht-22"},Sensor[i].name) then

                -- значения по умолчанию для DHT-11
                local readTime = Sensor[i].time or 1000     -- допустимая частота опроса (мс)
                local tempMin = Sensor[i].tempMin or 0      -- минимальная температура
                local tempMax = Sensor[i].tempMax or 50     -- максимальная температура
                local humiMin = Sensor[i].humiMin or 20     -- минимальная влажность
                local humiMax = Sensor[i].humiMax or 80     -- максимальная влажность

                -- Корректировка показаний сенсора
                local d_temp = (Config.sensor[i] and Config.sensor[i].temp and Config.sensor[i].temp.calibration) or 0
                local d_humi = (Config.sensor[i] and Config.sensor[i].humi and Config.sensor[i].humi.calibration) or 0

                -- Интервал опроса датчика (mc)
                local timeReadDHT = iterCount * readTime * 10    -- или задать нужное значение

                -- if Config.mqtt and Config.mqtt.enable and Config.mqtt.interval then
                --     timeReadDHT = Config.mqtt.interval * 60 * 1000
                -- end

                -- Получение среднеарифмитического значения сенсора DHT
                ---- Итерационная функция сбора показаний сенсора
                local function _readDHT (pin)
                    -- print("Initial function _readDHT. DHT pin - "..pin)
                    local i = 0
                    local data = {temp = {}, humi = {}}
                    return function()
                        i = ( i >= iterCount ) and 1 or i + 1
                        --print("\tRun function _readDHT. Ineration - "..i)

                        local status, temp, humi, temp_dec, humi_dec = dht.read(pin)

                        --[[
                        if status == dht.OK then
                            --print(string.format("\t\ttemp: %g \thumi: %g \ttemp_dec: %g\thumi_dec: %g", temp, humi, temp_dec, humi_dec))
                        elseif status == dht.ERROR_CHECKSUM then
                            print("\tSensor read error: ERROR_CHECKSUM")
                        elseif status == dht.ERROR_TIMEOUT then
                            print("\tError reading from sensor: dth.ERROR_TIMEOUT")
                        else
                            print("\tUnknown sensor read error")
                        end
                        --]]

                        if status == dht.OK and
                                temp >= tempMin and temp <= tempMax and
                                humi >= humiMin and humi <= humiMax then
                            data.temp[i] = temp
                            data.humi[i] = humi
                        end

                        return i, data
                    end
                end

                local function averDHT (readDHT, sensorID)
                    -- print("Start function averDHT")

                    local i, data = readDHT()

                    -- проверка окончания цикла
                    if i >= iterCount then
                        --CD.printjson(data)

                        -- подсчет среднего арифметического значения показателей
                        local count, _t, _h

                        for j = 1, i do
                            if data.temp[j] then
                                count = (count or 0) + 1
                                _t = (_t or 0) + data.temp[j]
                                _h = (_h or 0) + data.humi[j]
                            end
                        end

                        if count then
                            _t = round( _t/count, 1) + d_temp
                            _h = round( _h/count, 1) + d_humi
                        end
                        ----

                        -- Сохранение результата
                        if count then
                            -- print(string.format("Average DHT Temp: %g \tHumi: %g", _t, _h))
                            State.sensor[sensorID] = {}
                            State.sensor[sensorID].temp = _t
                            State.sensor[sensorID].humi = _h
                        else
                            print("Sensor read error")
                        end

                    else
                        tmr.create():alarm(readTime, tmr.ALARM_SINGLE, function() averDHT(readDHT, sensorID) end)
                    end
                end

                -- итерационная функция
                local readDHT = _readDHT(Sensor[i].pin)
                averDHT(readDHT, i)    -- сразу получить значение сенсора

                -- регистрация таймера периодического получения данных сенсора dht ()
                tmr.create():alarm(timeReadDHT, tmr.ALARM_AUTO, function() averDHT(readDHT, i) end)
            end

        end

    else
        print("Sensor processing skipped")
    end

end