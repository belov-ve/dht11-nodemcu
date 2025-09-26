--[[
  Компиляция lua файлов
  ver 1.0
--]]

do
    collectgarbage("collect")

    local function compile (n)
        print("\tCompile => " .. n)
        node.compile(n)
    end

    local fs = file.list("[%w-_]+.lua")
    for n,s in pairs(fs) do
        if n:match("%.([%a%d]+)$") == "lua" then
            print("Selected "..n)

            if file.exists(n) and  n ~= "init.lua" and n ~= "init-.lua" and
                    n ~= "all_compile.lua" and n ~= "all_lua_remove.lua" and n ~= "all_lc_to_lch.lua" then
                local st, err = pcall( compile, n )
                if (not st) then print("\t"..err) end
            end

        end
    end
end