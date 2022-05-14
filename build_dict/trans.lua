local raw_dict = {}
local DICT_MAX = 2^32
local function turn_code_to_num(...)
  local result = 0
  for i, v in ipairs(...) do
    v = v - 96
    result = result + v * 27 ^ (i - 1)
  end
  return math.floor(result)
end
local function get_dict_from_file(file_name)
  local function pure_string(str)
    return string.gsub(str, "%s+", "")
  end
  for line in io.lines(file_name) do
    local equal_pos = string.find(line, "=")
    if nil == equal_pos then
      break
    end
    local code = pure_string(string.sub(line, 1, equal_pos - 1))
    local comma_pos = string.find(line, ",")
    local frequency = pure_string(string.sub(line, equal_pos + 1, comma_pos - 1))
    local word = pure_string(string.sub(line, comma_pos + 1))
    local num = turn_code_to_num({string.byte(code, 1, -1)})
    raw_dict[num] = raw_dict[num] or {}
    raw_dict[num][#raw_dict[num] + 1] = {next = 0, is_list=false, frequency=frequency, word=word}
  end
end

local function find_new_num(begin)
  for i = begin + 1, DICT_MAX do
    if raw_dict[i] == nil then
      raw_dict[i] = {}
      return i
    end
  end
  error(string.format("dict szie more then %d", DICT_MAX))
end

local function average_dict()
  for num, num_item in pairs(raw_dict) do
    local num_item_size = #num_item
    local last_list = num_item[1]
    for i = 2, num_item_size do
      local new_num = find_new_num(num)
      last_list.next = new_num
      raw_dict[new_num][1] = num_item[i]
      last_list = raw_dict[new_num][1]
      raw_dict[new_num][1].is_list = true
      num_item[i] = nil
    end
  end
end

local function print_dict()
  local function bool2int(value)
    if value then
      return 1
    else
      return 0
    end
  end
  print(
[[#include "stdint.h"
#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"
#include "string.h"
#include "math.h"
typedef struct word {
    uint32_t next;
    uint8_t is_list;
    uint8_t frequency;
    char word[10];
}DICT;
DICT flypy_dict[] = {]])
  for num, num_item in pairs(raw_dict) do
    print(string.format("    [%d] = {%d, %d, %s, \"%s\"},",
      num,
      num_item[1].next,
      bool2int(num_item[1].is_list),
      num_item[1].frequency,
      num_item[1].word))
  end

  print("};")
end

get_dict_from_file("default_dict.ini")
get_dict_from_file("user_dict.ini")
average_dict()

print_dict()
