setfenv(1, require "sysapi-ns")
local bor = bit.bor

-- Creation Disposition
CREATE_NEW = 1
CREATE_ALWAYS = 2
OPEN_EXISTING = 3
OPEN_ALWAYS = 4
TRUNCATE_EXISTING = 5

-- Access rights to files and directories
-- https://docs.microsoft.com/ru-ru/windows/desktop/FileIO/file-access-rights-constants

FILE_READ_DATA = 0x0001 -- file & pipe
FILE_LIST_DIRECTORY = 0x0001 -- directory

FILE_WRITE_DATA = 0x0002 -- file & pipe
FILE_ADD_FILE = 0x0002 -- directory

FILE_APPEND_DATA = 0x0004 -- file
FILE_ADD_SUBDIRECTORY = 0x0004 -- directory
FILE_CREATE_PIPE_INSTANCE = 0x0004 -- named pipe

FILE_READ_EA = 0x0008 -- file & directory
FILE_WRITE_EA = 0x0010 -- file & directory

FILE_EXECUTE = 0x0020 -- file
FILE_TRAVERSE = 0x0020 -- directory

FILE_DELETE_CHILD = 0x0040 -- directory

FILE_READ_ATTRIBUTES = 0x0080 -- all
FILE_WRITE_ATTRIBUTES = 0x0100 -- all

FILE_ALL_ACCESS = bor(STANDARD_RIGHTS_REQUIRED, SYNCHRONIZE, 0x1FF)

FILE_GENERIC_READ = bor(STANDARD_RIGHTS_READ, FILE_READ_DATA, FILE_READ_ATTRIBUTES, FILE_READ_EA, SYNCHRONIZE)

FILE_GENERIC_WRITE =
  bor(STANDARD_RIGHTS_WRITE, FILE_WRITE_DATA, FILE_WRITE_ATTRIBUTES, FILE_WRITE_EA, FILE_APPEND_DATA, SYNCHRONIZE)

FILE_GENERIC_EXECUTE = bor(STANDARD_RIGHTS_EXECUTE, FILE_READ_ATTRIBUTES, FILE_EXECUTE, SYNCHRONIZE)

-- Sharing mode of the file or device

FILE_SHARE_READ = 0x00000001
FILE_SHARE_WRITE = 0x00000002
FILE_SHARE_DELETE = 0x00000004
FILE_SHARE_ALL = bor(FILE_SHARE_READ, FILE_SHARE_WRITE, FILE_SHARE_DELETE)

-- The file or device attributes
StringifyTableStart("FILE_ATTRIBUTE", "FILE_ATTRIBUTE_")
FILE_ATTRIBUTE_READONLY = 0x00000001
FILE_ATTRIBUTE_HIDDEN = 0x00000002
FILE_ATTRIBUTE_SYSTEM = 0x00000004
FILE_ATTRIBUTE_DIRECTORY = 0x00000010
FILE_ATTRIBUTE_ARCHIVE = 0x00000020
FILE_ATTRIBUTE_DEVICE = 0x00000040
FILE_ATTRIBUTE_NORMAL = 0x00000080
FILE_ATTRIBUTE_TEMPORARY = 0x00000100
FILE_ATTRIBUTE_SPARSE_FILE = 0x00000200
FILE_ATTRIBUTE_REPARSE_POINT = 0x00000400
FILE_ATTRIBUTE_COMPRESSED = 0x00000800
FILE_ATTRIBUTE_OFFLINE = 0x00001000
FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 0x00002000
FILE_ATTRIBUTE_ENCRYPTED = 0x00004000
FILE_ATTRIBUTE_VIRTUAL = 0x00010000
StringifyTableEnd()

-- The file or device flags

FILE_FLAG_WRITE_THROUGH = 0x80000000
FILE_FLAG_OVERLAPPED = 0x40000000
FILE_FLAG_NO_BUFFERING = 0x20000000
FILE_FLAG_RANDOM_ACCESS = 0x10000000
FILE_FLAG_SEQUENTIAL_SCAN = 0x08000000
FILE_FLAG_DELETE_ON_CLOSE = 0x04000000
FILE_FLAG_BACKUP_SEMANTICS = 0x02000000
FILE_FLAG_POSIX_SEMANTICS = 0x01000000
FILE_FLAG_SESSION_AWARE = 0x00800000
FILE_FLAG_OPEN_REPARSE_POINT = 0x00200000
FILE_FLAG_OPEN_NO_RECALL = 0x00100000
FILE_FLAG_FIRST_PIPE_INSTANCE = 0x00080000

-- Flags that specifies what action(s) the system should take with a specific file while deleting.

