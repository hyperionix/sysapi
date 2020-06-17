setfenv(1, require "sysapi-ns")

ffi.cdef [[
    int WideCharToMultiByte(
        UINT     CodePage,
        DWORD    dwFlags,
        LPCWSTR  lpWideCharStr,
        int      cchWideChar,
        LPSTR    lpMultiByteStr,
        int      cbMultiByte,
        LPCSTR   lpDefaultChar,
        LPBOOL   lpUsedDefaultChar);

    int MultiByteToWideChar(
        UINT     CodePage,
        DWORD    dwFlags,
        LPCSTR   lpMultiByteStr,
        int      cbMultiByte,
        LPWSTR   lpWideCharStr,
        int      cchWideChar);
]]
