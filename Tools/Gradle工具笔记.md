# Gradle工具笔记

#工具 

## 什么是Gradle

[官网地址](https://gradle.org/)

跟Maven差不多，也是用来构建项目的，它跟Maven最大的区别在于，它是采用Groovy或Kotlin语言进行编写的



## 配置

### Gradle User Home

首先和所有默认的配置文件一样，默认都是放在家目录`~/.gralde`下，这在Linux/Unix下无所谓，但是在Windows下会放在C盘，最好还是改一下这个目录

要修改的话，需要配置环境变量`GRADLE_USER_HOME`，指向Gradle的目录，这个目录是用来指定下载jar包和读取配置文件的目录，然后把`GRADLE_USER_HOME/bin`加入到Path路径

### Gradle目录

Gradle目录下有以下比较重要的子目录：

- bin：存放可执行文件
- lib：Gradle的库文件
- **init.d**：Gradle的初始化脚本，这里可以配置依赖的镜像
- caches：**这里就是存放jar包相关的地方**
  - **modules-2**：存储已下载的Maven和Ivy模块的缓存。包括JAR文件、POM文件和元数据
  - transforms-2：缓存经过转换的依赖项，如JAR文件的处理结果（比如ProGuard、R8等工具的输出）
  - jars-3：缓存编译任务输出的JAR文件
  - files-2.1：缓存构建过程中生成的文件，包括已编译的字节码、资源等
  - kotlin-dsl：缓存Kotlin DSL脚本的编译结果
- wrapper：包含Gradle Wrapper相关文件（具体看[GradleWrapper](#Gradle Wrapper)）
- daemon：存放Gradle守护进程的相关文件

简单使用的话，只需要关注init.d这个目录就可以了

### 配置仓库

Gradle的加载顺序如下：

1. ~/.gradle/init.gradle文件
2. ~/.gradle/init.d/目录下的以.gradle结尾的文件
3. GRADLE_HOME/init.d/目录下的以.gradle结尾的文件
4. GRADLE_USER_HOME/init.gradle文件
5. GRADLE_USER_HOME/init.d目录下的以.gradle结尾的文件

在init.d目录下，新建一个`init.gradle`文件，Gradle在启动的时候会去加载它

配置仓库：

```Groovy
allprojects {
    repositories {
        mavenLocal() //表示从本地仓库加载
        maven { url 'https://maven.aliyun.com/repository/public/' }
        maven { url 'https://maven.aliyun.com/repository/spring/'}
        maven { url 'https://maven.aliyun.com/repository/google/'}
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin/'}
        maven { url 'https://maven.aliyun.com/repository/spring-plugin/'}
        maven { url 'https://maven.aliyun.com/repository/grails-core/'}
        maven { url 'https://maven.aliyun.com/repository/apache-snapshots/'}
        mavenCentral() //表示从中央仓库加载
    }
}
```

而这个mavenLocal()本地仓库是放在哪里呢？会按照下面这个优先级

1. ~/.m2/setting.xml
2. M2_HOME/conf/settings.xml
3. ~/.m2/repository

因此，要想让配置的仓库生效，**一定要修改家目录maven配置文件**，哪怕本身已经配置了Maven仓库的地址

```xml
<localRepository>D:\DevTools\Maven\Local_Repository</localRepository>
```

### Idea中使用

在Idea中，如果要指定Gradle，则需要如下图配置，否则Idea会自动下载Gradle，很慢！

![image-20240518211219988](https://cdn.jsdelivr.net/gh/HoShum/PictureRepo/imgs/202405182112106.png)





## Gradle Wrapper





















## 参考资料

- [JavaGuide](https://javaguide.cn/tools/gradle/gradle-core-concepts.html#gradle-%E4%BB%8B%E7%BB%8D)
- [CSDN-优雅地shiyongGradle和Idea](https://blog.csdn.net/Holmes_shuai/article/details/119665758)
- [CSDN-解决SpringBoot编译报错](https://blog.csdn.net/weixin_43933728/article/details/125561921)

