-- Rewrite https://github.com/lgi-devs/lgi/blob/master/samples/cairo.lua
local cairo = require('cairo-ffi')

--
-- Sample cairo application, based on http://cairographics.org/samples/
--
-- Renders all samples into separate PNG images
--
local imagename = 'apple-red.png'

local samples = {}

function samples.arc(cr)
   local xc, yc = 128, 128
   local radius = 100
   local angle1, angle2 = math.rad(45), math.rad(180)

   cairo.set_line_width(cr, 10)
   cairo.arc(cr, xc, yc, radius, angle1, angle2)
   cairo.stroke(cr)

   -- draw helping lines
   cairo.set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
   cairo.set_line_width(cr, 6)

   cairo.arc(cr, xc, yc, 10, 0, math.rad(360))
   cairo.fill(cr)

   cairo.arc(cr, xc, yc, radius, angle1, angle1)
   cairo.line_to(cr, xc, yc)
   cairo.arc(cr, xc, yc, radius, angle2, angle2)
   cairo.line_to(cr, xc, yc)
   cairo.stroke(cr)
end

function samples.arc_negative(cr)
   local xc, yc = 128, 128
   local radius = 100
   local angle1, angle2 = math.rad(45), math.rad(180)

   cairo.set_line_width(cr, 10)
   cairo.arc_negative(cr, xc, yc, radius, angle1, angle2)
   cairo.stroke(cr)

   -- draw helping lines
   cairo.set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
   cairo.set_line_width(cr, 6)

   cairo.arc(cr, xc, yc, 10, 0, math.rad(360))
   cairo.fill(cr)

   cairo.arc(cr, xc, yc, radius, angle1, angle1)
   cairo.line_to(cr, xc, yc)
   cairo.arc(cr, xc, yc, radius, angle2, angle2)
   cairo.line_to(cr, xc, yc)
   cairo.stroke(cr)
end

function samples.clip(cr)
   cairo.arc(cr, 128, 128, 76.8, 0, math.rad(360))
   cairo.clip(cr)

   -- current path is not consumed by cairo.Context.clip()
   cairo.new_path(cr)

   cairo.rectangle(cr, 0, 0, 256, 256)
   cairo.fill(cr)
   cairo.set_source_rgb(cr, 0, 1, 0)
   cairo.move_to(cr, 0, 0)
   cairo.line_to(cr, 256, 256)
   cairo.move_to(cr, 256, 0)
   cairo.line_to(cr, 0, 256)
   cairo.set_line_width(cr, 10)
   cairo.stroke(cr)
end

function samples.clip_image(cr)
   cairo.arc(cr, 128, 128, 76.8, 0, math.rad(360))
   cairo.clip(cr)
   cairo.new_path(cr)

   local image = cairo.image_surface_create_from_png(imagename)
   local width = cairo.image_surface_get_width(image)
   local height = cairo.image_surface_get_height(image)
   cairo.scale(cr, 256 / width, 256 / height)
   cairo.set_source_surface(cr, image, 0, 0)
   cairo.paint(cr)
end

function samples.dash(cr)
   cairo.set_dash(cr, { 50, 10, 10, 10 }, -50, 0)

   cairo.set_line_width(cr, 10)
   cairo.move_to(cr, 128, 25.6)
   cairo.line_to(cr, 230.4, 230.4)
   cairo.rel_line_to(cr, -102.4, 0)
   cairo.curve_to(cr, 51.2, 230.4, 51.2, 128, 128, 128)

   cairo.stroke(cr)
end

function samples.curve_to(cr)
   local x, y = 25.6, 128
   local x1, y1 = 102.4, 230.4
   local x2, y2 = 153.6, 25.6
   local x3, y3 = 230.4, 128

   cairo.move_to(cr, x, y)
   cairo.curve_to(cr, x1, y1, x2, y2, x3, y3)

   cairo.set_line_width(cr, 10)
   cairo.stroke(cr)

   cairo.set_source_rgba(cr, 1, 0.2, 0.2, 0.6)
   cairo.set_line_width(cr, 6)
   cairo.move_to(cr, x, y)
   cairo.line_to(cr, x1, y1)
   cairo.move_to(cr, x2, y2)
   cairo.line_to(cr, x3, y3)
   cairo.stroke(cr)
