setfenv(1, require "sysapi-ns")

ffi.cdef [[
  errno_t _splitpath_s(
    const char * path,
    char * drive,
    size_t driveNumberOfElements,
    char * dir,
    size_t dirNumberOfElements,
    char * fname,
    size_t nameNumberOfElements,
    char * ext,
    size_t extNumberOfElements
);
]]
