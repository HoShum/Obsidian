#Java #Maven

# Maven相关

## 基本命令



## 安装时跳过测试
使用命令：`mvn install -DskipTests` 

## 展示所有依赖

使用命令：`mvn dependency:tree`

如果在Linux下，还可以通过管道符进行筛选，如：`mvn dependency:tree | grep "io.netty"`

如果只想分析某个模块，可以这样：`mvn dependency:tree -Dincludes=groupId:artifactId`