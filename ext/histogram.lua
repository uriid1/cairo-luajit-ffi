--- Адаптивная гистограмма.
-- Ширина изображения подбирается по числу столбцов.
-- @usage
-- local histogram = require('cairo-luajit-ffi.ext.histogram')
--
-- local h = histogram.new({
--   values = { 1, 5, 3, 8 },
--   descriptions = { 'a', 'b', 'c', 'd' },
-- })
-- h:writePng('histogram.png')
-- h:destroy()
local cairo = require('cairo-luajit-ffi')
local wrap = require('cairo-luajit-ffi.ext.base')

local consts = cairo.consts
local unpack = unpack or table.unpack -- luacheck: ignore 113 143

local MIN_WIDTH = 400  -- Минимальная ширина изображения
local MIN_HEIGHT = 400 -- Минимальная высота изображения
local FONT_SIZE = 16   -- Размер шрифта по умолчанию
local GRID_SPACE = 30  -- Минимальный шаг линий сетки по умолчанию

--- Создать гистограмму.
-- @tparam table opts опции
-- @tparam table opts.values массив значений столбцов
-- @tparam[opt] table opts.descriptions подписи столбцов, по умолчанию - индекс
-- @tparam[opt=400] number opts.height высота изображения, не меньше 400
-- @tparam[opt=50] number opts.space.leftRight отступ слева и справа
-- @tparam[opt=50] number opts.space.top отступ сверху
-- @tparam[opt=50] number opts.space.bottom отступ снизу
-- @tparam[opt=30] number opts.grid.space минимальный шаг линий сетки
-- @tparam[opt=25] number opts.bar.width ширина столбца
-- @tparam[opt=2] number opts.bar.space расстояние между столбцами
-- @tparam[opt] table opts.bar.color цвет столбцов { r, g, b }, по умолчанию - градиент по значению
-- @tparam[opt=16] number opts.text.fontSize размер шрифта
-- @tparam[opt=-30] number opts.text.rotateValueText поворот подписей значений, градусы
-- @tparam[opt=0] number opts.text.rotateDescriptionText поворот подписей столбцов, градусы
-- @tparam[opt=false] boolean opts.text.descriptionAlignmentCenter центрирование подписей под столбцами
-- @treturn table объект изображения (см. ext.base)
local function new(opts)
  local values = assert(opts.values, 'opts.values is required')
  local descriptions = opts.descriptions or {}
  local maxValues = math.max(unpack(values))

  local fontSize = opts.text and opts.text.fontSize or FONT_SIZE
  local rotateDescriptionText = opts.text and opts.text.rotateDescriptionText or 0
  local rotateValueText = opts.text and opts.text.rotateValueText or -30

  local height = math.max(opts.height or MIN_HEIGHT, MIN_HEIGHT)

  local rightLineSpace = 15
  local leftRightSpace = opts.space and opts.space.leftRight or 50
  local topSpace       = opts.space and opts.space.top       or 50
  local bottomSpace    = opts.space and opts.space.bottom    or 50

  local barCount = #values
  local barWidth = opts.bar and opts.bar.width or 25
  local barSpace = opts.bar and opts.bar.space or 2
  local barColor = opts.bar and opts.bar.color

  local plotHeight = height - topSpace - bottomSpace
  local barScaleFactor = maxValues > 0 and plotHeight / maxValues or 0

  local gridSpace = opts.grid and opts.grid.space or GRID_SPACE

  local width = math.max(
    MIN_WIDTH,
    barCount * (barWidth + barSpace) + leftRightSpace * 2
  )

  local surface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, width, height)
  local cr = cairo.create(surface)

  -- Заливка фона белым
  cairo.set_source_rgb(cr, 1, 1, 1)
  cairo.paint(cr)

  cairo.select_font_face(cr, 'Sans', consts.CAIRO_FONT_SLANT_NORMAL, consts.CAIRO_FONT_WEIGHT_BOLD)
  cairo.set_font_size(cr, fontSize)

  -- Отрисовка линий сетки с подписями значений
  --
  local gridLeftRightSpace = 5
  local gridLines = math.min(
    math.max(barCount - 1, 1),
    math.floor(plotHeight / gridSpace)
  ) + 1
  local gridSpacing = plotHeight / gridLines

  -- Выравнивание подписей по самой широкой - по значению максимума
  local maxLabelExtents = cairo.text_extents(cr, tostring(math.ceil(maxValues)))

  for i = 0, gridLines do
    local y = (height - bottomSpace) - i * gridSpacing

    -- Линия
    cairo.set_source_rgb(cr, 0.8, 0.8, 0.8)
    cairo.move_to(cr, leftRightSpace - gridLeftRightSpace, y)
    cairo.line_to(cr, width - rightLineSpace + gridLeftRightSpace, y)
    cairo.stroke(cr)

    -- value - линейная шкала от 0 до максимума, в одном масштабе со столбцами
    local value = maxValues * i / gridLines

    cairo.set_source_rgb(cr, 0.5, 0.5, 0.5)
    cairo.save(cr)
    cairo.translate(cr,
      leftRightSpace - gridLeftRightSpace - maxLabelExtents.width - 5,
      y + maxLabelExtents.height / 2
    )
    cairo.rotate(cr, math.rad(rotateValueText))
    cairo.move_to(cr, 0, 0)
    cairo.show_text(cr, string.format('%d', value))
    cairo.restore(cr)
  end

  -- Отрисовка столбцов с подписями
  --
  for i = 1, barCount do
    local barHeight = values[i] * barScaleFactor
    local barX = leftRightSpace + (i - 1) * (barWidth + barSpace)
    local barY = height - barHeight - bottomSpace

    if barColor then
      cairo.set_source_rgb(cr, barColor[1], barColor[2], barColor[3])
    else
      -- Градиент по значению: низкие столбцы красноватые, высокие - синеватые
      local t = maxValues > 0 and values[i] / maxValues or 0
      cairo.set_source_rgb(cr, 0.3 + (1 - t) * 0.6, 0.7, 0.3 + t * 0.7)
    end
    cairo.rectangle(cr, barX, barY, barWidth, barHeight)
    cairo.fill(cr)

    -- Подпись столбца
    local description = tostring(descriptions[i] or i)
    local extents = cairo.text_extents(cr, description)
    local textY = extents.height + extents.y_bearing

    cairo.set_source_rgb(cr, 0, 0, 0)
    cairo.save(cr)
    if opts.text and opts.text.descriptionAlignmentCenter then
      local textOx = extents.width / 2 + extents.x_bearing
      cairo.translate(cr,
        barX + barWidth / 2 - textOx,
        (height - bottomSpace) + 20 + textY
      )
    else
      cairo.translate(cr,
        barX + barWidth / 2 - extents.height / 2,
        (height - bottomSpace) + 20 + textY
      )
    end
    cairo.rotate(cr, math.rad(rotateDescriptionText))
    cairo.move_to(cr, 0, 0)
    cairo.show_text(cr, description)
    cairo.restore(cr)
  end

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
