local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.libflypy = require("libflypy")
  return self
end

-- @return boolean
function source:is_available()
  local context = require 'cmp.config.context'
  return context.in_treesitter_capture("comment")
  or context.in_syntax_group("Comment")
end

-- @return string
function source:get_debug_name()
  return 'flypy'
end

-- @return string
function source:get_keyword_pattern()
  return [[\<\l\{1,4\}\>]]
end

-- Return trigger characters for triggering completion. (Optional)
function source:get_trigger_characters()
  return { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z' }
end

function source:complete(params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset)
  local query_result = { self.libflypy.get_word_by_code(input) }
  local reply_items = {}

  for _, query_item in pairs(query_result) do
    table.insert(reply_items, {
      label = query_item.word,
      word = query_item.word,
      filterText = input,
      preselect = true,
    })
  end
  callback(reply_items)
end

return source.new()
