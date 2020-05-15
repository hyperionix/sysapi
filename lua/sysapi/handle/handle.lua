setfenv(1, require "sysapi-ns")
require "handle.handle-windef"

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

function Getters.objectName(self, name)
  local info = ffi.cast("OBJECT_NAME_INFORMATION*", ffi.new("char[?]", 1024))
  local retSize = ffi.new("ULONG[1]")
  local ret = ntdll.NtQueryObject(self.handle, ffi.C.ObjectNameInformation, info, 1024, retSize)
  local objectName = string.fromUS(info.Name)
  self[name] = objectName
  return objectName
end

function Getters.objectType(self, name)
  local info = ffi.cast("OBJECT_TYPE_INFORMATION*", ffi.new("char[?]", 1024))
  local retSize = ffi.new("ULONG[1]")
  local ret = ntdll.NtQueryObject(self.handle, ffi.C.ObjectTypeInformation, info, 1024, retSize)
  local objectType = string.fromUS(info.TypeName)
  self[name] = objectType
  return objectType
end

function M.create(handle)
  return setmetatable({handle = handle}, MT)
end

return M
