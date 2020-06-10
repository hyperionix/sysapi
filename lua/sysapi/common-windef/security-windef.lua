setfenv(1, require "sysapi-ns")

ffi.cdef [[
  typedef WORD SECURITY_DESCRIPTOR_CONTROL, *PSECURITY_DESCRIPTOR_CONTROL;

  typedef struct _ACL {
    BYTE AclRevision;
    BYTE Sbz1;
    WORD AclSize;
    WORD AceCount;
    WORD Sbz2;
  } ACL, *PACL;

  typedef struct _SECURITY_DESCRIPTOR {
    BYTE                        Revision;
    BYTE                        Sbz1;
    SECURITY_DESCRIPTOR_CONTROL Control;
    PSID                        Owner;
    PSID                        Group;
    PACL                        Sacl;
    PACL                        Dacl;
  } SECURITY_DESCRIPTOR, *PSECURITY_DESCRIPTOR;
]]
