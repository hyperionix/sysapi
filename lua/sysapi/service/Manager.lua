--- Class describes system Service Control Manager object
--
-- @classmod ServiceManager
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "service.service-windef"
local Service = require "service.Service"
local advapi32 = ffi.load("advapi32")

local ServiceManager = SysapiMod("ServiceManager")
local ServiceManager_MT = {__index = ServiceManager}

--- Open SCM
-- @param[opt=SC_MANAGER_ALL_ACCESS] access desired access
-- @return ServiceManager object
-- @function ServiceManager.open
function ServiceManager.open(access)
  local handle = advapi32.OpenSCManagerA(nil, nil, access or SC_MANAGER_ALL_ACCESS)
  if handle ~= ffi.NULL then
    return setmetatable({handle = ffi.gc(handle, advapi32.CloseServiceHandle)}, ServiceManager_MT)
  end
end

--- Open a service and create corresponding @{Service} object
-- @param name name of the target service
-- @param[opt=GENERIC_ALL] access desired access to the service
-- @return @{Service} object
function ServiceManager:openService(name, access)
  return Service.open(self.handle, name, access)
end

--- Create a service and create corresponding @{Service} object
-- @param name name of the service
-- @param binPath fully qualified path to the service binary file, can also include arguments
-- @param[opt=SERVICE_ALL_ACCESS] access desired access to the service
-- @param[opt=SERVICE_WIN32_OWN_PROCESS] serviceType service type
-- @param[opt=SERVICE_DEMAND_START] startType service start options
-- @param[opt=SERVICE_ERROR_NORMAL] errControl severity of the error, and action taken, if this service fails to start
-- @param[opt] account name of the account under which the service should run
-- @param[opt] password password to the account name specified by the account parameter
-- @return @{Service} object
function ServiceManager:createService(name, binPath, access, serviceType, startType, errControl, account, password)
  return Service.create(self.handle, name, binPath, access, serviceType, startType, errControl, account, password)
end

--- Enumerates services and call the function for each
-- @param func function to be called for each service.
-- The function accept `[ENUM_SERVICE_STATUS_PROCESSA](https://docs.microsoft.com/ru-ru/windows/win32/api/winsvc/ns-winsvc-enum_service_status_processa)`
-- @param[opt=SERVICE_TYPE_ALL] serviceTypes combination of service types to enumerate
-- @param[opt=SERVICE_STATE_ALL] state services states
function ServiceManager:forEachService(func, serviceTypes, state)
  local bytesNeeded = ffi.new("DWORD[1]")
  local servicesReturned = ffi.new("DWORD[1]")
  local resumeHandle = ffi.new("DWORD[1]")
  local size = 256 * 1024
  local data
  local err
  repeat
    data = ffi.new("char[?]", size)
    err =
      advapi32.EnumServicesStatusExA(
      self.handle,
      0,
      serviceTypes or SERVICE_TYPE_ALL,
      state or SERVICE_STATE_ALL,
      data,
      size,
      bytesNeeded,
      servicesReturned,
      resumeHandle,
      nil
    )
    size = bytesNeeded[0]
  until not (err == 0 and ffi.C.GetLastError() == ERROR_MORE_DATA)
  if err ~= 0 then
    local services = ffi.cast("ENUM_SERVICE_STATUS_PROCESSA *", data), servicesReturned[0]
    for i = 0, servicesReturned[0] - 1 do
      if func(services[i]) then
        break
      end
    end
  end
end

--- Close service manager
function ServiceManager:close()
  advapi32.CloseServiceHandle(self.handle)
end

return ServiceManager
