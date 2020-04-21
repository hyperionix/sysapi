--- Class describes FileResources object
--
-- @classmod FileResources
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
local versionDll = ffi.load("version")
local band, rshift, lshift = bit.band, bit.rshift, bit.lshift

local FileResources = {}
local FileResources_MT = {__index = FileResources}
local M = {}

--- Create @{FileResources} object
-- @string path file path
-- @return @{FileResources} object or `nil`
-- @function FileResources.create
function M.create(path)
  local buf = ffi.new("char[?]", 16 * 1024)
  if versionDll.GetFileVersionInfoA(path, 0, 1024 * 1024, buf) ~= 0 then
    return setmetatable({verInfo = buf}, FileResources_MT)
  end
end

local function queryValue(verInfo, subBlock, binValue)
  local length = ffi.new("ULONG[1]")
  local info = ffi.new("PVOID[1]")
  local err = versionDll.VerQueryValueA(verInfo, subBlock or [[\]], info, length)
  if err ~= 0 and length[0] ~= 0 then
    if binValue then
      return ffi.string(info[0], length[0])
    else
      return ffi.string(info[0], length[0] - 1) -- trim trailing \0 for string values
    end
  end
end

--- Get numeric verion of the file.
-- @return string with the file version
function FileResources:getVersion()
  local info = queryValue(self.verInfo, nil, true)
  if not info then
    return
  end

  info = ffi.cast("VS_FIXEDFILEINFO*", info)[0]

  return string.format(
    "%d.%d.%d.%d",
    rshift(band(info.dwFileVersionMS, 0xffff0000), 16),
    band(info.dwFileVersionMS, 0xffff),
    rshift(band(info.dwFileVersionLS, 0xffff0000), 16),
    band(info.dwFileVersionLS, 0xffff)
  )
end

-- TODO: make me private
function FileResources:getLangCP()
  local info = queryValue(self.verInfo, [[\VarFileInfo\Translation]], true)
  if not info then
    self.langCP = lshift(MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US), 16) + 1252
  else
    local buffer = ffi.cast("PUSHORT", info)
    -- Combine the language ID and code page
    self.langCP = lshift(buffer[0], 16) + buffer[1]
  end

  return self.langCP
end

--- Get value of a field in `\StringFileInfo\{lang-codepage}\`
-- @string name name of the field
-- @return a string with value or `nil`
function FileResources:getField(name)
  local langCP = self.langCP or self:getLangCP()
  if langCP then
    local p = ([[\StringFileInfo\%08X\%s]]):format(tonumber(langCP), name)
    local info = queryValue(self.verInfo, p)
    if info then
      return info
    end
  end
end

return M
