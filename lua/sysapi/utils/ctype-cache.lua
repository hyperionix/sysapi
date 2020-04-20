local ffi = require "ffi"
local M = {}

function M:cache(name)
  rawset(self, name, ffi.typeof(name))
  rawset(self, "P" .. name, ffi.typeof(name .. "*"))
end

return M
