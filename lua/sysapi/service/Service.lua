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
-- @return @{Service} object
-- @function Service.open
function Service.open(scmHandle, name, access)
  local handle = advapi32.OpenServiceA(scmHandle, name, access or GENERIC_ALL)
  if handle ~= ffi.NULL then
    return setmetatable({handle = ffi.gc(handle, advapi32.CloseServiceHandle)}, Service_MT)
  end
end

--- Create a service
-- The function shouldn't be used directly, use @{ServiceManager:createService} instead
-- @param scmHandle handle to SCM
-- @param name name of the service
-- @param binPath fully qualified path to the service binary file, can also include arguments
-- @param[opt=SERVICE_ALL_ACCESS] access desired access to the service
-- @param[opt=SERVICE_WIN32_OWN_PROCESS] serviceType service type
-- @param[opt=SERVICE_DEMAND_START] startType service start options
-- @param[opt=SERVICE_ERROR_NORMAL] errControl severity of the error, and action taken, if this service fails to start
-- @param[opt] account name of the account under which the service should run
-- @param[opt] password password to the account name specified by the account parameter
-- @return @{Service} object
-- @function Service.create
function Service.create(scmHandle, name, binPath, access, serviceType, startType, errControl, account, password)
  local handle =
    advapi32.CreateServiceA(
    scmHandle,
    name,
    ffi.NULL,
    access or SERVICE_ALL_ACCESS,
    serviceType or SERVICE_WIN32_OWN_PROCESS,
    startType or SERVICE_DEMAND_START,
    errControl or SERVICE_ERROR_NORMAL,
    binPath,
    ffi.NULL,
    ffi.NULL,
    ffi.NULL,
    account or ffi.NULL,
    password or ffi.NULL
  )

  if handle ~= ffi.NULL then
    return setmetatable({handle = ffi.gc(handle, advapi32.CloseServiceHandle)}, Service_MT)
  end
end

--- Create @{Service} object from a handle
-- @param handle handle of the service
-- @return @{Service} object
-- @function Service.fromHandle
function Service.fromHandle(handle)
  return setmetatable({handle = handle}, Service_MT)
end

--- Update information about the service status
-- After the function call you can access to the Service status fields
-- @return `true` on success
-- @function updateStatus
function Service:updateStatus()
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
    self.status = {}
    --- service state
    self.status.state = info.dwCurrentState
    --- PID if the service
    self.status.pid = info.dwProcessId
    --- full service status information (`[SERVICE_STATUS_PROCESS](https://docs.microsoft.com/en-us/windows/win32/api/winsvc/ns-winsvc-service_status_process)`)
    self.status.full = info
    return true
  end
end

--- Update information about the service config
-- After the function call you can access to the Service config fields
-- @return `true` on success
-- @function updateConfig
function Service:updateConfig()
  local bytesNeeded = ffi.new("DWORD[1]")

  local err = advapi32.QueryServiceConfigA(self.handle, ffi.NULL, 0, bytesNeeded)
  if err == 0 and ffi.C.GetLastError() == ERROR_INSUFFICIENT_BUFFER then
    local info = ffi.cast("LPQUERY_SERVICE_CONFIGA", ffi.new("char[?]", bytesNeeded[0]))

    err = advapi32.QueryServiceConfigA(self.handle, info, bytesNeeded[0], bytesNeeded)
    if err ~= 0 then
      self.config = {}
      self.config.type = info.dwServiceType
      self.config.startType = info.dwStartType
      self.config.name = ffi.string(info.lpDisplayName)
      self.config.binPath = ffi.string(info.lpBinaryPathName)
      self.config.account = info.lpServiceStartName and ffi.string(info.lpServiceStartName)
      return true
    end
  end
end

--- Delete the service
-- @return `true` on success
-- @function delete
function Service:delete()
  return advapi32.DeleteService(self.handle) ~= 0
end

--- Start the service
-- @param[opt] args array of the null-terminated strings to be passed to the ServiceMain
-- function for the service as arguments, where first arg is the name of the service
-- followed by any additional arguments
-- @param[opt] numArgs number of strings in the args array
-- @return `true` on success
-- @function start
function Service:start(args, numArgs)
  return advapi32.StartServiceA(self.handle, numArgs or 0, args or ffi.NULL) ~= 0
end

--- Send control code to the service
-- @param code system or user-defined control code
-- @return `true` on success
-- @function control
function Service:control(code)
  local info = ffi.new("SERVICE_STATUS[1]")
  return advapi32.ControlService(self.handle, code, info) ~= 0
end

return Service
