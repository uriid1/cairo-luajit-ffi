local cairo = require('cairo-ffi')

local WIDTH = 256
local HEIGHT = 256

local surface = cairo.image_surface_create(cairo.lib.CAIRO_FORMAT_ARGB32, WIDTH, HEIGHT)
local cr = cairo.create(surface)

cairo.set_source_rgb(cr, 1, 1, 1)
cairo.paint(cr)

-- a custom shape that could be wrapped in a function
-- parameters like cairo_rectangle
local x = 20
local y = 20
local width = WIDTH - 40
local height = HEIGHT - 40
local aspect = 1.0 -- aspect ratio
local corner_radius = height / 10 -- and corner curvature radius

local radius = corner_radius / aspect
local degrees = math.pi / 180

cairo.new_sub_path(cr)
cairo.arc(cr, x + width - radius, y + radius, radius, -90 * degrees, 0 * degrees)
cairo.arc(cr, x + width - radius, y + height - radius, radius, 0 * degrees, 90 * degrees)
cairo.arc(cr, x + radius, y + height - radius, radius, 90 * degrees, 180 * degrees)
cairo.arc(cr, x + radius, y + radius, radius, 180 * degrees, 270 * degrees)
cairo.close_path(cr)

cairo.set_source_rgb(cr, 0.7, 0.7, 0.9)
cairo.fill_preserve(cr)
cairo.set_source_rgba(cr, 0.5, 0, 0, 0.5)
cairo.set_line_width(cr, 5);
cairo.stroke(cr)

cairo.surface_write_to_png(surface, 'test-shape.png')
cairo.destroy(cr)
cairo.surface_destroy(surface)
