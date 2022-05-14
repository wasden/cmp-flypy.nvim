# cmp-flypy.nvim
A chinese IM for neovim  
![image](https://github.com/wasden/cmp-flypy.nvim/blob/main/img/screenshot.png)
## Description
小鹤音形码表挂接，写注释用的（默认只在注释里开启）
为什么不用输入法？neovide不支持fcitx
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
}

-- nvim-cmp setup
require('cmp').setup({
  sources = {
    { name = 'flypy' },
  },
})

```
