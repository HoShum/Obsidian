#Java #Spring/IOC 
## 什么是IOC
我们可以换个角度，在没有IOC的情况下，我们是如何创建对象的？
```java
private UserService = new UserServiceImpl()
```
如果此时，我们并没有UserServiceImpl这个实现类，编译期间就会报错，这种就叫**强依赖/紧耦合**
但是如果我们使用IOC呢？
```java
private UserService = (UserService) BeanFactory.getBean("userService")
```
这种情况下，只有当代码在运行的时候，才会去找到该实现类，这种就叫**弱依赖/松耦合**
```ad-note
总而言之，通过将创建对象的这种控制权交给别人的思想，我们就可以称作：控制反转**(Inversion of Control，IOC)**
```
## SpringFramework
发展到今天，Spring家族已经有很多成员了，而当我们说起Spring容器，指的其实是SpringFramework，在官方文档中，它的描述如下：
>The Spring Framework provides a comprehensive programming and configuration model for modern Java-based enterprise applications - on any kind of deployment platform.
>A key element of Spring is infrastructural support at the application level: Spring focuses on the "plumbing" of enterprise applications so that teams can focus on application-level business logic, without unnecessary ties to specific deployment environments.

以下是一些对主要功能的描述：
- [Core technologies](https://docs.spring.io/spring-framework/reference/core.html): dependency injection, events, resources, i18n, validation, data binding, type conversion, SpEL, AOP.
- [Testing](https://docs.spring.io/spring-framework/reference/testing.html#testing): mock objects, TestContext framework, Spring MVC Test, WebTestClient.
- [Data Access](https://docs.spring.io/spring-framework/reference/data-access.html): transactions, DAO support, JDBC, ORM, Marshalling XML.
- [Spring MVC](https://docs.spring.io/spring-framework/reference/web.html) and [Spring WebFlux](https://docs.spring.io/spring-framework/reference/web-reactive.html) web frameworks.
- [Integration](https://docs.spring.io/spring-framework/reference/integration.html): remoting, JMS, JCA, JMX, email, tasks, scheduling, cache and observability.
- [Languages](https://docs.spring.io/spring-framework/reference/languages.html): Kotlin, Groovy, dynamic languages.

可以看到，Spring的功能非常强大，涵盖方方面面，比如依赖注入，资源管理，数据绑定等，而且除了Java，还支持Kotlin，Groovy等语言
