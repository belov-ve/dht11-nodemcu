--[[
 Скрипт загрузки HTTP сервера
ver 1.2
--]]

--require('net')
-- node.egc.setmode(node.egc.ALWAYS)
CF = require "comfun"

do
    -- print("Start module WebServer")
    -- HTTP Server
    -- Close old Server
    if HTTPD then
        HTTPD:close()
    end

    HTTPD = net.createServer(net.TCP)

        Headers = {
            [200] = "200 OK",
            [500] = "500 Internal Server Error",
            [404] ="404 Not Found"
        }

        Ext = {
            txt="text/plain", js="application/javascript",json="application/json",
            ico="image/x-icon", html="text/html", css="text/css", lua="text/html",
            gif="image/gif", png="image/png", jpeg = "image/jpeg", jpg = "image/jpeg"
        }


        -- вызов процесса
        local function receive_http_try(sck, data)
            HTTP_SCK, HTTP_DATA = sck, data

            if not CF.doluafile("webProc") then
                sck = nil
                data = nil
            end

            HTTP_SCK, HTTP_DATA = nil, nil

            collectgarbage()
            return nil
        end

    if HTTPD then
        -- print("Lister started")
        HTTPD:listen(80, function(conn)
          conn:on("receive", receive_http_try)
        end)
    -- else
        -- print("Lister not start -> HTTPD=nil")
    end
end