setfenv(1, require "sysapi-ns")
require "ioctl.ioctl-windef"
local stringify = require "utils.stringify"

local DEVICE_TYPE_TABLE = stringify.getTable("DEVICE_TYPE")
local METHOD_CODE_TABLE = stringify.getTable("METHOD_CODE")

local rshift, band = bit.rshift, bit.band

local M = {}

function M.getMethod(ctlCode)
  local method = METHOD_FROM_CTL_CODE(ctlCode)
  return METHOD_CODE_TABLE[method]
end

function M.getDeviceType(ctlCode)
  local deviceType = DEVICE_TYPE_FROM_CTL_CODE(ctlCode)
  return DEVICE_TYPE_TABLE[deviceType] or ("CUSTOM_" .. tohex(deviceType))
end

function M.getFunction(ctlCode)
  return rshift(band(ctlCode, 0x3ffc), 0x2)
end

return M
