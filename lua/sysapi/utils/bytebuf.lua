--- Function to create a byte buffer.
--
-- @module bytebuf
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
local tonumber = tonumber
local sformat = string.format
local schar = string.char
local ffi = require "ffi"
local M = {}

--- Creates byte buffer.
-- @param s a sequence of bytes in string
-- @return byte buffer
-- @usage
-- local bytebuf = require "bytebuf"
-- local data = bytebuf.create([[\x12\x34\x56\x78]])
-- @function bytebuf.create
function M.create(s)
  return ffi.string(
    s:gsub(
      "(\\x%x+)",
      function(ch)
        local res = ch:gsub("\\", "0")
        return schar(tonumber(res))
      end
    )
  )
end

function M.dump(ptr, size, as)
  local as = as or "intptr_t"
  ptr = ffi.cast(as .. "*", ptr)
  local data = ""
  local typeSize = ffi.sizeof(as)
  for i = 0, size - 1 do
    if i % (16 / typeSize) == 0 then
      data = data .. sformat("\n0x%X: ", toaddress(ptr))
    end
    data = data .. sformat("%0" .. typeSize * 2 .. "X ", tonumber(ptr[0]))
    ptr = ptr + 1
  end
  return data
end

return M
