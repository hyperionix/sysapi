setfenv(1, require "sysapi-ns")
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

function M.measure(func, iterCnt)
  local t =
    M.timeme(
    function()
      for i = 1, iterCnt do
        func()
      end
    end
  )

  return t
end

return M
