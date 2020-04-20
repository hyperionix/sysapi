setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef LONG NTSTATUS;
]]

STATUS_SUCCESS = 0x00000000
STATUS_BUFFER_TOO_SMALL = 0xC0000023
STATUS_BUFFER_OVERFLOW = 0x80000005
STATUS_INFO_LENGTH_MISMATCH = 0xC0000004

function NT_SUCCESS(status)
  return ffi.cast("int32_t", status) >= 0
end

function IS_STATUS(status, value)
  return tonumber(ffi.cast("uint32_t", status)) == value
end
