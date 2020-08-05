setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef LONG NTSTATUS;
]]

STATUS_SUCCESS = 0x00000000
STATUS_BUFFER_OVERFLOW = 0x80000005
STATUS_UNSUCCESSFUL = 0xC0000001
STATUS_INFO_LENGTH_MISMATCH = 0xC0000004
STATUS_ACCESS_VIOLATION = 0xC0000005
STATUS_INVALID_PARAMETER = 0xC000000D
STATUS_ACCESS_DENIED = 0xC0000022
STATUS_BUFFER_TOO_SMALL = 0xC0000023
STATUS_OBJECT_TYPE_MISMATCH = 0xC0000024

local INT32_T = ffi.typeof("int32_t")
local INT64_T = ffi.typeof("int64_t")
local UINT32_T = ffi.typeof("uint32_t")

function NT_SUCCESS(status)
  return ffi.cast(INT32_T, status) >= 0
end

function IS_STATUS(status, value)
  return tonumber(ffi.cast(UINT32_T, ffi.cast(INT64_T, status))) == value
end