FILE_DISPOSITION_DO_NOT_DELETE = 0x00000000
FILE_DISPOSITION_DELETE = 0x00000001
FILE_DISPOSITION_POSIX_SEMANTICS = 0x00000002
FILE_DISPOSITION_FORCE_IMAGE_SECTION_CHECK = 0x00000004
FILE_DISPOSITION_ON_CLOSE = 0x00000008
FILE_DISPOSITION_IGNORE_READONLY_ATTRIBUTE = 0x00000010

-- https://docs.microsoft.com/ru-ru/windows/win32/api/fileapi/nf-fileapi-getfinalpathnamebyhandlea?redirectedfrom=MSDN
VOLUME_NAME_DOS = 0x0
VOLUME_NAME_GUID = 0x1
VOLUME_NAME_NT = 0x2
VOLUME_NAME_NONE = 0x4

FILE_NAME_NORMALIZED = 0x0
FILE_NAME_OPENED = 0x8

INVALID_HANDLE_VALUE = ffi.cast("HANDLE", -1)

-- https://docs.microsoft.com/ru-ru/windows-hardware/drivers/ddi/ntddk/ns-ntddk-_file_disposition_information_ex
FILE_DISPOSITION_DO_NOT_DELETE = 0x00000000
FILE_DISPOSITION_DELETE = 0x00000001
FILE_DISPOSITION_POSIX_SEMANTICS = 0x00000002
FILE_DISPOSITION_FORCE_IMAGE_SECTION_CHECK = 0x00000004
FILE_DISPOSITION_ON_CLOSE = 0x00000008
FILE_DISPOSITION_IGNORE_READONLY_ATTRIBUTE = 0x00000010

ffi.cdef [[
  typedef enum _FILE_INFORMATION_CLASS {
    FileDirectoryInformation = 1,
    FileFullDirectoryInformation,
    FileBothDirectoryInformation,
    FileBasicInformation,
    FileStandardInformation,
    FileInternalInformation,
    FileEaInformation,
    FileAccessInformation,
    FileNameInformation,
    FileRenameInformation,
    FileLinkInformation,
    FileNamesInformation,
    FileDispositionInformation,
    FilePositionInformation,
    FileFullEaInformation,
    FileModeInformation,
    FileAlignmentInformation,
    FileAllInformation,
    FileAllocationInformation,
    FileEndOfFileInformation,
    FileAlternateNameInformation,
    FileStreamInformation,
    FilePipeInformation,
    FilePipeLocalInformation,
    FilePipeRemoteInformation,
    FileMailslotQueryInformation,
    FileMailslotSetInformation,
    FileCompressionInformation,
    FileObjectIdInformation,
    FileCompletionInformation,
    FileMoveClusterInformation,
    FileQuotaInformation,
    FileReparsePointInformation,
    FileNetworkOpenInformation,
    FileAttributeTagInformation,
    FileTrackingInformation,
    FileIdBothDirectoryInformation,
    FileIdFullDirectoryInformation,
    FileValidDataLengthInformation,
    FileShortNameInformation,
    FileIoCompletionNotificationInformation,
    FileIoStatusBlockRangeInformation,
    FileIoPriorityHintInformation,
    FileSfioReserveInformation,
    FileSfioVolumeInformation,
    FileHardLinkInformation,
    FileProcessIdsUsingFileInformation,
    FileNormalizedNameInformation,
    FileNetworkPhysicalNameInformation,
    FileIdGlobalTxDirectoryInformation,
    FileIsRemoteDeviceInformation,
    FileUnusedInformation,
    FileNumaNodeInformation,
    FileStandardLinkInformation,
    FileRemoteProtocolInformation,
    FileRenameInformationBypassAccessCheck,
    FileLinkInformationBypassAccessCheck,
    FileVolumeNameInformation,
    FileIdInformation,
    FileIdExtdDirectoryInformation,
    FileReplaceCompletionInformation,
    FileHardLinkFullIdInformation,
    FileIdExtdBothDirectoryInformation,
    FileDispositionInformationEx,
    FileRenameInformationEx,
    FileRenameInformationExBypassAccessCheck,
    FileDesiredStorageClassInformation,
    FileStatInformation,
    FileMemoryPartitionInformation,
    FileStatLxInformation,
    FileCaseSensitiveInformation,
    FileLinkInformationEx,
    FileLinkInformationExBypassAccessCheck,
    FileStorageReserveIdInformation,
    FileCaseSensitiveInformationForceAccessCheck,
    FileMaximumInformation
  } FILE_INFORMATION_CLASS;

  typedef struct _FILE_STANDARD_INFORMATION {
    LARGE_INTEGER AllocationSize;
    LARGE_INTEGER EndOfFile;
    ULONG         NumberOfLinks;
    BOOLEAN       DeletePending;
    BOOLEAN       Directory;
  } FILE_STANDARD_INFORMATION, *PFILE_STANDARD_INFORMATION;

  typedef struct _FILE_BASIC_INFORMATION {
      LARGE_INTEGER CreationTime;
      LARGE_INTEGER LastAccessTime;
      LARGE_INTEGER LastWriteTime;
      LARGE_INTEGER ChangeTime;
      ULONG         FileAttributes;
  } FILE_BASIC_INFORMATION, *PFILE_BASIC_INFORMATION;

  typedef struct _FILE_NAME_INFORMATION {
      ULONG FileNameLength;
      WCHAR FileName[1];
  } FILE_NAME_INFORMATION, *PFILE_NAME_INFORMATION;

  typedef struct _IO_STATUS_BLOCK {
    union {
      NTSTATUS Status;
      PVOID    Pointer;
    } DUMMYUNIONNAME;
    ULONG_PTR Information;
  } IO_STATUS_BLOCK, *PIO_STATUS_BLOCK;

  typedef VOID(*PIO_APC_ROUTINE)(PVOID ApcContext, PIO_STATUS_BLOCK IoStatusBlock, ULONG Reserved);

  typedef struct _OVERLAPPED {
    ULONG_PTR Internal;
    ULONG_PTR InternalHigh;
    union {
      struct {
        DWORD Offset;
        DWORD OffsetHigh;
      };
      PVOID Pointer;
    };
    HANDLE hEvent;
  } OVERLAPPED, *LPOVERLAPPED;

  typedef struct tagVS_FIXEDFILEINFO {
    DWORD   dwSignature;
    DWORD   dwStrucVersion;
    DWORD   dwFileVersionMS;
    DWORD   dwFileVersionLS;
    DWORD   dwProductVersionMS;
    DWORD   dwProductVersionLS;
    DWORD   dwFileFlagsMask;
    DWORD   dwFileFlags;
    DWORD   dwFileOS;
    DWORD   dwFileType;
    DWORD   dwFileSubtype;
    DWORD   dwFileDateMS;
    DWORD   dwFileDateLS;
  } VS_FIXEDFILEINFO;

  typedef struct _FILE_DISPOSITION_INFORMATION_EX {
    ULONG Flags;
  } FILE_DISPOSITION_INFORMATION_EX, *PFILE_DISPOSITION_INFORMATION_EX;
]]

