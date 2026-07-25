-- Подключение библиотеки из репозитория при запуске из любого каталога
local root = arg[0]:match('(.*/)') or './'
package.path = root..'../../?/init.lua;'..root..'../../?.lua;'..package.path

local placeholder = require('cairo-luajit-ffi.ext.placeholder')

local p = placeholder.new({
  width = 300,
  height = 150,
})

p:writePng('placeholder.png')
p:destroy()
