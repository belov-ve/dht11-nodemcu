--[[
 Скрипт выполнения HTTP запроса файла
ver 1.2
--]]

do
    -- print( "Load WebProcF " .. tostring(node.heap()) )
    local maxlen = 128                      -- Ограничение длины передаваемого блока (условно)
    local mlua = "<%?lua(.-)%?>"

    local sck, url_file = SCK, URL

    local sendfile = {}
    sendfile.__index = sendfile

        -- функция класса
        function sendfile.new(sck, fname)
            local self = setmetatable({}, sendfile)
            self.fext = fname:match("%.([%a%d]+)$")
            self.sck = sck
            self.fd = file.open(fname, "r")

            -- фукция исполнения интегрированного кода LUA
            local function exec(s)
                for j in s:gmatch(mlua) do
                    local d,k = pcall(loadstring(j))
                    s=s:gsub(mlua, tostring(d and k or "Error in imported LUA"), 1)
                end
                return s
            end

            -- основаная функция отправки
            local function send(lsck)
                local out = nil

                if self.fext == "html" then
                    -- читаем в out из файла строки, но суммой не более максимально допустмой длины
                    repeat
                        local _s = self.readln()

                        if _s and _s:find(mlua) then
                            out = (out or "")..exec(_s).."\n"
                        elseif _s then
                            out = (out or "").._s.."\n"
                        end
                    until (out and #out or maxlen) >= maxlen or _s == nil
                else
                    out = self.fd:read(maxlen)
                end

                -- отправляем данные или закрываем сокет и все очищаем
                if out then
                    pcall(function() return lsck:send(out) end)
                else
                    if self.fd then
                        self.fd:close()
                        self.readln, self.fd = nil, nil
                    end
                    lsck:close()
                    self, lsck = nil, nil
                end
            end

            -- чтение порциями в локальный буфер из файла
            local function _readln(self)
                local mas = {}
                return function()
                    if (#mas < 2) then      -- 2 чтобы склеивать разорванные чтением в буфер строки
                        local buf = self.fd:read(maxlen)
                        if buf then
                            local l
                            if #mas == 1 then l = true end -- для склеивания разорванных чтением в буфер строк (важно для <?lua)
                            for _s in buf:gmatch("([^\n]+)") do
                                if l then
                                    mas[1] = mas[1].._s
                                    l = nil
                                else table.insert( mas, _s ) end
                            end
                        end
                        buf = nil
                    end
                    --
                    local ret = mas[1]
                    table.remove(mas, 1)
                    collectgarbage("collect")

                    return ret
                end
            end

            if self.fd then
                -- старт отправки
                self.readln = _readln(self)
                self.sck:on("sent", send)

                -- подпись на disconnect
                self.sck:on("disconnection",
                    function()
                        if self.fd then
                            self.fd:close()
                        end
                        self = nil
                        return nil
                    end
                )

                self.sck:send(Header(200, self.fext or "txt"))
                send(self.sck)
            else
                self = nil
            end
            return self
        end

    assert( sendfile.new(sck, url_file), "Error in WebServProcF")

end