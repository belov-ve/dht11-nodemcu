--[[
 Скрипт перевода модуля в режим глубокого сна
   Условие:
    Config.sleep = true и State.published = true или безусловно через 1 мин с момента активации скрипта
    Пробуждение через: Config.sleeptime или Config.mqtt.interval - меньшее из указанных или 5 мин.
 ver 1.0
--]]

local disableTime = 60  -- время отключения по умолчанию (сек)
local chkTime = 5       -- время проверки состояния (сек)
local modeSleep = 2     -- режим глубокого сна (4 - wifi не поднялся)



do
    -- Таймер на каждые 5 сек. для проверки засыпания
    local tmrSleep = tmr.create()

    local function _sleep()
        local _i = 0
        return function ()

            -- удаление таймера, если конфигурация загружена и засыпание отключено
            if Config and not Config.sleep then
                print("Config.sleep not enebled. Timer stopped")
                tmrSleep:unregister()
                return nil
            end

            local ts = (Config.sleeptime and Config.mqtt and Config.mqtt.interval) and
                (Config.sleeptime < Config.mqtt.interval and Config.sleeptime or Config.mqtt.interval) or
                Config.sleeptime or Config.mqtt.interval or 5*60    -- спать указанное время или 5 минут по умолчанию

            -- проверка на безусловное отключение через 1 минуту (по умолчанию)
            _i = _i + 1
            if _i >= disableTime/chkTime then
                -- конфигурация загружена. отключение разрешено
                print("Sleep process (sec). MQTT not published: "..ts)
                node.dsleep(ts * 1000000, modeSleep)
            end

            -- если засыпание разрешено, то отключение по факту успешной публикации в топики
            if Config and Config.sleep and State and State.published then
                print("Sleep process after published (sec): "..ts)
                if MQTT then MQTT:close() end
                node.dsleep(ts * 1000000, modeSleep)
            end
        end
    end
    -------------------

    local slFn = _sleep()
    tmrSleep:alarm(chkTime * 1000, tmr.ALARM_AUTO, function() slFn() end)

end
