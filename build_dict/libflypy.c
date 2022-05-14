#include "mydict.h"

static int get_word_by_code (lua_State *L) {
    uint32_t return_cnt = 0;
    uint32_t hash       = 0;

    //check and fetch the arguments
    const char *input = luaL_checkstring(L, 1);
    for (size_t i = 0; i < strlen(input); i++) {
        if (input[i] < 'a' || input[i] > 'z')
        {
            goto EXIT_LABEL;
        }
        hash += (uint32_t)((input[i] - 'a' + 1) * pow(27, i));
    }

    while (hash != 0) {
        if (0 == flypy_dict[hash].word[0]) {
            goto EXIT_LABEL;
        }
        // lua_pushstring(L, flypy_dict[hash].word);
        lua_newtable(L);
        lua_pushstring(L, "word");
        lua_pushstring(L, flypy_dict[hash].word);
        lua_settable(L, -3);

        lua_pushstring(L, "frequency");
        lua_pushinteger(L, flypy_dict[hash].frequency);
        lua_settable(L, -3);

        hash = flypy_dict[hash].next;
        return_cnt++;
    }

EXIT_LABEL:
    //return number of results
    return return_cnt;
}

//library to be registered
static const struct luaL_Reg libflypy [] = {
      {"get_word_by_code", get_word_by_code},
      {NULL, NULL}  /* sentinel */
    };

int luaopen_libflypy(lua_State *L){
    luaL_newlib(L, libflypy);
    return 1;
}
