setfenv(1, require "sysapi-ns")
local ServiceManager = require "service.manager"

local mgr = ServiceManager.open()
assert(mgr)
local service = mgr:openService("http")
assert(service)
if service:updateInfo() then
  assert(service.type)
  assert(service.state)
  assert(service.pid)
end

mgr:forEachService(
  function(info)
    print(ffi.string(info.lpServiceName), info.ServiceStatusProcess.dwProcessId)
  end,
  SERVICE_WIN32_OWN_PROCESS
)
