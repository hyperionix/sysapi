--- Class describes Registry Key object
--
-- @classmod RegKey
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "registry.registry-windef"
local advapi32 = ffi.load("advapi32")

local RegKey = SysapiMod("RegKey")
local RegKey_MT = {__index = RegKey}

--- Create or open if exists a key
-- @param parentKeyHandle handle of the parent key or one of predefined keys: `"HKEY_CLASSES_ROOT"`, `"HKEY_CURRENT_USER"`, `"HKEY_LOCAL_MACHINE"`, `"HKEY_USERS"`
-- @param keyName name of the target key
-- @param[opt=KEY_ALL_ACCESS] access access attributes to the key
-- @param[opt=REG_OPTION_NON_VOLATILE] options
function RegKey:create(parentKeyHandle, keyName, access, options)
  local handle = ffi.new("HKEY[1]")
  local disp = ffi.new("DWORD[1]")

  if
    advapi32.RegCreateKeyExA(
      parentKeyHandle,
      keyName,
      0,
      nil,
      options or REG_OPTION_NON_VOLATILE,
      access or KEY_ALL_ACCESS,
      nil,
      handle,
      disp
    ) == 0
   then
    return setmetatable({handle = ffi.gc(handle[0], advapi32.RegCloseKey)}, RegKey_MT)
  end
end

function RegKey:openPredefined(predefinedKeyHandle)
  return setmetatable({handle = predefinedKeyHandle}, RegKey_MT)
end

--- Open existing key
-- @param parentKeyHandle handle of the parent key or one of predefined keys: `"HKEY_CLASSES_ROOT"`, `"HKEY_CURRENT_USER"`, `"HKEY_LOCAL_MACHINE"`, `"HKEY_USERS"`
-- @param keyName name of the target key
-- @param[opt=KEY_ALL_ACCESS] access access attributes to the key
-- @param[opt=0] options
function RegKey:open(parentKeyHandle, keyName, access, options)
  local handle = ffi.new("HKEY[1]")
  if advapi32.RegOpenKeyExA(parentKeyHandle, keyName, options or 0, access or KEY_ALL_ACCESS, handle) == 0 then
    return setmetatable({handle = ffi.gc(handle[0], advapi32.RegCloseKey)}, RegKey_MT)
  end
end

--- Deletes a subkey and its values
-- @param subKeyName name of the key
-- @return 0 on success
function RegKey:delete(subKeyName)
  return advapi32.RegDeleteKeyA(self.handle, subKeyName)
end

--- Get value of the key
-- @param valueName name of the value
-- @param[opt=nil] subKeyName subkey of the key to get value from
-- @param[opt] size assumed size of the value, if nil the function detemines it itself but it costs additional API call
-- @param[opt=RRF_RT_ANY] flags operation flags
function RegKey:getVal(valueName, subKeyName, size, flags)
  if not size then
    local retSize = ffi.new("DWORD[1]")
    local err = advapi32.RegGetValueA(self.handle, subKeyName, valueName, flags or RRF_RT_ANY, nil, nil, retSize)
    if err ~= 0 then
      return
    end

    size = retSize[0]
  end

  local retSize = ffi.new("DWORD[1]", size)
  local data = ffi.new("char[?]", size)
  local valType = ffi.new("DWORD[1]")
  local err = advapi32.RegGetValueA(self.handle, subKeyName, valueName, flags or RRF_RT_ANY, valType, data, retSize)
  if err == 0 then
    return data, valType[0], retSize[0]
  end
  print(err)
end

--- Set value of the key
-- @param valueName name of the value
-- @param valueType type of the value
-- @param data data to write
-- @param size size of the data
-- @param[opt] subKeyName name of the subkey
-- @return 0 on success
function RegKey:setVal(valueName, valueType, data, size, subKeyName)
  return advapi32.RegSetKeyValueA(self.handle, subKeyName, valueName, valueType, data, size)
end

--- Removes a named value
-- @param valueName name of the value to be removed
-- @return 0 on success
function RegKey:deleteValue(valueName)
  return advapi32.RegDeleteValueA(self.handle, valueName)
end

