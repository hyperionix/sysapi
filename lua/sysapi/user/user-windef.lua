setfenv(1, require "sysapi-ns")

USER_PRIV_GUEST = 0
USER_PRIV_USER = 1
USER_PRIV_ADMIN = 2

UF_SCRIPT = 1
UF_ACCOUNTDISABLE = 2
UF_HOMEDIR_REQUIRED = 8
UF_LOCKOUT = 16
UF_PASSWD_NOTREQD = 32
UF_PASSWD_CANT_CHANGE = 64
UF_TEMP_DUPLICATE_ACCOUNT = 256
UF_NORMAL_ACCOUNT = 512
UF_INTERDOMAIN_TRUST_ACCOUNT = 2048
UF_WORKSTATION_TRUST_ACCOUNT = 4096
UF_SERVER_TRUST_ACCOUNT = 8192
UF_DONT_EXPIRE_PASSWD = 65536
UF_MNS_LOGON_ACCOUNT = 131072

FILTER_TEMP_DUPLICATE_ACCOUNT = 1
FILTER_NORMAL_ACCOUNT = 2
FILTER_INTERDOMAIN_TRUST_ACCOUNT = 8
FILTER_WORKSTATION_TRUST_ACCOUNT = 16
FILTER_SERVER_TRUST_ACCOUNT = 32

MAX_PREFERRED_LENGTH = -1

