--- Filesystem operations
--
-- @module fs
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "fs.fs-windef"
local shell32 = ffi.load("shell32")
local ole32 = ffi.load("ole32")

local M = SysapiMod("FS")

--- Enumerate files in directory
-- @param path path to the directory
-- @return iterator to enumrate files
-- @function fs.dir
function M.dir(path)
  local ffd = ffi.new("WIN32_FIND_DATAA[1]")
  local findHandle
  if findHandle ~= INVALID_HANDLE_VALUE then
    return function()
      if not findHandle then
        findHandle = ffi.C.FindFirstFileA(path, ffd)
        if findHandle == INVALID_HANDLE_VALUE then
          return
        end
        ffi.gc(findHandle, ffi.C.FindClose)
        return ffi.string(ffd[0].cFileName), ffd[0]
      else
        if ffi.C.FindNextFileA(findHandle, ffd) ~= 0 then
          return ffi.string(ffd[0].cFileName), ffd[0]
        else
          ffi.C.FindClose(ffi.gc(findHandle, nil))
        end
      end
    end
  end
end

local function getWNDirectory(token, guid)
  local rfid = ffi.new("KNOWNFOLDERID[1]")
  local path = ffi.new("LPWSTR[1]")

  rfid[0] = guid

  if shell32.SHGetKnownFolderPath(rfid, ffi.C.KF_FLAG_DEFAULT, token, path) == 0 then
    local ret = ffi.string(string.fromWC(path[0]))
    ole32.CoTaskMemFree(path[0])
    return ret
  end
end

--- Get user Downloads directory
-- @param[opt] token user token handle
-- @return Downloads directory path
-- @function fs.getDownloadsDirectory
function M.getDownloadsDirectory(token)
  return getWNDirectory(token, FOLDERID_Downloads)
end

--- Get user Windows directory
-- @param[opt] token user token handle
-- @return Windows directory path
-- @function fs.getWindowsDirectory
function M.getWindowsDirectory(token)
  return getWNDirectory(token, FOLDERID_Windows)
end

--- Get user Startup directory
-- @param[opt] token user token handle
-- @return Startup directory path
-- @function fs.getStartupDirectory
function M.getStartupDirectory(token)
  return getWNDirectory(token, FOLDERID_Startup)
end

--- Get user UserProfile directory
-- @param[opt] token user token handle
-- @return UserProfile directory path
-- @function fs.getUserProfileDirectory
function M.getUserProfileDirectory(token)
  return getWNDirectory(token, FOLDERID_Profile)
end

--- Get user Temp directory
-- @return Temp directory path
-- @function fs.getTempDirectory
function M.getTempDirectory()
  local buf = ffi.new("CHAR[?]", 1024)
  ffi.C.GetTempPathA(1024, buf)
  return ffi.string(buf)
end

return M
