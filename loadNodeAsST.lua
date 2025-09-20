--[[
 Скрипт загрузки модуля в режиме STATION
 ver 1.0
--]]

print("Load the module in STATION modeN")

do
    wifi.setmode(wifi.STATION)    -- wifi.setmode(wifi.STATION, false)
    
    if config.setphymode then     -- wifi.PHYMODE_B=1, wifi.PHYMODE_G=2, wifi.PHYMODE_N=3
        if config.setphymode == "PHYMODE_B" then wifi.setphymode(wifi.PHYMODE_B)
        elseif config.setphymode == "PHYMODE_G" then wifi.setphymode(wifi.PHYMODE_G)
        elseif config.setphymode == "PHYMODE_N" then wifi.setphymode(wifi.PHYMODE_N)
        end
    end

    if config.hostname then
        wifi.sta.sethostname(config.hostname)
    end

    local wifi_cfg = {ssid = config.ssid, save = false}
    wifi_cfg.pwd = config.pwd or nil
    
    if (config.ip and config.netmask and config.gateway) then
        wifi.sta.setip({ip = config.ip, netmask = config.netmask, gateway = config.gateway})
    end
    
    if wifi.sta.config(wifi_cfg) then
        wifi.sta.connect()
    else
        print("An error occurred while loading the WIFI configuration")
    end
end
