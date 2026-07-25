![Screenshot](https://github.com/uriid1/cairo-luajit-ffi/blob/main/screenshot.png)
[Russian](README_RU.md) | English</br>

## Cairo LuaJit FFI
FFI bindings to Cairo graphics

## Installation
## LuaRocks
```bash
sudo luarocks --lua-version 5.1 install rocks/cairo-luajit-ffi-0.1.0-1.rockspec
```

## Dependencies
For Debian or Ubuntu
```bash
sudo apt-get install libcairo2-dev
```

For Fedora
```bash
sudo yum install cairo-devel
```

For openSUSE
```bash
zypper install cairo-devel
```

# Documentation
https://www.cairographics.org/manual/
Methods have undergone minimal changes, but it's better to refer to cairo-ffi.lua, the examples, and test/all_test.lua.

# Constants
All cairo enum constants are available through `cairo.consts`:
```lua
local consts = require('cairo-luajit-ffi').consts

local format = consts.CAIRO_FORMAT_ARGB32
```

# Minimal Example
```lua
local cairo = require('cairo-luajit-ffi')
local consts = cairo.consts

local WIDTH = 512
local HEIGHT = 512

local surface = cairo.image_surface_create(consts.CAIRO_FORMAT_ARGB32, WIDTH, HEIGHT)
local cr = cairo.create(surface)

cairo.set_source_rgb(cr, 1, 1, 1)
cairo.paint(cr)

-- Fill circle
cairo.set_source_rgb(cr, 0, 0.7, 0.7)
cairo.arc(cr, WIDTH/2, HEIGHT/2, 128, 0, 2 * math.pi)
cairo.fill(cr)

cairo.surface_write_to_png(surface, 'circle-test.png')
cairo.destroy(cr)
cairo.surface_destroy(surface)
```

# Extensions
The `ext/` modules return objects with `:writePng(filename)`, `:pngString()` and `:destroy()` methods.

Captcha:
```lua
local captcha = require('cairo-luajit-ffi.ext.captcha')

math.randomseed(os.time())

local c = captcha.new({ length = 6 })
print(c.text)
c:writePng(c.text..'.png')
c:destroy()
```

Histogram:
```lua
local histogram = require('cairo-luajit-ffi.ext.histogram')

local h = histogram.new({
  values = { 1, 5, 3, 8 },
  descriptions = { 'a', 'b', 'c', 'd' },
})
h:writePng('histogram.png')
h:destroy()
```

Identicon (deterministic avatar from a string):
```lua
local identicon = require('cairo-luajit-ffi.ext.identicon')

local icon = identicon.new({ seed = 'user@example.com' })
icon:writePng('avatar.png')
icon:destroy()
```

Placeholder image:
```lua
local placeholder = require('cairo-luajit-ffi.ext.placeholder')

local p = placeholder.new({ width = 300, height = 150 })
p:writePng('placeholder.png')
p:destroy()
```

Badge (shields.io style):
```lua
local badge = require('cairo-luajit-ffi.ext.badge')

local b = badge.new({ label = 'build', value = 'passing' })
b:writePng('badge.png')
b:destroy()
```

Progress ring:
```lua
local progress = require('cairo-luajit-ffi.ext.progress')

local p = progress.new({ percent = 42 })
p:writePng('progress.png')
p:destroy()
```
