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

  typedef struct _GENERIC_MAPPING {
    ACCESS_MASK GenericRead;
    ACCESS_MASK GenericWrite;
    ACCESS_MASK GenericExecute;
    ACCESS_MASK GenericAll;
  } GENERIC_MAPPING;

  typedef struct _OBJECT_TYPE_INFORMATION {
      UNICODE_STRING TypeName;
      ULONG TotalNumberOfObjects;
      ULONG TotalNumberOfHandles;
      ULONG TotalPagedPoolUsage;
      ULONG TotalNonPagedPoolUsage;
      ULONG TotalNamePoolUsage;
      ULONG TotalHandleTableUsage;
      ULONG HighWaterNumberOfObjects;
      ULONG HighWaterNumberOfHandles;
      ULONG HighWaterPagedPoolUsage;
      ULONG HighWaterNonPagedPoolUsage;
      ULONG HighWaterNamePoolUsage;
      ULONG HighWaterHandleTableUsage;
      ULONG InvalidAttributes;
      GENERIC_MAPPING GenericMapping;
      ULONG ValidAccessMask;
      BOOLEAN SecurityRequired;
      BOOLEAN MaintainHandleCount;
      UCHAR TypeIndex; // since WINBLUE
      CHAR ReservedByte;
      ULONG PoolType;
      ULONG DefaultPagedPoolCharge;
      ULONG DefaultNonPagedPoolCharge;
  } OBJECT_TYPE_INFORMATION, *POBJECT_TYPE_INFORMATION;

  typedef struct _OBJECT_NAME_INFORMATION {
    UNICODE_STRING Name;
  } OBJECT_NAME_INFORMATION, *POBJECT_NAME_INFORMATION;

  typedef enum _OBJECT_INFORMATION_CLASS {
      ObjectBasicInformation, // OBJECT_BASIC_INFORMATION
      ObjectNameInformation, // OBJECT_NAME_INFORMATION
      ObjectTypeInformation, // OBJECT_TYPE_INFORMATION
      ObjectTypesInformation, // OBJECT_TYPES_INFORMATION
      ObjectHandleFlagInformation, // OBJECT_HANDLE_FLAG_INFORMATION
      ObjectSessionInformation,
      ObjectSessionObjectInformation,
      MaxObjectInfoClass
  } OBJECT_INFORMATION_CLASS;

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
  NTSTATUS
  NtQueryObject(
    HANDLE Handle,
    OBJECT_INFORMATION_CLASS ObjectInformationClass,
    PVOID ObjectInformation,
    ULONG ObjectInformationLength,
    PULONG ReturnLength
  );

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
