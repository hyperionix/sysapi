setfenv(1, require "sysapi-ns")
require "web.web-windef"

local M = SysapiMod("WEB")
local urlmon = nil

function M.downloadFile(url, outfile)
  if not urlmon then
    urlmon = ffi.load("urlmon")
  end

  return urlmon.URLDownloadToFileA(nil, url, outfile, 0, nil) == 0
end

return M
