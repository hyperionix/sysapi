setfenv(1, require "sysapi-ns")
local bor = bit.bor

-- Process Security and Access Rights
-- https://docs.microsoft.com/ru-ru/windows/desktop/ProcThread/process-security-and-access-rights
StringifyTableStart("PROCESS_ACCESS", "PROCESS_")
PROCESS_TERMINATE = 0x0001
PROCESS_CREATE_THREAD = 0x0002
PROCESS_SET_SESSIONID = 0x0004
PROCESS_VM_OPERATION = 0x0008
PROCESS_VM_READ = 0x0010
PROCESS_VM_WRITE = 0x0020
PROCESS_DUP_HANDLE = 0x0040
PROCESS_CREATE_PROCESS = 0x0080
PROCESS_SET_QUOTA = 0x0100
PROCESS_SET_INFORMATION = 0x0200
PROCESS_QUERY_INFORMATION = 0x0400
PROCESS_SUSPEND_RESUME = 0x0800
PROCESS_QUERY_LIMITED_INFORMATION = 0x1000
PROCESS_SET_LIMITED_INFORMATION = 0x2000
PROCESS_ALL_ACCESS = bor(STANDARD_RIGHTS_REQUIRED, SYNCHRONIZE, 0xFFFF)
StringifyTableEnd()

TH32CS_SNAPHEAPLIST = 0x00000001
TH32CS_SNAPPROCESS = 0x00000002
TH32CS_SNAPTHREAD = 0x00000004
TH32CS_SNAPMODULE = 0x00000008
TH32CS_SNAPMODULE32 = 0x00000010
TH32CS_SNAPALL = bor(TH32CS_SNAPHEAPLIST, TH32CS_SNAPPROCESS, TH32CS_SNAPTHREAD, TH32CS_SNAPMODULE)
TH32CS_INHERIT = 0x80000000

