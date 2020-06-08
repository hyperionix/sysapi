--- User operations
--
-- @module user
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "user.user-windef"
local netapi32 = ffi.load("netapi32")

local M = SysapiMod("User")

--- Add user
-- @param username user name
-- @param[opt] password password (if not specified, the user created without a password)
-- @param[opt] servername server DNS or NetBIOS name (if not specified, the local computer is used)
-- @param[opt=UF_SCRIPT] flags user account control flags
-- @return 0 on success
-- @function user.add
function M.add(username, password, servername, flags)
  local info = ffi.new("USER_INFO_1[1]")
  info[0].usri1_name = username:toWC()
  info[0].usri1_password = password and password:toWC() or ffi.NULL
  info[0].usri1_priv = USER_PRIV_USER
  info[0].usri1_home_dir = ffi.NULL
  info[0].usri1_comment = ffi.NULL
  info[0].usri1_flags = flags or UF_SCRIPT
  info[0].usri1_script_path = ffi.NULL

  return netapi32.NetUserAdd(servername and servername:toWC() or ffi.NULL, 1, ffi.cast("LPBYTE", info), ffi.NULL)
end

--- Delete user
-- @param username user name
-- @param[opt] servername server DNS or NetBIOS name (if not specified, the local computer is used)
-- @return 0 on success
-- @function user.delete
function M.delete(username, servername)
  return netapi32.NetUserDel(servername and servername:toWC() or ffi.NULL, username:toWC())
end

--- Change user's password
-- @param[opt] username user name (if not specified, the logon name of the caller is used)
-- @param oldpassword old password
-- @param newpassword new password
-- @param[opt] servername server DNS or NetBIOS name (if not specified, the local computer is used)
-- @return 0 on success
-- @function user.changePassword
function M.changePassword(username, oldpassword, newpassword, servername)
  return netapi32.NetUserChangePassword(
    servername and servername:toWC() or ffi.NULL,
    username and username:toWC() or ffi.NULL,
    oldpassword:toWC(),
    newpassword:toWC()
  )
end

-- possible types of info for users enumeration according to https://docs.microsoft.com/en-us/windows/win32/api/lmaccess/nf-lmaccess-netuserenum
local USER_INFO_TYPES_NAMES = {
  [0] = "USER_INFO_0 *",
  [1] = "USER_INFO_1 *",
  [2] = "USER_INFO_2 *",
  [3] = "USER_INFO_3 *",
  [10] = "USER_INFO_10 *",
  [11] = "USER_INFO_11 *",
  [20] = "USER_INFO_20 *"
}

--- Enumerate users and call the function for each
-- @param func function to be called for each user
-- @param[opt=0] level information level of the data
-- @param[opt=0] filter user account types to be included in the enumeration
-- @param[opt] servername server DNS or NetBIOS name (if not specified, the local computer is used)
-- @function user.forEach
function M.forEach(func, level, filter, servername)
  local buf = ffi.new("LPBYTE[1]")
  local entriesRead = ffi.new("DWORD[1]")
  local totalEntries = ffi.new("DWORD[1]")
  level = level or 0

  local err =
    netapi32.NetUserEnum(
    servername and servername:toWC() or ffi.NULL,
    level,
    filter or 0,
    buf,
    MAX_PREFERRED_LENGTH,
    entriesRead,
    totalEntries,
    ffi.NULL
  )

  if err == 0 then
    ffi.gc(buf[0], netapi32.NetApiBufferFree)
    local infoType = ffi.typeof(USER_INFO_TYPES_NAMES[level])
    local users = ffi.cast(infoType, buf[0])
    for i = 0, entriesRead[0] - 1 do
      if func(users[i]) then
        break
      end
    end
  end
end

return M
