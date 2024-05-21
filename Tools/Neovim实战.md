# Neovim实战

## 安装

Mac下：

```bash
brew install neovim
```

## 配置总览

```
├── LICENSE
├── README.md
├── init.lua
└── lua
    ├── autocmds.lua
    ├── basic.lua
    ├── colorscheme.lua
    ├── keybindings.lua
    ├── lsp
    │   ├── cmp.lua
    │   ├── config
    │   │   ├── bash.lua
    │   │   ├── emmet.lua
    │   │   ├── html.lua
    │   │   ├── json.lua
    │   │   ├── lua.lua
    │   │   ├── markdown.lua
    │   │   ├── pyright.lua
    │   │   ├── rust.lua
    │   │   └── ts.lua
    │   ├── formatter.lua
    │   ├── null-ls.lua
    │   ├── setup.lua
    │   └── ui.lua
    ├── plugin-config
    │   ├── bufferline.lua
    │   ├── comment.lua
    │   ├── dashboard.lua
    │   ├── gitsigns.lua
    │   ├── indent-blankline.lua
    │   ├── lualine.lua
    │   ├── nvim-autopairs.lua
    │   ├── nvim-tree.lua
    │   ├── nvim-treesitter.lua
    │   ├── project.lua
    │   ├── surround.lua
    │   ├── telescope.lua
    │   ├── toggleterm.lua
    │   ├── vimspector.lua
    │   └── which-key.lua
    ├── plugins.lua
    └── utils
        ├── fix-yank.lua
        ├── global.lua
        └── im-select.lua
```

首先 **init.lua** 是整个配置的入口文件，负责引用所有其他的模块，基本上想要打开或关闭某个插件只要在这里修改一行代码即可。

- **basic.lua：** 基础配置，是对默认配置的一个重置。

- **colorscheme.lua：** 我们安装的主题皮肤配置，在这里切换主题。

- **keybindings.lua：** 快捷键的设置，所有插件的快捷键也都会放在这里。

- **plugins.lua：** 插件安装管理，插件安装或卸载全在这里设置。

- lsp 文件夹：

  是对 Neovim 内置 LSP 功能的配置，包括常见编程语言与语法提示等。

  - **config** **：** 文件夹包含各种语言服务器单独的配置文件。
  - **setup.lua** **：** 内置 LSP 的配置。
  - **cmp.lua** **：** 语法自动补全补全的配置，包括各种补全源，与自定义代码段。
  - **ui.lua：** 对内置 LSP 功能增强和 UI 美化。
  - **formatter.lua：** 独立代码格式化功能。

- **plugin-config 文件夹：** 是对第三方插件的配置，未来每添加一个插件，这里就多一个配置文件。

- **utils 文件夹：** 是对常见问题的修改，包括输入法切换，针对 windows 的特殊配置等。

## 基础配置

> Neovim和Vim的最大不同就在于，Neovim全面使用Lua语法来编写配置文件，因此后面全部都会使用Lua来进行配置

Neovim的配置文件入口放在了`~/.config/nvim/init.lua`

## 参考资料

- [掘金小册](https://juejin.cn/book/7051157342770954277)
- [GitHub开箱即用配置](https://github.com/nshen/InsisVim?tab=readme-ov-file)



