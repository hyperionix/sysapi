setfenv(1, require "sysapi-ns")

ffi.cdef [[
  void Sleep(
    DWORD dwMilliseconds
  );
]]
