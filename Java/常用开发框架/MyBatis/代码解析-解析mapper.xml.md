#Java #MyBatis 
## 前情提要
MyBatis在执行这行代码时，会对mapper.xml文件进行解析
```java fold title:mapperElement
//...
InputStream inputStream = Resources.getResourceAsStream(resource);
XMLMapperBuilder mapperParser = new XMLMapperBuilder(inputStream, configuration, resource, configuration.getSqlFragments()); 
mapperParser.parse();
//...
```
可以看到，MyBatis会先新建一个XMLMapperBuilder，显然是用来解析文件的
```java fold title:parse
public void parse() {
    //检查资源是否已经加载过
    if (!configuration.isResourceLoaded(resource)) {
      //解析<mapper>标签
      configurationElement(parser.evalNode("/mapper"));
      //记录该资源已经被加载过
      configuration.addLoadedResource(resource);
      //绑定Mapper和namespace
      bindMapperForNamespace();
    }

    parsePendingResultMaps();
    parsePendingCacheRefs();
    parsePendingStatements();
}
```
可以说，这里面的代码就包含了MyBatis最核心的功能，解析mapper.xml文件，每去解析一个文件， 就会执行一次这个`parse()`方法
## configurationElement
这个方法就是用来提取每个mapper.xml文件中的元素，因为每个mapper.xml文件的顶级标签都是`<mapper>`
```java fold title:configurationElement
private void configurationElement(XNode context) {
    try {
        // 提取mapper.xml对应的命名空间
        String namespace = context.getStringAttribute("namespace");
        if (namespace == null || namespace.isEmpty()) {
            throw new BuilderException("Mapper's namespace cannot be empty");
        }
        builderAssistant.setCurrentNamespace(namespace);
        // 解析cache、cache-ref
        cacheRefElement(context.evalNode("cache-ref"));
        cacheElement(context.evalNode("cache"));
        // 解析提取parameterMap(官方文档称已废弃，不看了)
        parameterMapElement(context.evalNodes("/mapper/parameterMap"));
        // 解析提取resultMap
        resultMapElements(context.evalNodes("/mapper/resultMap"));
        // 解析封装SQL片段
        sqlElement(context.evalNodes("/mapper/sql"));
        // 构造Statement
        buildStatementFromContext(context.evalNodes("select|insert|update|delete"));
    } catch (Exception e) {
        throw new BuilderException("Error parsing Mapper XML. The XML location is '" + resource + "'. Cause: " + e, e);
    }
}
```
### namespace
从代码中就可以看到，为什么我们平时开发写mapper.xml文件时，总是要设置它的namespace的值？因为这个namespace其实对应的是一个唯一的mapper.xml文件
假如我们写了两个Mapper，分别都有`findAll()`方法，此时就可以通过namespace来区分
因此，如果我们没有指定namespace，MyBatis就会报错
### cache
`cacheElement` 是用来解析二级缓存的，而`cacheRefElement`是用来解析是否引用其他二级缓存
### resultMap
点开这个方法中，可以发现会循环去解析，因为一个mapper.xml文件中可以有多个`<resultMap>` 标签
由于MyBatis设计的resultMap功能非常强大，因此这里的代码逻辑也是非常复杂，同样分开一个单独的文档来分析😂[[代码解析-解析resultMap]]
### sqlElement
该方法是用来解析和封装公共的SQL片段，因为我们的mapper.xml文件中可以引用多个`<sql>`标签
```java fold title:sqlElement
private void sqlElement(List<XNode> list) {
    if (configuration.getDatabaseId() != null) {
        // 先全部过一遍，提取出匹配SQL片段的statement
        sqlElement(list, configuration.getDatabaseId());
    }
    // 再提取通用的SQL片段
    sqlElement(list, null);
}

private void sqlElement(List<XNode> list, String requiredDatabaseId) {
    for (XNode context : list) {
        String databaseId = context.getStringAttribute("databaseId");
        String id = context.getStringAttribute("id");
        id = builderAssistant.applyCurrentNamespace(id, false);
        // 鉴别当前SQL片段是否匹配
        if (databaseIdMatchesCurrent(id, databaseId, requiredDatabaseId)) {
            sqlFragments.put(id, context);
        }
    }
}
```
这里的代码很简单，就是用sql片段中id作为key，内容为value，放到缓存中
但是需要注意的是，MyBatis还会对databaseId进行区分
### statement
该方法同样非常核心，是用来解析我们在mapper文件中写的增删改查SQL；这里面的逻辑同样非常复杂，因此单独在另一个文档中进行解析[[代码解析-解析Statement]]
## bindMapperForNamespace
先上代码
```java fold title:bindMapperForNamespace
private void bindMapperForNamespace() {
    String namespace = builderAssistant.getCurrentNamespace();
    if (namespace != null) {
        Class<?> boundType = null;
        try {
            // 尝试加载namespace对应的类
            boundType = Resources.classForName(namespace);
        } catch (ClassNotFoundException e) {
            // ignore, bound type is not required
        }
        // 加载到类了，并且之前没存过这个Mapper接口，那就存起来
        if (boundType != null && !configuration.hasMapper(boundType)) {
            // Spring may not know the real resource name so we set a flag
            // to prevent loading again this resource from the mapper interface
            // look at MapperAnnotationBuilder#loadXmlResource
            // Spring可能不知道真实的资源名称，因此设置了一个标志来防止再次从Mapper接口加载此资源
            configuration.addLoadedResource("namespace:" + namespace);
            configuration.addMapper(boundType);
        }
    }
}
```
这段代码的大概步骤是这样的：
1. 解析到一个mappe.xml文件
2. 通过它的namespace去检索对应的Mapper的Class文件
3. 如果检索到且配置中还不存在，则标记该xml文件已经被访问，同时标记该Mapper已经被加载

为什么要这样做呢？
* 在早期的MyBatis版本中并不不支持Mapper接口去调用方法的，而是需要通过`sqlSession`来加载对应的mapper.xml文件，因此从这里的代码中也可以看到，即使找不到对应的Mapper接口，也不影响MyBatis运行
* 而MyBatis加入了接口机制后，为了防止重复加载Mapper接口，当扫描每个mapper.xml文件后，MyBatis就会尝试通过它的namespace去加载对应的Mapper接口

```ad-note
通过上面的代码，也理解了为什么MyBatis要求我们在写mapper.xml文件时，它的namespace需要设置为对应的Mapper接口的全路径
```