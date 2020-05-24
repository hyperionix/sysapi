setfenv(1, require "sysapi-ns")

ffi.cdef [[
  HRESULT URLDownloadToFileA(
    LPUNKNOWN pCaller,
    PCSTR    szURL,
    PCSTR    szFileName,
    DWORD     dwReserved,
    LPVOID    lpfnCB
  );
]]
