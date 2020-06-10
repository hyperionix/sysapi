--- Share operations
--
-- @module share
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "share.share-windef"
local netapi32 = ffi.load("netapi32")

local M = SysapiMod("Share")

--- Add share
-- @param shareName share name
-- @param sharePath share path
-- @param[opt=STYPE_DISKTREE] shareType share type
-- @param[opt] serverName server DNS or NetBIOS name (if not specified, the local computer is used)
-- @return 0 on success
-- @function share.add
function M.add(shareName, sharePath, shareType, serverName)
  local info = ffi.new("SHARE_INFO_2[1]")
  info[0].shi2_netname = shareName:toWC()
  info[0].shi2_type = shareType or STYPE_DISKTREE
  info[0].shi2_remark = ffi.NULL
  info[0].shi2_permissions = 0
  info[0].shi2_max_uses = -1
  info[0].shi2_current_uses = 0
  info[0].shi2_path = sharePath:toWC()
  info[0].shi2_passwd = ffi.NULL

  return netapi32.NetShareAdd(serverName and serverName:toWC() or ffi.NULL, 2, ffi.cast("LPBYTE", info), ffi.NULL)
end

--- Check whether or not a server is sharing a resource with specified path
-- @param sharePath path to check for shared access
-- @param[out_opt] shareType LPDWORD that on success receives a bitmask of flags that specify the type of the shared resource
-- @param[opt] serverName server DNS or NetBIOS name (if not specified, the local computer is used)
-- @return 0 on success
-- @function share.check
function M.check(sharePath, shareType, serverName)
  return netapi32.NetShareCheck(
    serverName and serverName:toWC() or ffi.NULL,
    sharePath:toWC(),
    shareType or ffi.new("DWORD[1]")
  )
end

--- Delete share
-- @param shareName share name
-- @param[opt] serverName server DNS or NetBIOS name (if not specified, the local computer is used)
-- @return 0 on success
-- @function share.delete
function M.delete(shareName, serverName)
  return netapi32.NetShareDel(serverName and serverName:toWC() or ffi.NULL, shareName:toWC(), 0)
end

-- possible types of info for shares enumeration according to https://docs.microsoft.com/en-us/windows/win32/api/lmshare/nf-lmshare-netshareenum
local SHARE_INFO_TYPES_NAMES = {
  [0] = "SHARE_INFO_0 *",
  [1] = "SHARE_INFO_1 *",
  [2] = "SHARE_INFO_2 *",
  [502] = "SHARE_INFO_502 *",
  [503] = "SHARE_INFO_503 *"
}

--- Enumerate shares and call the function for each
-- @param func function to be called for each share
-- @param[opt=0] level information level of the data
-- @param[opt] serverName server DNS or NetBIOS name (if not specified, the local computer is used)
-- @function share.forEach
function M.forEach(func, level, serverName)
  local buf = ffi.new("LPBYTE[1]")
  local entriesRead = ffi.new("DWORD[1]")
  local totalEntries = ffi.new("DWORD[1]")
  level = level or 0

  local err =
    netapi32.NetShareEnum(
    serverName and serverName:toWC() or ffi.NULL,
    level,
    buf,
    MAX_PREFERRED_LENGTH,
    entriesRead,
    totalEntries,
    ffi.NULL
  )

  if err == 0 then
    ffi.gc(buf[0], netapi32.NetApiBufferFree)
    local infoType = ffi.typeof(SHARE_INFO_TYPES_NAMES[level])
    local shares = ffi.cast(infoType, buf[0])
    for i = 0, entriesRead[0] - 1 do
      if func(shares[i]) then
        break
      end
    end
  end
end

return M
