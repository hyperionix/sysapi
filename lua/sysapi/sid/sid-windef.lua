setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef enum _SID_NAME_USE {
    SidTypeUser = 1,
    SidTypeGroup,
    SidTypeDomain,
    SidTypeAlias,
    SidTypeWellKnownGroup,
    SidTypeDeletedAccount,
    SidTypeInvalid,
    SidTypeUnknown,
    SidTypeComputer,
    SidTypeLabel
  } SID_NAME_USE, *PSID_NAME_USE;
]]

ffi.cdef [[
  PULONG RtlSubAuthoritySid(
    PSID  Sid,
    ULONG SubAuthority
  );

  BOOLEAN RtlValidSid(
      PSID Sid
  );

  ULONG RtlLengthSid(
      PSID Sid
  );

  uint32_t RtlCopySid(
      ULONG DestinationSidLength,
      PSID  DestinationSid,
      PSID  SourceSid
  );

  uint32_t RtlConvertSidToUnicodeString(
      PUNICODE_STRING UnicodeString,
      PSID            Sid,
      BOOLEAN         AllocateDestinationString
  );

  BOOL LookupAccountSidA(
      LPCSTR        lpSystemName,
      PSID          Sid,
      LPSTR         Name,
      LPDWORD       cchName,
      LPSTR         ReferencedDomainName,
      LPDWORD       cchReferencedDomainName,
      PSID_NAME_USE peUse
  );
]]
