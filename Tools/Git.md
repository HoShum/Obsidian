#Git
# Git实用笔记
本文档记录一些Git相关的常用的操作
## Git Stash
### 原理
Git Stash相当于一个Git提供用来缓存修改的工具，搭配回退等操作，非常好用；它的原理是将本地没提交的内容（**包含工作区和暂存区**）缓存起来，并从当前分支移除（**即恢复到当前HEAD指针指向的状态**），缓存的数据结构为先进后出的**栈结构**
注意：该命令只会对被Git管理的文件有效！
### 查看缓存
有两种方式：
① `git stash list` 该命令可以查看当前所有的缓存
② `git stash show -p 'stash@{1}'` 该命令可以用来查看具体某个缓存
### 使用缓存
有两种方式：
① `git stash pop` 该命令会拉取最前面的一个缓存
② `git stash apply 0` 或者`git stash apply 'stash@{0}'` 该命令可以指定使用哪个缓存
### 放入缓存
有两种方式：
① `git stash` 该命令会将当前所有未提交的内容放到缓存
② `git stash save 'xxx'` 该命令可以指定一个名字进行缓存
### 删除缓存
有两种方式
① `git stash drop 0` 或者`git stash drop 'stash@{0}'` 该命令可以指定删除某个缓存
② `git stash clear` 该命令会清空所有缓存
## Git Branch
### 基本操作
`git branch 分支名` 可以创建一个分支
`git checkout 分支名` 可以切换一个分支
`git branch -d 分支名` 可以删除一个分支
`git push origin --delete 分支名` 可以删除远端一个分支
`git pull origin 分支名` 可以拉取一个远端的分支，但前提是你本地要先切换到这个分支
## Git Remote
该命令主要用来管理远端地址，常用的有以下：
`git remote -v`可以用来查看远端地址
`git remote add origin xxx` 用来添加远端仓库，注意，这个origin是仓库别名，可以自定义