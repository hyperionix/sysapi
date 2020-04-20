--- Filesystem path operations
--
-- @module path
-- @pragma nostrip
setfenv(1, require "sysapi-ns")
local msvcrt = ffi.load("msvcrt")
local M = SysapiMod("FilePath")

--- Split full path into the path components
-- @param fullPath full path of a FS target
-- @return `{drive, dir, basename, ext}` a table with the path components
-- @function path.split
function M.split(fullPath)
  local size = #fullPath
  local drive = ffi.new("char[5]")
  local dir = ffi.new("char[?]", size)
  local basename = ffi.new("char[?]", size)
  local ext = ffi.new("char[?]", size)

  if msvcrt._splitpath_s(fullPath, drive, 5, dir, size, basename, size, ext, size) == 0 then
    return {
      drive = ffi.string(drive):toUTF8(),
      dir = ffi.string(dir):toUTF8(),
      basename = ffi.string(basename):toUTF8(),
      ext = ffi.string(ext):toUTF8()
    }
  end
end

return M
