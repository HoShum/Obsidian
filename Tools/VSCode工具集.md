# VSCode工具集
## 快捷键
- 显示所有命令：`ctrl + P`
- 找到文件：`ctrl + O`
- 切换终端：`alt + 3`
- 关闭Tab：`alt + w`
- 资源管理器：`ctrl + 1`
- 格式化文档（代码）：`alt + F`


## Vim
VSCode也支持Vim插件，但相比于Idea，它使用JSON来进行设置的，以下是我的配置
按理说，如果要用Vim来指定VSCode本身的命令，可以这样干：
```json
{
    "before": ["r", "r"],
    "command": ["editor.action.formatDocument]
}
```
