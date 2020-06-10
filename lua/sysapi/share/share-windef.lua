setfenv(1, require "sysapi-ns")

STYPE_DISKTREE = 0
STYPE_PRINTQ = 1
STYPE_DEVICE = 2
STYPE_IPC = 3

STYPE_MASK = 0x000000FF

STYPE_TEMPORARY = 0x40000000
STYPE_SPECIAL = 0x80000000

ffi.cdef [[
  typedef struct _SHARE_INFO_0 {
    LMSTR shi0_netname;
  } SHARE_INFO_0, *PSHARE_INFO_0, *LPSHARE_INFO_0;

  typedef struct _SHARE_INFO_1 {
    LMSTR shi1_netname;
    DWORD shi1_type;
    LMSTR shi1_remark;
  } SHARE_INFO_1, *PSHARE_INFO_1, *LPSHARE_INFO_1;

  typedef struct _SHARE_INFO_2 {
    LMSTR shi2_netname;
    DWORD shi2_type;
    LMSTR shi2_remark;
    DWORD shi2_permissions;
    DWORD shi2_max_uses;
    DWORD shi2_current_uses;
    LMSTR shi2_path;
    LMSTR shi2_passwd;
  } SHARE_INFO_2, *PSHARE_INFO_2, *LPSHARE_INFO_2;

  typedef struct _SHARE_INFO_502 {
    LMSTR                shi502_netname;
    DWORD                shi502_type;
    LMSTR                shi502_remark;
    DWORD                shi502_permissions;
    DWORD                shi502_max_uses;
    DWORD                shi502_current_uses;
    LMSTR                shi502_path;
    LMSTR                shi502_passwd;
    DWORD                shi502_reserved;
    PSECURITY_DESCRIPTOR shi502_security_descriptor;
  } SHARE_INFO_502, *PSHARE_INFO_502, *LPSHARE_INFO_502;

  typedef struct _SHARE_INFO_503 {
    LMSTR                shi503_netname;
    DWORD                shi503_type;
    LMSTR                shi503_remark;
    DWORD                shi503_permissions;
    DWORD                shi503_max_uses;
    DWORD                shi503_current_uses;
    LMSTR                shi503_path;
    LMSTR                shi503_passwd;
    LMSTR                shi503_servername;
    DWORD                shi503_reserved;
    PSECURITY_DESCRIPTOR shi503_security_descriptor;
  } SHARE_INFO_503, *PSHARE_INFO_503, *LPSHARE_INFO_503;
]]

ffi.cdef [[
  NET_API_STATUS NetShareAdd(
    LMSTR   servername,
    DWORD   level,
    LPBYTE  buf,
    LPDWORD parm_err
  );

  NET_API_STATUS NetShareDel(
    LMSTR servername,
    LMSTR netname,
    DWORD reserved
  );

  NET_API_STATUS NetShareEnum(
    LMSTR   servername,
    DWORD   level,
    LPBYTE  *bufptr,
    DWORD   prefmaxlen,
    LPDWORD entriesread,
    LPDWORD totalentries,
    LPDWORD resume_handle
  );

  NET_API_STATUS NetShareCheck(
    LMSTR   servername,
    LMSTR   device,
    LPDWORD type
  );
]]
