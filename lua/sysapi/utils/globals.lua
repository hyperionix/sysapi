--- Global table extensions
--
-- @module globals
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
local btohex = bit.tohex
local intptr_ct = ffi.typeof("intptr_t")

--- Function to convert a ffi pointer to integer representation
function toaddress(value)
  return tonumber(ffi.cast(intptr_ct, value))
end

--- Convert a value to hex string
function tohex(value)
  return "0x" .. btohex(value)
end
