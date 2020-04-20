setfenv(1, require "sysapi-ns")
local fs = require "fs.fs"

print(fs.getDownloadsDirectory())
print(fs.getWindowsDirectory())
print(fs.getStartupDirectory())
print(fs.getUserProfileDirectory())
