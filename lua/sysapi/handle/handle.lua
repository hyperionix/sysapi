setfenv(1, require "sysapi-ns")
require "handle.handle-windef"

local tcache = require "utils.ctype-cache"
tcache:cache("OBJECT_BASIC_INFORMATION")
tcache:cache("OBJECT_NAME_INFORMATION")
tcache:cache("OBJECT_TYPE_INFORMATION")

local ntdll = ffi.load("ntdll.dll")

local M = SysapiMod("Handle")
local Getters = {}
local Methods = {}

local MT = {
  __index = function(self, name)
    if Getters[name] then
      return Getters[name](self, name)
    else
      return Methods[name]
    end
  end
}

function Methods:queryInfo(infoClass, ctype, ctypePtr, assumedSize)
  if self.handle then
    local data = assumedSize and ffi.new("char[?]", assumedSize) or ctype()
    local size = assumedSize or ffi.sizeof(ctype)
    local retSize = ffi.new("ULONG[1]")
    local err = ntdll.NtQueryObject(self.handle, infoClass, data, size, retSize)
    if NT_SUCCESS(err) then
      return ffi.cast(ctypePtr, data), retSize[0]
    end
  end
end

function Getters._objBasicInfo(obj, name)
  local info =
    obj:queryInfo(ffi.C.ObjectBasicInformation, tcache.OBJECT_BASIC_INFORMATION, tcache.POBJECT_BASIC_INFORMATION)
  obj[name] = info
  return info
end

function Getters._objNameInfo(obj, name)
  local info =
    obj:queryInfo(ffi.C.ObjectNameInformation, tcache.OBJECT_NAME_INFORMATION, tcache.POBJECT_NAME_INFORMATION, 1024)
  obj[name] = info
  return info
end

function Getters._objTypeInfo(obj, name)
  local info =
    obj:queryInfo(ffi.C.ObjectTypeInformation, tcache.OBJECT_TYPE_INFORMATION, tcache.POBJECT_TYPE_INFORMATION, 1024)
  obj[name] = info
  return info
end

function Getters.objectName(self, name)
  if self._objNameInfo then
    local objectName = string.fromUS(self._objNameInfo.Name)
    self[name] = objectName
    return objectName
  end
end

function Getters.objectType(self, name)
  if self._objTypeInfo then
    local objectType = string.fromUS(self._objTypeInfo.TypeName)
    self[name] = objectType
    return objectType
  end
end

function Getters.objectAccess(self, name)
  if self._objBasicInfo then
    local access = self._objBasicInfo.GrantedAccess
    self[name] = access
    return access
  end
end

function M.create(handle)
  return setmetatable({handle = handle}, MT)
end

return M
