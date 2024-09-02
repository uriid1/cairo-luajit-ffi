local hist = require('cairo-luajit-ffi.ext.histogram')
local descriptions = {}
local values  = {}

local sin_step = 0
for i = 1, 35 do
  sin_step = sin_step + math.pi/8
  table.insert(values, i + math.sin(sin_step)*5)
  table.insert(descriptions, tostring(i))
end

local surface = hist.mk_histogram({
  values = values,
  descriptions = descriptions,
  --
  height = 500,
  --
  space = {
    left_right = 65,
    bottom = 35,
    top = 35
  },
  --
  grid = {
    space = 30,
  },
  --
  text = {
    font_size = 16,
    rotate_value_text = -30,
    rotate_description_text = 0,
    description_alignment_center = false,
  },
  --
  bar = {
    width = 25,
    space = 2
  }
})

-- local buff = {}
-- hist.write_to_png_stream(surface, function (data)
--   table.insert(buff, data)
-- end)
-- print(table.concat(buff))

hist.write_to_png(surface, 'histogram.png')
hist.surface_destroy(surface)