ffi.cdef [[
  typedef struct _STARTUPINFOA {
    DWORD  cb;
    LPSTR  lpReserved;
    LPSTR  lpDesktop;
    LPSTR  lpTitle;
    DWORD  dwX;
    DWORD  dwY;
    DWORD  dwXSize;
    DWORD  dwYSize;
    DWORD  dwXCountChars;
    DWORD  dwYCountChars;
    DWORD  dwFillAttribute;
    DWORD  dwFlags;
    WORD   wShowWindow;
    WORD   cbReserved2;
    LPBYTE lpReserved2;
    HANDLE hStdInput;
    HANDLE hStdOutput;
    HANDLE hStdError;
  } STARTUPINFOA, *LPSTARTUPINFOA;

  typedef struct _PROCESS_INFORMATION {
    HANDLE hProcess;
    HANDLE hThread;
    DWORD  dwProcessId;
    DWORD  dwThreadId;
  } PROCESS_INFORMATION, *PPROCESS_INFORMATION, *LPPROCESS_INFORMATION;  

  typedef struct _KERNEL_USER_TIMES {
      LARGE_INTEGER CreateTime;
      LARGE_INTEGER ExitTime;
      LARGE_INTEGER KernelTime;
      LARGE_INTEGER UserTime;
  } KERNEL_USER_TIMES, *PKERNEL_USER_TIMES;

  typedef struct tagPROCESSENTRY32 {
    DWORD     dwSize;
    DWORD     cntUsage;
    DWORD     th32ProcessID;
    ULONG_PTR th32DefaultHeapID;
    DWORD     th32ModuleID;
    DWORD     cntThreads;
    DWORD     th32ParentProcessID;
    LONG      pcPriClassBase;
    DWORD     dwFlags;
    CHAR      szExeFile[260];
  } PROCESSENTRY32, *PPROCESSENTRY32;

  typedef PROCESSENTRY32 *LPPROCESSENTRY32;

  typedef enum _PROCESS_MITIGATION_POLICY {
    ProcessDEPPolicy,
    ProcessASLRPolicy,
    ProcessDynamicCodePolicy,
    ProcessStrictHandleCheckPolicy,
    ProcessSystemCallDisablePolicy,
    ProcessMitigationOptionsMask,
    ProcessExtensionPointDisablePolicy,
    ProcessReserved1Policy,
    ProcessSignaturePolicy,
    MaxProcessMitigationPolicy
  } PROCESS_MITIGATION_POLICY, *PPROCESS_MITIGATION_POLICY;

  typedef struct _PROCESS_MITIGATION_DEP_POLICY {
    union {
      DWORD Flags;
      struct {
        DWORD Enable : 1;
        DWORD DisableAtlThunkEmulation : 1;
        DWORD ReservedFlags : 30;
      } DUMMYSTRUCTNAME;
    } DUMMYUNIONNAME;
    BOOLEAN Permanent;
  } PROCESS_MITIGATION_DEP_POLICY, *PPROCESS_MITIGATION_DEP_POLICY;

  typedef struct _PROCESS_MITIGATION_ASLR_POLICY {
      union {
        DWORD Flags;
        struct {
          DWORD EnableBottomUpRandomization : 1;
          DWORD EnableForceRelocateImages : 1;
          DWORD EnableHighEntropy : 1;
          DWORD DisallowStrippedImages : 1;
          DWORD ReservedFlags : 28;
        } DUMMYSTRUCTNAME;
      } DUMMYUNIONNAME;
  } PROCESS_MITIGATION_ASLR_POLICY, *PPROCESS_MITIGATION_ASLR_POLICY;

  typedef struct _PROCESS_MITIGATION_DYNAMIC_CODE_POLICY {
      union {
        DWORD Flags;
        struct {
          DWORD ProhibitDynamicCode : 1;
          DWORD AllowThreadOptOut : 1;
          DWORD AllowRemoteDowngrade : 1;
          DWORD AuditProhibitDynamicCode : 1;
          DWORD ReservedFlags : 28;
        } DUMMYSTRUCTNAME;
      } DUMMYUNIONNAME;
  } PROCESS_MITIGATION_DYNAMIC_CODE_POLICY, *PPROCESS_MITIGATION_DYNAMIC_CODE_POLICY;

  typedef struct _PROCESS_MITIGATION_BINARY_SIGNATURE_POLICY {
      union {
        DWORD Flags;
        struct {
          DWORD MicrosoftSignedOnly : 1;
          DWORD StoreSignedOnly : 1;
          DWORD MitigationOptIn : 1;
          DWORD AuditMicrosoftSignedOnly : 1;
          DWORD AuditStoreSignedOnly : 1;
          DWORD ReservedFlags : 27;
        } DUMMYSTRUCTNAME;
      } DUMMYUNIONNAME;
  } PROCESS_MITIGATION_BINARY_SIGNATURE_POLICY, *PPROCESS_MITIGATION_BINARY_SIGNATURE_POLICY;

  typedef enum _PROCESSINFOCLASS {
    ProcessBasicInformation, // q: PROCESS_BASIC_INFORMATION, PROCESS_EXTENDED_BASIC_INFORMATION
    ProcessQuotaLimits, // qs: QUOTA_LIMITS, QUOTA_LIMITS_EX
    ProcessIoCounters, // q: IO_COUNTERS
    ProcessVmCounters, // q: VM_COUNTERS, VM_COUNTERS_EX, VM_COUNTERS_EX2
    ProcessTimes, // q: KERNEL_USER_TIMES
    ProcessBasePriority, // s: KPRIORITY
    ProcessRaisePriority, // s: ULONG
    ProcessDebugPort, // q: HANDLE
    ProcessExceptionPort, // s: PROCESS_EXCEPTION_PORT
    ProcessAccessToken, // s: PROCESS_ACCESS_TOKEN
    ProcessLdtInformation, // qs: PROCESS_LDT_INFORMATION // 10
    ProcessLdtSize, // s: PROCESS_LDT_SIZE
    ProcessDefaultHardErrorMode, // qs: ULONG
    ProcessIoPortHandlers, // (kernel-mode only)
    ProcessPooledUsageAndLimits, // q: POOLED_USAGE_AND_LIMITS
    ProcessWorkingSetWatch, // q: PROCESS_WS_WATCH_INFORMATION[]; s: void
    ProcessUserModeIOPL,
    ProcessEnableAlignmentFaultFixup, // s: BOOLEAN
    ProcessPriorityClass, // qs: PROCESS_PRIORITY_CLASS
    ProcessWx86Information,
    ProcessHandleCount, // q: ULONG, PROCESS_HANDLE_INFORMATION // 20
    ProcessAffinityMask, // s: KAFFINITY
    ProcessPriorityBoost, // qs: ULONG
    ProcessDeviceMap, // qs: PROCESS_DEVICEMAP_INFORMATION, PROCESS_DEVICEMAP_INFORMATION_EX
    ProcessSessionInformation, // q: PROCESS_SESSION_INFORMATION
    ProcessForegroundInformation, // s: PROCESS_FOREGROUND_BACKGROUND
    ProcessWow64Information, // q: ULONG_PTR
    ProcessImageFileName, // q: UNICODE_STRING
    ProcessLUIDDeviceMapsEnabled, // q: ULONG
    ProcessBreakOnTermination, // qs: ULONG
    ProcessDebugObjectHandle, // q: HANDLE // 30
    ProcessDebugFlags, // qs: ULONG
    ProcessHandleTracing, // q: PROCESS_HANDLE_TRACING_QUERY; s: size 0 disables, otherwise enables
    ProcessIoPriority, // qs: IO_PRIORITY_HINT
    ProcessExecuteFlags, // qs: ULONG
    ProcessResourceManagement, // ProcessTlsInformation // PROCESS_TLS_INFORMATION
    ProcessCookie, // q: ULONG
    ProcessImageInformation, // q: SECTION_IMAGE_INFORMATION
    ProcessCycleTime, // q: PROCESS_CYCLE_TIME_INFORMATION // since VISTA
    ProcessPagePriority, // q: PAGE_PRIORITY_INFORMATION
    ProcessInstrumentationCallback, // qs: PROCESS_INSTRUMENTATION_CALLBACK_INFORMATION // 40
    ProcessThreadStackAllocation, // s: PROCESS_STACK_ALLOCATION_INFORMATION, PROCESS_STACK_ALLOCATION_INFORMATION_EX
    ProcessWorkingSetWatchEx, // q: PROCESS_WS_WATCH_INFORMATION_EX[]
    ProcessImageFileNameWin32, // q: UNICODE_STRING
    ProcessImageFileMapping, // q: HANDLE (input)
    ProcessAffinityUpdateMode, // qs: PROCESS_AFFINITY_UPDATE_MODE
    ProcessMemoryAllocationMode, // qs: PROCESS_MEMORY_ALLOCATION_MODE
    ProcessGroupInformation, // q: USHORT[]
    ProcessTokenVirtualizationEnabled, // s: ULONG
    ProcessConsoleHostProcess, // q: ULONG_PTR // ProcessOwnerInformation
    ProcessWindowInformation, // q: PROCESS_WINDOW_INFORMATION // 50
    ProcessHandleInformation, // q: PROCESS_HANDLE_SNAPSHOT_INFORMATION // since WIN8
    ProcessMitigationPolicy, // s: PROCESS_MITIGATION_POLICY_INFORMATION
    ProcessDynamicFunctionTableInformation,
    ProcessHandleCheckingMode, // qs: ULONG; s: 0 disables, otherwise enables
    ProcessKeepAliveCount, // q: PROCESS_KEEPALIVE_COUNT_INFORMATION
    ProcessRevokeFileHandles, // s: PROCESS_REVOKE_FILE_HANDLES_INFORMATION
    ProcessWorkingSetControl, // s: PROCESS_WORKING_SET_CONTROL
    ProcessHandleTable, // since WINBLUE
    ProcessCheckStackExtentsMode,
    ProcessCommandLineInformation, // q: UNICODE_STRING // 60
    ProcessProtectionInformation, // q: PS_PROTECTION
    ProcessMemoryExhaustion, // PROCESS_MEMORY_EXHAUSTION_INFO // since THRESHOLD
    ProcessFaultInformation, // PROCESS_FAULT_INFORMATION
    ProcessTelemetryIdInformation, // PROCESS_TELEMETRY_ID_INFORMATION
    ProcessCommitReleaseInformation, // PROCESS_COMMIT_RELEASE_INFORMATION
    ProcessDefaultCpuSetsInformation,
    ProcessAllowedCpuSetsInformation,
    ProcessSubsystemProcess,
    ProcessJobMemoryInformation, // PROCESS_JOB_MEMORY_INFO
    ProcessInPrivate, // since THRESHOLD2 // 70
    ProcessRaiseUMExceptionOnInvalidHandleClose,
    ProcessIumChallengeResponse,
    ProcessChildProcessInformation, // PROCESS_CHILD_PROCESS_INFORMATION
    ProcessHighGraphicsPriorityInformation,
    ProcessSubsystemInformation, // q: SUBSYSTEM_INFORMATION_TYPE // since REDSTONE2
    ProcessEnergyValues, // PROCESS_ENERGY_VALUES, PROCESS_EXTENDED_ENERGY_VALUES
    ProcessActivityThrottleState, // PROCESS_ACTIVITY_THROTTLE_STATE
    ProcessActivityThrottlePolicy, // PROCESS_ACTIVITY_THROTTLE_POLICY
    ProcessWin32kSyscallFilterInformation,
    ProcessDisableSystemAllowedCpuSets, // 80
    ProcessWakeInformation, // PROCESS_WAKE_INFORMATION
    ProcessEnergyTrackingState, // PROCESS_ENERGY_TRACKING_STATE
    ProcessManageWritesToExecutableMemory, // MANAGE_WRITES_TO_EXECUTABLE_MEMORY // since REDSTONE3
    ProcessCaptureTrustletLiveDump,
    ProcessTelemetryCoverage,
    ProcessEnclaveInformation,
    ProcessEnableReadWriteVmLogging, // PROCESS_READWRITEVM_LOGGING_INFORMATION
    ProcessUptimeInformation, // PROCESS_UPTIME_INFORMATION
    ProcessImageSection,
    ProcessDebugAuthInformation, // since REDSTONE4 // 90
    ProcessSystemResourceManagement, // PROCESS_SYSTEM_RESOURCE_MANAGEMENT
    ProcessSequenceNumber, // q: ULONGLONG
    ProcessLoaderDetour, // since REDSTONE5
    ProcessSecurityDomainInformation, // PROCESS_SECURITY_DOMAIN_INFORMATION
    ProcessCombineSecurityDomainsInformation, // PROCESS_COMBINE_SECURITY_DOMAINS_INFORMATION
    ProcessEnableLogging, // PROCESS_LOGGING_INFORMATION
    ProcessLeapSecondInformation, // PROCESS_LEAP_SECOND_INFORMATION
    MaxProcessInfoClass
  } PROCESSINFOCLASS;

  typedef struct _PROCESS_BASIC_INFORMATION {
    NTSTATUS ExitStatus;
    PVOID PebBaseAddress;
    ULONG_PTR AffinityMask;
    KPRIORITY BasePriority;
    HANDLE UniqueProcessId;
    HANDLE InheritedFromUniqueProcessId;
  } PROCESS_BASIC_INFORMATION, *PPROCESS_BASIC_INFORMATION;

  typedef struct _PROCESS_EXTENDED_BASIC_INFORMATION {
      SIZE_T Size; // set to sizeof structure on input
      PROCESS_BASIC_INFORMATION BasicInfo;
      union
      {
          ULONG Flags;
          struct
          {
              ULONG IsProtectedProcess : 1;
              ULONG IsWow64Process : 1;
              ULONG IsProcessDeleting : 1;
              ULONG IsCrossSessionCreate : 1;
              ULONG IsFrozen : 1;
              ULONG IsBackground : 1;
              ULONG IsStronglyNamed : 1;
              ULONG IsSecureProcess : 1;
              ULONG IsSubsystemProcess : 1;
              ULONG SpareBits : 23;
          };
      };
  } PROCESS_EXTENDED_BASIC_INFORMATION, *PPROCESS_EXTENDED_BASIC_INFORMATION;

  typedef struct _RTL_USER_PROCESS_PARAMETERS {
    ULONG MaximumLength;
    ULONG Length;

    ULONG Flags;
    ULONG DebugFlags;

    HANDLE ConsoleHandle;
    ULONG ConsoleFlags;
    HANDLE StandardInput;
    HANDLE StandardOutput;
    HANDLE StandardError;

    CURDIR CurrentDirectory;
    UNICODE_STRING DllPath;
    UNICODE_STRING ImagePathName;
    UNICODE_STRING CommandLine;
    PVOID Environment;

    ULONG StartingX;
    ULONG StartingY;
    ULONG CountX;
    ULONG CountY;
    ULONG CountCharsX;
    ULONG CountCharsY;
    ULONG FillAttribute;

    ULONG WindowFlags;
    ULONG ShowWindowFlags;
    UNICODE_STRING WindowTitle;
    UNICODE_STRING DesktopInfo;
    UNICODE_STRING ShellInfo;
    UNICODE_STRING RuntimeData;
    RTL_DRIVE_LETTER_CURDIR CurrentDirectories[32];

    ULONG_PTR EnvironmentSize;
    ULONG_PTR EnvironmentVersion;
    PVOID PackageDependencyData;
    ULONG ProcessGroupId;
    ULONG LoaderThreads;

    UNICODE_STRING RedirectionDllName; 
    UNICODE_STRING HeapPartitionName;
    ULONG_PTR DefaultThreadpoolCpuSetMasks;
    ULONG DefaultThreadpoolCpuSetMaskCount;
  } RTL_USER_PROCESS_PARAMETERS, *PRTL_USER_PROCESS_PARAMETERS;

  typedef enum _PS_CREATE_STATE {
      PsCreateInitialState,
      PsCreateFailOnFileOpen,
      PsCreateFailOnSectionCreate,
      PsCreateFailExeFormat,
      PsCreateFailMachineMismatch,
      PsCreateFailExeName, // Debugger specified
      PsCreateSuccess,
      PsCreateMaximumStates
  } PS_CREATE_STATE;
  
  typedef struct _PS_CREATE_INFO {
      SIZE_T Size;
      PS_CREATE_STATE State;
      union
      {
          // PsCreateInitialState
          struct
          {
              union
              {
                  ULONG InitFlags;
                  struct
                  {
                      UCHAR WriteOutputOnExit : 1;
                      UCHAR DetectManifest : 1;
                      UCHAR IFEOSkipDebugger : 1;
                      UCHAR IFEODoNotPropagateKeyState : 1;
                      UCHAR SpareBits1 : 4;
                      UCHAR SpareBits2 : 8;
                      USHORT ProhibitedImageCharacteristics : 16;
                  };
              };
              ACCESS_MASK AdditionalFileAccess;
          } InitState;
  
          // PsCreateFailOnSectionCreate
          struct
          {
              HANDLE FileHandle;
          } FailSection;
  
          // PsCreateFailExeFormat
          struct
          {
              USHORT DllCharacteristics;
          } ExeFormat;
  
          // PsCreateFailExeName
          struct
          {
              HANDLE IFEOKey;
          } ExeName;
  
          // PsCreateSuccess
          struct
          {
              union
              {
                  ULONG OutputFlags;
                  struct
                  {
                      UCHAR ProtectedProcess : 1;
                      UCHAR AddressSpaceOverride : 1;
                      UCHAR DevOverrideEnabled : 1; // from Image File Execution Options
                      UCHAR ManifestDetected : 1;
                      UCHAR ProtectedProcessLight : 1;
                      UCHAR SpareBits1 : 3;
                      UCHAR SpareBits2 : 8;
                      USHORT SpareBits3 : 16;
                  };
              };
              HANDLE FileHandle;
              HANDLE SectionHandle;
              ULONGLONG UserProcessParametersNative;
              ULONG UserProcessParametersWow64;
              ULONG CurrentParameterFlags;
              ULONGLONG PebAddressNative;
              ULONG PebAddressWow64;
              ULONGLONG ManifestAddress;
              ULONG ManifestSize;
          } SuccessState;
      };
 } PS_CREATE_INFO, *PPS_CREATE_INFO;
]]

