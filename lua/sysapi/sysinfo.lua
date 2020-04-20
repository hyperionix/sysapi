setfenv(1, require "sysapi-ns")

local SystemInfo = {}
local SystemInfo_MT = {}

function SystemInfo_MT.init()
  local osVersion = ffi.new("RTL_OSVERSIONINFOW[1]")
  osVersion[0].dwOSVersionInfoSize = ffi.sizeof("RTL_OSVERSIONINFOW")
  local ntdll = ffi.load("ntdll")
  ntdll.RtlGetVersion(osVersion)

  SystemInfo.is64Bit = ffi.abi("64bit")
  SystemInfo.versionMajor = osVersion[0].dwMajorVersion
  SystemInfo.versionMinor = osVersion[0].dwMinorVersion
  SystemInfo.build = osVersion[0].dwBuildNumber
end

setmetatable(
  SystemInfo,
  {
    __index = SystemInfo_MT,
    __tostring = function(self)
      return ("Windows version %d.%d.%d, 64 bit: %s"):format(
        self.versionMajor,
        self.versionMinor,
        self.build,
        self.is64Bit
      )
    end
  }
)

SystemInfo.init()
return SystemInfo
