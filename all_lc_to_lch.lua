--[[
  Переименование lс файлов в lch
  ver 1.0
--]]

do
    collectgarbage("collect")

    local fs = file.list("[%w-_]+.lc")

    for n,s in pairs(fs) do
        if n:match("%.([%a%d]+)$") == "lc" then

            if file.exists(n) then
                local _n = n:match("(.*).lc$")
                local _old = _n..".lc"
                local _new = _n..".lch"

                print(string.format("Rename:\t%s -> %s", _old, _new))
                file.rename(_old, _new)
            end

        end
    end
end
