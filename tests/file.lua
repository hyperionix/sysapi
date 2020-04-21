setfenv(1, require "sysapi-ns")
local File = require "file.File"
local fs = require "fs.fs"

local function testFile(path)
  local f = File.create(path, OPEN_EXISTING, GENERIC_READ)
  assert(f)

  local getters = File._getGetters()
  for name, getter in pairs(getters) do
    print(name, f[name])
  end

  local data = f:read()
  assert(data)
  assert(#data == f.size)
end

testFile(fs.getWindowsDirectory() .. [[\notepad.exe]])
testFile(fs.getWindowsDirectory() .. [[\system32\ntdll.dll]])
