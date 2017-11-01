# ffi hook

这是一个借助[luaffi](https://github.com/jmckaskill/luaffi)实现的inline hook库。这是一个简单的例子

``` lua
local ffi = require 'ffi'
local hk = require 'ffi_hook'

function ffi.hook(real, fake)
    return hk.install(real, fake, ffi.new)
end

function ffi.unhook(h)
    hk.uninstall(h)
end

ffi.cdef [[
    int __stdcall MessageBoxA(int hWnd, const char* lpText, const char* lpCaption, unsigned int uType);
]]

local realMessageBoxA 
realMessageBoxA = ffi.hook(ffi.C.MessageBoxA, function(hwnd, text, title, type)
    return realMessageBoxA(hwnd, 'Hello ' .. ffi.string(text), ffi.string(title), type)
end)
ffi.C.MessageBoxA(0, 'Test', 'Title', 0)
ffi.unhook(realMessageBoxA)
ffi.C.MessageBoxA(0, 'Test', 'Title', 0)
```

# build

1. luaffi 两个主流的luaffi对lua5.3的支持都有不同的问题（[luaffi](https://github.com/jmckaskill/luaffi)、[luaffifb](https://github.com/facebookarchive/luaffifb)）。你可以使用我的版本[luaffi](https://github.com/actboy168/YDWE/tree/master/OpenSource/luaffi)，不过只支持x86，需要其他平台的版本可以自行参考修改。

2. ffi_hook中有两个函数的实现没有提供，base::hook::inline_install/base::hook::inline_uninstall。你可以自行接入一个InlineHook库，例如[Detours](https://www.microsoft.com/en-us/research/project/detours)、[MinHook](https://github.com/TsudaKageyu/minhook)、[EasyHook](https://github.com/EasyHook/EasyHook)等。
