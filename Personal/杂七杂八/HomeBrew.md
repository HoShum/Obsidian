#MacOS #HomeBrew
## 关于HomeBrew
HomeBrew是在MacOS平台下的一个包管理软件，使用它可以很方便地下载和管理一些软件，尤其是一些只需要在后台运行的软件
HomeBrew的路径位于`/opt/homebrew`下
## 基本操作
### 搜索
使用`brew search`命令即可搜索想要的软件
### 安装
使用`brew install` 命令即可安装想要的软件
### 查询&升级
使用`brew info`可用来查看安装好的软件自带的一些信息
使用`brew upgrade`可以用来对软件进行升级
### HomeBrew仓库
HomeBrew默认只有`Formulae`和`Casks`两个仓库
我们可以使用`brew tap`来看有哪些仓库
而如果我们想要添加其它仓库，则可以使用`brew tap`即可依赖一些第三方的仓库，比如使用`brew tap homebrew/services`，即可以使用homebrew来管理后台服务
>更多内容可以参考这篇文章：[Homebrew Taps 添加更多仓库马克 - 知乎](https://zhuanlan.zhihu.com/p/107635134)
