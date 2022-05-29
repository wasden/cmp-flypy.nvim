local source = {}

local defaults = {
  dict_name = "flypy",
  comment = true, -- 在所有文件类型的注释下开启
  filetype = { "markdown", },  -- 在指定文件类型下开启
  num_filter = true, -- 数字筛选
  source_code = true,
}

local config = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.config = config
  return self
end

function source.setup(opts)
  if not opts then
    return
  end
  local new_config = vim.tbl_deep_extend('keep', opts, defaults)
  setmetatable(config, {__index = new_config})
end

-- @return boolean
function source:is_available()
  if not self.dict then
    self.dict = require("lib" .. self.config.dict_name)
  end

  if self.config.filetype and vim.tbl_contains(self.config.filetype, vim.api.nvim_buf_get_option(0, "filetype")) then
    return true
  end

  if self.config.comment then
    local context = require 'cmp.config.context'
    return context.in_treesitter_capture("comment")
    or context.in_syntax_group("Comment")
  end
  return false
end

-- @return string
function source:get_debug_name()
  return 'flypy'
end

-- @return string
function source:get_keyword_pattern()
  return [[\<\l\+\d\?]]
end

-- Return trigger characters for triggering completion. (Optional)
function source:get_trigger_characters()
  return { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z' }
end

function source:complete(params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset)
  local query_result = { self.dict.query(input) }
  local reply_items = {}
  vim.pretty_print(self.config)

  for i, query_item in pairs(query_result) do
    local uncode = string.sub(input, 1, #input - #query_item.code)
    table.insert(reply_items, {
      label = (function ()
        local label = query_item.word
        if self.config.source_code then
          label = string.format("%s(%s)", label, query_item.code)
        end
        if self.config.num_filter then
          label = string.format("%s(%d)", label, i)
        end
        return label
      end)(),
      word = string.format("%s%s", uncode, query_item.word),
      filterText = (function ()
        if self.config.num_filter then
          return string.format("%s%d", input, i)
        else
          return input
        end
      end)(),
      sortText = i,
      preselect = #uncode == 0,
      -- commitCharacters = {i},
    })
  end
  callback(reply_items)
end

return source
