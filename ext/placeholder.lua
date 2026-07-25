--- Генератор картинок-заглушек.
-- Однотонный фон с текстом по центру, по умолчанию - размеры картинки.
-- @usage
-- local placeholder = require('cairo-luajit-ffi.ext.placeholder')
--
-- local p = placeholder.new({ width = 300, height = 150 })
-- p:writePng('placeholder.png')
-- p:destroy()
local cairo = require('cairo-luajit-ffi')
local wrap = require('cairo-luajit-ffi.ext.base')

local consts = cairo.consts

--- Создать картинку-заглушку.
-- @tparam[opt] table opts опции
-- @tparam[opt=300] number opts.width ширина изображения
-- @tparam[opt=150] number opts.height высота изображения
-- @tparam[opt='WxH'] string opts.text текст по центру
-- @tparam[opt] table opts.background цвет фона { r, g, b }
-- @tparam[opt] table opts.color цвет текста { r, g, b }
-- @tparam[opt='Sans'] string opts.font семейство шрифта
-- @tparam[opt] number opts.fontSize размер шрифта, по умолчанию - от размеров картинки
-- @treturn table объект изображения (см. ext.base)
local function new(opts)
  opts = opts or {}

  local width = opts.width or 300
  local height = opts.height or 150
  local text = opts.text or (width..'x'..height)
  local background = opts.background or { 0.8, 0.8, 0.8 }
  local color = opts.color or { 0.45, 0.45, 0.45 }
  local fontSize = opts.fontSize or math.min(width, height) / 5

  local surface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, width, height)
  local cr = cairo.create(surface)

  -- Заливка фона
  cairo.set_source_rgb(cr, background[1], background[2], background[3])
  cairo.paint(cr)

  -- Текст по центру
  cairo.select_font_face(cr, opts.font or 'Sans', consts.CAIRO_FONT_SLANT_NORMAL, consts.CAIRO_FONT_WEIGHT_BOLD)
  cairo.set_font_size(cr, fontSize)

  local extents = cairo.text_extents(cr, text)
  cairo.set_source_rgb(cr, color[1], color[2], color[3])
  cairo.move_to(cr,
    width / 2 - (extents.width / 2 + extents.x_bearing),
    height / 2 - (extents.height / 2 + extents.y_bearing)
  )
  cairo.show_text(cr, text)

  cairo.destroy(cr)

  return wrap({
    surface = surface,
    width = width,
    height = height,
  })
end

return {
  new = new,
}