--- Get the size of the key's subkey with the longest name
-- @return maximum len or nil
function RegKey:getMaxSubkeyNameLen()
  local keyNameLen = ffi.new("DWORD[1]")
  if advapi32.RegQueryInfoKeyA(self.handle, nil, nil, nil, nil, keyNameLen, nil, nil, nil, nil, nil, nil) == 0 then
    return keyNameLen[0]
  end
end

--- Get max value info
-- @return the size of the key's longest value name
-- @return the size of the longest data component among the key's values
function RegKey:getMaxValueInfo()
  local valDataSize = ffi.new("DWORD[1]")
  local valNameLen = ffi.new("DWORD[1]")

  if advapi32.RegQueryInfoKeyA(self.handle, nil, nil, nil, nil, nil, nil, nil, valNameLen, valDataSize, nil, nil) == 0 then
    return valNameLen[0], valDataSize[0]
  end
end

--- Get all information about the key
-- @return table with registry key information
function RegKey:getAllInfo()
  local subKeys = ffi.new("DWORD[1]")
  local maxSubKeyLen = ffi.new("DWORD[1]")
  local maxClassLen = ffi.new("DWORD[1]")
  local values = ffi.new("DWORD[1]")
  local maxValueNameLen = ffi.new("DWORD[1]")
  local maxValueLen = ffi.new("DWORD[1]")
  local sizeSecurityDescriptor = ffi.new("DWORD[1]")
  local lastWriteTime = ffi.new("FILETIME[1]")
  local err =
    advapi32.RegQueryInfoKeyA(
    self.handle,
    nil,
    nil,
    nil,
    subKeys,
    maxSubKeyLen,
    maxClassLen,
    values,
    maxValueNameLen,
    maxValueLen,
    sizeSecurityDescriptor,
    lastWriteTime
  )
  if err == 0 then
    return {
      subKeys = subKeys[0],
      maxSubKeyLen = maxSubKeyLen[0],
      maxClassLen = maxClassLen[0],
      values = values[0],
      maxValueNameLen = maxValueNameLen[0],
      maxValueLen = maxValueLen[0],
      sizeSecurityDescriptor = sizeSecurityDescriptor[0],
      lastWriteTime = ffi.cast("ULARGE_INTEGER*", lastWriteTime)[0].QuadPart
    }
  end
end

--- Enumerate all subkeys of the key
-- @param func function to be called for each key with its name
function RegKey:forEachKey(func)
  local maxNameLen = self:getMaxSubkeyNameLen()
  if maxNameLen then
    maxNameLen = maxNameLen + 1
    local keyNameLen = ffi.new("DWORD[1]")
    local keyName = ffi.new("CHAR[?]", maxNameLen)
    local index = 0
    while true do
      keyNameLen[0] = maxNameLen
      local err = advapi32.RegEnumKeyExA(self.handle, index, keyName, keyNameLen, nil, nil, nil, nil)
      if err == 0 then
        func(ffi.string(keyName, keyNameLen[0]))
        index = index + 1
      else
        break
      end
    end
  end
end

--- Enumerate all values of the key
-- @param func functions to be called for each value with `name`, `valueData`, `valueDataSize` and `valueType`
function RegKey:forEachValue(func)
  local maxValueNameLen, maxValueDataSize = self:getMaxValueInfo()
  if maxValueNameLen then
    maxValueNameLen = maxValueNameLen + 1
    local valDataType = ffi.new("DWORD[1]")
    local valName = ffi.new("CHAR[?]", maxValueNameLen)
    local valData = ffi.new("BYTE[?]", maxValueDataSize)
    local index = 0

    local valNameLen = ffi.new("DWORD[1]")
    local valDataSize = ffi.new("DWORD[1]")
    while true do
      valNameLen[0] = maxValueNameLen
      valDataSize[0] = maxValueDataSize

      local err =
        advapi32.RegEnumValueA(self.handle, index, valName, valNameLen, nil, valDataType, valData, valDataSize)
      if err == 0 then
        func(ffi.string(valName, valNameLen[0]), valData, valDataSize[0], valDataType[0])
        index = index + 1
      else
        break
      end
    end
  end
end

return RegKey
