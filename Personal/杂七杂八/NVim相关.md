# NVim相关
#Vim 
## WSL下配置
### 常见问题
#### 如何共用Windows的剪切板
主要参考了这篇文章：[Wsl的nvim与Windows系统剪切板通信 - 知乎](https://zhuanlan.zhihu.com/p/450705959)
然后我在NVim的`~./config/nvim/lua/basic.lua`文件中，添加了如下配置：
```lua
if vim.fn.has('wsl') then
  vim.cmd [[
  augroup Yank
  autocmd!
  autocmd TextYankPost * :call system('/mnt/c/windows/system32/clip.exe ',@")
  augroup END
  ]]
end
```
就实现了共享剪切板的功能