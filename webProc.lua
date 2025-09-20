--[[
Скрипт процесса обработки HTTP
ver 1.2
--]]

CF = require "comfun"

do
    -- print( "load WebProc " .. "\tHeap() " .. tostring(node.heap()) )

    local sck, data = HTTP_SCK, HTTP_DATA

        function Header(hc, td)
            if not td then td = "txt" end
            local s = "HTTP/1.0 ".. Headers[hc] .."\r\nServer: web-server\r\nContent-Type: "..Ext[td].."\r\n"

            if COOKIE then
                for key, val in pairs(COOKIE) do
                    s = s.."Set-Cookie: "..key.."="..val.."\r\n"
                end
            end

            s = s.."Connection: close\r\n\r\n"
            return s
        end

        -- decode URI
        local function decodeURI(s)
            if(s) then
                s = string.gsub(s, '%%(%x%x)',
                function (hex) return string.char(tonumber(hex,16)) end )
            end
            return s
        end


    --local host_name = data:match("Host: ([0-9,\.]*)")
    local url_file = data:match("[^/]*\/([^ ?]*)[ ?]") or Url_file     -- path request
    local uri = decodeURI(data:match("[^?]*\?([^ ]*)[ ]"))
    local cookies = data:match("Cookie:%s+([%w%s_=;]*)")

    -- парсим COOKIE
    COOKIE={}
    if cookies then
        for key, value in string.gmatch(cookies, "([%w_]+)=([%w_]+)") do
            COOKIE[key]=decodeURI(value)
        end
    end

    -- парсим GET parameters
    GET={}
    if uri then
        for key, value in string.gmatch(uri, "([^=&]*)=([^&]*)") do
            GET[key]=value
        end
    end

    -- POST parameters (парсим в обработчиках)
    -- только Content-type = application/json
    local post = string.match(data,"\n([^\n]*)$",1)
    post = post and post:gsub("+", " ") or data
    POST = nil
    if post then
        if #post == 0 then
            Url_file = url_file
        else
            Url_file = nil
            POST = decodeURI(post)
        end
        post = nil
    end

    local request_OK = false

    -- если путь не указан, отправляем index.html
    url_file = url_file == "" and "index.html" or url_file

    -- защита конфигурации от просмотра
    url_file = url_file == Conf_file and "" or url_file

    -- print("url_file = " .. url_file)

    if url_file and not file.exists(url_file) then
        local _ext, _find = {".luah", ".lch"}, ""
        for i,v in pairs(_ext) do
            if file.exists(url_file..v) then
                _find = url_file..v
                break
            end
        end
        url_file = _find
    end

    local fext = url_file:match("%.([%a%d]+)$")

    SCK, URL = sck, url_file
    if Ext[fext] then
        if CF.doluafile("webProcF") then
            request_OK = true
        end

    -- execute LUA file (расширение исполняемых lua скриптов для безопасности изменил)
    -- luah - файл lua; lch - файл lc
    elseif (fext == 'luah' or fext == 'lch') then

        if CF.doluafile("webProcL") then
            request_OK = true
        end

    end
    SCK, URL = nil, nil

    if request_OK == false then
        sck:on("sent", function(sck) sck:close(); sck = nil end)
        sck:send(Header(404, "html"))
        sck:send(string.format("<h1>%s</h1>", Headers[404]))
        return true
    end

    Header = nil

end