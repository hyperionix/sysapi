setfenv(1, require "sysapi-ns")

ffi.cdef [[
  HMODULE LoadLibraryA(
    LPCSTR lpLibFileName
  );

  BOOL FreeLibrary(
    HMODULE hLibModule
  );

  DWORD GetModuleFileNameA(
    HMODULE hModule,
    LPSTR   lpFilename,
    DWORD   nSize
  );
]]
