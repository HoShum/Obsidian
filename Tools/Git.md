#Git
# Git实用笔记
本文档记录一些Git相关的常用的操作
## git clone
普通的克隆非常简单，但如果一个仓库有多个分支，而只想克隆某个分支时，可以使用以下命令：
- `git clone -b <branch> <url>`
## git stash
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
## git branch
### 基本操作
- `git branch 分支名` 可以创建一个分支
- `git checkout 分支名` 可以切换一个分支
- `git branch -d 分支名` 可以删除一个分支，如果要强制删除，可以使用`-D`参数，会把未合并的内容也删除
- `git push origin --delete 分支名` 可以删除远端一个分支
- `git pull origin 分支名` 可以拉取一个远端的分支，但前提是你本地要先切换到这个分支

- `git branch -M 分支名`给分支强制换名，一般用于初始化一个Git分支

### 本地拉取不同分支
情景是这样，本地已经有远端master的分支情况下，想再拉取远端的dev分支该如何操作呢？
首先可以通过`git branch -a`查看有哪些分支
然后可以使用`git checkout -b dev origin/dev`来将远端的dev分支拉取到本地并切换
### 创建孤儿分支
如果我们希望可以创建一支全新的分支，不会保留任何历史记录，此时就可以使用`git checkout --orphan newBranch`来创建一个孤儿分支，此时你会发现使用`git log`会没有任何提交记录
你可以把这支分支上的所有内容都删除掉，然后再提交新的内容
这支分支会和原来的分支没有任何关系

## git rm
这个命令可以用来清除工作目录中的内容，比如像上面那样，创建了一支孤儿分支，需要清理所有内容然后重新提交，就可以使用以下命令
- `git rm -rf *`：清理工作目录下所有内容
- `git clean -fdx`：删除所有未被跟踪的文件和目录（包括被忽略的），其中d属性表示整个目录，x表示被忽略的
## git remote
该命令主要用来管理远端地址，常用的有以下：
`git remote -v`可以用来查看远端地址
`git remote add origin xxx` 用来添加远端仓库，注意，这个origin是仓库别名，可以自定义
## git ignore
### 排除忽略文件
如果已经把.gitignore文件提交到远程仓库，此时如果本地需要把那些之前被忽略的文件重新加入到Git管理的话，可以使用以下命令：
* `git add -f 文件名/文件路径` ：添加指定的文件或文件路径
* `git add -f .`：递归地添加所有被忽略的文件

### 重新添加忽略文件
如果在已经提交.gitignore文件的情况下发现某些文件又需要被忽略，则需要使用以下命令：
1. 先修改.gitignore文件，然后提交
2. 使用`git rm -r --cached .`命令清空Git的缓存
3. 重新使用`git add .`来添加到暂存区
4. （有必要的话）再push到远端

### .gitignore匹配规则
以下由ChatGPT生成
1. **基本语法**：
    - **空行** 或以 `#` 开始的行会被忽略，视为注释。
    - 标准的 glob 模式用于匹配路径名。例如，`*.log` 匹配所有以 `.log` 结尾的文件。
    - 以 `/` 结尾的模式指定目录，会递归地忽略目录下所有内容。例如，`build/` 忽略所有名为 `build` 的目录及其子目录中的所有文件。
    - 以 `/` 开头的模式阻止递归，指定仅匹配仓库根目录下的路径。例如，`/TODO` 仅匹配根目录下的 `TODO` 文件，不匹配 `subdir/TODO`。
    - 使用 `!` 可以否定前面的忽略规则，即强制跟踪某些文件。例如，在忽略所有 `.log` 文件后（`*.log`），可以再添加 `!/important.log` 强制跟踪 `important.log` 文件。
2. **模式匹配**：
    - `*` 匹配任何数量的字符，但不包括目录分隔符（`/`），只作用于单一目录层级。
    - `?` 匹配单一字符。
    - `**` 在模式的开始或结束时使用，表示匹配任何级别的目录。例如，`**/foo` 匹配任何目录下的 `foo` 目录或文件，`foo/**` 匹配 `foo` 目录及其任意深度的所有子目录和文件。
    - `[abc]` 匹配任何一个列在括号中的字符（在这个例子中是 `a`、`b` 或 `c`）。
3. **优先级和冲突**：
    - 当 `.gitignore` 文件中的规则冲突时（如同一文件被一条规则忽略，另一条规则又取消忽略），最后的规则优先。
    - 各个 `.gitignore` 文件的规则是累加的。Git 将检查所有相关的 `.gitignore` 文件（例如一个在项目根目录，一个在子目录中）来决定是否忽略一个文件。
4. **示例**：
    - `*.log` 忽略所有以 `.log` 结尾的文件。
    - `config/*.json` 忽略 `config/` 目录下所有 `.json` 结尾的文件，不会影响其他目录下的 `.json` 文件。
    - `**/*.bak` 忽略所有目录下的以 `.bak` 结尾的文件。
## git config
该命令用来查看Git的配置信息
所有的配置项都会保存到一个叫`.gitconfig`文件中，只是位置不同，跟**范围参数**有关
* local：当前仓库，保存到当前仓库
* global：全局配置，保存到用户主目录下
* system：系统范围，通常保存到`/etc/gitconfig`（不清楚Windows是否如此）

下面是一些Git配置的常用命令
> 注意，大部分命令都可以加上`--[范围参数]`来指定，下面不再赘述
### 查看配置
* `git config --list` ：查看所有配置信息
* `git config key`：查看某个配置，比如我想查看user.name，则输入`git config user.name`

### 编辑配置
* `git config --edit`：进行配置信息的编辑
* `git config key value`：修改/新增配置，比如使用`git config http.proxy http://localhost:7890`

## git tag
该功能是用来打标签
### 打标签
`git tag {tagName}`：针对当前提交版本打标签
`git tag {tagName} {commitId}`：针对指定提交版本打标签
`git tag -a {tagName} -m {TagMessage} {commitId}`：附注标签，同样可以指定版本
### 推送标签
`git push origin --tags`：将本地所有标签推送到远端仓库
`git push origin {tagName}`：将指定标签推送到远端仓库
### 查看标签
`git tag`：查看所有标签信息
`git show {tagName}`：查看指定标签的附注信息
### 删除标签
`git tag -d {tagName}`：删除本地指定标签
`git push origin --delete {tagName}`：将指定删除的标签推送到远端