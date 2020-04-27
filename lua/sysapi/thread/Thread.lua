--- Class describes system Thread object
--
-- @classmod Thread
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "thread.thread-windef"

local Thread = SysapiMod("Thread")
local Thread_MT = {__index = Thread}

--- Create Thread Object from handle
-- @int handle handle of the thread
-- @return @{Thread} object
-- @function Thread.fromHandle
function Thread.fromHandle(handle, tid)
  return setmetatable({handle = ffi.gc(handle, ffi.C.CloseHandle), tid = tid}, Thread_MT)
end

--- Return ID of current thread
-- @function Thread.getCurrentId
function Thread.getCurrentId()
  return ffi.C.GetCurrentThreadId()
end

--- Close thread handle
function Thread:close()
  ffi.C.CloseHandle(ffi.gc(self.handle, nil))
end

return Thread
