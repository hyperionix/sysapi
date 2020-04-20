setfenv(1, require "sysapi-ns")

-- Registry Key Security and Access Rights
-- https://docs.microsoft.com/ru-ru/windows/desktop/SysInfo/registry-key-security-and-access-rights

KEY_QUERY_VALUE = 0x0001
KEY_SET_VALUE = 0x0002
KEY_CREATE_SUB_KEY = 0x0004
KEY_ENUMERATE_SUB_KEYS = 0x0008
KEY_NOTIFY = 0x0010
KEY_CREATE_LINK = 0x0020
KEY_WOW64_64KEY = 0x0100
KEY_WOW64_32KEY = 0x0200
KEY_READ = 0x20019
KEY_WRITE = 0x20006
KEY_EXECUTE = 0x20019
KEY_ALL_ACCESS = 0xF003F

-- Registry Value Types
-- https://docs.microsoft.com/ru-ru/windows/desktop/SysInfo/registry-value-types

REG_NONE = 0
REG_SZ = 1
REG_EXPAND_SZ = 2
REG_BINARY = 3
REG_DWORD = 4
REG_DWORD_LITTLE_ENDIAN = 4
REG_DWORD_BIG_ENDIAN = 5
REG_LINK = 6
REG_MULTI_SZ = 7
REG_RESOURCE_LIST = 8
REG_FULL_RESOURCE_DESCRIPTOR = 9
REG_RESOURCE_REQUIREMENTS_LIST = 10
REG_QWORD = 11
REG_QWORD_LITTLE_ENDIAN = 11

-- Registry Key Open/Create Options
REG_OPTION_NON_VOLATILE = 0x00000000
REG_OPTION_VOLATILE = 0x00000001
REG_OPTION_CREATE_LINK = 0x00000002
REG_OPTION_BACKUP_RESTORE = 0x00000004
REG_OPTION_OPEN_LINK = 0x00000008

-- Registry Key Creation/Open Disposition
REG_CREATED_NEW_KEY = 0x00000001
REG_OPENED_EXISTING_KEY = 0x00000002

-- Registry key value type restrictions
RRF_RT_ANY = 0x0000ffff
RRF_RT_DWORD = 0x00000018
RRF_RT_QWORD = 0x00000048
RRF_RT_REG_BINARY = 0x00000008
RRF_RT_REG_DWORD = 0x00000010
RRF_RT_REG_EXPAND_SZ = 0x00000004
RRF_RT_REG_MULTI_SZ = 0x00000020
RRF_RT_REG_NONE = 0x00000001
RRF_RT_REG_QWORD = 0x00000040
RRF_RT_REG_SZ = 0x00000002

RRF_NOEXPAND = 0x10000000
RRF_ZEROONFAILURE = 0x20000000
RRF_SUBKEY_WOW6464KEY = 0x00010000
RRF_SUBKEY_WOW6432KEY = 0x00020000

-- Registry key restore & hive load flags
REG_WHOLE_HIVE_VOLATILE = 0x00000001
REG_REFRESH_HIVE = 0x00000002
REG_NO_LAZY_FLUSH = 0x00000004
REG_FORCE_RESTORE = 0x00000008
REG_APP_HIVE = 0x00000010
REG_PROCESS_PRIVATE = 0x00000020
REG_START_JOURNAL = 0x00000040
REG_HIVE_EXACT_FILE_GROWTH = 0x00000080
REG_HIVE_NO_RM = 0x00000100
REG_HIVE_SINGLE_LOG = 0x00000200
REG_BOOT_HIVE = 0x00000400
REG_LOAD_HIVE_OPEN_HANDLE = 0x00000800
REG_FLUSH_HIVE_FILE_GROWTH = 0x00001000
REG_OPEN_READ_ONLY = 0x00002000
REG_IMMUTABLE = 0x00004000
REG_APP_HIVE_OPEN_READ_ONLY = REG_OPEN_READ_ONLY

