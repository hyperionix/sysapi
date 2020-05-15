setfenv(1, require "sysapi-ns")
local time = require "time.time"
local M = {}

ffi.cdef [[
  BOOL QueryPerformanceCounter(
    LARGE_INTEGER *lpPerformanceCount
  );

  BOOL QueryPerformanceFrequency(
    LARGE_INTEGER *lpFrequency
  );
]]

local LI_BUF = ffi.new("LARGE_INTEGER")

local function qpf()
  ffi.C.QueryPerformanceFrequency(LI_BUF)
  return tonumber(LI_BUF.QuadPart)
end

local function qpc()
  ffi.C.QueryPerformanceCounter(LI_BUF)
  return tonumber(LI_BUF.QuadPart)
end

function M.timeme(func)
  local start = qpc()
  func()
  return ((qpc() - start) / qpf()) * 1000 * 1000 * 1000
end

function M.measure(func, iterCnt, factor)
  local t =
    M.timeme(
    function()
      for i = 1, iterCnt do
        func()
      end
    end
  )

  if factor == "us" then
    return time.nsToUs(t)
  elseif factor == "ms" then
    return time.nsToMs(t)
  elseif factor == "sec" then
    return time.nsToSec(t)
  else
    return t
  end
end

---@class BenchmarkResult
---@field total integer
---@field rate integer
local BenchmarkResult = {}

---@param func any
---@param iterCnt any
---@return BenchmarkResult
function M.measure2(func, iterCnt, factor)
  local t = M.measure(func, iterCnt, factor)
  return {total = t, rate = t / iterCnt}
end

return M
