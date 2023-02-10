local DICT_HASH_MAX = 2^32
local WORD_LEN_MAX = 4*3
local HEADER_FILE_NAME = "dict.h"
local HEAD =
[[
#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"
typedef struct word {
    uint32_t next;
    uint8_t is_list;
    uint8_t frequency;
    char word[14];
}DICT;
DICT dict[] = {
]]
local TAIL =
[[
};
]]

local function tbl_isempty(t)
  if t == nil or next(t) == nil then
    return true
  end
  return false
end

local function get_hash_by_bytes(...)
  local hash = 0
  for i, byte in ipairs(...) do
    local alpha = byte - 96
    hash = hash + alpha * 27 ^ (i - 1)
  end
  return math.floor(hash)
end

local function get_dict_from_file(file)
  local dict = {}

  -- line: code=frequency,word
  for line in io.lines(file) do
    local code, frequency, word = line:match("(.*)=(.*),(.*)")
    if not code or not frequency or not word then
      print("pattern not match: " .. line)
      break
    end

    code = code:gsub("%s+", "")
    frequency = frequency:gsub("%s+", "")
    word = word:gsub("%s+", "")
    if code:len() == 0 or frequency:len() == 0 or word:len() == 0 then
      print("missed items: " .. line)
      break
    end

    if word:len() > WORD_LEN_MAX then
      print(string.format("word len limited to %d: %s", WORD_LEN_MAX, word))
      break
    end

    local hash = get_hash_by_bytes({code:byte(1, -1)})
    dict[hash] = dict[hash] or {}
    table.insert(dict[hash], {
      next = 0,
      is_list=false,
      frequency=frequency,
      word=word
    })
  end
  return dict
end

local function find_new_hash(dict, hash_begin)
  for i = hash_begin + 1, DICT_HASH_MAX do
    if tbl_isempty(dict[i]) then
      dict[i] = {}
      return i
    end
  end
  error(string.format("dict szie exceed limit: %d", DICT_HASH_MAX))
  os.exit(-1)
end

-- hash:[word] -> hash:word
local function average_dict(unaverage_dict)
  local dict = {}
  -- entry
  for hash_idx, item in pairs(unaverage_dict) do
    if not tbl_isempty(item) then
      dict[hash_idx] = item[1]
    end
  end

  -- list
  for hash_idx, item in pairs(unaverage_dict) do
    local last_item = dict[hash_idx]
    for other_idx = 2, #item do
      local new_hash = find_new_hash(unaverage_dict, hash_idx)
      last_item.next = new_hash
      dict[new_hash] = item[other_idx]
      last_item = dict[new_hash]
      dict[new_hash].is_list = true
    end
  end
  return dict
end

local function save_dict(dict)
  local file = io.open(HEADER_FILE_NAME, "w")
  if file == nil then
    error(string.format("file open failed: %s", HEADER_FILE_NAME))
    os.exit(-1)
    return
  end
  file:write(HEAD)
  for hash_idx, item in pairs(dict) do
    file:write(string.format("    [%d] = {%d, %d, %s, \"%s\"},\n",
      hash_idx,
      item.next,
      (function ()
        if item.is_list then
          return 1
        else
          return 0
        end
      end)(),
      item.frequency,
      item.word))
  end

  file:write(TAIL)
  file:close()
end

save_dict(average_dict(get_dict_from_file(arg[1])))
