--[[
 Скрипт загрузки состояния устройства
 ver 2.0
--]]

--local cf = require "comfun"

SaveStateToFile = false     -- требуется ли сохранять State в файл (зависит от проекта)
State_file = "state.json"   -- имя файла сохраненного состояния
State = {}                  -- глобальный массив параметров состояния


do

    -- создание нового файла состояний
    local function createState(sfl)
        local state = {}

        -- переключатели
        if Switch then
            state.switch = {}

            for i,val in pairs(Switch) do
                if Config and Config.switch and Config.switch[i] and (Config.switch[i].default ~= "last") then
                    state.switch[i] = Config.switch[i].default
                else
                    state.switch[i] = "on"     -- если не указано в конфиге, по умолчанию включено
                end
            end
        end

        -- сенсоры
        if Sensor then
            state.sensor = {}
        end

        -- индикаторы
        if Led then
            state.led = {}
        end

        -- сохранение файла состояний
        if sfl then
            local sj = sjson.encode(state)
            if file.open(sfl, "w+") then
                file.write(sj)
                file.close()
            else
                print("Error save new state file")
            end
        end

        return state
    end

    -- очистка пустых полей в Json
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

    local stsf
    if SaveStateToFile and file.exists(State_file) then
        local fl = file.open(State_file, "r")
        if fl then
            stsf = pcall( function ()
                local sj = fl:read()
                fl:close()
                State = sjson.decode(sj)
            end)
        end
    end

    if not stsf then

        if SaveStateToFile then
            print("No valid state file found. Create new")
            State = createState(State_file)    -- сохранение в файл конфигурации по умолчанию
        else
            State = createState()    -- создание нового файла состояний без сохранения в файл
        end

    end

    clearJson(State)

    --print("State loaded:")
    --CD.printjson(State)    -- печать json объекта
end