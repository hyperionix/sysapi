--- Filesystem path operations
--
-- @module path
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
local string = string
local setmetatable = setmetatable
local msvcrt = ffi.load("msvcrt")
local M = SysapiMod("FilePath")
local Getters = {}
local Methods = {
  full = nil,
  drive = nil,
  dir = nil,
  basename = nil,
  ext = nil
}

-- XXX: This trick is also used to satisfy code completion plugin
local MT = {__index = Methods, __metatable = {}}
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

local function splitPath(obj)
  if obj.full then
    local size = #obj.full
    local drive = ffi.new("char[5]")
    local dir = ffi.new("char[?]", size)
    local basename = ffi.new("char[?]", size)
    local ext = ffi.new("char[?]", size)

    if msvcrt._splitpath_s(obj.full, drive, 5, dir, size, basename, size, ext, size) == 0 then
      obj.drive = ffi.string(drive):toUTF8()
      obj.dir = ffi.string(dir):toUTF8()
      obj.basename = ffi.string(basename):toUTF8()
      obj.ext = ffi.string(ext):toUTF8()
      return
    end
  else
    obj.full = ""
  end

  obj.drive = ""
  obj.dir = ""
  obj.basename = ""
  obj.ext = ""
end

local function internalGetter(obj, name)
  splitPath(obj)
  return rawget(obj, name)
end

function Getters.drive(obj, name)
  return internalGetter(obj, name)
end

function Getters.dir(obj, name)
  return internalGetter(obj, name)
end

function Getters.basename(obj, name)
  return internalGetter(obj, name)
end

function Getters.ext(obj, name)
  return internalGetter(obj, name)
end

function M.fromUS(usFullPath)
  return setmetatable({full = string.fromUS(usFullPath)}, MT)
end

function M.fromString(strFullPath)
  return setmetatable({full = strFullPath}, MT)
end

function Methods:split()
  splitPath(self)
  return self
end

return M
