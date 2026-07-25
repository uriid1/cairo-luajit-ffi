--- Генератор бейджей в стиле shields.io.
-- Две секции: слева label на тёмном фоне, справа value на цветном.
-- Ширина подбирается по тексту.
-- @usage
-- local badge = require('cairo-luajit-ffi.ext.badge')
--
-- local b = badge.new({ label = 'build', value = 'passing' })
-- b:writePng('badge.png')
-- b:destroy()
local cairo = require('cairo-luajit-ffi')
local wrap = require('cairo-luajit-ffi.ext.base')

local consts = cairo.consts

-- Путь скруглённого прямоугольника
local function roundedRect(cr, x, y, width, height, radius)
  cairo.new_sub_path(cr)
  cairo.arc(cr, x + width - radius, y + radius, radius, math.rad(-90), 0)
  cairo.arc(cr, x + width - radius, y + height - radius, radius, 0, math.rad(90))
  cairo.arc(cr, x + radius, y + height - radius, radius, math.rad(90), math.rad(180))
  cairo.arc(cr, x + radius, y + radius, radius, math.rad(180), math.rad(270))
  cairo.close_path(cr)
end

-- Текст по центру прямоугольника
local function centeredText(cr, text, x, y, width, height)
  local extents = cairo.text_extents(cr, text)
  cairo.move_to(cr,
    x + width / 2 - (extents.width / 2 + extents.x_bearing),
    y + height / 2 - (extents.height / 2 + extents.y_bearing)
  )
  cairo.show_text(cr, text)
end

--- Создать бейдж.
-- @tparam table opts опции
-- @tparam string opts.label текст левой секции
-- @tparam string opts.value текст правой секции
-- @tparam[opt] table opts.color фон правой секции { r, g, b }
-- @tparam[opt] table opts.labelColor фон левой секции { r, g, b }
-- @tparam[opt] table opts.textColor цвет текста { r, g, b }
-- @tparam[opt=20] number opts.height высота бейджа
-- @tparam[opt=6] number opts.padding горизонтальный отступ текста
-- @tparam[opt=3] number opts.radius радиус скругления углов
-- @tparam[opt='Sans'] string opts.font семейство шрифта
-- @tparam[opt=12] number opts.fontSize размер шрифта
-- @treturn table объект изображения (см. ext.base)
local function new(opts)
  local label = assert(opts.label, 'opts.label is required')
  local value = assert(opts.value, 'opts.value is required')

  local color = opts.color or { 0.27, 0.76, 0.06 }
  local labelColor = opts.labelColor or { 0.33, 0.33, 0.33 }
  local textColor = opts.textColor or { 1, 1, 1 }
  local height = opts.height or 20
  local padding = opts.padding or 6
  local radius = opts.radius or 3
  local font = opts.font or 'Sans'
  local fontSize = opts.fontSize or 12

  -- Измерение текста во временном контексте - ширина бейджа
  -- должна быть известна до создания итоговой поверхности
  local measureSurface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, 1, 1)
  local measureCr = cairo.create(measureSurface)
  cairo.select_font_face(measureCr, font, consts.CAIRO_FONT_SLANT_NORMAL, consts.CAIRO_FONT_WEIGHT_NORMAL)
  cairo.set_font_size(measureCr, fontSize)

  local labelWidth = cairo.text_extents(measureCr, label).x_advance + padding * 2
  local valueWidth = cairo.text_extents(measureCr, value).x_advance + padding * 2

  cairo.destroy(measureCr)
  cairo.surface_destroy(measureSurface)

  local width = math.ceil(labelWidth + valueWidth)

  local surface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, width, height)
  local cr = cairo.create(surface)

  -- Обрезка по скруглённому прямоугольнику - секции рисуются простыми
  -- прямоугольниками, углы остаются прозрачными
  roundedRect(cr, 0, 0, width, height, radius)
  cairo.clip(cr)

  -- Левая секция
  cairo.set_source_rgb(cr, labelColor[1], labelColor[2], labelColor[3])
  cairo.rectangle(cr, 0, 0, labelWidth, height)
  cairo.fill(cr)

  -- Правая секция
  cairo.set_source_rgb(cr, color[1], color[2], color[3])
  cairo.rectangle(cr, labelWidth, 0, valueWidth, height)
  cairo.fill(cr)

  -- Текст секций
  cairo.select_font_face(cr, font, consts.CAIRO_FONT_SLANT_NORMAL, consts.CAIRO_FONT_WEIGHT_NORMAL)
  cairo.set_font_size(cr, fontSize)
  cairo.set_source_rgb(cr, textColor[1], textColor[2], textColor[3])
  centeredText(cr, label, 0, 0, labelWidth, height)
  centeredText(cr, value, labelWidth, 0, valueWidth, height)

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
