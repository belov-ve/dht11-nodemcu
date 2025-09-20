--[[
 Cкрипт загрузки параметров модул¤ из файла конфигурации
 ver 1.0
--]]

conf_file = "conf.ini"
config = {}     -- глобальный массив параметров конфигурации

function createConfig(cfl)
    -- сделать включение в режиме точки доступа с настройкой всех параметров
    -- пока назначаю параметры и создаю файл
    local mas = {}
    mas.hostname = "NodeMCU-Lab"
    mas.ssid = "Asus-Home_7-1_2.4"
    mas.pwd = "xxxxxxxxxx"

    local fl = file.open(cfl, "w+")
    if fl then
        fl:write(sjson.encode(mas))
        fl:close();                 -- fl = nil
    end
    return mas
end

do
    if file.exists(conf_file) then
        local fl = file.open(conf_file, "r")
        if fl then
            local sj = fl:read()
            fl:close();             -- fl = nil
            config = sjson.decode(sj)
            for k,v in pairs(config) do -- очищаем пустые параметры
                config[k] = v=="" and nil or config[k]
            end
        else                        -- ошибка открыти¤ файла конфигурации
            createConfig(conf_file)
        end      
    else                            -- файла конфигурации нет
        createConfig(conf_file)    
    end
end
