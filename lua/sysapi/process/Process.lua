--- Class describes system Process object
--
-- Most of the fields are lazy evaluated
-- @classmod Process
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "process.process-windef"
local vm = require "vm.vm"
local Thread = require "thread.Thread"
local Token = require "token.Token"
local time = require "time.time"
local sysinfo = require "sysinfo"
local tcache = require "utils.ctype-cache"
local bor = bit.bor
local string = string
local ntdll = ffi.load("ntdll")
assert(ntdll)

tcache:cache("PROCESS_EXTENDED_BASIC_INFORMATION")
tcache:cache("UNICODE_STRING")
tcache:cache("ULONG_PTR")
tcache:cache("KERNEL_USER_TIMES")
tcache:cache("PROCESS_MITIGATION_DEP_POLICY")
tcache:cache("PROCESS_MITIGATION_ASLR_POLICY")
tcache:cache("PROCESS_MITIGATION_DYNAMIC_CODE_POLICY")
tcache:cache("PROCESS_MITIGATION_BINARY_SIGNATURE_POLICY")

local M = SysapiMod("Process")
local Getters = {}
-- XXX: This nil fields are used to satisfy code completion plugin
local Methods = {
  --- main executable path
  backingFile = nil,
  --- bitness (32 or 64)
  bitness = nil,
  --- command line
  commandLine = nil,
  --- create time
  createTime = nil,
  --- process ID
  pid = nil,
  --- ASLR enabled flag
  policyAslr = nil,
  ---  loading of images depending on the signatures for the image status
  policyBinarySignature = nil,
  --- DEP enabled flag
  policyDep = nil,
  --- restricting dynamic code generation and modification flag
  policyProhibitDynamicCode = nil,
  --- parent process ID
  ppid = nil,
  --- @{Token} objectof the process
  token = nil
}

-- XXX: This trick is also used to satisfy code completion plugin
local MT = {__index = Methods}
rawset(
  MT,
  string.format("__index"),
  function(self, name)
    if Getters[name] then
      return Getters[name](self, name)
    else
      return Methods[name]
    end
  end
)

function Getters._extendedBasicInfo(obj, name)
  local info =
    obj:queryInfo(
    ffi.C.ProcessBasicInformation,
    tcache.PROCESS_EXTENDED_BASIC_INFORMATION,
    tcache.PPROCESS_EXTENDED_BASIC_INFORMATION
  )
  rawset(obj, name, info)
  return info
end

function Getters.token(obj, name)
  local token = Token.open(obj.handle)
  rawset(obj, name, token)
  return token
end

function Getters.pid(obj, name)
  if obj._extendedBasicInfo then
    local pid = toaddress(obj._extendedBasicInfo.BasicInfo.UniqueProcessId)
    rawset(obj, name, pid)
    return pid
  end
end

function Getters.ppid(obj, name)
  if obj._extendedBasicInfo then
    local ppid = toaddress(obj._extendedBasicInfo.BasicInfo.InheritedFromUniqueProcessId)
    rawset(obj, name, ppid)
    return ppid
  end
end

function Getters.bitness(obj, name)
  if not sysinfo.is64Bit then
    rawset(obj, name, 32)
    return 32
  end

  local info =
    obj:queryInfo(ffi.C.ProcessWow64Information, tcache.ULONG_PTR, tcache.PULONG_PTR, ffi.sizeof(tcache.ULONG_PTR))
  if info then
    if info[0] ~= 0 then
      rawset(obj, name, 32)
      return 32
    else
      rawset(obj, name, 64)
      return 64
    end
  end
end

function Getters.backingFile(obj, name)
  local info = obj:queryInfo(ffi.C.ProcessImageFileNameWin32, tcache.UNICODE_STRING, tcache.PUNICODE_STRING, 1024)
  if info then
    local backingFile = string.fromUS(info)
    rawset(obj, name, backingFile)
    return backingFile
  end
end

function Getters.commandLine(obj, name)
  local info = obj:queryInfo(ffi.C.ProcessCommandLineInformation, tcache.UNICODE_STRING, tcache.PUNICODE_STRING, 1024)
  if info then
    local commandLine = string.fromUS(info)
    rawset(obj, name, commandLine)
    return commandLine
  end
end

function Getters.createTime(obj, name)
  local info = obj:queryInfo(ffi.C.ProcessTimes, tcache.KERNEL_USER_TIMES, tcache.PKERNEL_USER_TIMES)
  if info then
    local createTime = tonumber(time.toUnixTimestamp(info.CreateTime.QuadPart))
    rawset(obj, name, createTime)
    return createTime
  end
