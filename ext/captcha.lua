--- Генератор капчи.
-- Модуль не трогает глобальный сид генератора случайных чисел.
-- Вызывающий инициализирует math.randomseed сам либо передаёт
-- свой генератор в opts.rng.
-- @usage
-- local captcha = require('cairo-luajit-ffi.ext.captcha')
--
-- math.randomseed(os.time())
--
-- local c = captcha.new({ length = 6 })
-- print(c.text)
-- c:writePng(c.text..'.png')
-- c:destroy()
local cairo = require('cairo-luajit-ffi')
local wrap = require('cairo-luajit-ffi.ext.base')

local consts = cairo.consts

-- Алфавит по умолчанию: без визуально похожих символов (0/O, 1/I)
local DEFAULT_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'

--- Сгенерировать случайный текст капчи.
-- @tparam number length число символов
-- @tparam[opt] string chars алфавит генерации
-- @tparam[opt] function rng генератор с семантикой math.random
-- @treturn string текст
local function randomText(length, chars, rng)
  chars = chars or DEFAULT_CHARS
  rng = rng or math.random

  local buff = {}
  for i = 1, length do
    local pos = rng(1, #chars)
    buff[i] = chars:sub(pos, pos)
  end

  return table.concat(buff)
end

--- Создать изображение капчи.
-- @tparam[opt] table opts опции
-- @tparam[opt] string opts.text фиксированный текст, по умолчанию генерируется
-- @tparam[opt=6] number opts.length число генерируемых символов
-- @tparam[opt] string opts.chars алфавит генерации
-- @tparam[opt=300] number opts.width ширина изображения
-- @tparam[opt=120] number opts.height высота изображения
-- @tparam[opt='Sans'] string opts.font семейство шрифта
-- @tparam[opt=0.02] number opts.noise плотность точек шума, доля от числа пикселей
-- @tparam[opt=5] number opts.lines число прямых линий шума
-- @tparam[opt=2] number opts.waves число волнистых линий поверх текста
-- @tparam[opt] function opts.rng генератор с семантикой math.random
-- @treturn table объект изображения с полем text (см. ext.base)
local function new(opts)
  opts = opts or {}

  local rng = opts.rng or math.random
  local text = opts.text or randomText(opts.length or 6, opts.chars, rng)
  local width = opts.width or 300
  local height = opts.height or 120

  -- Равномерное дробное число в [min, max)
  local function frand(min, max)
    return min + rng() * (max - min)
  end

  local function setRandomRgb(cr, min, max)
    cairo.set_source_rgb(cr, frand(min, max), frand(min, max), frand(min, max))
  end

  local surface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, width, height)
  local cr = cairo.create(surface)

  -- Заливка фона белым
  cairo.set_source_rgb(cr, 1, 1, 1)
  cairo.paint(cr)

  -- Настройка шрифта
  local fontSize = height * 0.4
  cairo.select_font_face(
    cr,
    opts.font or 'Sans',
    consts.CAIRO_FONT_SLANT_NORMAL,
    consts.CAIRO_FONT_WEIGHT_BOLD
  )
  cairo.set_font_size(cr, fontSize)

  -- Измерение символов для центрирования всего текста
  local charWidths = {}
  local totalWidth = 0

  for i = 1, #text do
    local extents = cairo.text_extents(cr, text:sub(i, i))
    charWidths[i] = extents.x_advance
    totalWidth = totalWidth + extents.x_advance
  end

  local spacing = (width - totalWidth) / (#text + 1)
  local xPos = spacing
  local baseY = height * 0.6
  local yOffset = fontSize * 0.2

  -- Отрисовка символов со случайным поворотом, смещением и цветом
  for i = 1, #text do
    local x = xPos
    local y = baseY + frand(-yOffset, yOffset)

    cairo.save(cr)

    -- Поворот вокруг позиции символа
    cairo.translate(cr, x, y)
    cairo.rotate(cr, frand(-0.4, 0.4))
    cairo.translate(cr, -x, -y)

    setRandomRgb(cr, 0, 0.6)
    cairo.move_to(cr, x, y)
    cairo.show_text(cr, text:sub(i, i))

    cairo.restore(cr)

    xPos = xPos + charWidths[i] + spacing * 0.5
  end

  -- Точки шума
  for _ = 1, width * height * (opts.noise or 0.02) do
    setRandomRgb(cr, 0.7, 0.9)
    cairo.rectangle(cr, frand(0, width), frand(0, height), frand(1, 2.5), frand(1, 2.5))
    cairo.fill(cr)
  end

  -- Прямые линии шума
  for _ = 1, opts.lines or 5 do
    setRandomRgb(cr, 0.6, 0.8)
    cairo.set_line_width(cr, frand(1, 2))
    cairo.move_to(cr, frand(0, width), frand(0, height))
    cairo.line_to(cr, frand(0, width), frand(0, height))
    cairo.stroke(cr)
  end

  -- Волнистые линии поверх текста
  for _ = 1, opts.waves or 2 do
    local y = frand(height * 0.3, height * 0.7)
    local amplitude = frand(3, 8)
    local frequency = frand(0.03, 0.07)
    local phase = frand(0, 2 * math.pi)

    setRandomRgb(cr, 0.5, 0.7)
    cairo.set_line_width(cr, frand(1, 1.5))

    cairo.move_to(cr, 0, y + math.sin(phase) * amplitude)
    for x = 5, width, 5 do
      cairo.line_to(cr, x, y + math.sin(x * frequency + phase) * amplitude)
    end
    cairo.stroke(cr)
  end

  cairo.destroy(cr)

  return wrap({
    surface = surface,
    text = text,
    width = width,
    height = height,
  })
end

return {
  new = new,
  randomText = randomText,
}
