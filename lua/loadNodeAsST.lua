--[[
 Скрипт загрузки модуля в режиме STATION
 ver 1.3
--]]
-- print("Load module in STATION mode")

CF = require "comfun"

do
    wifi.sta.autoconnect(0)

    wifi.setmode(wifi.STATION)    -- wifi.setmode(wifi.STATION, false)

    if Config.network.sta.setphymode then     -- wifi.PHYMODE_B=1, wifi.PHYMODE_G=2, wifi.PHYMODE_N=3
        if Config.network.sta.setphymode == "PHYMODE_B" then wifi.setphymode(wifi.PHYMODE_B)
        elseif Config.network.sta.setphymode == "PHYMODE_G" then wifi.setphymode(wifi.PHYMODE_G)
        elseif Config.network.sta.setphymode == "PHYMODE_N" then wifi.setphymode(wifi.PHYMODE_N)
        end
    end

    if Config.friendly_name then
        wifi.sta.sethostname(CF.mgsub(Config.friendly_name, "_ #*","--"))
    end

    local wifi_cfg = {ssid = Config.network.sta.ssid, pwd = Config.network.sta.pwd}

    if (not Config.network.sta.dhcp
            and Config.network.sta.ip
            and Config.network.sta.netmask
            and Config.network.sta.gateway) then
        wifi.sta.setip({ip = Config.network.sta.ip, netmask = Config.network.sta.netmask, gateway = Config.network.sta.gateway})
    end

    wifi.sta.autoconnect(1)

    if wifi.sta.config(wifi_cfg) then
        -- Подпись на события
        -- wifi.eventmon.register()

        ---[[
        -- STA_CONNECTED
        wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
            print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
                T.BSSID.."\n\tChannel: "..T.channel)
        end)
        --]]

        ---[[
        -- STA_GOT_IP
        wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
            print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
                T.netmask.."\n\tGateway IP: "..T.gateway)
            print("\tMAC address: "..wifi.sta.getmac())
        end)
        --]]

        ---[[
        -- STA_DISCONNECTED
        wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
            print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
                T.BSSID.."\n\treason: "..T.reason)
        end)
        --]]

        wifi.sta.connect()

    else
        print("An error occurred while loading the WIFI Configuration")
    end

end
