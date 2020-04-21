setfenv(1, require "sysapi-ns")
local Process = require "process.Process"
local Sid = require "sid.Sid"

local function testMem(p)
  local ok, err =
    pcall(
    function()
      local targetMem = p:memAlloc(1024)
      assert(targetMem)
      assert(p:memFree(targetMem) == 1)

      local targetMem = p:memAlloc(1024)
      assert(targetMem)
      local info = p:memQuery(targetMem)
      assert(info)
      assert(info.AllocationProtect == PAGE_EXECUTE_READWRITE)
      assert(p:memFree(targetMem) == 1)

      local targetMem = p:memAlloc(1024, PAGE_READONLY)
      assert(targetMem)
      local info = p:memQuery(targetMem)
      assert(info)
      assert(info.AllocationProtect == PAGE_READONLY)
      assert(p:memFree(targetMem) == 1)

      local targetMem = p:memAlloc(1024)
      assert(targetMem)
      assert(p:memProtect(targetMem, 1024, PAGE_READONLY) == 1)
      local info = p:memQuery(targetMem)
      assert(info)
      assert(info.AllocationProtect == PAGE_READONLY)
      assert(p:memFree(targetMem) == 1)
    end
  )
  if not ok then
    print(err, ffi.C.GetLastError())
  end
end

local function testQuery(p)
  local ok, err =
    pcall(
    function()
      local info =
        p:queryInfo(
        ffi.C.ProcessBasicInformation,
        ffi.typeof("PROCESS_BASIC_INFORMATION"),
        ffi.typeof("PPROCESS_BASIC_INFORMATION")
      )
      assert(info)
      assert(toaddress(info.UniqueProcessId) == p.pid)
    end
  )

  if not ok then
    print(err, ffi.C.GetLastError())
  end
end

local function testToken(p)
  local ok, err =
    pcall(
    function()
      local token = p.token
      assert(token)
      local info = token:queryInfo(ffi.C.TokenUser, ffi.typeof("TOKEN_USER"), ffi.typeof("PTOKEN_USER"))
      assert(info)
      local sid = Sid.init(info.User.Sid)
      print(sid:toString())
      print(sid:getDomainAndUsername())
    end
  )
  if not ok then
    print(err)
  end
end

local function testMisc(p)
  assert(p.backingFile:lower() == [[c:\windows\system32\notepad.exe]])
  print(p.createTime)
end

local p = Process.run("notepad.exe")
if p then
  testMem(p)
  testQuery(p)
  testToken(p)
  testMisc(p)

  p:terminate()
  p:close()
end
