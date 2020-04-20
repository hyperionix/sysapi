setfenv(1, require "sysapi-ns")
require "vm.vm-windef"
local bor = bit.bor

local VM = SysapiMod("VM")

function VM.alloc(handle, size, protect, allocType)
  local mem =
    ffi.C.VirtualAllocEx(
    handle,
    nil,
    size,
    allocType or bor(MEM_COMMIT, MEM_RESERVE),
    protect or PAGE_EXECUTE_READWRITE
  )
  if mem ~= NULL then
    return mem
  end
end

function VM.free(handle, addr)
  return ffi.C.VirtualFreeEx(handle, addr, 0, MEM_RELEASE)
end

function VM.read(handle, addr, buffer, size)
  return ffi.C.ReadProcessMemory(handle, addr, buffer, size, nil)
end

function VM.write(handle, addr, buffer, size)
  return ffi.C.WriteProcessMemory(handle, addr, buffer, size, nil)
end

function VM.protect(handle, addr, size, protect)
  local oldProtect = ffi.new("DWORD[1]")
  return ffi.C.VirtualProtectEx(handle, addr, size, protect, oldProtect)
end

function VM.query(handle, addr)
  local mb = ffi.new("MEMORY_BASIC_INFORMATION")
  if ffi.C.VirtualQueryEx(handle, addr, mb, ffi.sizeof(mb)) then
    return mb
  end
end

return VM
