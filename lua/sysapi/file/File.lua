--- Class describes system File object
--
-- Most of the fields are lazy evaluated
-- @classmod File
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "file.file-windef"
local FileResources = require "file.Resources"
local time = require "time.time"
local cert = require "crypto.cert"
local stringify = require "utils.stringify"
local tcache = require "utils.ctype-cache"
local ntdll = ffi.load("ntdll")
assert(ntdll)

tcache:cache("FILE_BASIC_INFORMATION")
tcache:cache("FILE_STANDARD_INFORMATION")
tcache:cache("FILE_FS_DEVICE_INFORMATION")

local FILE_ATTRIBUTE_STRINGIFY_TABLE = stringify.getTable("FILE_ATTRIBUTE")

local M = SysapiMod("File")
local Getters = {}
-- XXX: This nil fields are used to satisfy code completion plugin
local Methods = {
  --- access time
  accessTime = nil,
  --- attributes
  attributes = nil,
  --- file device type
  deviceType = nil,
  --- change time
  changeTime = nil,
  --- create time
  createTime = nil,
  --- full path
  fullPath = nil,
  --- handle
  handle = nil,
  --- @{FileResources} object
  resources = nil,
  --- signature status
  signStatus = nil,
  --- list of signers
  signers = nil,
  --- path with File object was created
  openPath = nil
}

-- XXX: This trick is also used to satisfy code completion plugin
local MT = {__index = Methods}
rawset(
  MT,
  string.format("__index"),
  function(self, name)
    if Getters[name] then
      return Getters[name](self, name)
    else
      return Methods[name]
    end
  end
)

function Getters._basicInfo(obj, name)
  local info = obj:queryInfo(ffi.C.FileBasicInformation, tcache.FILE_BASIC_INFORMATION, tcache.PFILE_BASIC_INFORMATION)
  rawset(obj, name, info)
  return info
end

function Getters._standardInfo(obj, name)
  local info =
    obj:queryInfo(ffi.C.FileStandardInformation, tcache.FILE_STANDARD_INFORMATION, tcache.PFILE_STANDARD_INFORMATION)
  rawset(obj, name, info)
  return info
end

function Getters._deviceInfo(obj, name)
  local info =
    obj:queryVolumeInfo(
    ffi.C.FileFsDeviceInformation,
    tcache.FILE_FS_DEVICE_INFORMATION,
    tcache.PFILE_FS_DEVICE_INFORMATION
  )
  rawset(obj, name, info)
  return info
end

function Getters._certInfo(obj, name)
  local signStatus, signers = cert.getCertInfo(obj.openPath or obj.fullPath)
  obj._certInfo = {
    signStatus = signStatus,
    signers = signers
  }
  return obj._certInfo
end

function Getters.fullPath(obj, name)
  local buf = ffi.new("char[?]", 512)
  local ret = ffi.C.GetFinalPathNameByHandleA(obj.handle, buf, 512, FILE_NAME_NORMALIZED)
  if ret ~= 0 then
    local fullPath = ffi.string(buf, ret):sub(5)
    rawset(obj, name, fullPath)
    return fullPath
  end
end

function Getters.handle(obj, name)
  local handle =
    ffi.C.CreateFileA(
    obj.openPath or obj.fullPath,
    GENERIC_READ,
    FILE_SHARE_ALL,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    nil
  )
  if handle ~= INVALID_HANDLE_VALUE then
    rawset(obj, name, ffi.gc(handle, ffi.C.CloseHandle))
    return handle
  end
end

function Getters.size(obj)
  if obj._standardInfo then
    obj.size = tonumber(obj._standardInfo.EndOfFile.QuadPart)
    return obj.size
  end
end

function Getters.createTime(obj, name)
  if obj._basicInfo then
    local createTime = time.toUnixTimestamp(obj._basicInfo.CreationTime.QuadPart)
    rawset(obj, name, createTime)
    return createTime
  end
end

function Getters.accessTime(obj, name)
  if obj._basicInfo then
    local accessTime = time.toUnixTimestamp(obj._basicInfo.LastAccessTime.QuadPart)
    rawset(obj, name, accessTime)
    return accessTime
  end
