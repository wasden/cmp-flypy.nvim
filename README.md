# cmp-flypy.nvim
A chinese IM for neovim  
![Peek-flypy](https://user-images.githubusercontent.com/26076025/170810014-1192d292-2add-4070-b8b3-a5de8e676ae9.gif)
## Description
使用补全插件无缝输入中英文（小鹤音形码表挂接）
## Feature
* 与其他补全同时存在
* 无需切换，直接输入中英文
## Requirements
* neovim
* nvim-cmp
## Installation
```lua
-- packer
use {
  'wasden/cmp-flypy.nvim',
  run = "make",
  after = "nvim-cmp",
  config = function()
    require("flypy").setup({
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
