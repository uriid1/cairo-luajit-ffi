local ffi = require('ffi')
local cairo = require('cairo-luajit-ffi')

local M = {}

function M:init(format, width, height)
  format = format or cairo.lib.CAIRO_FORMAT_ARGB32

  self.width = width
  self.height = height
  self.surface = cairo.image_surface_create(format, width, height)
  self.cr = cairo.create(self.surface)
end

function M:init_image()
  local surface_data = cairo.image_surface_get_data(self.surface)
  local surface_stride = cairo.image_surface_get_stride(self.surface)

  self.imageData = love.image.newImageData(
    self.width,
    self.height,
    "rgba8",
    ffi.string(surface_data, surface_stride * self.height)
  )

  self.image = love.graphics.newImage(self.imageData)
end

function M:clear()
  self.imageData:release()

  local surface_data = cairo.image_surface_get_data(self.surface)
  local surface_stride = cairo.image_surface_get_stride(self.surface)

  self.imageData = love.image.newImageData(
    self.width,
    self.height,
    "rgba8",
    ffi.string(surface_data, surface_stride * self.height)
  )

  -- self.image:release()
  -- self.image = love.graphics.newImage(self.imageData)
  self.image:replacePixels(self.imageData)
end

function M:release()
  cairo.destroy(self.cr)
  cairo.surface_destroy(self.surface)
end

return M
