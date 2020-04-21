local _M = {__index = _G}
setmetatable(_M, _M)
_M._M = _M

setfenv(1, _M)

ffi = require "ffi"

return _M
