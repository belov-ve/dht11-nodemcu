--[[
 Скрипт загрузки сетевой конфигурации
 ver 1.0
--]]

CF = require "comfun"

do

    if Config and (Config.mode == "ap" or BtnPressOnStart or not Config.network.sta.ssid) then

        CF.doluafile("loadNodeAsAP")    -- загрузка в рижиме AP
        CF.doluafile("webServer")       -- загрузка вебсервера

    elseif Config and Config.mode == "st" then

        CF.doluafile("loadNodeAsST")    -- загрузка в рижиме ST
        CF.doluafile("initMQTT")        -- загрузка конфигурации MQTT брокера

    else
        print("The configuration is not loaded. WIFI launch skipped")
    end;

end