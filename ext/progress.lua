--- Кольцевой индикатор прогресса.
-- Кольцо с заполненной дугой и процентом по центру.
-- @usage
-- local progress = require('cairo-luajit-ffi.ext.progress')
--
-- local p = progress.new({ percent = 42 })
-- p:writePng('progress.png')
-- p:destroy()
local cairo = require('cairo-luajit-ffi')
local wrap = require('cairo-luajit-ffi.ext.base')

local consts = cairo.consts

--- Создать индикатор прогресса.
-- @tparam table opts опции
-- @tparam number opts.percent прогресс в процентах, 0..100
-- @tparam[opt=200] number opts.size сторона квадратного изображения
-- @tparam[opt=size/10] number opts.thickness толщина кольца
-- @tparam[opt] table opts.color цвет дуги прогресса { r, g, b }
-- @tparam[opt] table opts.background цвет подложки кольца { r, g, b }
-- @tparam[opt] table opts.textColor цвет текста { r, g, b }, по умолчанию - цвет дуги
-- @tparam[opt=true] boolean opts.showText выводить процент по центру
-- @tparam[opt='Sans'] string opts.font семейство шрифта
-- @tparam[opt=size/5] number opts.fontSize размер шрифта
-- @treturn table объект изображения с полем percent (см. ext.base)
local function new(opts)
  local percent = assert(opts.percent, 'opts.percent is required')
  percent = math.max(0, math.min(100, percent))

  local size = opts.size or 200
  local thickness = opts.thickness or size / 10
  local color = opts.color or { 0.2, 0.6, 0.86 }
  local background = opts.background or { 0.9, 0.9, 0.9 }
  local textColor = opts.textColor or color

  local center = size / 2
  local radius = (size - thickness) / 2

  local surface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, size, size)
  local cr = cairo.create(surface)

  -- Подложка кольца
  cairo.set_line_width(cr, thickness)
  cairo.set_source_rgb(cr, background[1], background[2], background[3])
  cairo.arc(cr, center, center, radius, 0, 2 * math.pi)
  cairo.stroke(cr)

  -- Дуга прогресса: от 12 часов по часовой стрелке
  if percent > 0 then
    local startAngle = -math.pi / 2
    local endAngle = startAngle + 2 * math.pi * percent / 100

    cairo.set_line_cap(cr, consts.CAIRO_LINE_CAP_ROUND)
    cairo.set_source_rgb(cr, color[1], color[2], color[3])
    cairo.arc(cr, center, center, radius, startAngle, endAngle)
    cairo.stroke(cr)
  end

  -- Процент по центру
  if opts.showText ~= false then
    local text = string.format('%d%%', math.floor(percent + 0.5))
    local fontSize = opts.fontSize or size / 5

    cairo.select_font_face(cr, opts.font or 'Sans', consts.CAIRO_FONT_SLANT_NORMAL, consts.CAIRO_FONT_WEIGHT_BOLD)
    cairo.set_font_size(cr, fontSize)

    local extents = cairo.text_extents(cr, text)
    cairo.set_source_rgb(cr, textColor[1], textColor[2], textColor[3])
    cairo.move_to(cr,
      center - (extents.width / 2 + extents.x_bearing),
      center - (extents.height / 2 + extents.y_bearing)
    )
    cairo.show_text(cr, text)
  end

  cairo.destroy(cr)

  return wrap({
    surface = surface,
    percent = percent,
    width = size,
    height = size,
  })
end

return {
  new = new,
}
