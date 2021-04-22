local lm = require 'luamake'

lm:import '3rd/bee.lua/make.lua'

lm.rootdir = "3rd/luaffi"

local function dynasm(output, input, flags)
    lm:build ("dynasm_"..output) {
        "$luamake", "lua", "@src/dynasm/dynasm.lua",
        "-LNE",
        flags or {},
        "-o", "@src/"..output,
        "@src/"..input,
        output = "src/"..output,
    }
end

dynasm('call_x86.h', 'call_x86.dasc', {'-D', 'X32WIN'})
dynasm('call_x64.h', 'call_x86.dasc', {'-D', 'X64'})
dynasm('call_x64win.h', 'call_x86.dasc', {'-D', 'X64', '-D', 'X64WIN'})
dynasm('call_arm.h', 'call_arm.dasc')

lm:phony {
    input = {
        "src/call_x86.h",
        "src/call_x64.h",
        "src/call_x64win.h",
        "src/call_arm.h",
    },
    output = "src/call.c",
}

lm:lua_library "ffi" {
    luaversion = "lua54",
    sources = {
        "src/*.c",
        "!src/test.c",
    },
    ldflags = "/EXPORT:luaopen_ffi"
}

lm.rootdir = "."

lm:source_set 'detours' {
    rootdir = "3rd/detours/src",
    permissive = true,
    sources = {
        "*.cpp",
        "!uimports.cpp"
    }
}

lm:lua_dll 'hook' {
    deps = {
        'detours',
    },
    sources = {
        'src/luaopen_ffi_hook.cpp',
        'src/inline.cpp',
    },
}

lm:default {
    'bee',
    'lua',
    'ffi',
    'hook',
}
