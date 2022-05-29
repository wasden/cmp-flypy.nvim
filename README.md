# cmp-flypy.nvim
A chinese IM for neovim  
![Peek-flypy](https://user-images.githubusercontent.com/26076025/170810014-1192d292-2add-4070-b8b3-a5de8e676ae9.gif)
## Description
使用补全插件无缝输入中英文（码表挂接）
## Feature
* 与其他补全同时存在
* 无需切换，直接输入中英文
* 小鹤音形(flypy)
* 98五笔(wubi98)  
  ![Peek-wubi98](https://user-images.githubusercontent.com/26076025/170859645-56a4c79e-e1af-4cb4-bd0a-bf79334bd221.gif)

## Requirements
* neovim
* nvim-cmp
## Installation
```lua
-- packer
use {
  'wasden/cmp-flypy.nvim',
  run = "make",                    -- make flypy只编译小鹤音形， make wubi98只编译98五笔， make或make all全编译
  after = "nvim-cmp",
  config = function()              -- 配置config以修改默认配置
    require("flypy").setup({
      dict_name = "flypy",         -- 选择码表：flypy为小鹤音形，wubi98为98五笔
      comment = true,              -- 在所有文件类型的注释下开启
      filetype = { "markdown", },  -- 在指定文件类型下开启
      num_filter = true,           -- 数字筛选
      source_code = false,         -- 显示原码
    })
  end
}

-- nvim-cmp 配置源
require('cmp').setup({
  sources = {
    { name = 'flypy' },
  },
})
 -- 预选中时空格上屏配置（nvim-cmp)
["<Space>"] = cmp.mapping(function(fallback)
  if cmp.visible() then
    local selected_entry = cmp.core.view:get_selected_entry()
    if not selected_entry then
      return fallback()
    end
    if selected_entry.source.name == "flypy" and not cmp.confirm({select=true}) then
      return fallback()
    end
  else
    fallback()
  end
end,
{"i","s",}),


```
