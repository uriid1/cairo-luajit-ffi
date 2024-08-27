local cairo = require('cairo-luajit-ffi')

local WIDTH = 512
local HEIGHT = 512

local surface = cairo.image_surface_create(cairo.lib.CAIRO_FORMAT_ARGB32, WIDTH, HEIGHT)
local cr = cairo.create(surface)

cairo.set_source_rgb(cr, 1, 1, 1)
cairo.paint(cr)

-- Outline Circle
cairo.set_source_rgb(cr, 0, 0.7, 0.7)
cairo.save(cr)
cairo.translate(cr, WIDTH/2, HEIGHT/2)
cairo.scale(cr, WIDTH/4, HEIGHT/4)
cairo.arc(cr, 0, 0, 1, 0, 2 * math.pi)
cairo.restore(cr)
cairo.stroke(cr)

-- Fill circle
cairo.set_source_rgb(cr, 0, 0.7, 0.7)
cairo.save(cr)
cairo.translate(cr, WIDTH/2, HEIGHT/2)
cairo.scale(cr, WIDTH/6, HEIGHT/6)
cairo.arc(cr, 0, 0, 1, 0, 2 * math.pi)
cairo.restore(cr)
cairo.fill(cr)

cairo.surface_write_to_png(surface, 'circle-test.png')
cairo.destroy(cr)
cairo.surface_destroy(surface)
