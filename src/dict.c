#include "ctype.h"
#include "math.h"
#include "string.h"
#include "dict.h"
#include "query.h"

#define MAX_CODE_LEN 4
typedef void (*QUERY_ITEM_HANDLE)(lua_State *L, uint32_t hash, const char *code);

static void add_dict_as_table(lua_State *L, uint32_t hash, const char *code)
{
    lua_newtable(L);
    lua_pushstring(L, "word");
    lua_pushstring(L, dict[hash].word);
    lua_settable(L, -3);

    lua_pushstring(L, "frequency");
    lua_pushinteger(L, dict[hash].frequency);
    lua_settable(L, -3);

    lua_pushstring(L, "code");
    lua_pushstring(L, code);
    lua_settable(L, -3);
}

static int get_hash_by_code(const char *code)
{
    uint32_t hash = 0;
    for (size_t i = 0; i < strlen(code); i++)
    {
        if (!islower(code[i]))
        {
            return 0;
        }
        hash += (uint32_t)((code[i] - 'a' + 1) * pow(27, i));
    }
    return hash;
}

static int query_items_by_hash(lua_State *L,  uint32_t hash, QUERY_ITEM_HANDLE item_handle, const char *code)
{
    uint32_t return_cnt = 0;

    while (hash != 0)
    {
        if (0 == dict[hash].word[0])
        {
            goto EXIT_LABEL;
        }

        item_handle(L, hash, code);

        hash = dict[hash].next;
        return_cnt++;
    }

EXIT_LABEL:
    return return_cnt;
}

int query(lua_State *L)
{
    uint32_t    return_cnt     = 0;
    const char *input_string   = luaL_checkstring(L, 1);
    size_t      input_len      = strlen(input_string);
    size_t      code_begin_idx = input_len > MAX_CODE_LEN ? input_len - MAX_CODE_LEN : 0;

    for (size_t i = code_begin_idx; i < input_len; i++)
    {
        const char *code = &input_string[i];
        return_cnt += query_items_by_hash(L, get_hash_by_code(code), add_dict_as_table, code);
    }
    return return_cnt;
}