end

function Getters.writeTime(obj, name)
  if obj._basicInfo then
    local writeTime = time.toUnixTimestamp(obj._basicInfo.LastWriteTime.QuadPart)
    rawset(obj, name, writeTime)
    return writeTime
  end
end

function Getters.changeTime(obj, name)
  if obj._basicInfo then
    local changeTime = time.toUnixTimestamp(obj._basicInfo.ChangeTime.QuadPart)
    rawset(obj, name, changeTime)
    return changeTime
  end
end

function Getters.deviceType(obj, name)
  if obj._deviceInfo then
    return obj._deviceInfo.DeviceType
  end
end

function Getters.resources(obj, name)
  local resources = FileResources.create(obj.openPath or obj.fullPath)
  rawset(obj, name, resources)
  return resources
end

function Getters.attributes(obj, name)
  if obj._basicInfo then
    rawset(obj, name, obj._basicInfo.FileAttributes)
    return obj._basicInfo.FileAttributes
  end
end

function Getters.signStatus(obj, name)
  local signStatus = obj._certInfo.signStatus
  rawset(obj, name, signStatus)
  return signStatus
end

function Getters.signers(obj, name)
  local signers = obj._certInfo.signers
  rawset(obj, name, signers)
  return signers
end

--- Constructors
-- @section Constructors

--- Create or open a file
-- @string path relative or absolute path to file
-- @int disp
-- @int[opt=GENERIC_READWRITE] access to the file
-- @int[opt=FILE_ATTRIBUTE_NORMAL] attr fileattributes
-- @int[opt=FILE_SHARE_ALL] share sharing options
-- @return @{File} object or `nil`
-- @function File.open
function M.create(path, disp, access, attr, share)
  local handle =
    ffi.C.CreateFileA(
    path,
    access or GENERIC_READWRITE,
    share or FILE_SHARE_ALL,
    nil,
    disp,
    attr or FILE_ATTRIBUTE_NORMAL,
    nil
  )
  if handle ~= INVALID_HANDLE_VALUE then
    return setmetatable({handle = ffi.gc(handle, ffi.C.CloseHandle), openPath = path}, MT)
  end
end

function M.fromTable(kwargs)
  return setmetatable(kwargs, MT)
end

--- Create @{File} object from a handle
-- @int handle to the file
-- @return @{File} object or `nil`
-- @function File.fromHandle
function M.fromHandle(handle)
  return M.fromTable({handle = handle})
end

--- Create @{File} object from its path
-- @param path full or relative path to the file
-- @return @{File} object or `nil`
-- @function File.fromPath
function M.fromPath(path)
  return M.fromTable({openPath = path})
end

--- Create @{File} object from its full path
-- @param fullPath full path to the file
-- @return @{File} object or `nil`
-- @function File.fromFullPath
function M.fromFullPath(fullPath)
  return M.fromTable({fullPath = fullPath})
end

--- Static Methods
-- @section StaticMethods

--- Delete file by name
-- @param path to file
-- @return `true` on success, `false` on error
-- @function File.delete
function M.delete(path)
  return ffi.C.DeleteFileA(path)
end

--- Stringify file attributes mask
-- @int attrs file attributes
-- @return string representation of the mask
-- @function File.stringifyAttributes
function M.stringifyAttributes(attrs)
  return stringify.mask(attrs, FILE_ATTRIBUTE_STRINGIFY_TABLE)
end

function M._getGetters()
  return Getters
end

--- Object Methods
-- @section ObjectMethods

--- Read the whole data of file or a part
-- @int[opt=all] readSize size of data to read
-- @return read data or `nil`
-- @function read
function Methods:read(readSize)
  readSize = readSize or self.size
  local fileData = ffi.new("char[?]", readSize)
  local outBytes = ffi.new("DWORD[1]")
  if ffi.C.ReadFile(self.handle, fileData, readSize, outBytes, nil) then
    return ffi.string(fileData, outBytes[0])
  end
