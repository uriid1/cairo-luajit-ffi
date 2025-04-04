local cairo = require('cairo-luajit-ffi')

local function random_text(length)
  local chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  local text = ''

  for _ = 1, length do
    local rand = math.random(1, #chars)
    text = text .. chars:sub(rand, rand)
  end

  return text
end

local function random_color(min, max)
  min = min or 0
  max = max or 1
  return {
    math.random() * (max - min) + min,
    math.random() * (max - min) + min,
    math.random() * (max - min) + min
  }
end

local function mk_captcha(opts)
  local opts = opts or {}

  local text = opts.text or random_text(6)
  local width = opts.width or 300
  local height = opts.height or 120

  -- Новая поверхность и контекст Cairo
  local surface = cairo.image_surface_create(cairo.lib.CAIRO_FORMAT_ARGB32, width, height)
  local cr = cairo.create(surface)

  -- Заполнение фона белым цветом
  cairo.set_source_rgb(cr, 1, 1, 1)
  cairo.paint(cr)

  -- Настройки для текста
  --
  local font_size = height * 0.4
  cairo.select_font_face(
    cr,
    'Sans',
    cairo.lib.CAIRO_FONT_SLANT_NORMAL,
    cairo.lib.CAIRO_FONT_WEIGHT_BOLD
  )

  cairo.set_font_size(cr, font_size)

  local char_widths = {}
  local total_width = 0

  for i = 1, #text do
    local char = text:sub(i, i)
    local te = cairo.text_extents(cr, char)
    -- x_advance вместо width для лучшего интервала
    char_widths[i] = te.x_advance
    total_width = total_width + te.x_advance
  end

  -- Вычисление начальной позиции для центрирования всего текста
  local spacing = (width - total_width) / (#text + 1)
  local x_pos = spacing

  -- Безопасная зона для вертикального смещения (чтобы избежать выхода за границы)
  local y_safe_offset = font_size * 0.2
  local base_y = height * 0.6 -- Немного ниже центра

  for i = 1, #text do
    local char = text:sub(i, i)

    -- Позиция для текущего символа с учетом безопасных границ
    local x = x_pos
    local y = base_y + math.random(-y_safe_offset, y_safe_offset)

    cairo.save(cr)

    math.randomseed(os.clock() + i)

    -- Случайный поворот (с меньшим углом для лучшей читаемости)
    cairo.translate(cr, x, y)
    cairo.rotate(cr, math.random(-0.5, 0.5))
    cairo.translate(cr, -x, -y)

    -- Случайный цвет
    local color = random_color(0, 0.6)
    cairo.set_source_rgb(cr, color[1], color[2], color[3])

    -- Рисуем символ
    cairo.move_to(cr, x, y)
    cairo.show_text(cr, char)

    -- Восстановление состояния
    cairo.restore(cr)

    -- Увеличиваем позицию для следующего символа
    x_pos = x_pos + char_widths[i] + spacing * 0.5
  end

  -- Шум (случайные точки)
  for _ = 1, width * height * 0.02 do
    local x = math.random(0, width)
    local y = math.random(0, height)
    local size = math.random(1, 2)
    local color = random_color(0.7, 0.9)

    cairo.set_source_rgb(cr, color[1], color[2], color[3])
    cairo.rectangle(cr, x, y, size, size)
    cairo.fill(cr)
  end

  -- Линии
  for _ = 1, 5 do
    local x1 = math.random(0, width)
    local y1 = math.random(0, height)
    local x2 = math.random(0, width)
    local y2 = math.random(0, height)
    local color = random_color(0.6, 0.8)

    cairo.set_source_rgb(cr, color[1], color[2], color[3])
    cairo.set_line_width(cr, math.random(1, 2))
    cairo.move_to(cr, x1, y1)
    cairo.line_to(cr, x2, y2)
    cairo.stroke(cr)
  end

  -- Волнистые линии через текст
  for i = 1, 2 do
    local y = height * (0.3 + i * 0.3)
    local color = random_color(0.5, 0.7)
    cairo.set_source_rgb(cr, color[1], color[2], color[3])
    cairo.set_line_width(cr, 1)

    cairo.move_to(cr, 0, y)
    for x = 0, width, 10 do
      local new_y = y + math.sin(x * 0.05) * 5
      cairo.line_to(cr, x, new_y)
    end
    cairo.stroke(cr)
  end

  cairo.destroy(cr)

  return surface
end

return {
  mk_captcha = mk_captcha,
  random_text = random_text,
  surface_destroy = cairo.surface_destroy,
  write_to_png = cairo.surface_write_to_png,
  write_to_png_stream = cairo.surface_write_to_png_stream,
}
