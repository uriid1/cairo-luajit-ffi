local cairo = require('cairo-ffi')

local width = 612
local height = 792

local surface = cairo.pdf_surface_create("pdf-test.pdf", width, height)
local cr = cairo.create(surface)

cairo.set_source_rgb(cr, 0, 0, 0)
cairo.select_font_face(cr, "Sans", cairo.lib.CAIRO_FONT_SLANT_NORMAL,
  cairo.lib.CAIRO_FONT_WEIGHT_NORMAL);

cairo.set_font_size (cr, 40)

-- Page 1
cairo.move_to(cr, 10, 50);
cairo.show_text(cr, "Cairo LuaJit FFI")
cairo.set_line_width(cr, 1)
cairo.rectangle(cr, 20, 60, width - 40, height - 100)
cairo.stroke(cr)
cairo.show_page(cr)

-- Page 2
cairo.move_to(cr, 10, 50)
cairo.show_text(cr, "Page: 2")
cairo.show_page(cr)

cairo.surface_destroy(surface)
cairo.destroy(cr)
