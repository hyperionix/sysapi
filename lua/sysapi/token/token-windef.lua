setfenv(1, require "sysapi-ns")
local bor = bit.bor

-- Access Rights for Access-Token Objects
-- https://docs.microsoft.com/ru-ru/windows/desktop/SecAuthZ/access-rights-for-access-token-objects

TOKEN_ASSIGN_PRIMARY = 0x0001
TOKEN_DUPLICATE = 0x0002
TOKEN_IMPERSONATE = 0x0004
TOKEN_QUERY = 0x0008
TOKEN_QUERY_SOURCE = 0x0010
TOKEN_ADJUST_PRIVILEGES = 0x0020
TOKEN_ADJUST_GROUPS = 0x0040
TOKEN_ADJUST_DEFAULT = 0x0080
TOKEN_ADJUST_SESSIONID = 0x0100

TOKEN_ALL_ACCESS =
  bor(
  STANDARD_RIGHTS_REQUIRED,
  TOKEN_ASSIGN_PRIMARY,
  TOKEN_DUPLICATE,
  TOKEN_IMPERSONATE,
  TOKEN_QUERY,
  TOKEN_QUERY_SOURCE,
  TOKEN_ADJUST_PRIVILEGES,
  TOKEN_ADJUST_GROUPS,
  TOKEN_ADJUST_DEFAULT,
  TOKEN_ADJUST_SESSIONID
)
TOKEN_READ = bor(STANDARD_RIGHTS_READ, TOKEN_QUERY)
TOKEN_WRITE = bor(STANDARD_RIGHTS_WRITE, TOKEN_ADJUST_PRIVILEGES, TOKEN_ADJUST_GROUPS, TOKEN_ADJUST_DEFAULT)
TOKEN_EXECUTE = STANDARD_RIGHTS_EXECUTE

ffi.cdef [[
  typedef enum _TOKEN_INFORMATION_CLASS {
    TokenUser = 1,
    TokenGroups,
    TokenPrivileges,
    TokenOwner,
    TokenPrimaryGroup,
    TokenDefaultDacl,
    TokenSource,
    TokenType,
    TokenImpersonationLevel,
    TokenStatistics,
    TokenRestrictedSids,
    TokenSessionId,
    TokenGroupsAndPrivileges,
    TokenSessionReference,
    TokenSandBoxInert,
    TokenAuditPolicy,
    TokenOrigin,
    TokenElevationType,
    TokenLinkedToken,
    TokenElevation,
    TokenHasRestrictions,
    TokenAccessInformation,
    TokenVirtualizationAllowed,
    TokenVirtualizationEnabled,
    TokenIntegrityLevel,
    TokenUIAccess,
    TokenMandatoryPolicy,
    TokenLogonSid,
    TokenIsAppContainer,
    TokenCapabilities,
    TokenAppContainerSid,
    TokenAppContainerNumber,
    TokenUserClaimAttributes,
    TokenDeviceClaimAttributes,
    TokenRestrictedUserClaimAttributes,
    TokenRestrictedDeviceClaimAttributes,
    TokenDeviceGroups,
    TokenRestrictedDeviceGroups,
    TokenSecurityAttributes,
    TokenIsRestricted,
    MaxTokenInfoClass
  } TOKEN_INFORMATION_CLASS, *PTOKEN_INFORMATION_CLASS;

  typedef struct _TOKEN_MANDATORY_LABEL {
    SID_AND_ATTRIBUTES Label;
  } TOKEN_MANDATORY_LABEL, *PTOKEN_MANDATORY_LABEL;

  typedef struct _TOKEN_USER {
    SID_AND_ATTRIBUTES User;
  } TOKEN_USER, *PTOKEN_USER;
]]

ffi.cdef [[
  BOOL OpenProcessToken(
    HANDLE  ProcessHandle,
    DWORD   DesiredAccess,
    PHANDLE TokenHandle
  );

  NTSTATUS
  NtQueryInformationToken(
      HANDLE TokenHandle,
      TOKEN_INFORMATION_CLASS TokenInformationClass,
      PVOID TokenInformation,
      ULONG TokenInformationLength,
      PULONG ReturnLength
  );
]]
