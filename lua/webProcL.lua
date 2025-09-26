--[[
 Скрипт выполнения HTTP запроса Lua файла
ver 1.2
--]]

do
    -- print( "Load WebProcL " .. tostring(node.heap()) )

    local sck, url_file = SCK, URL

    local sendfile = {}
    sendfile.__index = sendfile

        -- функция класса
        function sendfile.new(sck, url_file)
            local self = setmetatable({}, sendfile)
            self.sck = sck
            self.st, self.dat = pcall(function() return dofile(url_file) end)

            if self.dat then
                --  подпись на disconnect
                self.sck:on("sent", function() self.sck:close(); self = nil end)
                self.sck:on("disconnection", function() self = nil end)

                if self.st then
                    self._ext = self.dat:sub(1,1)
                    self._ext = self._ext == "<" and "html" or self._ext == "{" and "json" or "txt"

                    self.sck:send(Header(200, self._ext))
                else
                    self.sck:send(Header(500, "html"))
                end
                self.sck:send(self.dat)

            else
                self = nil
            end

            return self
        end

    assert( sendfile.new(sck, url_file), "Error in WebProcL")

end