ffi.cdef [[
  typedef DWORD NET_API_STATUS;

  typedef struct _USER_INFO_0 {
    LPWSTR usri0_name;
  } USER_INFO_0, *PUSER_INFO_0, *LPUSER_INFO_0;

  typedef struct _USER_INFO_1 {
    LPWSTR usri1_name;
    LPWSTR usri1_password;
    DWORD  usri1_password_age;
    DWORD  usri1_priv;
    LPWSTR usri1_home_dir;
    LPWSTR usri1_comment;
    DWORD  usri1_flags;
    LPWSTR usri1_script_path;
  } USER_INFO_1, *PUSER_INFO_1, *LPUSER_INFO_1;

  typedef struct _USER_INFO_2 {
    LPWSTR usri2_name;
    LPWSTR usri2_password;
    DWORD  usri2_password_age;
    DWORD  usri2_priv;
    LPWSTR usri2_home_dir;
    LPWSTR usri2_comment;
    DWORD  usri2_flags;
    LPWSTR usri2_script_path;
    DWORD  usri2_auth_flags;
    LPWSTR usri2_full_name;
    LPWSTR usri2_usr_comment;
    LPWSTR usri2_parms;
    LPWSTR usri2_workstations;
    DWORD  usri2_last_logon;
    DWORD  usri2_last_logoff;
    DWORD  usri2_acct_expires;
    DWORD  usri2_max_storage;
    DWORD  usri2_units_per_week;
    PBYTE  usri2_logon_hours;
    DWORD  usri2_bad_pw_count;
    DWORD  usri2_num_logons;
    LPWSTR usri2_logon_server;
    DWORD  usri2_country_code;
    DWORD  usri2_code_page;
  } USER_INFO_2, *PUSER_INFO_2, *LPUSER_INFO_2;

  typedef struct _USER_INFO_3 {
    LPWSTR usri3_name;
    LPWSTR usri3_password;
    DWORD  usri3_password_age;
    DWORD  usri3_priv;
    LPWSTR usri3_home_dir;
    LPWSTR usri3_comment;
    DWORD  usri3_flags;
    LPWSTR usri3_script_path;
    DWORD  usri3_auth_flags;
    LPWSTR usri3_full_name;
    LPWSTR usri3_usr_comment;
    LPWSTR usri3_parms;
    LPWSTR usri3_workstations;
    DWORD  usri3_last_logon;
    DWORD  usri3_last_logoff;
    DWORD  usri3_acct_expires;
    DWORD  usri3_max_storage;
    DWORD  usri3_units_per_week;
    PBYTE  usri3_logon_hours;
    DWORD  usri3_bad_pw_count;
    DWORD  usri3_num_logons;
    LPWSTR usri3_logon_server;
    DWORD  usri3_country_code;
    DWORD  usri3_code_page;
    DWORD  usri3_user_id;
    DWORD  usri3_primary_group_id;
    LPWSTR usri3_profile;
    LPWSTR usri3_home_dir_drive;
    DWORD  usri3_password_expired;
  } USER_INFO_3, *PUSER_INFO_3, *LPUSER_INFO_3;

  typedef struct _USER_INFO_4 {
    LPWSTR usri4_name;
    LPWSTR usri4_password;
    DWORD  usri4_password_age;
    DWORD  usri4_priv;
    LPWSTR usri4_home_dir;
    LPWSTR usri4_comment;
    DWORD  usri4_flags;
    LPWSTR usri4_script_path;
    DWORD  usri4_auth_flags;
    LPWSTR usri4_full_name;
    LPWSTR usri4_usr_comment;
    LPWSTR usri4_parms;
    LPWSTR usri4_workstations;
    DWORD  usri4_last_logon;
    DWORD  usri4_last_logoff;
    DWORD  usri4_acct_expires;
    DWORD  usri4_max_storage;
    DWORD  usri4_units_per_week;
    PBYTE  usri4_logon_hours;
    DWORD  usri4_bad_pw_count;
    DWORD  usri4_num_logons;
    LPWSTR usri4_logon_server;
    DWORD  usri4_country_code;
    DWORD  usri4_code_page;
    PSID   usri4_user_sid;
    DWORD  usri4_primary_group_id;
    LPWSTR usri4_profile;
    LPWSTR usri4_home_dir_drive;
    DWORD  usri4_password_expired;
  } USER_INFO_4, *PUSER_INFO_4, *LPUSER_INFO_4;

  typedef struct _USER_INFO_10 {
    LPWSTR usri10_name;
    LPWSTR usri10_comment;
    LPWSTR usri10_usr_comment;
    LPWSTR usri10_full_name;
  } USER_INFO_10, *PUSER_INFO_10, *LPUSER_INFO_10;

  typedef struct _USER_INFO_11 {
    LPWSTR usri11_name;
    LPWSTR usri11_comment;
    LPWSTR usri11_usr_comment;
    LPWSTR usri11_full_name;
    DWORD  usri11_priv;
    DWORD  usri11_auth_flags;
    DWORD  usri11_password_age;
    LPWSTR usri11_home_dir;
    LPWSTR usri11_parms;
    DWORD  usri11_last_logon;
    DWORD  usri11_last_logoff;
    DWORD  usri11_bad_pw_count;
    DWORD  usri11_num_logons;
    LPWSTR usri11_logon_server;
    DWORD  usri11_country_code;
    LPWSTR usri11_workstations;
    DWORD  usri11_max_storage;
    DWORD  usri11_units_per_week;
    PBYTE  usri11_logon_hours;
    DWORD  usri11_code_page;
  } USER_INFO_11, *PUSER_INFO_11, *LPUSER_INFO_11;

  typedef struct _USER_INFO_20 {
    LPWSTR usri20_name;
    LPWSTR usri20_full_name;
    LPWSTR usri20_comment;
    DWORD  usri20_flags;
    DWORD  usri20_user_id;
  } USER_INFO_20, *PUSER_INFO_20, *LPUSER_INFO_20;
]]

ffi.cdef [[
  NET_API_STATUS NetUserAdd(
    LPCWSTR servername,
    DWORD   level,
    LPBYTE  buf,
    LPDWORD parm_err
  );

  NET_API_STATUS NetUserDel(
    LPCWSTR servername,
    LPCWSTR username
  );

  NET_API_STATUS NetUserChangePassword(
    LPCWSTR domainname,
    LPCWSTR username,
    LPCWSTR oldpassword,
    LPCWSTR newpassword
  );

  NET_API_STATUS NetUserEnum(
    LPCWSTR servername,
    DWORD   level,
    DWORD   filter,
    LPBYTE  *bufptr,
    DWORD   prefmaxlen,
    LPDWORD entriesread,
    LPDWORD totalentries,
    PDWORD  resume_handle
  );

  NET_API_STATUS NetApiBufferFree(
    LPVOID Buffer
  );
]]
