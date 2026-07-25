--- Генератор идентиконов.
-- Детерминированная аватарка по строке (email, логин, id):
-- одна и та же строка всегда даёт одну и ту же картинку.
-- Узор симметричен по вертикали, цвет выводится из хеша строки.
-- @usage
-- local identicon = require('cairo-luajit-ffi.ext.identicon')
--
-- local icon = identicon.new({ seed = 'user@example.com' })
-- icon:writePng('avatar.png')
-- icon:destroy()
local bit = require('bit')
local cairo = require('cairo-luajit-ffi')
local wrap = require('cairo-luajit-ffi.ext.base')

local consts = cairo.consts

-- Хеш Дженкинса (one-at-a-time) - детерминированный 32-битный хеш строки
local function jenkinsHash(str)
  local hash = 0

  for i = 1, #str do
    hash = bit.tobit(hash + str:byte(i))
    hash = bit.tobit(hash + bit.lshift(hash, 10))
    hash = bit.bxor(hash, bit.rshift(hash, 6))
  end

  hash = bit.tobit(hash + bit.lshift(hash, 3))
  hash = bit.bxor(hash, bit.rshift(hash, 11))
  hash = bit.tobit(hash + bit.lshift(hash, 15))

  return hash
end

-- Детерминированный поток битов на основе xorshift32
local function bitStream(seed)
  -- xorshift вырождается в нуле - подмена на произвольную константу
  local state = seed == 0 and 0x9e3779b9 or seed

  return function()
    state = bit.bxor(state, bit.lshift(state, 13))
    state = bit.bxor(state, bit.rshift(state, 17))
    state = bit.bxor(state, bit.lshift(state, 5))

    return bit.band(state, 1)
  end
end

-- Преобразование HSL -> RGB, все каналы в [0, 1]
local function hslToRgb(h, s, l)
  local function hueToRgb(p, q, t)
    if t < 0 then
      t = t + 1
    end
    if t > 1 then
      t = t - 1
    end

    if t < 1 / 6 then
      return p + (q - p) * 6 * t
    end
    if t < 1 / 2 then
      return q
    end
    if t < 2 / 3 then
      return p + (q - p) * (2 / 3 - t) * 6
    end

    return p
  end

  local q
  if l < 0.5 then
    q = l * (1 + s)
  else
    q = l + s - l * s
  end
  local p = 2 * l - q

  return hueToRgb(p, q, h + 1 / 3), hueToRgb(p, q, h), hueToRgb(p, q, h - 1 / 3)
end

--- Создать идентикон.
-- @tparam table opts опции
-- @tparam string opts.seed строка-источник (email, логин, id)
-- @tparam[opt=250] number opts.size сторона квадратного изображения
-- @tparam[opt=5] number opts.grid число ячеек по стороне
-- @tparam[opt=size/10] number opts.margin отступ до узора
-- @tparam[opt] table opts.background цвет фона { r, g, b }, false - прозрачный
-- @tparam[opt] table opts.color цвет узора { r, g, b }, по умолчанию - из хеша
-- @treturn table объект изображения с полем seed (см. ext.base)
local function new(opts)
  local seed = assert(opts.seed, 'opts.seed is required')

  local size = opts.size or 250
  local grid = opts.grid or 5
  local margin = opts.margin or size / 10

  local hash = jenkinsHash(seed)
  local nextBit = bitStream(hash)

  local surface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, size, size)
  local cr = cairo.create(surface)

  -- Заливка фона; background = false оставляет фон прозрачным
  if opts.background ~= false then
    local background = opts.background or { 0.94, 0.94, 0.94 }
    cairo.set_source_rgb(cr, background[1], background[2], background[3])
    cairo.paint(cr)
  end

  -- Цвет узора: тон из хеша, умеренные насыщенность и светлота
  if opts.color then
    cairo.set_source_rgb(cr, opts.color[1], opts.color[2], opts.color[3])
  else
    local hue = (bit.band(hash, 0x7fffffff) % 360) / 360
    cairo.set_source_rgb(cr, hslToRgb(hue, 0.5, 0.55))
  end

  -- Отрисовка узора: заполняется левая половина колонок
  -- и зеркалится направо - так узор всегда симметричен
  local cellSize = (size - margin * 2) / grid
  local halfCols = math.ceil(grid / 2)

  for row = 1, grid do
    for col = 1, halfCols do
      if nextBit() == 1 then
        local x = margin + (col - 1) * cellSize
        local y = margin + (row - 1) * cellSize
        cairo.rectangle(cr, x, y, cellSize, cellSize)

        local mirrorCol = grid - col + 1
        if mirrorCol ~= col then
          cairo.rectangle(cr, margin + (mirrorCol - 1) * cellSize, y, cellSize, cellSize)
        end
      end
    end
  end
  cairo.fill(cr)

  cairo.destroy(cr)

  return wrap({
    surface = surface,
    seed = seed,
    width = size,
    height = size,
  })
end

return {
  new = new,
}
