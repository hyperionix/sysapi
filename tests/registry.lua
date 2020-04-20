setfenv(1, require "sysapi-ns")
local RegKey = require "registry.RegKey"

assert(RegKey:create(HKEY_CURRENT_USER, "Test"))

local key = RegKey:open(HKEY_CURRENT_USER, "Console")
assert(key)
local val = key:getVal("FontSize", "ConEmu")
print(ffi.cast("PDWORD", val)[0])
local val = key:getVal("ColorTable00")
print(ffi.cast("PDWORD", val)[0])

key = RegKey:open(HKEY_CURRENT_USER, "Test")
assert(key)
local val = ffi.new("DWORD[1]", 100)
assert(key:setVal("test1", REG_DWORD, val, ffi.sizeof("DWORD")) == 0)
assert(key:setVal("test1", REG_DWORD, val, ffi.sizeof("DWORD"), "testKey") == 0)

local key = RegKey:openPredefined(HKEY_CURRENT_USER)
assert(key:getAllInfo())
key:forEachKey(
  function(name)
  end
)

local key = RegKey:open(HKEY_CURRENT_USER, "Console")
key:forEachValue(
  function(name, valData, size, dataType)
    print(name, valData, size, dataType)
  end
)
