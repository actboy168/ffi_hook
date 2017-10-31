#include <lua.hpp>
#include <base/hook/inline.h>

struct hook_t {
	uintptr_t real = 0;
	uintptr_t fake = 0;
};

static int hook_call(lua_State* L) {
	luaL_testudata(L, 1, "ffi.hook");
	if (LUA_TTABLE != lua_getuservalue(L, 1)) {
		return 0;
	}
	if (LUA_TUSERDATA != lua_geti(L, -1, 3)) {
		return 0;
	}
	lua_remove(L, -2);
	lua_replace(L, 1);
	lua_call(L, lua_gettop(L) - 1, LUA_MULTRET);
	return lua_gettop(L);
}

static int install(lua_State* L) {
	luaL_checktype(L, 1, LUA_TUSERDATA);
	luaL_checktype(L, 2, LUA_TUSERDATA);
	luaL_checktype(L, 3, LUA_TUSERDATA);
	hook_t* h = (hook_t*)lua_newuserdata(L, sizeof hook_t);
	if (!h) {
		return 0;
	}
	luaL_setmetatable(L, "ffi.hook");
	lua_newtable(L);
	for (int i = 1; i <= 3; ++i) {
		lua_pushvalue(L, i);
		lua_seti(L, -2, i);
	}
	lua_setuservalue(L, -2);

	h->real = *(uintptr_t*)((uintptr_t)lua_touserdata(L, 1) + 16);
	h->fake = *(uintptr_t*)((uintptr_t)lua_touserdata(L, 2) + 16);
	base::hook::inline_install(&h->real, h->fake);
	uintptr_t cd = (uintptr_t)lua_touserdata(L, 3);
	*(uintptr_t*)(cd + 16) = h->real;
	return 1;
}

static int uninstall(lua_State* L) {
	hook_t* h = (hook_t*)luaL_testudata(L, 1, "ffi.hook");
	if (!h) {
		return 0;
	}
	base::hook::inline_uninstall(&h->real, h->fake);
	return 0;
}

extern "C" __declspec(dllexport)
int luaopen_ffi_hook(lua_State* L)
{
	static luaL_Reg mt[] = {
		{ "__call", hook_call },
		{ NULL, NULL },
	};
	luaL_newmetatable(L, "ffi.hook");
	luaL_setfuncs(L, mt, 0);

	static luaL_Reg lib[] = {
		{ "install", install },
		{ "uninstall", uninstall },
		{ NULL, NULL }
	};
	luaL_newlib(L, lib);
	return 1;
}

#include <windows.h>

BOOL APIENTRY DllMain(HMODULE module, DWORD reason, LPVOID pReserved)
{
	if (reason == DLL_PROCESS_ATTACH)
	{
		DisableThreadLibraryCalls(module);
	}
	return TRUE;
}
