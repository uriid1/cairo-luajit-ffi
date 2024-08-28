local cairo = require('cairo-luajit-ffi')

local text = "cairo"
local width = 256
local height = 256

local surface = cairo.image_surface_create(
    cairo.lib.CAIRO_FORMAT_ARGB32,
    width,
    height)
local cr = cairo.create(surface)

cairo.set_source_rgb(cr, 1, 1, 1)
cairo.paint(cr)

cairo.select_font_face(cr, "Sans",
    cairo.lib.CAIRO_FONT_SLANT_NORMAL,
    cairo.lib.CAIRO_FONT_WEIGHT_NORMAL)

cairo.set_source_rgb(cr, 0, 0, 0)
cairo.set_font_size(cr, 52)
local extents = cairo.text_extents(cr, text)
local x = (width/2)-(extents.width/2 + extents.x_bearing)
local y = (height/2)-(extents.height/2 + extents.y_bearing)

cairo.move_to(cr, x, y)
cairo.show_text(cr, text)

-- draw helping lines
cairo.set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
cairo.set_line_width(cr, 6)
cairo.arc(cr, x, y, 10, 0, 2*math.pi)
cairo.fill(cr)
cairo.move_to(cr, width/2, 0)
cairo.rel_line_to(cr, 0, width)
cairo.move_to(cr, 0, height/2)
cairo.rel_line_to(cr, height, 0)
cairo.stroke(cr)

cairo.surface_write_to_png(surface, 'text-align-center-test.png')