end

function Methods:write(data, size)
  local outBytes = ffi.new("DWORD[1]")
  return ffi.C.WriteFile(self.handle, data, size or #data, outBytes, nil)
end

--- Query information about the file
-- @param infoClass `FILE_INFORMATION_CLASS`
-- @param ctype C type returned by `ffi.typeof()`
-- @param ctypePtr pointer to the type
-- @return typed pointer depends on `typeName` or `nil`
-- @function queryInfo
function Methods:queryInfo(infoClass, ctype, ctypePtr)
  local handle = self.handle
  if handle then
    local data = ctype()
    local size = ffi.sizeof(ctype)
    local io = ffi.new("IO_STATUS_BLOCK[1]")
    local err = ntdll.NtQueryInformationFile(handle, io, data, size, infoClass)
    if NT_SUCCESS(err) then
      return ffi.cast(ctypePtr, data)
    elseif IS_STATUS(err, STATUS_BUFFER_OVERFLOW) and infoClass == ffi.C.FileNameInformation then
      size = data.FileNameLength + ffi.sizeof("ULONG") + 2
      data = ffi.new("char[?]", size)
      if data then
        err = ntdll.NtQueryInformationFile(handle, io, data, size, infoClass)
        if NT_SUCCESS(err) then
          return ffi.cast(ctypePtr, data)
        end
      end
    end
  end
end

function Methods:queryVolumeInfo(infoClass, ctype, ctypePtr)
  local handle = self.handle
  if handle then
    local data = ctype()
    local size = ffi.sizeof(ctype)
    local io = ffi.new("IO_STATUS_BLOCK[1]")
    local err = ntdll.NtQueryVolumeInformationFile(handle, io, data, size, infoClass)
    if NT_SUCCESS(err) then
      return ffi.cast(ctypePtr, data)
    elseif IS_STATUS(err, STATUS_BUFFER_OVERFLOW) and infoClass == ffi.C.FileNameInformation then
      size = data.FileNameLength + ffi.sizeof("ULONG") + 2
      data = ffi.new("char[?]", size)
      if data then
        err = ntdll.NtQueryVolumeInformationFile(handle, io, data, size, infoClass)
        if NT_SUCCESS(err) then
          return ffi.cast(ctypePtr, data)
        end
      end
    end
  end
end

--- Set file information
-- @param infoClass `FILE_INFORMATION_CLASS`
-- @param info corresponding information structure
-- @param infoSize of the information
-- @return `true` or `false`
-- @function setInfo
function Methods:setInfo(infoClass, info, infoSize)
  local handle = self.handle
  if handle then
    local io = ffi.new("IO_STATUS_BLOCK")
    local err = ntdll.NtSetInformationFile(handle, io, info, infoSize or ffi.sizeof(info), infoClass)
    if NT_SUCCESS(err) then
      return true
    end
  end

  return false
end

--- Send IOCTL to the device
-- @param code IOCTL code
-- @param inBuf input buffer
-- @param outBuf output buffer
-- @param outBytes number of returned bytes
-- @return nonzero in case of success
-- @function setInfo
function Methods:ioctl(code, inBuf, outBuf, outBytes)
  local outBytes = outBytes or ffi.new("DWORD[1]")
  return ffi.C.DeviceIoControl(
    self.handle,
    code,
    inBuf,
    inBuf and ffi.sizeof(inBuf) or 0,
    outBuf,
    outBuf and ffi.sizeof(outBuf) or 0,
    outBytes,
    nil
  )
end

--- Delete the file
-- @return `true` or `false`
-- @function delete
function Methods:delete()
  local info = ffi.new("FILE_DISPOSITION_INFORMATION_EX")
  info.Flags = FILE_DISPOSITION_DELETE
  return self:setInfo(ffi.C.FileDispositionInformationEx, info)
end

--- Close the file
-- @function close
function Methods:close()
  local handle = rawget(self, "handle")
  if handle then
    ffi.C.CloseHandle(ffi.gc(handle, nil))
  end
end

return M
