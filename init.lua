-- node.egc.setmode(node.egc.ALWAYS)

CF = require "comfun"
-- CD = require "comdebug"
-----------------------

CF.doluafile("loadHW")          -- загрузка аппаратной конфигурации
CF.doluafile("loadConfig")      -- загрузка конфигурации
CF.doluafile("loadState")       -- загрузка состояния
CF.doluafile("initHW")          -- инцицализация аппаратной конфигурации
CF.doluafile("initNet")         -- выбор и загрузка сетевой конфигурации
CF.doluafile("dsleep")          -- активация таймеров режима глубокого сна