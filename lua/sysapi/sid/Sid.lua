--- Class describes system SID object
--
-- @classmod Sid
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "sid.sid-windef"
local ntdll = ffi.load("ntdll")
local advapi32 = ffi.load("advapi32")
assert(ntdll)

local Sid = SysapiMod("Sid")
local Sid_MT = {__index = Sid}

--- Initialize Sid object
-- @param sid system SID pointer
-- @return @{Sid} object
function Sid.init(sid)
  if ntdll.RtlValidSid(sid) then
    local size = ntdll.RtlLengthSid(sid)
    local sidBuf = ffi.new("BYTE[?]", size)
    ntdll.RtlCopySid(size, sidBuf, sid)
    return setmetatable({sid = sidBuf}, Sid_MT)
  end
end

--- Convert Sid object to string
-- @return string representation of Sid
function Sid:toString()
  local us = ffi.new("UNICODE_STRING[1]")
  local err = ntdll.RtlConvertSidToUnicodeString(us, self.sid, true)
  if NT_SUCCESS(err) then
    return string.fromUS(us[0])
  end
end

--- Get domain and username from Sid
-- @return domain
-- @return username
function Sid:getDomainAndUsername()
  local nameSize = ffi.new("DWORD[1]")
  local domainSize = ffi.new("DWORD[1]")
  local sidNameUse = ffi.new("SID_NAME_USE[1]", ffi.C.SidTypeUnknown)
  local err = advapi32.LookupAccountSidA(nil, self.sid, nil, nameSize, nil, domainSize, sidNameUse)
  if err ~= 0 or ffi.C.GetLastError() ~= ERROR_INSUFFICIENT_BUFFER then
    return
  end

  local name = ffi.new("char[?]", nameSize[0])
  local domain = ffi.new("char[?]", domainSize[0])

  err = advapi32.LookupAccountSidA(nil, self.sid, name, nameSize, domain, domainSize, sidNameUse)
  if err == 0 then
    return
  end

  return ffi.string(domain, domainSize[0]), ffi.string(name, nameSize[0])
end

return Sid
