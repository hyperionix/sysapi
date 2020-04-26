local function getSelfPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*[/\\])")
end

local initPath
if debug and not _HYPERIONIX then
  initPath = getSelfPath()
else
  if not _HYPERIONIX then
    initPath = [[.\lua\sysapi]]
  end
end

if initPath then
  package.path = package.path .. initPath .. [[\?.lua;]] .. initPath .. [[\?\init.lua;]]
end

setfenv(1, require "sysapi-ns")
SYSAPI = {
  _VERSION = "1.0"
}

-- XXX: We have to do all require due to nature of loading sysapi as package of Hyperionix (https://hyperionix.com)
require "common-windef"
require "utils"
require "sysinfo"
require "sysapi-mod"
require "thirdparty"

require "wcs"
require "time"
require "handle"
require "file"
require "fs"
require "process"
require "thread"
require "vm"
require "token"
require "sid"
require "crypto"
require "service"
