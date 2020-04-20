--- Class describes system Token object
--
-- @classmod Token
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "token.token-windef"
local stringify = require "utils.stringify"
local Sid = require "sid"
local ntdll = ffi.load("ntdll")
assert(ntdll)

local Token = SysapiMod("Token")
local TokenGetters = {
  --- domain name of the token user SID
  domain = nil,
  --- integrity level
  integrityLevel = nil,
  --- user name of the token user SID
  user = nil
}
local Token_MT = {
  __index = function(self, name)
    local method = rawget(Token, name)
    if method then
      return method
    end

    local getter = rawget(TokenGetters, name)
    if getter then
      return getter(self, name)
    end
  end
}

local types = {
  cache = function(self, name)
    rawset(self, name, ffi.typeof(name))
    rawset(self, "P" .. name, ffi.typeof(name .. "*"))
  end
}

local SECURITY_MANDATORY_TABLE = stringify.getTable("SECURITY_MANDATORY")

types:cache("TOKEN_USER")
types:cache("TOKEN_MANDATORY_LABEL")

local function getUserAndDomain(obj)
  local info = obj:queryInfo(ffi.C.TokenUser, types.TOKEN_USER, types.PTOKEN_USER)
  if info then
    local sid = Sid.init(info.User.Sid)
    local domain, user = sid:getDomainAndUsername()
    rawset(obj, "user", user)
    rawset(obj, "domain", domain)
  end
end

function TokenGetters.user(obj, name)
  getUserAndDomain(obj)
  return rawget(obj, name)
end

function TokenGetters.domain(obj, name)
  getUserAndDomain(obj)
  return rawget(obj, name)
end

function TokenGetters.integrityLevel(obj, name)
  local info = obj:queryInfo(ffi.C.TokenIntegrityLevel, types.TOKEN_MANDATORY_LABEL, types.PTOKEN_MANDATORY_LABEL)
  if info then
    local integrityLvl = ntdll.RtlSubAuthoritySid(info.Label.Sid, 0)
    if integrityLvl ~= NULL then
      integrityLvl = SECURITY_MANDATORY_TABLE[integrityLvl[0]]
      rawset(obj, name, integrityLvl)
      return integrityLvl
    end
  end
end

--- Open process token
-- @param procHandle handle of the process
-- @param[opt=TOKEN_ALL_ACCESS] access to token
-- @function Token.open
function Token.open(procHandle, access)
  local token = ffi.new("HANDLE[1]")
  if ffi.C.OpenProcessToken(procHandle, access or TOKEN_ALL_ACCESS, token) then
    return setmetatable({handle = ffi.gc(token[0], ffi.C.CloseHandle)}, Token_MT)
  end
end

--- Query information about the token
-- @param infoClass `TOKEN_INFORMATION_CLASS`
-- @param ctype C type returned by `ffi.typeof()`
-- @param ctypePtr pointer to the type
-- @return typed pointer depends on `typeName` or `nil`
function Token:queryInfo(infoClass, ctype, ctypePtr)
  local data = ctype()
  local size = ffi.sizeof(ctype)
  local retSize = ffi.new("ULONG[1]")
  local err = ntdll.NtQueryInformationToken(self.handle, infoClass, data, size, retSize)
  if NT_SUCCESS(err) then
    return ffi.cast(ctypePtr, data), retSize[0]
  elseif IS_STATUS(err, STATUS_BUFFER_TOO_SMALL) then
    size = retSize[0]
    data = ffi.new("char[?]", size)
    err = ntdll.NtQueryInformationToken(self.handle, infoClass, data, size, retSize)
    if NT_SUCCESS(err) then
      return ffi.cast(ctypePtr, data), retSize[0]
    end
  end
end

return Token
