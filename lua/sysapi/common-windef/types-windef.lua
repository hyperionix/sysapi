setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef void VOID;
  typedef signed char CCHAR, CHAR, INT8;
  typedef unsigned char BYTE, UCHAR, UINT8, BOOLEAN;
  typedef signed short SHORT, INT16;
  typedef unsigned short WORD, USHORT, UINT16;
  typedef signed int INT, INT32, BOOL;
  typedef unsigned int UINT, UINT32;
  typedef signed long LONG;
  typedef unsigned long ULONG, DWORD;
  typedef int64_t INT64;
  typedef uint64_t UINT64;
  typedef signed long long LONGLONG;
  typedef unsigned long long ULONGLONG;
  typedef intptr_t LONG_PTR;
  typedef uintptr_t ULONG_PTR;
  typedef size_t SIZE_T, *PSIZE_T;
  typedef int errno_t;
  typedef long HRESULT;

  typedef const char *LPCSTR, *LPCCH, *PCCH;;
  typedef CHAR *NPSTR, *LPSTR, *PSTR;
  typedef PSTR *PZPSTR;
  typedef const PSTR *PCZPSTR;
  typedef const CHAR *LPCSTR, *PCSTR;
  typedef PCSTR *PZPCSTR;
  typedef const PCSTR *PCZPCSTR;
  
  typedef wchar_t WCHAR, *PWCHAR, *PWCH, *PWSTR, *LPWSTR;
  typedef WCHAR *PWCHAR, *LPWCH, *PWCH;
  typedef const wchar_t *LPCWSTR, *PCWSTR;
  typedef const WCHAR *LPCWCH, *PCWCH;

  typedef VOID *PVOID, *LPVOID;
  typedef const VOID* LPCVOID;
  typedef CHAR *PCHAR, *LPSTR;
  typedef void * __ptr64  PVOID64;
  typedef UCHAR *PUCHAR;
  typedef SHORT *PSHORT;
  typedef USHORT *PUSHORT;
  typedef INT *PINT;
  typedef DWORD *PDWORD, *LPDWORD;
  typedef UINT *PUINT;
  typedef LONG *PLONG;
  typedef ULONG *PULONG;
  typedef LONGLONG *PLONGLONG;
  typedef ULONGLONG *PULONGLONG;
  typedef BOOL *PBOOL, *LPBOOL;
  typedef BYTE *LPBYTE;

  typedef PVOID HANDLE, *PHANDLE, *LPHANDLE;
  typedef PVOID HINSTANCE;
  typedef HINSTANCE HMODULE;

  typedef PVOID LPUNKNOWN;

  typedef DWORD (*PTHREAD_START_ROUTINE)(
    LPVOID lpThreadParameter
    );
  typedef PTHREAD_START_ROUTINE LPTHREAD_START_ROUTINE;

  typedef LONG KPRIORITY;

  typedef struct _SECURITY_ATTRIBUTES {
    DWORD  nLength;
    LPVOID lpSecurityDescriptor;
    BOOL   bInheritHandle;
  } SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

  typedef union _LARGE_INTEGER {
    struct {
        ULONG LowPart;
        LONG HighPart;
    } DUMMYSTRUCTNAME;
    struct {
        ULONG LowPart;
        LONG HighPart;
    } u;
    LONGLONG QuadPart;
  } LARGE_INTEGER, *PLARGE_INTEGER;

  typedef union _ULARGE_INTEGER {
    struct {
        DWORD LowPart;
        DWORD HighPart;
    } DUMMYSTRUCTNAME;
    struct {
        DWORD LowPart;
        DWORD HighPart;
    } u;
    ULONGLONG QuadPart;
  } ULARGE_INTEGER;

  typedef struct _STRING {
      USHORT Length;
      USHORT MaximumLength;
      PCHAR Buffer;
  } STRING, *PSTRING, ANSI_STRING, *PANSI_STRING, OEM_STRING, *POEM_STRING;

  typedef struct _UNICODE_STRING {
    USHORT Length;
    USHORT MaximumLength;
    PWCH   Buffer;
  } UNICODE_STRING, *PUNICODE_STRING;

  typedef struct _GUID {
    unsigned long  Data1;
    unsigned short Data2;
    unsigned short Data3;
    unsigned char  Data4[8];
  } GUID;

  typedef PVOID PSID;

  typedef struct _SID_AND_ATTRIBUTES {
    PSID Sid;
    DWORD Attributes;
  } SID_AND_ATTRIBUTES, * PSID_AND_ATTRIBUTES;
]]
