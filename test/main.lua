
local ffi = require 'ffi'
local hk = require 'ffi_hook'

function ffi.hook(name, realf, fakef)
    local def = tostring(ffi.debug().functions[name]):sub(7, -2)
    local _, real = debug.getupvalue(realf, 1)
    return hk.install(real, ffi.new(def, fakef), ffi.new(def, nil))
end

function ffi.unhook(h)
    hk.uninstall(h)
end

ffi.cdef [[
    int __stdcall MessageBoxA(int hWnd, const char* lpText, const char* lpCaption, unsigned int uType);
]]

local realMessageBoxA 
realMessageBoxA = ffi.hook('MessageBoxA', ffi.C.MessageBoxA, function(hwnd, text, title, type)
    return realMessageBoxA(hwnd, 'Hello ' .. ffi.string(text), ffi.string(title), type)
end)
ffi.C.MessageBoxA(0, 'Test', 'Title', 0)
ffi.unhook(realMessageBoxA)
ffi.C.MessageBoxA(0, 'Test', 'Title', 0)
