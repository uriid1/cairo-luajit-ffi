-- Подключение библиотеки из репозитория при запуске из любого каталога
local root = arg[0]:match('(.*/)') or './'
package.path = root..'../../?/init.lua;'..root..'../../?.lua;'..package.path

local histogram = require('cairo-luajit-ffi.ext.histogram')

local descriptions = {}
local values = {}

local sinStep = 0
for i = 1, 35 do
  sinStep = sinStep + math.pi / 8
  table.insert(values, i + math.sin(sinStep) * 5)
  table.insert(descriptions, tostring(i))
end

local h = histogram.new({
  values = values,
  descriptions = descriptions,
  --
  height = 500,
  --
  space = {
    leftRight = 65,
    bottom = 35,
    top = 35,
  },
  --
  grid = {
    space = 30,
  },
  --
  text = {
    fontSize = 16,
    rotateValueText = -30,
    rotateDescriptionText = 0,
    descriptionAlignmentCenter = false,
  },
  --
  bar = {
    width = 25,
    space = 2,
  },
})

-- PNG строкой
-- local data = h:pngString()

h:writePng('histogram.png')
h:destroy()
