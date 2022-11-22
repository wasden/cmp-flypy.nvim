local source = {}

local defaults = {
  dict_name = "flypy",
  comment = true, -- 在所有文件类型的注释下开启
  filetype = { "markdown", },  -- 在指定文件类型下开启
  num_filter = true, -- 数字筛选
  source_code = true,
  space_select_enable = false, -- 空格上屏使能
  space_select_enable_hint = "",
  space_select_switch_mappings = "<C-Space>", -- 空格上屏开关按键映射
}

local config = {}

local gen_lib_query = (function ()
  local this_dir = string.sub(debug.getinfo(1).source, 2, #"/flypy.lua" * -1)
  return function (dict_name)
    local lib_dir = string.format("%s../build/lib%s.so", this_dir, dict_name)
    return package.loadlib(lib_dir, "query")
  end
end)()

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.config = config
  setmetatable(config, {__index = defaults})
  return self
end

function source.space_select_init()
  if not config.space_select_enable then
    return
  end
  config.space_select_on = true
  local cmp = require "cmp"
  cmp.setup {
    mapping = {
      ["<Space>"] = cmp.mapping(function(fallback)
        if not config.space_select_on then
          return fallback()
        end
        if cmp.visible() then
          local selected_entry = cmp.core.view:get_selected_entry()
          if selected_entry
              and selected_entry.source.name == "flypy"
              and not cmp.confirm({ select = true }) then
            return fallback()
          end
        end
        fallback()
      end,
        { "i", "s", }),
      [config.space_select_switch_mappings] = cmp.mapping(function (fallback)
        if not config.space_select_enable then
          return fallback()
        end
        source.space_select_switch()
        if config.space_select_on then
          local selected_entry = cmp.core.view:get_selected_entry()
          if selected_entry and selected_entry.source.name == "flypy" then
            cmp.confirm({ select = true })
          else
            return fallback()
          end
        else
          return fallback()
        end
      end)
    },
  }
end

function source.space_select_switch()
  if not config.space_select_enable then
    return
  end
  if config.space_select_on then
    config.space_select_on = false
  else
    config.space_select_on = true
  end
end

function source.setup(opts)
  if not opts then
    return
  end
  local new_config = vim.tbl_deep_extend('keep', opts, defaults)
  setmetatable(config, {__index = new_config})
  source.space_select_init()
end

-- @return boolean
function source:is_available()
  if not self.query then
    self.query = gen_lib_query(self.config.dict_name)
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
  return [[\l\+\d\?]]
end

-- Return trigger characters for triggering completion. (Optional)
function source:get_trigger_characters()
  return { 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z' }
end

function source:complete(params, callback)
  local input = string.sub(params.context.cursor_before_line, params.offset)
  local query_result = { self.query(input) }
  local reply_items = {}

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
        if self.config.space_select_enable_hint and self.config.space_select_on and #uncode == 0 then
          label = string.format("%s %s", label, self.config.space_select_enable_hint)
        end
        return label
      end)(),
      -- word = string.format("%s%s", uncode, query_item.word),
      filterText = (function ()
        if self.config.num_filter then
          return string.format("%s%d", input, i)
        else
          return input
        end
      end)(),
      sortText = i,
      preselect = #uncode == 0,
      textEdit = {
        range = {
          start = {
            line = params.context.cursor.line,
            character = params.offset,
          },
          ['end'] = {
            line = params.context.cursor.line,
            character = params.context.cursor.col - 1,
          },
        },
        insert = {
        -- no utf-8
          start = {
            line = params.context.cursor.line,
            character = params.context.cursor.character - (params.context.cursor.col - params.offset),
          },
          ['end'] = {
            line = params.context.cursor.line,
            character = params.context.cursor.character,
          },
        },
        newText = string.format("%s%s", uncode, query_item.word),
      }
    })
  end
  callback(reply_items)
end

return source
