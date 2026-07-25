-- Подключение библиотеки из репозитория при запуске из любого каталога
local root = arg[0]:match('(.*/)') or './'
package.path = root..'../../?/init.lua;'..root..'../../?.lua;'..package.path

local badge = require('cairo-luajit-ffi.ext.badge')

local b = badge.new({
  label = 'build',
  value = 'passing',
})

b:writePng('badge.png')
b:destroy()

-- Красный бейдж с другим текстом
local failed = badge.new({
  label = 'tests',
  value = '3 failed',
  color = { 0.88, 0.25, 0.25 },
})

failed:writePng('badge-failed.png')
failed:destroy()
