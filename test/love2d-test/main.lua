--
local cairo = require('cairo-luajit-ffi')
local cairo_love = require('cairo-love2d')

local width = 800
local height = 600

function love.load()
  cairo_love:init(nil, width, height)
  cairo_love:init_image()
end

function love.draw()
  local cr = cairo_love.cr

  cairo.set_source_rgb(cr, 1, 1, 1)
  cairo.paint(cr)

  cairo.select_font_face(cr, "Sans",
      cairo.lib.CAIRO_FONT_SLANT_NORMAL,
      cairo.lib.CAIRO_FONT_WEIGHT_NORMAL)

  local text = "LOVE2D"
  cairo.set_source_rgb(cr, 0, 0, 0)
  cairo.set_font_size(cr, 52)
  local extents = cairo.text_extents(cr, text)
  local x = (width/2)-(extents.width/2 + extents.x_bearing)
  local y = (height/2)-(extents.height/2 + extents.y_bearing)

  -- Draw text
  cairo.move_to(cr, x, y)
  cairo.show_text(cr, text)

  -- Draw helping lines
  cairo.set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
  cairo.set_line_width(cr, 6)
  cairo.arc(cr, x, y, 10, 0, 2*math.pi)
  cairo.fill(cr)
  -- Vertical
  cairo.move_to(cr, width/2, 0)
  cairo.rel_line_to(cr, 0, height)
  -- Horizontal
  cairo.move_to(cr, 0, height/2)
  cairo.rel_line_to(cr, width, 0)
  cairo.stroke(cr)
  cairo.restore(cr)

  love.graphics.draw(cairo_love.image, 0, 0)
  cairo_love:clear()
end

function love.quit()
  cairo_love:release()
end