end

function Getters.policyDep(obj, name)
  local policy =
    obj:_getPolicy(ffi.C.ProcessDEPPolicy, tcache.PROCESS_MITIGATION_DEP_POLICY, tcache.PPROCESS_MITIGATION_DEP_POLICY)
  if policy then
    policy = policy.DUMMYUNIONNAME.DUMMYSTRUCTNAME.Enable
    rawset(obj, name, policy)
    return policy
  end
end

function Getters.policyAslr(obj, name)
  local policy =
    obj:_getPolicy(
    ffi.C.ProcessASLRPolicy,
    tcache.PROCESS_MITIGATION_ASLR_POLICY,
    tcache.PPROCESS_MITIGATION_ASLR_POLICY
  )
  if policy then
    policy = policy.DUMMYUNIONNAME.DUMMYSTRUCTNAME.EnableBottomUpRandomization
    rawset(obj, name, policy)
    return policy
  end
end

function Getters.policyProhibitDynamicCode(obj, name)
  local policy =
    obj:_getPolicy(
    ffi.C.ProcessDynamicCodePolicy,
    tcache.PROCESS_MITIGATION_DYNAMIC_CODE_POLICY,
    tcache.PPROCESS_MITIGATION_DYNAMIC_CODE_POLICY
  )
  if policy then
    policy = policy.DUMMYUNIONNAME.DUMMYSTRUCTNAME.ProhibitDynamicCode
    rawset(obj, name, policy)
    return policy
  end
end

function Getters.policyBinarySignature(obj, name)
  local policy =
    obj:_getPolicy(
    ffi.C.ProcessSignaturePolicy,
    tcache.PROCESS_MITIGATION_BINARY_SIGNATURE_POLICY,
    tcache.PPROCESS_MITIGATION_BINARY_SIGNATURE_POLICY
  )
  if policy then
    policy = policy.DUMMYUNIONNAME.Flags
    rawset(obj, name, policy)
    return policy
  end
end

--- Create process with command line
-- @string cmdLine process command line
-- @return @{Process} object
-- @function Process.run
function M.run(cmdLine)
  local si = ffi.new("STARTUPINFOA[1]")
  si[0].cb = ffi.sizeof(si[0])
  local pi = ffi.new("PROCESS_INFORMATION[1]")

  if ffi.C.CreateProcessA(nil, cmdLine, nil, nil, false, 0, nil, nil, si, pi) == 0 then
    return
  end

  return setmetatable(
    {
      handle = ffi.gc(pi[0].hProcess, ffi.C.CloseHandle),
      threadHandle = ffi.gc(pi[0].hThread, ffi.C.CloseHandle),
      pid = pi[0].dwProcessId
    },
    MT
  )
end

--- Open process by pid
-- @int pid target process PID
-- @int[opt] access access to the process object
-- @return @{Process} object
-- @function Process.open
function M.open(pid, access)
  local handle = ffi.C.OpenProcess(access or PROCESS_ALL_ACCESS, false, pid)
  if handle ~= ffi.NULL then
    return setmetatable({pid = pid, handle = ffi.gc(handle, ffi.C.CloseHandle)}, MT)
  end
end

--- Open first found process by name
-- @string process name to open
-- @int[opt] access access to the process object
-- @return @{Process} object
-- @function Process.openByName
function M.openByName(name, access)
  local snapshot = ffi.C.CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0)
  if snapshot == INVALID_HANDLE_VALUE then
    return
  end

  ffi.gc(snapshot, ffi.C.CloseHandle)

  local entry = ffi.new("PROCESSENTRY32[1]")
  entry[0].dwSize = ffi.sizeof(entry)

  if ffi.C.Process32First(snapshot, entry[0]) ~= 0 then
    repeat
      local procName = ffi.string(entry[0].szExeFile)
      if procName:lower() == name then
        return M.open(entry[0].th32ProcessID, access)
      end
    until ffi.C.Process32Next(snapshot, entry[0]) == 0
  end
end

--- Create Process Object from handle
-- @int handle handle of the process
-- @return @{Process} object
-- @function Process.fromHandle
function M.fromHandle(handle)
  return setmetatable({handle = handle}, MT)
end

--- Create Process Object from current process
-- @return @{Process} object
-- @function Process.current
function M.current()
  return M.fromHandle(ffi.C.GetCurrentProcess())
end

