local perf = require "utils.perf"

local ITER_CNT = 1000000000
perf.measure(
  function()
    local obj = {}
    return obj
  end,
  ITER_CNT,
  "Local table empty"
)

perf.measure(
  function()
    local obj = {}
    obj.f1 = nil
    return obj
  end,
  ITER_CNT,
  "Local table with one nil field"
)

perf.measure(
  function()
    local obj = {}
    obj.f1 = nil
    obj.f2 = nil
    obj.f3 = nil
    obj.f4 = nil
    obj.f5 = nil
    obj.f6 = nil
    return obj
  end,
  ITER_CNT,
  "Local table with multiple nil fields"
)

perf.measure(
  function()
    return {}
  end,
  ITER_CNT,
  "Table empty"
)

perf.measure(
  function()
    return {f1 = nil}
  end,
  ITER_CNT,
  "Table with one nil field"
)

perf.measure(
  function()
    return {
      f1 = nil,
      f2 = nil,
      f3 = nil,
      f4 = nil,
      f5 = nil,
      f6 = nil
    }
  end,
  ITER_CNT,
  "Table with multiple nil fields"
)

local MT = {}
perf.measure(
  function()
    return setmetatable({}, MT)
  end,
  ITER_CNT,
  "Table emtpy with predefined metatable"
)

perf.measure(
  function()
    return setmetatable({}, {})
  end,
  ITER_CNT,
  "Table empty with new created metatable"
)
