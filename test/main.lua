local ffi = require 'ffi'
local hk = require 'hook'

hk.initialize(ffi.new)

function ffi.hook(target, detour)
    return hk.inline(target, detour)
end

ffi.cdef [[
    typedef unsigned int HANDLE;
    typedef unsigned int DWORD;
    typedef unsigned int LPSECURITY_ATTRIBUTES;
    typedef const char* LPCSTR;
    typedef const wchar_t* LPWCSTR;

    HANDLE __stdcall CreateFileA(
        LPCSTR                lpFileName,
        DWORD                 dwDesiredAccess,
        DWORD                 dwShareMode,
        LPSECURITY_ATTRIBUTES lpSecurityAttributes,
        DWORD                 dwCreationDisposition,
        DWORD                 dwFlagsAndAttributes,
        HANDLE                hTemplateFile
      );
      HANDLE __stdcall CreateFileW(
          LPWCSTR               lpFileName,
          DWORD                 dwDesiredAccess,
          DWORD                 dwShareMode,
          LPSECURITY_ATTRIBUTES lpSecurityAttributes,
          DWORD                 dwCreationDisposition,
          DWORD                 dwFlagsAndAttributes,
          HANDLE                hTemplateFile
        );
]]

local uni = require 'unicode'

local hook = {}

hook.CreateFileA = ffi.hook(ffi.C.CreateFileA, function(filename, ...)
    print('CreateFileA', ffi.string(filename))
    return hook.CreateFileA(ffi.string(filename), ...)
end)
hook.CreateFileW = ffi.hook(ffi.C.CreateFileW, function(filename, ...)
    print('CreateFileW', uni.w2u(filename))
    return hook.CreateFileW(filename, ...)
end)

print(io.open('main.lua'))
