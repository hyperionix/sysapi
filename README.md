# sysapi
LuaJIT library for simplifying usage of Windows low-level API like [WinAPI](https://docs.microsoft.com/en-us/windows/win32/apiindex/api-index-portal) or NT API

## usage
### local
```bat
xcopy .\lua\sysapi %LUAJIT_DIR%\lua\sysapi\ /E
```
Then in your code
```Lua
require "sysapi"
local Process = require "process"
local File = require "file"
...
```
## run tests
```bat
luajit.exe .\run.lua`
```

## documentation generation
You may need to install [ldoc](https://stevedonovan.github.io/ldoc/)
```bat
luarocks install ldoc
```
Assume you have luarocks trees `bin` directory in PATH
```bat
ldoc.bat . -i
```