setfenv(1, require "sysapi-ns")
local bor = bit.bor

INVALID_HANDLE_VALUE = ffi.cast("HANDLE", -1)

-- These are the generic rights
-- https://docs.microsoft.com/ru-ru/windows/desktop/SecAuthZ/generic-access-rights
GENERIC_READ = 0x80000000
GENERIC_WRITE = 0x40000000
GENERIC_EXECUTE = 0x20000000
GENERIC_READWRITE = bor(GENERIC_READ, GENERIC_WRITE)
GENERIC_ALL = 0x10000000

-- Standard Access Rights
-- https://docs.microsoft.com/ru-ru/windows/desktop/SecAuthZ/standard-access-rights
DELETE = 0x00010000
READ_CONTROL = 0x00020000
WRITE_DAC = 0x00040000
WRITE_OWNER = 0x00080000
SYNCHRONIZE = 0x00100000

STANDARD_RIGHTS_REQUIRED = 0x000F0000

STANDARD_RIGHTS_READ = READ_CONTROL
STANDARD_RIGHTS_WRITE = READ_CONTROL
STANDARD_RIGHTS_EXECUTE = READ_CONTROL

STANDARD_RIGHTS_ALL = 0x001F0000

SPECIFIC_RIGHTS_ALL = 0x0000FFFF

-- #define DECLARE_HANDLE(name) struct name##__{int unused;}; typedef struct name##__ *name
function DECLARE_HANDLE(name)
  local decl = string.format("struct %s__{int unused;}; typedef struct %s__ *%s;", name, name, name)
  ffi.cdef(decl)
end

ffi.cdef [[
  typedef DWORD ACCESS_MASK;
  typedef ACCESS_MASK* PACCESS_MASK;

  typedef struct _OBJECT_ATTRIBUTES {
    ULONG           Length;
    HANDLE          RootDirectory;
    PUNICODE_STRING ObjectName;
    ULONG           Attributes;
    PVOID           SecurityDescriptor;
    PVOID           SecurityQualityOfService;
  } OBJECT_ATTRIBUTES, *POBJECT_ATTRIBUTES;
]]

ffi.cdef [[
  BOOL CloseHandle(
    HANDLE hObject
  );

  BOOL DuplicateHandle(
    HANDLE   hSourceProcessHandle,
    HANDLE   hSourceHandle,
    HANDLE   hTargetProcessHandle,
    LPHANDLE lpTargetHandle,
    DWORD    dwDesiredAccess,
    BOOL     bInheritHandle,
    DWORD    dwOptions
  );

  BOOL GetHandleInformation(
    HANDLE  hObject,
    LPDWORD lpdwFlags
  );

  BOOL SetHandleInformation(
    HANDLE hObject,
    DWORD  dwMask,
    DWORD  dwFlags
  );
]]
