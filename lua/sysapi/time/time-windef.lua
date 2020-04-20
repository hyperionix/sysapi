setfenv(1, require "sysapi-ns")

EPOCH_BIAS = 116444736000000000
TICKS_PER_SEC = 10000000

ffi.cdef [[
  typedef struct _FILETIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
  } FILETIME, *PFILETIME, *LPFILETIME;
]]

ffi.cdef [[
  BOOL GetProcessTimes(
    HANDLE     hProcess,
    LPFILETIME lpCreationTime,
    LPFILETIME lpExitTime,
    LPFILETIME lpKernelTime,
    LPFILETIME lpUserTime
  );
]]
