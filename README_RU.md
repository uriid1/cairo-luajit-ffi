![Screenshot](https://github.com/uriid1/cairo-luajit-ffi/blob/main/screenshot.png)
Russian | [English](README.md)</br>

## Cairo LuaJit FFI
FFI Биндинги к cairo graphics.</br>
Тестировалось на версии cairo 1.18.0

## Установка
## LuaRocks
```bash
sudo luarocks --lua-version 5.1 install rocks/cairo-luajit-ffi-0.1.0-1.rockspec
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

# Константы
Все enum-константы cairo доступны через `cairo.consts`:
```lua
local consts = require('cairo-luajit-ffi').consts

local format = consts.CAIRO_FORMAT_ARGB32
```

# Минимальный пример
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

# Расширения
Модули из `ext/` возвращают объекты с методами `:writePng(filename)`, `:pngString()` и `:destroy()`.

Капча:
```lua
local captcha = require('cairo-luajit-ffi.ext.captcha')

math.randomseed(os.time())

local c = captcha.new({ length = 6 })
print(c.text)
c:writePng(c.text..'.png')
c:destroy()
```

Гистограмма:
```lua
local histogram = require('cairo-luajit-ffi.ext.histogram')

local h = histogram.new({
  values = { 1, 5, 3, 8 },
  descriptions = { 'a', 'b', 'c', 'd' },
})
h:writePng('histogram.png')
h:destroy()
```

Идентикон (детерминированная аватарка по строке):
```lua
local identicon = require('cairo-luajit-ffi.ext.identicon')

local icon = identicon.new({ seed = 'user@example.com' })
icon:writePng('avatar.png')
icon:destroy()
```

Картинка-заглушка:
```lua
local placeholder = require('cairo-luajit-ffi.ext.placeholder')

local p = placeholder.new({ width = 300, height = 150 })
p:writePng('placeholder.png')
p:destroy()
```

Бейдж (в стиле shields.io):
```lua
local badge = require('cairo-luajit-ffi.ext.badge')

local b = badge.new({ label = 'build', value = 'passing' })
b:writePng('badge.png')
b:destroy()
```

Кольцо прогресса:
```lua
local progress = require('cairo-luajit-ffi.ext.progress')

local p = progress.new({ percent = 42 })
p:writePng('progress.png')
p:destroy()
```
