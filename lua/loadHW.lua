--[[
 Описание аппаратной конфигурации
 ver 3.3
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
-- Встроенный датчик напряжения питания
---[[
if adc.force_init_mode(adc.INIT_VDD33)
then
  node.restart()
  return -- Требуется перезагрузка для активации
end
--]]
---[[
Sensor = {
    {pin=7, name="dht-11", time=1000, tempMin=0, tempMax=52, humiMin=15, humiMax=95, mode=gpio.INPUT}
}
--]]
