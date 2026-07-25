--- Общая обёртка для модулей ext/.
-- Оборачивает cairo-поверхность в объект с методами записи PNG
-- и освобождения ресурсов.
-- @usage
-- local wrap = require('cairo-luajit-ffi.ext.base')
-- local image = wrap({ surface = surface, width = w, height = h })
-- image:writePng('out.png')
-- image:destroy()
local cairo = require('cairo-luajit-ffi')

local Image = {}
Image.__index = Image

--- Записать поверхность в PNG-файл.
-- @tparam string filename путь к файлу
-- @treturn number статус cairo (0 - успех)
function Image:writePng(filename)
  return tonumber(cairo.surface_write_to_png(self.surface, filename))
end

--- Получить PNG-изображение строкой.
-- @treturn string содержимое PNG
function Image:pngString()
  local chunks = {}
  cairo.surface_write_to_png_stream(self.surface, function(data)
    chunks[#chunks + 1] = data
  end)

  return table.concat(chunks)
end

--- Освободить поверхность.
-- Повторный вызов безопасен.
function Image:destroy()
  if self.surface then
    cairo.surface_destroy(self.surface)
    self.surface = nil
  end
end

--- Обернуть таблицу с полем surface в объект изображения.
-- @tparam table fields поля объекта, обязательно fields.surface
-- @treturn table объект изображения
local function wrap(fields)
  return setmetatable(fields, Image)
end

return wrap
