--CD = require "comdebug"

-- пин датчика
local pinDHT = 7

-- погрешность датчика
local d_temp = 0
local d_humi = 10

-- допустимый интервал опроса сенсора (в мс)
local readTime = 1000
local tempMin = 0
local tempMax = 50
local humiMin = 20
local humiMax = 80


-- количество итераций чтения (для определения среднего арифметического)
local iterCount = 4

-----------------
print("Start DHT")
gpio.mode(pinDHT, gpio.INPUT)

-- Цикл вывода показаний
tmr.create():alarm(iterCount * readTime * 2, tmr.ALARM_AUTO, function(t)

    --[[
        -- local status, temp, humi, temp_dec, humi_dec = dht.read11(pinDHT)
        local status, temp, humi, temp_dec, humi_dec = dht.read(pinDHT)
        -- local status, temp, humi, temp_dec, humi_dec = dht.read11(pinDHT)
        -- local status, temp, humi, temp_dec, humi_dec = dht.read22(pinDHT)

        if status == dht.OK then
            temp = temp + d_temp
            humi = humi + d_humi

            print(string.format("temp: %g \thumi: %g \ttemp_dec: %g\thumi_dec: %g", temp, humi, temp_dec, humi_dec))

        elseif status == dht.ERROR_CHECKSUM then
            print("Sensor read error: ERROR_CHECKSUM")
        elseif status == dht.ERROR_TIMEOUT then
            print("Error reading from sensor: dth.ERROR_TIMEOUT")
        else
            print("Unknown sensor read error")

        end
    --]]




    ---[[ Получение среднеарифмитического значения сенсора DHT

        -- функция математичесого округления
        local function round (num, idp)
            local mult = 10^(idp or 0)
            return math.floor(num * mult + 0.5) / mult
        end

        -- Итерационная функция сбора показаний сенсора
        local function _readDHT (pin)
            -- print("Initial function _readDHT. DHT pin - "..pin)
            local i = 0
            local data = {temp = {}, humi = {}}
            return function()
                i = i + 1
                --print("\tRun function _readDHT. Ineration - "..i)

                local status, temp, humi, temp_dec, humi_dec = dht.read(pin)


                if status == dht.OK then
                    --print(string.format("\t\ttemp: %g \thumi: %g \ttemp_dec: %g\thumi_dec: %g", temp, humi, temp_dec, humi_dec))
                elseif status == dht.ERROR_CHECKSUM then
                    print("\tSensor read error: ERROR_CHECKSUM")
                elseif status == dht.ERROR_TIMEOUT then
                    print("\tError reading from sensor: dth.ERROR_TIMEOUT")
                else
                    print("\tUnknown sensor read error")
                end


                if status == dht.OK and
                        temp >= tempMin and temp <= tempMax and
                        humi >= humiMin and humi <= humiMax then
                    data.temp[i] = temp
                    data.humi[i] = humi
                end

                return i, data
            end
        end

        -- итерационная функция
        local readDHT = _readDHT(pinDHT)

        -- Создаем периодический таймер считывания показаний сенсора
        local tmrDHT  = tmr.create()
        tmrDHT:alarm(readTime, tmr.ALARM_AUTO,  --function averDHT(readDHT, tmrDHT)
            function ()
                -- print("Start function averDHT")

                local i, data = readDHT()

                -- проверка окончания цикла
                if i >= iterCount then
                    -- остановка таймера итераций сбора значений
                    tmrDHT:unregister()

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
                        temp = round( _t/count, 1) + d_temp
                        humi = round( _h/count, 1) + d_humi
                    end
                    --

                    -- вывод результата
                    if count then
                        print(string.format("Average Temp: %g \tHumi: %g", temp, humi))
                    else
                        print("Sensor read error")
                    end

                end

            end
        )
    --]]


end )
