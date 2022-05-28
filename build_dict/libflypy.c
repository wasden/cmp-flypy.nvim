#include "ctype.h"
#include "math.h"
#include "string.h"
#include "mydict.h"

#define MAX_CODE_LEN 4

static int query_by_hash(lua_State *L, const char *code)
{
    uint32_t return_cnt = 0;
    uint32_t hash       = 0;

    for (size_t i = 0; i < strlen(code); i++)
    {
        if (!islower(code[i]))
        {
            goto EXIT_LABEL;
        }
        hash += (uint32_t)((code[i] - 'a' + 1) * pow(27, i));
    }

    while (hash != 0)
    {
        if (0 == flypy_dict[hash].word[0])
        {
            goto EXIT_LABEL;
        }
        lua_newtable(L);
        lua_pushstring(L, "word");
        lua_pushstring(L, flypy_dict[hash].word);
        lua_settable(L, -3);

        lua_pushstring(L, "frequency");
        lua_pushinteger(L, flypy_dict[hash].frequency);
        lua_settable(L, -3);

        lua_pushstring(L, "code");
        lua_pushstring(L, code);
        lua_settable(L, -3);

        hash = flypy_dict[hash].next;
        return_cnt++;
    }

EXIT_LABEL:
    return return_cnt;
}

static int query(lua_State *L)
{
    uint32_t    return_cnt     = 0;
    const char *input_string   = luaL_checkstring(L, 1);
    size_t      input_len      = strlen(input_string);
    size_t      code_begin_idx = input_len > MAX_CODE_LEN ? input_len - MAX_CODE_LEN : 0;

    for (size_t i = code_begin_idx; i < input_len; i++)
    {
        return_cnt += query_by_hash(L, &input_string[i]);
    }
    return return_cnt;
}

static const struct luaL_Reg libflypy[] = 
{
    { "query", query }, { NULL, NULL }
};

int luaopen_libflypy(lua_State *L)
{
    luaL_newlib(L, libflypy);
    return 1;
}
