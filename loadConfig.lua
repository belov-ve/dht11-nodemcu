--[[
 Скрипт загрузки параметров модуля из файла конфигурации
 ver 2.1
--]]

--[[ библиотеки для отладки на ББ
local sjson = require "json"
local file = require "io"
--]]

CF = require "comfun"

Conf_file = "esp.cfg"       -- имя файла конфигурации
Config = {}                 -- глобальный массив параметров конфигурации
Model = "NodeMCU DHT Sensor (DHT-11)"
ModelVersion = "ver:1.0"
ModelManufacturer = "BVE"


do
    local friendly_name = "Lab thermometer" -- "DHT Sensor"

    -- создание шаблонного конфиг файла
    local function createConfig(cfl)
        ----- default config -----
        local sj = [[
        {
            "mode": "st",
            "sleep": true,
            "sensor": [
                {
                    "temp": {
                        "unit_of_measurement": "°C",
                        "device_class": "temperature",
                        "calibration": 0,
                        "icon": "mdi:thermometer-plus"
                    },
                    "humi": {
                        "unit_of_measurement": "RH(%)",
                        "device_class": "humidity",
                        "calibration": 10,
                        "icon": "mdi:water-percent"
                    }
                }
            ],
            "network": {
                "ap": {
                    "setphymode": "PHYMODE_G",
                    "pwd": "",
                    "auth": "",
                    "ip": "192.168.4.1",
                    "netmask": "255.255.255.0",
                    "gateway": "192.168.4.1"
                },
                "sta": {
                    "setphymode": "PHYMODE_G",
                    "ssid": "Asus-Home_7-1_2.4",
                    "pwd": "xxxxxxxx",
                    "dhcp": true,
                    "ip": "192.168.225.99",
                    "netmask": "255.255.255.0",
                    "gateway": "192.168.225.1"
                }
            },
            "mqtt": {
                "enable": true,
                "interval": 300,
                "server": ["192.168.225.3", "192.168.225.4", "belov.duckdns.org"],
                "port": "1883",
                "user": "mqtt",
                "pwd": "MQTT!User"
            },
            "ha": {
                "enable": false,
                "discovery_prefix": "homeassistant"
            }
        }
        ]]
        ------------------

        local config = sjson.decode(sj)

        -- Имя модуля
        config.name = "ESP-" .. tostring(node.info('hw').chip_id)
        if friendly_name then
            config.friendly_name =  CF.mgsub(friendly_name, " #*/", "_--_")
        else
            config.friendly_name =  CF.mgsub(config.name, " #*/", "_--_")
        end

        -- топики mqtt
        config.mqtt.state = "nodemcu/" .. string.lower(config.friendly_name)
        config.mqtt.lwt = config.mqtt.state .. "/lwt"

        --[[
        if Switch then
            config.mqtt.switch = {}
            for i,val in pairs(Switch) do
                config.mqtt.switch[i] = config.mqtt.state .. "/switch/" .. i .. "/set"
            end
        end
        --]]

        do
            sj = sjson.encode(config)
            if file.open(cfl, "w+") then
                file.write(sj)
                file.close()
            else
                -- print("Error save new config file")
            end
        end
        return config
    end

    -- очистка пустых полей config
    local function clearJson(obj)
        for k,v in pairs(obj) do                    -- перебираем объекты
            if type(v) == "table" then
                clearJson(v)
            elseif type(v) == "string" then
                obj[k] = v~="" and obj[k] or nil    -- очищаем пустые параметры
            end
        end
    end


------------------
    local stcf
    if file.exists(Conf_file) then
        local fl = file.open(Conf_file, "r")
        if fl then
            stcf = pcall( function ()
                local sj = fl:read()
                fl:close()
                Config = sjson.decode(sj)
            end)
        end
    end

    if not stcf then
        --print("No valid configuration file found. Create new")
        Config = createConfig(Conf_file)    -- сохранение в файл конфигурации по умолчанию

        -- выбор загружаемой конфигурации (установить по смыслу поведения устройства) - "ap" или "st"
        Config.mode = "st"   -- определить какой будет первая загрузка после создания конфигурации
    else
        -- Пример реализации для бескнопочной конфигурации.
        -- 1. при подаче питания или ресет кнопкой (из dsleep два раза ресет):
        --      30 секунд ожидания в "ap" для выбора режима и далее ресет програмный
        -- 2. ресет програмный или dsleep или ресет кнопкой из dsleep:
        --      загружаем конфигурацию из конфига
        local p1,p2 = node.bootreason()
        if p2 ~= 4 and p2 ~= 5 then  -- 4 software restart, 5 wake from deep sleep
            Config.mode = "ap"
            tmr.create():alarm(30*1000, tmr.ALARM_AUTO, function () node.restart() end)
        end
        print(string.format("Load in: '%s'\tbootreason = %u, %u", Config.mode, p1, p2))
    end

    clearJson(Config)

    -- print("Parameters loaded:")
    -- CD.printjson(Config)    -- печать json объекта
end