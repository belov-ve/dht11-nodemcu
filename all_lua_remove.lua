--[[
  Компиляция lua файлов
  ver 1.0
--]]

do
    collectgarbage("collect")

    local fs = file.list("[%w-_]+.lua")
    for n,s in pairs(fs) do

        if n:match("%.([%a%d]+)$") == "lua" then
            if file.exists(n) and  n ~= "init.lua" and n ~= "init-.lua" and
                    n ~= "all_compile.lua" and n ~= "all_lua_remove.lua" and n ~= "all_lc_to_lch.lua" then
                print("Remove => " .. n)
                file.remove(n)
            end
        end

    end
end