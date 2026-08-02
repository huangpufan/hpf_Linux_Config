local ffi = require "ffi"
pcall(
  ffi.cdef,
  [[
  struct pollfd { int fd; short events; short revents; };
]]
)

local viewer = require "config.sixel_image"
local ok, err = viewer._ffi_status()
assert(ok, "Sixel FFI declarations should survive a predeclared generic struct pollfd: " .. tostring(err))
print "sixel_ffi_collision_check: ok"
vim.cmd "qa!"
