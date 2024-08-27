package = "cairo-luajit-ffi"
version = "0.0-1"

source = {
  url = "git+https://github.com/uriid1/cairo-luajit-ffi.git",
}

description = {
  summary = "FFI bindings for Cairo graphics",
  detailed = [[
    https://www.cairographics.org/manual/ Methods have undergone minimal changes, but it's better to refer to cairo-ffi.lua, the examples, and test/all_test.lua.
  ]],
  homepage = "https://github.com/uriid1/cairo-luajit-ffi",
  license = "GPL"
}

dependencies = {
 "lua >= 5.1",
}

build = {
  type = "builtin",
  modules = {
    [package] = "cairo-luajit-ffi.lua",
    --
    [package..".src"] = "cairo.h",
    [package..".src"] = "cairo-tee.h",
    [package..".src"] = "cairo-svg.h",
    [package..".src"] = "cairo-ps.h",
    [package..".src"] = "cairo-pdf.h",
    --
    [package..".ext"] = "histogram.lua",
  }
}
