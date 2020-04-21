# sysapi
LuaJIT library for simplifying usage of Windows low-level API like [WinAPI](https://docs.microsoft.com/en-us/windows/win32/apiindex/api-index-portal) or NT API

## Usage
### Local
```bat
xcopy .\lua\sysapi %LUAJIT_DIR%\lua\sysapi\ /E
```
Then in your code
```Lua
require "sysapi"                -- initialize the library
setfenv(1, require "sysapi-ns") -- make available all ffi.cdef definitions, global constants etc
local Process = require "process.Process"
local File = require "file.File"
...
```
## Run tests
```bat
luajit.exe .\run.lua [--filter=<test-name>]
```

## Documentation generation
Generated documentation could be found [here](https://docs.hyperionix.com/sysapi/index.html)
You may need to install [ldoc](https://stevedonovan.github.io/ldoc/)
```bat
luarocks install ldoc
```
Assume you have luarocks trees `bin` directory in PATH
```bat
ldoc.bat . -i
```