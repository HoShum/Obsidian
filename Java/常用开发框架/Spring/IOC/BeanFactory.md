#Java #Spring/IOC 
## 什么是BeanFactory
BeanFactory是一个接口，而借助Idea，可以发现它并没有父接口，可以这么说，SpringFramework的源头就是BeanFactory，Spring中的所有容器都是实现了该接口！
这是它的UML图：
![UML图](https://cdn.jsdelivr.net/gh/HoShum/PictureRepo/imgs/202401312350854.png)
通过阅读JavaDoc文档，可以发现BeanFactory有以下主要功能：
* 是Spring容器中的根接口，用来**管理Bean**，而具体功能由其子接口和实现类实现
* 每个Bean会有一个唯一的名称，且BeanFactory会根据它的作用域来返回一个Bean（比如单例或者多例）
* 支持**父子结构**，如果在当前容器中找不到Bean，则会从父容器中获取
* 提供了对Bean完整的生命周期的控制

```ad-note
title:总结
其实总结来说，BeanFactory提供了最基本的管理Bean的能力，但具体的功能还要看它的子接口和实现类
```
## 子接口
[[类关系思维导图]]
