setfenv(1, require "sysapi-ns")

THREAD_CREATE_FLAGS_CREATE_SUSPENDED = 0x00000001
THREAD_CREATE_FLAGS_SKIP_THREAD_ATTACH = 0x00000002
THREAD_CREATE_FLAGS_HIDE_FROM_DEBUGGER = 0x00000004
THREAD_CREATE_FLAGS_HAS_SECURITY_DESCRIPTOR = 0x00000010
THREAD_CREATE_FLAGS_ACCESS_CHECK_IN_TARGET = 0x00000020
THREAD_CREATE_FLAGS_INITIAL_THREAD = 0x00000080

ffi.cdef [[
  typedef struct _INITIAL_TEB {
    struct
    {
        PVOID OldStackBase;
        PVOID OldStackLimit;
    } OldInitialTeb;
    PVOID StackBase;
    PVOID StackLimit;
    PVOID StackAllocationBase;
  } INITIAL_TEB, *PINITIAL_TEB;
]]

ffi.cdef [[
  DWORD GetCurrentThreadId();

  HANDLE CreateRemoteThread(
    HANDLE                 hProcess,
    LPSECURITY_ATTRIBUTES  lpThreadAttributes,
    SIZE_T                 dwStackSize,
    LPTHREAD_START_ROUTINE lpStartAddress,
    LPVOID                 lpParameter,
    DWORD                  dwCreationFlags,
    LPDWORD                lpThreadId
  );
]]
