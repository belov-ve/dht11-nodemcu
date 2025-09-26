--[[
 Обратока сенсоров DHT
 ver 1.1
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

        for sid, val in pairs(Sensor) do

            if Sensor[sid].name and CF.findInTable({"dht-11","dht-22"},Sensor[sid].name) then

                -- значения по умолчанию для DHT-11
                local readTime = Sensor[sid].time   -- допустимая частота опроса (мс)
                local tempMin = Sensor[sid].tempMin -- минимальная температура
                local tempMax = Sensor[sid].tempMax -- максимальная температура
                local humiMin = Sensor[sid].humiMin -- минимальная влажность
                local humiMax = Sensor[sid].humiMax -- максимальная влажность

                -- Корректировка показаний сенсора
                local d_temp = (Config.sensor[sid] and Config.sensor[sid].temp and Config.sensor[sid].temp.calibration) or 0
                local d_humi = (Config.sensor[sid] and Config.sensor[sid].humi and Config.sensor[sid].humi.calibration) or 0

                -- Интервал получений итоговых измерений датчика (мс)
                -- local timeReadDHT = iterCount * readTime * 10    -- или задать нужное значение
                local timeReadDHT = 60000

                -- Получение среднеарифмитического значения сенсора DHT
                ---- Итерационная функция сбора показаний сенсора на pin
                local function _readDHT (pin)
                    -- print("Initial function _readDHT. DHT pin - "..pin)
                    local i = 0
                    local data = {temp = {}, humi = {}}
                    return function()
                        i = ( i >= iterCount ) and 1 or i + 1
                        --print("\tRun function _readDHT. Iteration - "..i)

                        local status, temp, humi, temp_dec, humi_dec = dht.read(pin)

                        ---[[
                        if status == dht.OK then
                            print(string.format("\t\tSensor pin: %g \tCycle: %g \ttemp: %g \thumi: %g \ttemp_dec: %g\thumi_dec: %g", pin, i, temp, humi, temp_dec, humi_dec))
                        elseif status == dht.ERROR_CHECKSUM then
                            print("\tSensor read error: ERROR_CHECKSUM")
                        elseif status == dht.ERROR_TIMEOUT then
                            print("\tError reading from sensor: dth.ERROR_TIMEOUT")
                        else
                            print("\tUnknown sensor read error")
                        end
                        --]]

                        --[[ for debug
                        if not (status == dht.OK) then print("status fail") end
                        if not (temp >= tempMin and temp <= tempMax) then print("temp fail") end
                        if not (humi >= humiMin and humi <= humiMax) then print("humi fail") end
                        --]]

                        if status == dht.OK and
                            temp >= tempMin and temp <= tempMax and
                            humi >= humiMin and humi <= humiMax
                        then
                            data.temp[i] = temp
                            data.humi[i] = humi
                        end

                        -- print("function _readDHT i="..i)
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
                            if data.temp[j] and data.humi[j] then
                                count = (count or 0) + 1
                                _t = (_t or 0) + data.temp[j]
                                _h = (_h or 0) + data.humi[j]
                            end
                            -- print(string.format("\t\t averege i: %s \tj: %s \tcount: %s ", i, j, tostring(count) or "nil"))  -- for debug
                        end
                        ----

                        -- Сохранение результата
                        if count then
                            -- округление с учетом корректировки
                            _t = round( _t/count, 1) + d_temp
                            _h = round( _h/count, 1) + d_humi

                            -- print(string.format("Average DHT Temp: %g \tHumi: %g", _t, _h))
                            State.sensor[sensorID] = {}
                            State.sensor[sensorID].temp = _t
                            State.sensor[sensorID].humi = _h
                        else
                            print("In Function averDHT: Sensor no data")
                        end

                    else
                        tmr.create():alarm(readTime, tmr.ALARM_SINGLE, function() averDHT(readDHT, sensorID) end)
                    end
                end

                -- итерационная функция
                local readDHT = _readDHT(Sensor[sid].pin)
                averDHT(readDHT, sid)    -- сразу получить значение сенсора

                -- регистрация таймера периодического получения данных сенсора dht ()
                tmr.create():alarm(timeReadDHT, tmr.ALARM_AUTO, function() averDHT(readDHT, sid) end)
            end

        end

    else
        print("Sensor processing skipped")
    end

end