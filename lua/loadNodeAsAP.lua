--[[
 Скрипт загрузки модуля в режиме Access Point
 ver 1.3
--]]
-- print("Start the module in AP mode")

do
    wifi.sta.autoconnect(0)

    wifi.setmode(wifi.SOFTAP)

    local wifi_cfg = {
        ssid = Config.friendly_name or Config.name or nil,  -- SSID chars 8-64
        pwd = Config.network.ap.pwd or nil, -- password
    }
    -- authentication method: wifi.OPEN (default), wifi.WPA_PSK, wifi.WPA2_PSK, wifi.WPA_WPA2_PSK
    if Config and Config.network.ap.auth and wifi_cfg.pwd then
        if Config.network.ap.auth == "OPEN" then wifi_cfg.auth = wifi.OPEN
        elseif Config.network.ap.auth == "WPA_PSK" then wifi_cfg.auth = wifi.WPA_PSK
        elseif Config.network.ap.auth == "WPA2_PSK" then wifi_cfg.auth = wifi.WPA2_PSK
        elseif Config.network.ap.auth == "WPA_WPA2_PSK" then wifi_cfg.auth = wifi.WPA_WPA2_PSK
        end
    end

    -- wifi.PHYMODE_B=1, wifi.PHYMODE_G=2, wifi.PHYMODE_N=3
    if Config.network.ap.setphymode == "PHYMODE_B" then wifi.setphymode(wifi.PHYMODE_B)
    elseif Config.network.ap.setphymode == "PHYMODE_G" then wifi.setphymode(wifi.PHYMODE_G)
    elseif Config.network.ap.setphymode == "PHYMODE_N" then wifi.setphymode(wifi.PHYMODE_N)
    end

    if (Config.network.ap.ip and Config.network.ap.netmask) then    -- and config.network.ap.gateway
        wifi.ap.setip({ip = Config.network.ap.ip, netmask = Config.network.ap.netmask, gateway = Config.network.ap.gateway})
    end

    if wifi.ap.config(wifi_cfg) then    -- загружаем конфигурацию
        local i, m, g = wifi.ap.getip()
        -- print("\n\tIP: "..i.."\tMASK: "..m.."\tGW: "..g)

        -- Подпись на события
        -- wifi.eventmon.register()

        --[[
        -- AP_STACONNECTED
        wifi.eventmon.register(wifi.eventmon.AP_STACONNECTED, function(T)
            print("\n\tAP - STATION CONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
        end)
        --]]


        -- AP_STADISCONNECTED
        --[[
        wifi.eventmon.register(wifi.eventmon.AP_STADISCONNECTED, function(T)
            print("\n\tAP - STATION DISCONNECTED".."\n\tMAC: "..T.MAC.."\n\tAID: "..T.AID)
        end)
        --]]


        --[[
        -- AP_PROBEREQRECVED
        wifi.eventmon.register(wifi.eventmon.AP_PROBEREQRECVED, function(T)
            print("\n\tAP - PROBE REQUEST RECEIVED".."\n\tMAC: ".. T.MAC.."\n\tRSSI: "..T.RSSI)
        end)
        --]]

    -- else
        -- print("An error occurred while loading the AP configuration")
    end
end