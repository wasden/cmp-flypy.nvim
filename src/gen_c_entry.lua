local c_entry_name = arg[1] .. ".c" -- libname.c
local file = io.open(c_entry_name, "w")
if not file then
  error("open file failed: %s", c_entry_name)
  os.exit(-1)
  return
end
local templete =
[[
#include "query.h"

static const struct luaL_Reg libname[] = 
{
    { "query", query }, { NULL, NULL }
};

int luaopen_libname(lua_State *L)
{
    luaL_newlib(L, libname);
    return 1;
}
]]
local content = templete:gsub("libname", arg[1])
file:write(content)
file:close()
