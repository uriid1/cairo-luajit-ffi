![Screenshot](https://github.com/uriid1/cairo-luajit-ffi/blob/main/screenshot.png)
Russian | [English](README.md)</br>

## Cairo LuaJit FFI
FFI Биндинги к cairo graphics.</br>
Тестировалось на версии cairo 1.18.0

## Установка
## LuaRocks
```bash
sudo luarocks --lua-version 5.1 install cairo-luajit-ffi-0.0-1.rockspec
```

## Зависимости
Для Debian или Ubuntu
```bash
sudo apt-get install libcairo2-dev
```

Для Arch или Manjaro
```bash
sudo pacman -S cairo
```

Для Fedora
```bash
sudo yum install cairo-devel
```

Для openSUSE
```bash
zypper install cairo-devel
```

# Документация
https://www.cairographics.org/manual/
Методы практически не притерпели изменений, но лучше сверяться с `cairo-ffi.lua` и примерами и `test/all_test.lua`.

# Минимальный пример
```lua
local cairo = require('cairo-ffi')

local WIDTH = 512
local HEIGHT = 512

local surface = cairo.image_surface_create(cairo.lib.CAIRO_FORMAT_ARGB32, WIDTH, HEIGHT)
local cr = cairo.create(surface)

cairo.set_source_rgb(cr, 1, 1, 1)
cairo.paint(cr)

-- Fill circle
cairo.set_source_rgb(cr, 0, 0.7, 0.7)
cairo.save(cr)
cairo.translate(cr, WIDTH/2, HEIGHT/2)
cairo.scale(cr, WIDTH/4, HEIGHT/4)
cairo.arc(cr, 0, 0, 1, 0, 2 * math.pi)
cairo.restore(cr)
cairo.fill(cr)

cairo.surface_write_to_png(surface, 'circle-test.png')
cairo.destroy(cr)
cairo.surface_destroy(surface)
```
