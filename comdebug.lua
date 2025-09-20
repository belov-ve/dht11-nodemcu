--[[
    # debugfun v1.1
    printjson   <- Печать json объектов
    (вывод многомерных массивов из памяти, в том числе со структурой json)
==========================================================================
--]]

--[[ библиотеки для отладки на ББ
local sjson = require "json"
--]]

-------------------------
-- Печать json объектов
--
-- printjson(jObject)
-------------------------

local function printjson (js,jroot)
    jroot = jroot and jroot.."." or ""

    for k,v in pairs(js) do
        if type(v)=="table" then
            print(jroot..k)
            printjson(v,"\t"..jroot..k)
        elseif type(v)=="string" or type(v)=="boolean" or type(v)=="number" then
            print(jroot..k..":",v)
        end
    end
end

------
return {
    printjson   = printjson,    -- Печать json объектов
}
