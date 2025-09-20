--[[
 Описание аппаратной конфигурации
 ver 3.1
--]]

-- Кнопки
--[[
Btn = {
    {pin=4, mode=gpio.INT, press=gpio.LOW, presstype="both"}        -- GPIO2 pin4
}
--]]

-- Led индикаторы
---[[
Led = {
    -- {pin=1, on=gpio.LOW, off=gpio.HIGH, mode=gpio.OUTPUT},          -- GPIO5 pin1
    -- {pin=2, on=gpio.HIGH, off=gpio.LOW, mode=gpio.OUTPUT}
    {pin=4, on=gpio.LOW, off=gpio.HIGH, mode=gpio.OUTPUT}           -- GPIO4 pin2 NodeMcu v3 LED
}
--]]

-- Выключатели
--[[
Switch = {
    {pin=3, on=gpio.HIGH, off=gpio.LOW, mode=gpio.OUTPUT}           -- GPIO0 pin3
}
--]]

-- Датчики
---[[
Sensor = {
    {pin=7, name="dht-11", time=500, tempMin=0, tempMax=50, humiMin=20, humiMax=80, mode=gpio.INPUT}
}
--]]
