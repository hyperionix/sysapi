local M = {}

function M.timeme(func)
  local start = os.clock()
  func()
  return os.clock() - start
end

function M.measure(func, iterCnt, name)
  print(
    (name and name .. ": " or "unnamed: ") ..
      M.timeme(
        function()
          for i = 1, iterCnt do
            func()
          end
        end
      )
  )
end

return M
