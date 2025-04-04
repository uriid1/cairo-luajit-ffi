local challenge = require('cairo-luajit-ffi.ext.captcha')

math.randomseed(os.time() + os.clock())

local text = challenge.random_text(5)
local output = text..'.png'
print('Challenge: '..text)

local surface = challenge.mk_captcha({
  text = text,
  width = 300,
  height = 120
})

-- Buffer
-- local buff = {}
-- challenge.write_to_png_stream(surface, function (data)
--   table.insert(buff, data)
-- end)

challenge.write_to_png(surface, output)
challenge.surface_destroy(surface)
