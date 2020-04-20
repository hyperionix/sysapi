--- Function to create a byte buffer.
--
-- @module bytebuf
-- @pragma nostrip
local tonumber = tonumber
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

return M
