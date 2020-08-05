setfenv(1, require "sysapi-ns")
local bor = bit.bor

-- Memory Protection Constants
-- https://docs.microsoft.com/en-us/windows/desktop/memory/memory-protection-constants

PAGE_NOACCESS = 0x01
PAGE_READONLY = 0x02
PAGE_READWRITE = 0x04
PAGE_WRITECOPY = 0x08
PAGE_EXECUTE = 0x10
PAGE_EXECUTE_READ = 0x20
PAGE_EXECUTE_READWRITE = 0x40
PAGE_EXECUTE_WRITECOPY = 0x80
PAGE_GUARD = 0x100
PAGE_NOCACHE = 0x200
PAGE_WRITECOMBINE = 0x400
PAGE_TARGETS_INVALID = 0x40000000
PAGE_TARGETS_NO_UPDATE = 0x40000000
PAGE_REVERT_TO_FILE_MAP = 0x80000000

MEM_COMMIT = 0x1000
MEM_RESERVE = 0x2000
MEM_DECOMMIT = 0x4000
MEM_RELEASE = 0x8000
MEM_FREE = 0x10000
MEM_PRIVATE = 0x20000
MEM_MAPPED = 0x40000
MEM_RESET = 0x80000
MEM_TOP_DOWN = 0x100000
MEM_WRITE_WATCH = 0x200000
MEM_PHYSICAL = 0x400000
MEM_ROTATE = 0x800000
MEM_DIFFERENT_IMAGE_BASE_OK = 0x800000
MEM_RESET_UNDO = 0x1000000
MEM_LARGE_PAGES = 0x20000000
MEM_4MB_PAGES = 0x80000000

SECTION_QUERY = 0x0001
SECTION_MAP_WRITE = 0x0002
SECTION_MAP_READ = 0x0004
SECTION_MAP_EXECUTE = 0x0008
SECTION_EXTEND_SIZE = 0x0010
SECTION_MAP_EXECUTE_EXPLICIT = 0x0020

SECTION_ALL_ACCESS =
  bor(
  STANDARD_RIGHTS_REQUIRED,
  SECTION_QUERY,
  SECTION_MAP_WRITE,
  SECTION_MAP_READ,
  SECTION_MAP_EXECUTE,
  SECTION_EXTEND_SIZE
)

FILE_MAP_WRITE = SECTION_MAP_WRITE
FILE_MAP_READ = SECTION_MAP_READ
FILE_MAP_ALL_ACCESS = SECTION_ALL_ACCESS

ffi.cdef [[
  typedef struct _MEMORY_BASIC_INFORMATION {
    PVOID  BaseAddress;
    PVOID  AllocationBase;
    DWORD  AllocationProtect;
    SIZE_T RegionSize;
    DWORD  State;
    DWORD  Protect;
    DWORD  Type;
  } MEMORY_BASIC_INFORMATION, *PMEMORY_BASIC_INFORMATION;
]]

ffi.cdef [[
    LPVOID VirtualAlloc(
      LPVOID lpAddress,
      SIZE_T dwSize,
      DWORD  flAllocationType,
      DWORD  flProtect
    );

    BOOL VirtualProtect(
      LPVOID lpAddress,
      SIZE_T dwSize,
      DWORD  flNewProtect,
      PDWORD lpflOldProtect
    );

    SIZE_T VirtualQuery(
      LPCVOID                   lpAddress,
      PMEMORY_BASIC_INFORMATION lpBuffer,
      SIZE_T                    dwLength
    );

    BOOL VirtualFree(
      LPVOID lpAddress,
      SIZE_T dwSize,
      DWORD  dwFreeType
    );

    LPVOID VirtualAllocEx(
      HANDLE hProcess,
      LPVOID lpAddress,
      SIZE_T dwSize,
      DWORD  flAllocationType,
      DWORD  flProtect
    );

    SIZE_T VirtualQueryEx(
      HANDLE                    hProcess,
      LPCVOID                   lpAddress,
      PMEMORY_BASIC_INFORMATION lpBuffer,
      SIZE_T                    dwLength
    );
    
    BOOL VirtualProtectEx(
      HANDLE hProcess,
      LPVOID lpAddress,
      SIZE_T dwSize,
      DWORD  flNewProtect,
      PDWORD lpflOldProtect
    );

    BOOL WriteProcessMemory(
      HANDLE  hProcess,
      LPVOID  lpBaseAddress,
      LPCVOID lpBuffer,
      SIZE_T  nSize,
      SIZE_T  *lpNumberOfBytesWritten
    );

    BOOL ReadProcessMemory(
      HANDLE  hProcess,
      LPCVOID lpBaseAddress,
      LPVOID  lpBuffer,
      SIZE_T  nSize,
      SIZE_T  *lpNumberOfBytesRead
    );

    BOOL VirtualFreeEx(
      HANDLE hProcess,
      LPVOID lpAddress,
      SIZE_T dwSize,
      DWORD  dwFreeType
    );

    HANDLE CreateFileMappingA(
      HANDLE                hFile,
      LPSECURITY_ATTRIBUTES lpFileMappingAttributes,
      DWORD                 flProtect,
      DWORD                 dwMaximumSizeHigh,
      DWORD                 dwMaximumSizeLow,
      LPCSTR                lpName
    );
  
    LPVOID MapViewOfFile(
      HANDLE hFileMappingObject,
      DWORD  dwDesiredAccess,
      DWORD  dwFileOffsetHigh,
      DWORD  dwFileOffsetLow,
      SIZE_T dwNumberOfBytesToMap
    );
  
    BOOL UnmapViewOfFile(
      LPCVOID lpBaseAddress
    );
]]
