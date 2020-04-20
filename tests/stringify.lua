setfenv(1, require "sysapi-ns")
local stringify = require "utils.stringify"

assert(stringify.value(SERVICE_RUNNING, "SERVICE_STATE") == "SERVICE_RUNNING")
assert(stringify.value(SERVICE_RUNNING, stringify.getTable("SERVICE_STATE")) == "SERVICE_RUNNING")

assert(stringify.mask(SERVICE_RECOGNIZER_DRIVER, "SERVICE_TYPE") == "SERVICE_RECOGNIZER_DRIVER")
assert(stringify.mask(SERVICE_RECOGNIZER_DRIVER, stringify.getTable("SERVICE_TYPE")) == "SERVICE_RECOGNIZER_DRIVER")
