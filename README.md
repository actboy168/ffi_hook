# ffi hook

这是一个借助[luaffi](https://github.com/jmckaskill/luaffi)实现的inline hook库。这是一个简单的例子

``` lua
local ffi = require 'ffi'
local hk = require 'ffi_hook'

hk.initialize(ffi.new)

function ffi.hook(target, detour)
    return hk.install(target, detour)
end

ffi.cdef [[
    int __stdcall MessageBoxA(int hWnd, const char* lpText, const char* lpCaption, unsigned int uType);
]]

local hookMessageBoxA 
hookMessageBoxA = ffi.hook(ffi.C.MessageBoxA, function(hwnd, text, title, type)
    return hookMessageBoxA(hwnd, 'Hello ' .. ffi.string(text), ffi.string(title), type)
end)
ffi.C.MessageBoxA(0, 'Test', 'Title', 0)
hookMessageBoxA:remove()
ffi.C.MessageBoxA(0, 'Test', 'Title', 0)
```
