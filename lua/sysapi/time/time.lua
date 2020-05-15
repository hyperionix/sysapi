--- Time operations
--
-- @module time
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
require "time.time-windef"

local date = os.date
local tonumber = tonumber

local M = {}

--- Convert Windows FILETIME into UNIX timestamp
-- @param ft Windows FILETIME
-- @return UNIX timestamp
-- @function time.toUnixTimestamp
function M.toUnixTimestamp(ft)
  return tonumber((ft - EPOCH_BIAS) / TICKS_PER_SEC)
end

--- Convert UNIX timestamp to human readable representation
-- @param ts UNIX timestamp value
-- @return string with human representation of the timestamp
-- @function time.toHumanReadable
function M.toHumanReadable(ts)
  return date("%c", ts)
end

--- Convert nanoseconds to microseconds
-- @function time.nsToUs
function M.nsToUs(ns)
  return ns / (1000)
end

--- Convert nanoseconds to milliseconds
-- @function time.nsToMs
function M.nsToMs(ns)
  return ns / (1000 * 1000)
end

--- Convert nanoseconds to seconds
-- @function time.nsToSec
function M.nsToSec(ns)
  return ns / (1000 * 1000 * 1000)
end

return M
