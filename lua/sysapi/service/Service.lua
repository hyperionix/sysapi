--- Class describes system Service object
--
-- @classmod Service
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "service.service-windef"
local advapi32 = ffi.load("advapi32")

local Service = SysapiMod("Service")
local Service_MT = {__index = Service}

--- Open a service
-- The function shouldn't be used directly, use @{ServiceManager:openService} instead
-- @param scmHandle handle to SCM
-- @param name name of the service
-- @param access desired access to the service
-- @return Service object
-- @function Service.open
function Service.open(scmHandle, name, access)
  local handle = advapi32.OpenServiceA(scmHandle, name, access or GENERIC_ALL)
  if handle ~= ffi.NULL then
    return setmetatable({handle = ffi.gc(handle, advapi32.CloseServiceHandle)}, Service_MT)
  end
end

--- Update information about the service
-- After the function call you can access to the Service fields
-- @return `true` on success
function Service:updateInfo()
  local info = ffi.new("SERVICE_STATUS_PROCESS[1]")
  local bytesNeeded = ffi.new("DWORD[1]")
  if
    advapi32.QueryServiceStatusEx(
      self.handle,
      0,
      ffi.cast("LPBYTE", info),
      ffi.sizeof("SERVICE_STATUS_PROCESS"),
      bytesNeeded
    ) ~= 0
   then
    info = info[0]
    --- service type
    self.type = info.dwServiceType
    --- service state
    self.state = info.dwCurrentState
    --- PID if the service
    self.pid = info.dwProcessId
    --- full service information (`[SERVICE_STATUS_PROCESS](https://docs.microsoft.com/en-us/windows/win32/api/winsvc/ns-winsvc-service_status_process)`)
    self.fullInfo = info
    return true
  end
end

return Service