--- Is the handle is the current process
-- return boolean
-- @functino Process.isCurrentProcess`
function M.isCurrentProcess(handle)
  return ffi.C.GetProcessId(handle) == ffi.C.GetCurrentProcessId()
end

function M._getGetters()
  return Getters
end

function Methods:_getPolicy(policyType, ctype, ctypePtr)
  local buffer = ctype()
  if ffi.C.GetProcessMitigationPolicy(self.handle, policyType, buffer, ffi.sizeof(buffer)) ~= 0 then
    return ffi.cast(ctypePtr, buffer)
  end
end

--- General routine to get infomration about the process
-- @param infoClass `PROCESSINFOCLASS`
-- @param ctype C type returned by `ffi.typeof()`
-- @param ctypePtr pointer to the type
-- @param[opt=sizeof(ctype)] assumedSize assumed size of the query info output
-- @return typed pointer depends on `typeName` or `nil`
-- @function queryInfo
function Methods:queryInfo(infoClass, ctype, ctypePtr, assumedSize)
  local data = assumedSize and ffi.new("char[?]", assumedSize) or ctype()
  local size = assumedSize or ffi.sizeof(ctype)
  local retSize = ffi.new("ULONG[1]")
  local err = ntdll.NtQueryInformationProcess(self.handle, infoClass, data, size, retSize)
  if NT_SUCCESS(err) then
    return ffi.cast(ctypePtr, data), retSize[0]
  elseif IS_STATUS(err, STATUS_BUFFER_TOO_SMALL) or IS_STATUS(err, STATUS_INFO_LENGTH_MISMATCH) then
    size = retSize[0] * 2
    data = ffi.new("char[?]", size)
    if data then
      err = ntdll.NtQueryInformationProcess(self.handle, infoClass, data, size, retSize)
      if NT_SUCCESS(err) then
        return ffi.cast(ctypePtr, data), retSize[0]
      end
    end
  end
end

--- Create thread in the target process
-- @param funcAddr address of the function for thread thread
-- @param paramAddr address of the argument for the thread
-- @return @{Thread} object
-- @function createThread
function Methods:createThread(funcAddr, paramAddr)
  local tid = ffi.new("DWORD[1]")
  local handle = ffi.C.CreateRemoteThread(self.handle, nil, 0, funcAddr, paramAddr, 0, tid)
  if handle ~= NULL then
    return Thread.fromHandle(handle, tid[0])
  end
end

--- Allocate virtual memory in the process
-- @int size of memory
-- @int[opt] protect the memory protection for the region of the pages
-- @int[opt] allocType the type of memory allocation
-- @return pointer to the allocated region or `nil`
-- @function memAlloc
function Methods:memAlloc(size, protect, allocType)
  return vm.alloc(self.handle, size, protect or PAGE_EXECUTE_READWRITE, allocType or bor(MEM_COMMIT, MEM_RESERVE))
end

--- Free virtual memory region in the process
-- @int addr address of the memory region
-- @return `true` if success or `false` otherwise
-- @function memFree
function Methods:memFree(addr)
  return vm.free(self.handle, addr)
end

--- Read memory from the process
-- @int addr address of the memory region
-- @param buffer (***cdata***) buffer to read into
-- @int size size of bytes to read
-- @return `true` if success or `false` otherwise
-- @function memRead
function Methods:memRead(addr, buffer, size)
  return vm.read(self.handle, addr, buffer, size or ffi.sizeof(buffer))
end

--- Write data to the process
-- @int addr address of the memory region
-- @param buffer (***cdata*** or ***string***) buffer with data to write
-- @int size of the data (*optional if* `buffer` *is string*)
-- @return `true` if success or `false` otherwise
-- @function memWrite
function Methods:memWrite(addr, buffer, size)
  if type(buffer) == "string" then
    return vm.write(self.handle, addr, buffer, #buffer)
  else
    return vm.write(self.handle, addr, buffer, size)
  end
end

--- Change protection of the target memory region
-- @int addr address of the memory region
-- @int size size of the region
-- @param protect new protect of the memory region
-- @return `true` if success or `false` otherwise
-- @function memProtect
function Methods:memProtect(addr, size, protect)
  return vm.protect(self.handle, addr, size, protect)
end

--- Query information about a memory region
-- @int addr address of the memory region
-- @return [`MEMORY_BASIC_INFORMATION`](https://docs.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-memory_basic_information) or `nil`
-- @function memQuery
function Methods:memQuery(addr)
  return vm.query(self.handle, addr)
end

--- Close process handle
-- @function close
function Methods:close()
  ffi.C.CloseHandle(ffi.gc(self.handle, nil))
end

--- Terminate process with optional code
-- @int[opt] code process termination status
-- @function terminate
function Methods:terminate(code)
  ffi.C.TerminateProcess(self.handle, code or 0)
end

return M
