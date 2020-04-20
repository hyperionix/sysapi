setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef struct _OSVERSIONINFOW {
    ULONG dwOSVersionInfoSize;
    ULONG dwMajorVersion;
    ULONG dwMinorVersion;
    ULONG dwBuildNumber;
    ULONG dwPlatformId;
    WCHAR  szCSDVersion[ 128 ];
  } OSVERSIONINFOW, *POSVERSIONINFOW, RTL_OSVERSIONINFOW, *PRTL_OSVERSIONINFOW;
]]

ffi.cdef [[
  NTSTATUS RtlGetVersion(
    PRTL_OSVERSIONINFOW lpVersionInformation
  );
]]