ffi.cdef [[
  typedef void *HKEY;
  typedef HKEY *PHKEY;
  typedef ACCESS_MASK REGSAM;
]]

ffi.cdef [[
  typedef LONG LSTATUS;

  LONG RegCreateKeyExA(
    HKEY                        hKey,
    LPCSTR                      lpSubKey,
    DWORD                       Reserved,
    LPSTR                       lpClass,
    DWORD                       dwOptions,
    REGSAM                      samDesired,
    const LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    PHKEY                       phkResult,
    LPDWORD                     lpdwDisposition
  );

  LONG RegOpenKeyExA(
      HKEY   hKey,
      LPCSTR lpSubKey,
      DWORD  ulOptions,
      REGSAM samDesired,
      PHKEY  phkResult
  );

  LONG RegOpenCurrentUser(
      REGSAM samDesired,
      PHKEY  phkResult
  );

  LONG RegGetValueA(
      HKEY    hkey,
      LPCSTR  lpSubKey,
      LPCSTR  lpValue,
      DWORD   dwFlags,
      LPDWORD pdwType,
      PVOID   pvData,
      LPDWORD pcbData
  );

  LONG RegSetValueExA(
    HKEY       hKey,
    LPCSTR     lpValueName,
    DWORD      Reserved,
    DWORD      dwType,
    const BYTE *lpData,
    DWORD      cbData
  );

  LSTATUS RegSetKeyValueA(
    HKEY    hKey,
    LPCSTR  lpSubKey,
    LPCSTR  lpValueName,
    DWORD   dwType,
    LPCVOID lpData,
    DWORD   cbData
  );

  LONG RegSaveKeyA(
      HKEY                        hKey,
      LPCSTR                      lpFile,
      const LPSECURITY_ATTRIBUTES lpSecurityAttributes
  );

  LONG RegRestoreKeyA(
      HKEY   hKey,
      LPCSTR lpFile,
      DWORD  dwFlags
  );

  LONG RegDeleteTreeA(
      HKEY   hKey,
      LPCSTR lpSubKey
  );

  LONG RegQueryInfoKeyA(
      HKEY      hKey,
      LPSTR     lpClass,
      LPDWORD   lpcchClass,
      LPDWORD   lpReserved,
      LPDWORD   lpcSubKeys,
      LPDWORD   lpcbMaxSubKeyLen,
      LPDWORD   lpcbMaxClassLen,
      LPDWORD   lpcValues,
      LPDWORD   lpcbMaxValueNameLen,
      LPDWORD   lpcbMaxValueLen,
      LPDWORD   lpcbSecurityDescriptor,
      PFILETIME lpftLastWriteTime
  );

  LONG RegCloseKey(HKEY hKey);

  LONG RegDeleteValueA(
    HKEY hKey,
    LPCSTR lpValueName
  );

  LONG RegDeleteKeyA(
    HKEY   hKey,
    LPCSTR lpSubKey
  );

  LONG RegEnumKeyExA(
    HKEY      hKey,
    DWORD     dwIndex,
    LPSTR     lpName,
    LPDWORD   lpcchName,
    LPDWORD   lpReserved,
    LPSTR     lpClass,
    LPDWORD   lpcchClass,
    PFILETIME lpftLastWriteTime
  );

  LONG RegEnumValueA(
    HKEY    hKey,
    DWORD   dwIndex,
    LPSTR   lpValueName,
    LPDWORD lpcchValueName,
    LPDWORD lpReserved,
    LPDWORD lpType,
    LPBYTE  lpData,
    LPDWORD lpcbData
  );
]]

HKEY_CLASSES_ROOT = ffi.cast("HKEY", 0x80000000)
HKEY_CURRENT_USER = ffi.cast("HKEY", 0x80000001)
HKEY_LOCAL_MACHINE = ffi.cast("HKEY", 0x80000002)
HKEY_USERS = ffi.cast("HKEY", 0x80000003)
