setfenv(1, require "sysapi-ns")
local ServiceManager = require "service.manager"

local mgr = ServiceManager.open()
assert(mgr)
local service = mgr:openService("http")
assert(service)
if service:updateStatus() then
  assert(service.status.state)
  assert(service.status.pid)
end
if service:updateConfig() then
  assert(service.config.type)
  assert(service.config.startType)
  assert(service.config.name)
  assert(service.config.binPath)
end

mgr:forEachService(
  function(info)
    print(ffi.string(info.lpServiceName), info.ServiceStatusProcess.dwProcessId)
  end,
  SERVICE_WIN32_OWN_PROCESS
)
