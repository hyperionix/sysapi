setfenv(1, require "sysapi-ns")

FOLDERID_Downloads = {0x374de290, 0x123f, 0x4565, {0x91, 0x64, 0x39, 0xc4, 0x92, 0x5e, 0x46, 0x7b}}
FOLDERID_Windows = {0xF38BF404, 0x1D43, 0x42F2, {0x93, 0x05, 0x67, 0xDE, 0x0B, 0x28, 0xFC, 0x23}}
FOLDERID_Startup = {0xB97D20BB, 0xF46A, 0x4C97, {0xBA, 0x10, 0x5E, 0x36, 0x08, 0x43, 0x08, 0x54}}
FOLDERID_PrintersFolder = {0x76FC4E2D, 0xD6AD, 0x4519, {0xA6, 0x63, 0x37, 0xBD, 0x56, 0x06, 0x81, 0x85}}
FOLDERID_Profile = {0x5E6C858F, 0x0E22, 0x4760, {0x9A, 0xFE, 0xEA, 0x33, 0x17, 0xB6, 0x71, 0x73}}

ffi.cdef [[
  typedef GUID KNOWNFOLDERID;

  typedef enum KF_CATEGORY {
    KF_CATEGORY_VIRTUAL,
    KF_CATEGORY_FIXED,
    KF_CATEGORY_COMMON,
    KF_CATEGORY_PERUSER
  };

  typedef enum  {
    KF_FLAG_DEFAULT = 0x00000000,
    KF_FLAG_FORCE_APP_DATA_REDIRECTION = 0x00080000,
    KF_FLAG_RETURN_FILTER_REDIRECTION_TARGET = 0x00040000,
    KF_FLAG_FORCE_PACKAGE_REDIRECTION = 0x00020000,
    KF_FLAG_NO_PACKAGE_REDIRECTION = 0x00010000,
    KF_FLAG_FORCE_APPCONTAINER_REDIRECTION = 0x00020000,
    KF_FLAG_NO_APPCONTAINER_REDIRECTION = 0x00010000,
    KF_FLAG_CREATE = 0x00008000,
    KF_FLAG_DONT_VERIFY = 0x00004000,
    KF_FLAG_DONT_UNEXPAND = 0x00002000,
    KF_FLAG_NO_ALIAS = 0x00001000,
    KF_FLAG_INIT = 0x00000800,
    KF_FLAG_DEFAULT_PATH = 0x00000400,
    KF_FLAG_NOT_PARENT_RELATIVE = 0x00000200,
    KF_FLAG_SIMPLE_IDLIST = 0x00000100,
    KF_FLAG_ALIAS_ONLY = 0x80000000,
  };

  typedef struct _WIN32_FIND_DATAA {
    DWORD    dwFileAttributes;
    FILETIME ftCreationTime;
    FILETIME ftLastAccessTime;
    FILETIME ftLastWriteTime;
    DWORD    nFileSizeHigh;
    DWORD    nFileSizeLow;
    DWORD    dwReserved0;
    DWORD    dwReserved1;
    CHAR     cFileName[260]; // MAX_PATH
    CHAR     cAlternateFileName[14];
    DWORD    dwFileType;
    DWORD    dwCreatorType;
    WORD     wFinderFlags;
  } WIN32_FIND_DATAA, *PWIN32_FIND_DATAA, *LPWIN32_FIND_DATAA;

  typedef struct _CURDIR {
    UNICODE_STRING DosPath;
    HANDLE Handle;
  } CURDIR, *PCURDIR;

  typedef struct _RTL_DRIVE_LETTER_CURDIR {
      USHORT Flags;
      USHORT Length;
      ULONG TimeStamp;
      STRING DosPath;
  } RTL_DRIVE_LETTER_CURDIR, *PRTL_DRIVE_LETTER_CURDIR;
]]

ffi.cdef [[
  DWORD GetTempPathA(
    DWORD nBufferLength,
    LPSTR lpBuffer
  );

  HANDLE FindFirstFileA(
    LPCSTR             lpFileName,
    LPWIN32_FIND_DATAA lpFindFileData
  );
  
  BOOL FindNextFileA(
    HANDLE             hFindFile,
    LPWIN32_FIND_DATAA lpFindFileData
  );

  BOOL FindClose(
    HANDLE hFindFile
  );

  void CoTaskMemFree(PVOID pv);

  LONG SHGetKnownFolderPath(
      KNOWNFOLDERID *rfid,
      DWORD         dwFlags,
      HANDLE        hToken,
      LPWSTR        *ppszPath
  );
]]
