# 解析Mapper接口

上一篇中介绍了在配置文件中通过`<mapper>`标签来注入对应的mapper.xml文件，但实际开发中，我们用得最多的是使用Mapper接口来注入，因此这里就介绍MyBatis是如何解析Mapper接口的

这里回到XMLConfigBuilder#mapperElement方法中

```java
private void mapperElement(XNode parent) throws Exception {
    if (parent != null) {
        for (XNode child : parent.getChildren()) {
            // 包扫描Mapper接口
            if ("package".equals(child.getName())) {
                String mapperPackage = child.getStringAttribute("name");
                // 【注意看这里】
                configuration.addMappers(mapperPackage);
            } else {
                // ......
                } else if (resource == null && url == null && mapperClass != null) {
                    // 注册单个Mapper接口
                    // 【注意看这里】
                    Class<?> mapperInterface = Resources.classForName(mapperClass);
                    configuration.addMapper(mapperInterface);
                } // ......
            }
        }
    }
}
```

## addMapper

上面的addMapper()方法虽然是通过Configuration来调用的，但实际上是内部是通过MapperRegistry的addMapper()来调用的

>   这个MapperRegistry是直接在Configuration中维护的

```java
public class MapperRegistry {

  private final Configuration config;
  //维护了对每个Mapper接口的代理工厂
  private final Map<Class<?>, MapperProxyFactory<?>> knownMappers = new HashMap<>();

  public MapperRegistry(Configuration config) {
    this.config = config;
  }
//...
}
```

MapperRegistry#addMapper

```java
public <T> void addMapper(Class<T> type) {
    // 只有接口才会解析
    if (type.isInterface()) {
        // 重复注册的检查
        if (hasMapper(type)) {
            throw new BindingException("Type " + type + " is already known to the MapperRegistry.");
        }
        boolean loadCompleted = false;
        try {
            // 记录在Map中，留意value的类型是MapperProxyFactory
            knownMappers.put(type, new MapperProxyFactory<>(type));
            // It's important that the type is added before the parser is run
            // otherwise the binding may automatically be attempted by the
            // mapper parser. If the type is already known, it won't try.
            MapperAnnotationBuilder parser = new MapperAnnotationBuilder(config, type);
            // 利用MapperAnnotationBuilder解析Mapper接口
            parser.parse();
            loadCompleted = true;
        } finally {
            if (!loadCompleted) {
                knownMappers.remove(type);
            }
        }
    }
}
```

可以看到，对于每一个Mapper接口，都会新增一个MapperAnnotationBuilder来处理

## MapperAnnotationBuilder

先来看看它的内部

```java
public class MapperAnnotationBuilder {
    private final Configuration configuration;
    private final MapperBuilderAssistant assistant;
    private final Class<?> type;
    
    public MapperAnnotationBuilder(Configuration configuration, Class<?> type) {
        String resource = type.getName().replace('.', '/') + ".java (best guess)";
        this.assistant = new MapperBuilderAssistant(configuration, resource);
        this.configuration = configuration;
        this.type = type;
    }
//....
}
```

可以看到它也维护了一个“助手”来解析mapper.xml文件

### parse()

该类用来解析Mapper接口的核心方法依然叫parse

```java
public void parse() {
    String resource = type.toString();
    // 2. 检查接口是否已经加载
    if (!configuration.isResourceLoaded(resource)) {
        // 加载Mapper接口对应的mapper.xml
        loadXmlResource();
        configuration.addLoadedResource(resource);
        assistant.setCurrentNamespace(type.getName());
        // 3. 解析注解配置的缓存
        parseCache();
        parseCacheRef();
        // 解析Mapper方法
        for (Method method : type.getMethods()) {
            if (!canHaveStatement(method)) {
                continue;
            }
            // 4. 解析注解配置的ResultMap
            if (getAnnotationWrapper(method, false, Select.class, SelectProvider.class).isPresent()
                && method.getAnnotation(ResultMap.class) == null) {
                parseResultMap(method);
            }
            try {
                // 5. 构造statement
                parseStatement(method);
            } catch (IncompleteElementException e) {
                configuration.addIncompleteMethod(new MethodResolver(this, method));
            }
        }
    }
    parsePendingMethods();
}
```

看着还是挺清晰的是不是，下面来看看它是如何加载mapper.xml文件的

#### loadXmlResource()

```java
private void loadXmlResource() {
    // Spring may not know the real resource name so we check a flag
    // to prevent loading again a resource twice
    // this flag is set at XMLMapperBuilder#bindMapperForNamespace
    if (!configuration.isResourceLoaded("namespace:" + type.getName())) {
        String xmlResource = type.getName().replace('.', '/') + ".xml";
        InputStream inputStream = type.getResourceAsStream("/" + xmlResource);
        if (inputStream == null) {
            // Search XML mapper that is not in the module but in the classpath.
            try {
                inputStream = Resources.getResourceAsStream(type.getClassLoader(), xmlResource);
            } catch (IOException e2) {
                // ignore, resource is not required
            }
        }
        if (inputStream != null) {
            XMLMapperBuilder xmlParser = new XMLMapperBuilder(inputStream, 
                    assistant.getConfiguration(), xmlResource, configuration.getSqlFragments(), type.getName());
            xmlParser.parse();
        }
    }
}
```

第6行的代码清晰地展示了，MyBatis默认会按照Mapper的全类名，把"."替换成“/”去加载，所以才会有约定：**mapper.xml文件的文件名应该和Mapper接口的全类名保持一致**

当加载到mapper.xml文件后，依然会通过XMLMapperBuilder去进行解析，这里和上一篇中解析mapper文件是一样的

----

后面用来解析@ResultMap和用来构造statement的代码都比较复杂，后续再介绍~

