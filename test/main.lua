
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
