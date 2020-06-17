setfenv(1, require "sysapi-ns")
require "strings.strings-windef"
local ntdll = ffi.load("ntdll")
assert(ntdll)

local CP_ACP = 0
local CP_UTF8 = 65001

local MBS_ctype = ffi.typeof "CHAR[?]"
local WCS_ctype = ffi.typeof "WCHAR[?]"
local PWCS_ctype = ffi.typeof "WCHAR*"
local PUS_ctype = ffi.typeof("PUNICODE_STRING")
local WC2MB = ffi.C.WideCharToMultiByte
local MB2WC = ffi.C.MultiByteToWideChar
local WC = 0
local MB = 0

string.fromUS = function(us)
  local sz = WC2MB(CP_UTF8, WC, us.Buffer, us.Length / 2, nil, 0, nil, nil)
  if sz ~= 0 then
    local buf = MBS_ctype(sz)
    if WC2MB(CP_UTF8, WC, us.Buffer, us.Length / 2, buf, sz, nil, nil) ~= 0 then
      return ffi.string(buf, sz)
    end
  end
end

string.fromAS = function(as)
  if as.Buffer ~= ffi.NULL and as.Length ~= 0 then
    return ffi.string(as.Buffer, as.Length)
  end
end

string.fromWC = function(wcs)
  local sz = WC2MB(CP_UTF8, WC, wcs, -1, nil, 0, nil, nil)
  if sz ~= 0 then
    local buf = MBS_ctype(sz)
    if WC2MB(CP_UTF8, WC, wcs, -1, buf, sz, nil, nil) ~= 0 then
      return ffi.string(buf, sz - 1)
    end
  end
end

string.toWC = function(s, code)
  code = code or CP_UTF8
  local sz = MB2WC(code, MB, s, -1, nil, 0)
  if sz ~= 0 then
    local ws = WCS_ctype(sz)
    if MB2WC(code, MB, s, -1, ws, sz) ~= 0 then
      return ws
    end
  end
end

string.toUTF8 = function(s)
  local ws = string.toWC(s, CP_ACP)
  if ws ~= nil then
    return string.fromWC(ws)
  end
end
