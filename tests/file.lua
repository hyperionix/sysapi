setfenv(1, require "sysapi-ns")
local File = require "file.File"
local time = require "time"
local bor = bit.bor

local f = File.create("blbalbal", CREATE_ALWAYS, bor(GENERIC_READWRITE, DELETE))
f:delete()
