# Neovim配置

## 前置说明
- 一定要安装字体，否则有些图标无法显示[NerdFonts](https://www.nerdfonts.com/font-downloads)

## 配置

### 基础配置basic.lua
 
```
-- utf8
vim.g.encoding = "UTF-8"
vim.o.fileencoding = 'utf-8'
-- jkhl 移动时光标周围保留8行
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
-- 使用相对行号
vim.wo.number = true
vim.wo.relativenumber = true
-- 高亮所在行
vim.wo.cursorline = true
-- 显示左侧图标指示列
vim.wo.signcolumn = "yes"
-- 右侧参考线，超过表示代码太长了，考虑换行
vim.wo.colorcolumn = "80"
-- 缩进2个空格等于一个Tab
vim.o.tabstop = 2
vim.bo.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftround = true
-- >> << 时移动长度
vim.o.shiftwidth = 2
vim.bo.shiftwidth = 2
-- 空格替代tab
vim.o.expandtab = true
vim.bo.expandtab = true
-- 新行对齐当前行
vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true
-- 搜索大小写不敏感，除非包含大写
vim.o.ignorecase = true
vim.o.smartcase = true
-- 搜索不要高亮
vim.o.hlsearch = false
-- 边输入边搜索
vim.o.incsearch = true
-- 命令行高为2，提供足够的显示空间
vim.o.cmdheight = 2
-- 当文件被外部程序修改时，自动加载
vim.o.autoread = true
vim.bo.autoread = true
-- 禁止折行
vim.wo.wrap = false
-- 光标在行首尾时<Left><Right>可以跳到下一行
vim.o.whichwrap = '<,>,[,]'
-- 允许隐藏被修改过的buffer
vim.o.hidden = true
-- 鼠标支持
vim.o.mouse = "a"
-- 禁止创建备份文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false
-- smaller updatetime
vim.o.updatetime = 300
-- 设置 timeoutlen 为等待键盘快捷键连击时间500毫秒，可根据需要设置
vim.o.timeoutlen = 500
-- split window 从下边和右边出现
vim.o.splitbelow = true
vim.o.splitright = true
-- 自动补全不自动选中
vim.g.completeopt = "menu,menuone,noselect,noinsert"
-- 样式
vim.o.background = "dark"
vim.o.termguicolors = true
vim.opt.termguicolors = true
-- 不可见字符的显示，这里只把空格显示为一个点
vim.o.list = true
vim.o.listchars = "space:·"
-- 补全增强
vim.o.wildmenu = true
-- Dont' pass messages to |ins-completin menu|
vim.o.shortmess = vim.o.shortmess .. 'c'
-- 补全最多显示10行
vim.o.pumheight = 10
-- 永远显示 tabline
vim.o.showtabline = 2
-- 使用增强状态栏插件后不再需要 vim 的模式提示
vim.o.showmode = false
```

解释：
- vim.g.{name}：全局变量
- vim.b.{name}：缓冲区变量
- vim.w.{name}：窗口变量
- vim.bo.{option}：buffer-local选项
- vim.wo.{option}：window-local选项

### 快捷键配置
Neovim中分为两类快捷键
- vim.api.nvim_set_keymap()：全局快捷键
- vim.api.nvim_buf_set_keymap()：Buffer快捷键

而格式为：
```lua
vim.api.nvim_set_keymap('模式', '按键', '映射的按键', 'options')
```

模式：
- n Normal模式
- i Insert模式
- v Visual模式
- t Terminal模式
- c Command模式

options：
大部分会设置为{noremap = true, silent = true}，表示不会循环映射，且不输出多余信息

下面是我的配置：

```lua
```

### 插件安装和管理

一般会使用插件管理器来管理插件，而最常用的插件管理器是`vim-plug`和`Packer.nvim`，下面记录的是`Packer.nvim`

首先是从Github上安装插件

```bash
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
~/.local/share/nvim/site/pack/packer/start/packer.nvim
```
注意直接复制执行，不然改了插件管理器的地址，可能会导致找不到

然后在新建`lua/plugins.lua`文件，如下：

```lua
local packer = require("packer")
packer.startup(
  function(use)
   -- Packer 可以管理自己本身
   use 'wbthomason/packer.nvim'
   -- 你的插件列表...
end)
```

要安装自己的插件，只需要使用`use 'name/repo'`即可
当我们安装自己的插件后，先保存文件，然后使用`PackerSync`来安装（注意要保证能连上GitHub），安装完后，按`q`即可退出
默认情况下，插件会安装在`~${标准目录}/site/pack/packer/start/目录下`，当然你可以通过`:echo stdpath("data")`来查看自己的**标准目录**

### 配置主题
众所周知，一个好看的IDE，最重要的当然是主题！🤣
Neovim本身也内置了一些主题，可以使用`:colorscheme Tab`来查看，它们都保存在`$VIMRUNTIME/colors/`目录下
> 同样道理，可以使用`:echo $VIMRUNTIME`开看具体路径

但是由于默认并没有我们想要的主题，因此下面就来看如何配置自己想要的主题
同样的，首先新建一个`lua/colorscheme.lua`文件，如下：

```lua
local colorscheme = "tokyonight" 
local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " 没有找到！")
  return
end
```

这里稍微解释下代码：
- `local colorscheme` = "tokyonight"，定义了一个变量，表示想要改成这个主题
- `local status_ok, _`，这个函数的第二个返回`_`可能有点费解，实际上它的意思是，如果调用vim.cmd成功，则返回的结果可以忽略，而如果失败，则这个值为错误信息，同样不重要
- `= pcall(vim.cmd, "colorscheme " .. colorscheme)`，
	- 首先`pcall`是lua的一个错误捕获函数，它会返回两个值，第一个是status，表示函数执行是否成功，而第二个则是报错值（报错的话）
	- 这里的`..`实际是lua的字符串拼接函数，最终会变成`colorscheme tokyonight`
>这里有个坑，因为所谓的vim.cmd其实就相当于`:xxx`，所以这里的`colorscheme `最后是有一个**空格的**，如果不加这个空格，命令就会变成`:colorschemetokyonight`

#### 安装第三方主题
这里推荐安装Neovim制作的第三方主题，具体GitHub地址[Colorschemes](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Colorschemes)
而要使用也非常简单，在`plugins.lua`文件下，添加如下内容：

```lua
packer.startup({
  function(use)
    -- Packer 可以升级自己
    use("wbthomason/packer.nvim")
    --------------------- colorschemes --------------------
    -- tokyonight
    use("folke/tokyonight.nvim") 
    -------------------------------------------------------
})
```
只需要注意能连上GitHub，且保证名字没有错即可

### 配置侧边栏插件
首先侧边栏插件的GitHub地址：[nvim-tree](https://github.com/nvim-tree/nvim-tree.lua)
然后则是引入依赖：
```lua
packer.startup({
  function(use)
    -- nvim-tree (新增)
    use({ "kyazdani42/nvim-tree.lua", requires = "kyazdani42/nvim-web-devicons" })
```
`requires`表示前面的需要依赖后面的，因此安装的时候会把两个都安装







