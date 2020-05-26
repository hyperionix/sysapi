setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef enum _SYSTEM_INFORMATION_CLASS {
    SystemBasicInformation,
    SystemProcessorInformation,
    SystemPerformanceInformation,
    SystemTimeOfDayInformation,
    SystemPathInformation,
    SystemProcessInformation,
    SystemCallCountInformation,
    SystemDeviceInformation,
    SystemProcessorPerformanceInformation,
    SystemFlagsInformation,
    SystemCallTimeInformation,
    SystemModuleInformation,
    SystemLocksInformation,
    SystemStackTraceInformation,
    SystemPagedPoolInformation,
    SystemNonPagedPoolInformation,
    SystemHandleInformation,
    SystemObjectInformation,
    SystemPageFileInformation,
    SystemVdmInstemulInformation,
    SystemVdmBopInformation,
    SystemFileCacheInformation,
    SystemPoolTagInformation,
    SystemInterruptInformation,
    SystemDpcBehaviorInformation,
    SystemFullMemoryInformation,
    SystemLoadGdiDriverInformation,
    SystemUnloadGdiDriverInformation,
    SystemTimeAdjustmentInformation,
    SystemSummaryMemoryInformation,
    SystemMirrorMemoryInformation,
    SystemPerformanceTraceInformation,
    SystemObsolete0,
    SystemExceptionInformation,
    SystemCrashDumpStateInformation,
    SystemKernelDebuggerInformation,
    SystemContextSwitchInformation,
    SystemRegistryQuotaInformation,
    SystemExtendServiceTableInformation,
    SystemPrioritySeperation,
    SystemVerifierAddDriverInformation,
    SystemVerifierRemoveDriverInformation,
    SystemProcessorIdleInformation,
    SystemLegacyDriverInformation,
    SystemCurrentTimeZoneInformation,
    SystemLookasideInformation,
    SystemTimeSlipNotification,
    SystemSessionCreate,
    SystemSessionDetach,
    SystemSessionInformation,
    SystemRangeStartInformation,
    SystemVerifierInformation,
    SystemVerifierThunkExtend,
    SystemSessionProcessInformation,
    SystemLoadGdiDriverInSystemSpace,
    SystemNumaProcessorMap,
    SystemPrefetcherInformation,
    SystemExtendedProcessInformation,
    SystemRecommendedSharedDataAlignment,
    SystemComPlusPackage,
    SystemNumaAvailableMemory,
    SystemProcessorPowerInformation,
    SystemEmulationBasicInformation,
    SystemEmulationProcessorInformation,
    SystemExtendedHandleInformation,
    SystemLostDelayedWriteInformation,
    SystemBigPoolInformation,
    SystemSessionPoolTagInformation,
    SystemSessionMappedViewInformation,
    SystemHotpatchInformation,
    SystemObjectSecurityMode,
    SystemWatchdogTimerHandler,
    SystemWatchdogTimerInformation,
    SystemLogicalProcessorInformation,
    SystemWow64SharedInformationObsolete,
    SystemRegisterFirmwareTableInformationHandler,
    SystemFirmwareTableInformation,
    SystemModuleInformationEx,
    SystemVerifierTriageInformation,
    SystemSuperfetchInformation,
    SystemMemoryListInformation,
    SystemFileCacheInformationEx,
    SystemThreadPriorityClientIdInformation,
    SystemProcessorIdleCycleTimeInformation,
    SystemVerifierCancellationInformation,
    SystemProcessorPowerInformationEx,
    SystemRefTraceInformation,
    SystemSpecialPoolInformation,
    SystemProcessIdInformation,
    SystemErrorPortInformation,
    SystemBootEnvironmentInformation,
    SystemHypervisorInformation,
    SystemVerifierInformationEx,
    SystemTimeZoneInformation,
    SystemImageFileExecutionOptionsInformation,
    SystemCoverageInformation,
    SystemPrefetchPatchInformation,
    SystemVerifierFaultsInformation,
    SystemSystemPartitionInformation,
    SystemSystemDiskInformation,
    SystemProcessorPerformanceDistribution,
    SystemNumaProximityNodeInformation,
    SystemDynamicTimeZoneInformation,
    SystemCodeIntegrityInformation,
    SystemProcessorMicrocodeUpdateInformation,
    SystemProcessorBrandString,
    SystemVirtualAddressInformation,
    SystemLogicalProcessorAndGroupInformation,
    SystemProcessorCycleTimeInformation,
    SystemStoreInformation,
    SystemRegistryAppendString,
    SystemAitSamplingValue,
    SystemVhdBootInformation,
    SystemCpuQuotaInformation,
    SystemNativeBasicInformation,
    SystemSpare1,
    SystemLowPriorityIoInformation,
    SystemTpmBootEntropyInformation,
    SystemVerifierCountersInformation,
    SystemPagedPoolInformationEx,
    SystemSystemPtesInformationEx,
    SystemNodeDistanceInformation,
    SystemAcpiAuditInformation,
    SystemBasicPerformanceInformation,
    SystemQueryPerformanceCounterInformation,
    SystemSessionBigPoolInformation,
    SystemBootGraphicsInformation,
    SystemScrubPhysicalMemoryInformation,
    SystemBadPageInformation,
    SystemProcessorProfileControlArea,
    SystemCombinePhysicalMemoryInformation,
    SystemEntropyInterruptTimingCallback,
    SystemConsoleInformation,
    SystemPlatformBinaryInformation,
    SystemThrottleNotificationInformation,
    SystemHypervisorProcessorCountInformation,
    SystemDeviceDataInformation,
    SystemDeviceDataEnumerationInformation,
    SystemMemoryTopologyInformation,
    SystemMemoryChannelInformation,
    SystemBootLogoInformation,
    SystemProcessorPerformanceInformationEx,
    SystemSpare0,
    SystemSecureBootPolicyInformation,
    SystemPageFileInformationEx,
    SystemSecureBootInformation,
    SystemEntropyInterruptTimingRawInformation,
    SystemPortableWorkspaceEfiLauncherInformation,
    SystemFullProcessInformation,
    SystemKernelDebuggerInformationEx,
    SystemBootMetadataInformation,
    SystemSoftRebootInformation,
    SystemElamCertificateInformation,
    SystemOfflineDumpConfigInformation,
    SystemProcessorFeaturesInformation,
    SystemRegistryReconciliationInformation,
    SystemEdidInformation,
    SystemManufacturingInformation,
    SystemEnergyEstimationConfigInformation,
    SystemHypervisorDetailInformation,
    SystemProcessorCycleStatsInformation,
    SystemVmGenerationCountInformation,
    SystemTrustedPlatformModuleInformation,
    SystemKernelDebuggerFlags,
    SystemCodeIntegrityPolicyInformation,
    SystemIsolatedUserModeInformation,
    SystemHardwareSecurityTestInterfaceResultsInformation,
    SystemSingleModuleInformation,
    SystemAllowedCpuSetsInformation,
    SystemDmaProtectionInformation,
    SystemInterruptCpuSetsInformation,
    SystemSecureBootPolicyFullInformation,
    SystemCodeIntegrityPolicyFullInformation,
    SystemAffinitizedInterruptProcessorInformation,
    SystemRootSiloInformation,
    MaxSystemInfoClass
  } SYSTEM_INFORMATION_CLASS;

  typedef struct _VM_COUNTERS {
    SIZE_T PeakVirtualSize;
    SIZE_T VirtualSize;
    ULONG  PageFaultCount;
    SIZE_T PeakWorkingSetSize;
    SIZE_T WorkingSetSize;
    SIZE_T QuotaPeakPagedPoolUsage;
    SIZE_T QuotaPagedPoolUsage;
    SIZE_T QuotaPeakNonPagedPoolUsage;
    SIZE_T QuotaNonPagedPoolUsage;
    SIZE_T PagefileUsage;
    SIZE_T PeakPagefileUsage;
  } VM_COUNTERS, *PVM_COUNTERS;
  
  typedef struct _IO_COUNTERS {
    ULONGLONG ReadOperationCount;
    ULONGLONG WriteOperationCount;
    ULONGLONG OtherOperationCount;
    ULONGLONG ReadTransferCount;
    ULONGLONG WriteTransferCount;
    ULONGLONG OtherTransferCount;
  } IO_COUNTERS, *PIO_COUNTERS;
  
  typedef enum _KWAIT_REASON {
    Executive,
    FreePage,
    PageIn,
    PoolAllocation,
    DelayExecution,
    Suspended,
    UserRequest,
    WrExecutive,
    WrFreePage,
    WrPageIn,
    WrPoolAllocation,
    WrDelayExecution,
    WrSuspended,
    WrUserRequest,
    WrEventPair,
    WrQueue,
    WrLpcReceive,
    WrLpcReply,
    WrVirtualMemory,
    WrPageOut,
    WrRendezvous,
    Spare2,
    Spare3,
    Spare4,
    Spare5,
    WrCalloutStack,
    WrKernel,
    WrResource,
    WrPushLock,
    WrMutex,
    WrQuantumEnd,
    WrDispatchInt,
    WrPreempted,
    WrYieldExecution,
    WrFastMutex,
    WrGuardedMutex,
    WrRundown,
    MaximumWaitReason
  } KWAIT_REASON;

  typedef struct _CLIENT_ID {
    HANDLE UniqueProcess;
    HANDLE UniqueThread;
  } CLIENT_ID, *PCLIENT_ID;

  typedef struct _SYSTEM_THREAD {
    LARGE_INTEGER KernelTime;
    LARGE_INTEGER UserTime;
    LARGE_INTEGER CreateTime;
    ULONG         WaitTime;
    PVOID         StartAddress;
    CLIENT_ID     ClientId;
    KPRIORITY     Priority;
    LONG          BasePriority;
    ULONG         ContextSwitchCount;
    ULONG         State;
    KWAIT_REASON  WaitReason;
  } SYSTEM_THREAD, *PSYSTEM_THREAD;
  
  typedef struct _SYSTEM_PROCESS_INFORMATION {
    ULONG          NextEntryOffset;
    ULONG          NumberOfThreads;
    LARGE_INTEGER  Reserved[3];
    LARGE_INTEGER  CreateTime;
    LARGE_INTEGER  UserTime;
    LARGE_INTEGER  KernelTime;
    UNICODE_STRING ImageName;
    KPRIORITY      BasePriority;
    HANDLE         ProcessId;
    HANDLE         InheritedFromProcessId;
    ULONG          HandleCount;
    ULONG          Reserved2[2];
    ULONG          PrivatePageCount;
    VM_COUNTERS    VirtualMemoryCounters;
    IO_COUNTERS    IoCounters;
    SYSTEM_THREAD  Threads[0];
  } SYSTEM_PROCESS_INFORMATION, *PSYSTEM_PROCESS_INFORMATION;
]]
