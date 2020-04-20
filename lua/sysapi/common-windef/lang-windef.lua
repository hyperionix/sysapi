setfenv(1, require "sysapi-ns")
local bor, lshift = bit.bor, bit.lshift

-- Language Identifier Constants and Strings
-- https://docs.microsoft.com/en-us/windows/win32/intl/language-identifier-constants-and-strings
LANG_ENGLISH = 0x09
SUBLANG_ENGLISH_US = 0x01

-- #define MAKELANGID(p, s) ((((WORD  )(s)) << 10) | (WORD  )(p))
function MAKELANGID(p, s)
  return bor(lshift(ffi.cast("WORD", s), 10), ffi.cast("WORD", p))
end
