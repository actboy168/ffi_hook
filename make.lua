local lm = require 'luamake'

lm:import '3rd/bee.lua/make.lua'

lm:build 'ffi_dynasm' {
    '$luamake', 'lua', 'make/ffi_dynasm.lua',
    output = "3rd/bee.lua/3rd/luaffi/src/call_x86.h",
}

lm:phony {
    input = "3rd/bee.lua/3rd/luaffi/src/call_x86.h",
    output = "3rd/bee.lua/3rd/luaffi/src/call.c",
}

lm:shared_library 'ffi' {
    deps = {
        'lua54',
        'ffi_dynasm'
    },
    sources = {
        '3rd/bee.lua/3rd/luaffi/src/*.c',
        '!3rd/bee.lua/3rd/luaffi/src/test.c',
    },
    ldflags = '/EXPORT:luaopen_ffi'
}

lm:source_set 'detours' {
    rootdir = "3rd/detours/src",
    permissive = true,
    sources = {
        "*.cpp",
        "!uimports.cpp"
    }
}

lm:shared_library 'hook' {
    deps = {
        'lua54',
        'detours',
    },
    sources = {
        'src/luaopen_ffi_hook.cpp',
        'src/inline.cpp',
    },
    ldflags = '/EXPORT:luaopen_hook'
}

lm:default {
    'bee',
    'lua',
    'ffi',
    'hook',
}
