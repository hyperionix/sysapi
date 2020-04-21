setfenv(1, require "sysapi-ns")
local tinsert, tsort = table.insert, table.sort
local pairs, setmetatable = pairs, setmetatable

SysapiMod =
  setmetatable(
  {
    all = {},
    getAll = function(self)
      local res = ""
      local names = {}
      for name in pairs(self.all) do
        tinsert(names, name)
      end
      tsort(names)

      for i = 1, #names do
        res = res .. tostring(self.all[names[i]])
      end

      return res
    end
  },
  {
    __call = function(self, name)
      local mod =
        setmetatable(
        {
          name = name
        },
        {
          __tostring = function(self)
            local fields = {}
            local res = self.name .. "\n"
            for field in pairs(self) do
              if field ~= "name" then
                tinsert(fields, field)
              end
            end
            tsort(fields)
            for _, field in pairs(fields) do
              res = res .. "  " .. field .. "\n"
            end
            return res
          end
        }
      )

      self.all[name] = mod
      return mod
    end
  }
)