ffi.cdef [[
  HANDLE CreateFileA(
    LPCSTR                lpFileName,
    DWORD                 dwDesiredAccess,
    DWORD                 dwShareMode,
    LPSECURITY_ATTRIBUTES lpSecurityAttributes,
    DWORD                 dwCreationDisposition,
    DWORD                 dwFlagsAndAttributes,
    HANDLE                hTemplateFile
  );

  BOOL ReadFile(
    HANDLE       hFile,
    LPVOID       lpBuffer,
    DWORD        nNumberOfBytesToRead,
    LPDWORD      lpNumberOfBytesRead,
    LPOVERLAPPED lpOverlapped
  );

  BOOL GetFileSizeEx(
    HANDLE         hFile,
    PLARGE_INTEGER lpFileSize
  );

  DWORD GetFinalPathNameByHandleA(
    HANDLE hFile,
    LPSTR  lpszFilePath,
    DWORD  cchFilePath,
    DWORD  dwFlags
  );

  BOOL GetFileVersionInfoA(
    LPCSTR lptstrFilename,
    DWORD  dwHandle,
    DWORD  dwLen,
    LPVOID lpData
  );

  DWORD GetFileVersionInfoSizeA(
    LPCSTR  lptstrFilename,
    LPDWORD lpdwHandle
  );

  BOOL VerQueryValueA(
    LPCVOID pBlock,
    LPCSTR  lpSubBlock,
    LPVOID  *lplpBuffer,
    PUINT   puLen
  );

  NTSTATUS
  NtQueryInformationFile(
      HANDLE                 FileHandle,
      PIO_STATUS_BLOCK       IoStatusBlock,
      PVOID                  FileInformation,
      ULONG                  Length,
      FILE_INFORMATION_CLASS FileInformationClass
  );

  NTSTATUS NtSetInformationFile(
    HANDLE                 FileHandle,
    PIO_STATUS_BLOCK       IoStatusBlock,
    PVOID                  FileInformation,
    ULONG                  Length,
    FILE_INFORMATION_CLASS FileInformationClass
  );

  BOOL DeleteFileA(
    LPCSTR lpFileName
  );

]]
