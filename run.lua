-- Running tests and/or examples
package.path = package.path .. [[lua\?.lua;lua\?\init.lua;]]

local TEST_DIR = "tests"

require "sysapi"

local function parse_args(args)
  local ret = {}
  for i = 1, #args do
    local k, v = args[i]:match("--(%w+)=(%w+)")
    if k then
      ret[k] = v
    end
  end
  return ret
end

local args = parse_args(arg)

local fs = require "fs.fs"
for path in fs.dir(TEST_DIR .. [[\*.lua]]) do
  if not args.filter or path:sub(0, -5) == args.filter then
    print("-------------------------")
    print(path)
    print("-------------------------")
    local f, err = loadfile(TEST_DIR .. [[\]] .. path)
    if f then
      local ok, err = pcall(f)
      if not ok then
        print(err)
      end
    else
      print(err)
    end
  end
end
