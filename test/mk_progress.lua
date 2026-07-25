-- Подключение библиотеки из репозитория при запуске из любого каталога
local root = arg[0]:match('(.*/)') or './'
package.path = root..'../../?/init.lua;'..root..'../../?.lua;'..package.path

local progress = require('cairo-luajit-ffi.ext.progress')

local p = progress.new({ percent = 42 })
p:writePng('progress.png')
p:destroy()

-- Граничные значения не должны ломать отрисовку
for _, percent in pairs({ 0, 100, 146 }) do
  local edge = progress.new({ percent = percent })
  edge:destroy()
end