end

function samples.fill_and_stroke(cr)
   cairo.move_to(cr, 128, 25.6)
   cairo.line_to(cr, 230.4, 230.4)
   cairo.rel_line_to(cr, -102.4, 0)
   cairo.curve_to(cr, 51.2, 230.4, 51.2, 128, 128, 128)
   cairo.close_path(cr)

   cairo.move_to(cr, 64, 25.6)
   cairo.rel_line_to(cr, 51.2, 51.2)
   cairo.rel_line_to(cr, -51.2, 51.2)
   cairo.rel_line_to(cr, -51.2, -51.2)
   cairo.close_path(cr)

   cairo.set_line_width(cr, 6)
   cairo.set_source_rgb(cr, 0, 0, 1)
   cairo.fill_preserve(cr)
   cairo.set_source_rgb(cr, 0, 0, 0)
   cairo.stroke(cr)
end

function samples.imagepattern(cr)
   local image = cairo.image_surface_create_from_png(imagename)

   local pattern = cairo.pattern_create_for_surface(image)
   cairo.pattern_set_extend(pattern, cairo.lib.CAIRO_EXTEND_REPEAT)

   cairo.translate(cr, 128, 128)
   cairo.rotate(cr, math.rad(45))
   cairo.scale(cr, 1 / math.sqrt(2), 1 / math.sqrt(2))
   cairo.translate(cr, -128, -128)

   local width = cairo.image_surface_get_width(image)
   local height = cairo.image_surface_get_height(image)
   cairo.matrix_init_scale(width / 256 * 5, height / 256 * 5)

   cairo.set_source(cr, pattern)
   cairo.rectangle(cr, 0, 0, 256, 256)
   cairo.fill(cr)
   cairo.pattern_destroy(pattern)
end

function samples.multisegment_caps(cr)
   cairo.move_to(cr, 50, 75)
   cairo.line_to(cr, 200, 75)

   cairo.move_to(cr, 50, 125)
   cairo.line_to(cr, 200, 125)

   cairo.move_to(cr, 50, 175)
   cairo.line_to(cr, 200, 175)

   cairo.set_line_width(cr, 15)
   cairo.set_line_cap(cr, cairo.lib.CAIRO_LINE_CAP_ROUND)
   cairo.stroke(cr)
end

function samples.rounded_rectangle(cr)
   local x, y, width, height = 25.6, 25.6, 204.8, 204.8
   local aspect = 1
   local corner_radius = height / 10

   local radius = corner_radius / aspect

   cairo.new_sub_path(cr)
   cairo.arc(cr, x + width - radius, y + radius, radius,
    math.rad(-90), math.rad(0))
   cairo.arc(cr, x + width - radius, y + height - radius, radius,
    math.rad(0), math.rad(90))
   cairo.arc(cr, x + radius, y + height - radius, radius,
    math.rad(90), math.rad(180))
   cairo.arc(cr, x + radius, y + radius, radius,
    math.rad(180), math.rad(270))
   cairo.close_path(cr)

   cairo.set_source_rgb(cr, 0.5, 0.5, 1)
   cairo.fill_preserve(cr)
   cairo.set_source_rgba(cr, 0.5, 0, 0, 0.5)
   cairo.set_line_width(cr, 10)
   cairo.stroke(cr)
end

-- Iterate through all samples and create .png files from them
for name, sample in pairs(samples) do
   local surface = cairo.image_surface_create(cairo.lib.CAIRO_FORMAT_ARGB32, 256, 256)
   local cr = cairo.create(surface)
   sample(cr)
   cairo.surface_write_to_png(surface, 'cairodemo-' .. name .. '.png')
end