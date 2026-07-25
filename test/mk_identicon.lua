-- Подключение библиотеки из репозитория при запуске из любого каталога
local root = arg[0]:match('(.*/)') or './'
package.path = root..'../../?/init.lua;'..root..'../../?.lua;'..package.path

local identicon = require('cairo-luajit-ffi.ext.identicon')

-- Детерминированность: один seed - одна и та же картинка
local first = identicon.new({ seed = 'user@example.com' })
local second = identicon.new({ seed = 'user@example.com' })
assert(first:pngString() == second:pngString(), 'same seed must give same image')
second:destroy()

-- Разные seed - разные картинки
local other = identicon.new({ seed = 'other@example.com' })
assert(first:pngString() ~= other:pngString(), 'different seeds must give different images')
other:destroy()

first:writePng('identicon.png')
first:destroy()
