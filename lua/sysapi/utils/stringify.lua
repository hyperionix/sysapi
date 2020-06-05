--- Stringify utilities
--
-- @module stringify
-- @pragma nostrip
local btohex, rshift, lshift, band = bit.tohex, bit.rshift, bit.lshift, bit.band
local M = {}
local allStringifyTables = {}

local function trimField(name, trimStart, trimEnd)
  return name:sub(trimStart and #trimStart + 1 or 0, trimEnd and -(#trimEnd + 1) or #name)
end

--- Function marks start of a stringify table values.
-- Call this function before defining variables you want to stringify @see a *-windef.lua file
-- @param name name of the table
-- @param[opt] trimStart symbols to trim from start
-- @param[opt] trimEnd symbols to trim from end
-- @usage StringifyTableStart("MY_TABLE", "FOO_", "_BAR")
-- FOO_VALUE_1_BAR = 1
-- FOO_VALUE_2_BAR = 2
-- FOO_VALUE_3_BAR = 3
-- StringifyTableEnd()
-- ..
-- print(stringify.value(1, "MY_TABLE")) -- will print "VALUE_1"
function StringifyTableStart(name, trimStart, trimEnd)
  local prevEnv = getfenv(2)
  local newEnv =
    setmetatable(
    {
      getfenv = getfenv,
      setfenv = setfenv,
      prevEnv = prevEnv,
      tableName = name,
      trimStart = trimStart,
      trimEnd = trimEnd,
      StringifyTableEnd = StringifyTableEnd
    },
    {__index = prevEnv}
  )
  setfenv(2, newEnv)
end

--- Function ends stringify table values previously started with @{StringifyTableStart}.
function StringifyTableEnd()
  local env = getfenv(2)
  local prevEnv = env.prevEnv
  setfenv(2, prevEnv)
  env.StringifyTableEnd = nil
  env.setfenv = nil
  env.getfenv = nil
  env.prevEnv = nil
  local trimStart = env.trimStart
  env.trimStart = nil
  local trimEnd = env.trimEnd
  env.trimEnd = nil
  local tableName = env.tableName
  env.tableName = nil

  local newTable = {}
  for field, value in pairs(env) do
    newTable[value] = trimField(field, trimStart, trimEnd)
    prevEnv[field] = value
  end
  allStringifyTables[tableName] = newTable
end

--- Return stringify table with name.
--
-- The table should be created with @{StringifyTableStart}. Its better to cache the table and pass
-- it into @{stringify.mask} or @{stringify.value} instead table name to increase performance a little bit.
-- @param name name of the table
-- @function stringify.getTable
function M.getTable(name)
  return allStringifyTables[name]
end

--- Stringify a byte buffer.
-- @param buffer buffer
-- @param size size of the buffer
-- @return string representation of the buffer
-- @function stringify.byteBuffer
function M.byteBuffer(buffer, size)
  if buffer then
    local ret = ""
    for i = 0, size - 1 do
      ret = ret .. btohex(buffer[i], 2)
    end

    return ret
  else
    return ""
  end
end

--- Stringify a bit mask
-- @param mask bit mask to stringify
-- @param tableOrName could be stringify table or name of the table created with @{StringifyTableStart}
-- @return string representation of the bit mask
-- @function stringify.mask
function M.mask(mask, tableOrName)
  if type(tableOrName) == "string" then
    tableOrName = allStringifyTables[tableOrName]
    if not tableOrName then
      return ""
    end
  end

  local res = ""
  local bitPos = 0
  while mask ~= 0 do
    if band(mask, 1) ~= 0 then
      local strValue = tableOrName[lshift(1, bitPos)] or ""
      res = res .. strValue .. " "
    end

    mask = rshift(mask, 1)
    bitPos = bitPos + 1
  end
  return res:sub(0, -2)
end

--- Stringify a value
-- @param value value to stringify
-- @param tableOrName could be stringify table or name of the table created with @{StringifyTableStart}
-- @return string representation of the value
-- @function stringify.value
function M.value(value, tableOrName)
  if type(tableOrName) == "string" then
    tableOrName = allStringifyTables[tableOrName]
  end
  if tableOrName then
    return tableOrName[value] or ""
  end
  return ""
end

return M