ffi.cdef [[
  BOOL CreateProcessA(
    LPCSTR                lpApplicationName,
    LPCSTR                 lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes,
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    BOOL                  bInheritHandles,
    DWORD                 dwCreationFlags,
    LPVOID                lpEnvironment,
    LPCSTR                lpCurrentDirectory,
    LPSTARTUPINFOA        lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation
  );

  HANDLE OpenProcess(
    DWORD dwDesiredAccess,
    BOOL  bInheritHandle,
    DWORD dwProcessId
  );

  BOOL TerminateProcess(
    HANDLE hProcess,
    UINT   uExitCode
  );

  BOOL QueryFullProcessImageNameA(
    HANDLE hProcess,
    DWORD  dwFlags,
    LPSTR  lpExeName,
    PDWORD lpdwSize
  );

  HANDLE CreateToolhelp32Snapshot(
      DWORD dwFlags,
      DWORD th32ProcessID
  );

  BOOL Process32First(
      HANDLE           hSnapshot,
      LPPROCESSENTRY32 lppe
  );

  BOOL Process32Next(
      HANDLE           hSnapshot,
      LPPROCESSENTRY32 lppe
  );


  BOOL GetProcessMitigationPolicy(
      HANDLE                    hProcess,
      PROCESS_MITIGATION_POLICY MitigationPolicy,
      PVOID                     lpBuffer,
      SIZE_T                    dwLength
  );

  HANDLE GetCurrentProcess();
  DWORD GetCurrentProcessId();
  DWORD GetProcessId(HANDLE Process);

  NTSTATUS
  NtQueryInformationProcess(
      HANDLE ProcessHandle,
      PROCESSINFOCLASS ProcessInformationClass,
      PVOID ProcessInformation,
      ULONG ProcessInformationLength,
      PULONG ReturnLength
  );
]]
