#Java #MyBatis 
## 标签作用
根据我自己开发的经验，其实大部分时候都不会用到`<resultMap>`这个标签，因为我们一般直接用一个实体类去接收返回的信息，而懒得去设置那么多复杂的结构
但MyBatis本身则是为这个标签设计了很强大的功能，可以用来映射一些复杂的结构
> 官方文档：[mybatis – MyBatis 3 | Mapper XML Files](https://mybatis.org/mybatis-3/sqlmap-xml.html#result-maps)

这里简单说明一下其中的一些标签的作用
### resultMap
首先它是一个根标签，代表一个resultMap结构，它有以下子标签：
* constructor：用来指定构造器
    * idArg：主键参数
    * arg：构造器参数
* id：指定主键的字段映射
* result：指定普通字段的映射
* association：指定一个关联对象的字段，比如`department`字段对应一个`Department`对象
* collection：指定一对多的字段，比如`students`是一个List集合字段
* discriminator：一个选择器，可以指定一个字段不同值对应不同的resultMap

```ad-note
除了这些标签外，标签也有很多不同的属性可以设置，具体可看官方文档，都有详细的例子
```
## ResultMap
解析后，一个`<resultMap>`最后会封装成一个ResultMap对象
```java fold title:ResultMap
public class ResultMap {
  private Configuration configuration;

  private String id;
  private Class<?> type;
  private List<ResultMapping> resultMappings;
  private List<ResultMapping> idResultMappings;
  private List<ResultMapping> constructorResultMappings;
  private List<ResultMapping> propertyResultMappings;
  private Set<String> mappedColumns;
  private Set<String> mappedProperties;
  private Discriminator discriminator;
  private boolean hasNestedResultMaps;
  private boolean hasNestedQueries;
  private Boolean autoMapping;
//...
```
而一个ResultMapping对象则代表`<resultMap>`标签中的其中一个配置映射项，可以这么说，一个ResultMap对象中关联多个ResultMapping对象
```java fold title:ResultMapping
public class ResultMapping {

    private Configuration configuration;
    // 实体类的属性名
    private String property;
    // 结果集的列名
    private String column;
    // 映射属性的类型(可能是关联属性)
    private Class<?> javaType;
    private JdbcType jdbcType;
    private TypeHandler<?> typeHandler;
    // 直接引用另一个resultMap的全限定名
    private String nestedResultMapI
    // 关联查询的statement全限定名(用于延迟加载)
    private String nestedQueryId;
    private Set<String> notNullColumns;
    // 引用其它resultMap时列名的前缀
    private String columnPrefix;
    private List<ResultFlag> flags;
    private List<ResultMapping> composites;
    private String resultSet;
    private String foreignColumn;
    private boolean lazy;
//...
```

```ad-note
其实说白了，就是将标签中的属性封装到对应的实体类中
```
## 代码解析流程
下面开始分析复杂的解析代码
```java fold title:XMLMapperBuilder#resultMapElement
  private ResultMap resultMapElement(XNode resultMapNode, List<ResultMapping> additionalResultMappings, Class<?> enclosingType) {
    ErrorContext.instance().activity("processing " + resultMapNode.getValueBasedIdentifier());
    //获取type、ofType、resultType或javaType属性
    String type = resultMapNode.getStringAttribute("type",
        resultMapNode.getStringAttribute("ofType",
            resultMapNode.getStringAttribute("resultType",
                resultMapNode.getStringAttribute("javaType"))));
    //获取resultMap对应的返回实体类                                  
    Class<?> typeClass = resolveClass(type);
    if (typeClass == null) {
      typeClass = inheritEnclosingType(resultMapNode, enclosingType);
    }
    Discriminator discriminator = null;
    List<ResultMapping> resultMappings = new ArrayList<>(additionalResultMappings);
    List<XNode> resultChildren = resultMapNode.getChildren();
    //解析子标签
    for (XNode resultChild : resultChildren) {
      if ("constructor".equals(resultChild.getName())) {
        processConstructorElement(resultChild, typeClass, resultMappings);
      } else if ("discriminator".equals(resultChild.getName())) {
        discriminator = processDiscriminatorElement(resultChild, typeClass, resultMappings);
      } else {
        List<ResultFlag> flags = new ArrayList<>();
        if ("id".equals(resultChild.getName())) {
          flags.add(ResultFlag.ID);
        }
        resultMappings.add(buildResultMappingFromContext(resultChild, typeClass, flags));
      }
    }
    //获取<resultMap>的id，extends和autoMapping属性
    String id = resultMapNode.getStringAttribute("id",
            resultMapNode.getValueBasedIdentifier());
    String extend = resultMapNode.getStringAttribute("extends");
    Boolean autoMapping = resultMapNode.getBooleanAttribute("autoMapping");
    //构建一个ResultMapResolver来处理
    ResultMapResolver resultMapResolver = new ResultMapResolver(builderAssistant, id, typeClass, extend, discriminator, resultMappings, autoMapping);
    try {
      //真正解析出ResultMap
      return resultMapResolver.resolve();
    } catch (IncompleteElementException e) {
      configuration.addIncompleteResultMap(resultMapResolver);
      throw e;
    }
  }
```
### 1、获取返回类型
也许你会对第4行的代码不停嵌套`resultMapNode.getStringAttribute()`感到困惑，其实点进去就会知道，它是相当于Map的`getOrDefault`方法，因此这里获取的顺序是type，ofType，resultType和javaType
### 2、解析子标签
从第17行代码开始，直到第29行代码，都是用来解析子标签的，而由于`<resultMap>`标签只有3类子标签
```ad-question
可能你会问，官方文档中不是有6种吗，怎么这里只有3种？
其实是因为MyBatis将result,association和collection归类为了普通字段映射
```
#### 2.1 构造器映射
```java fold title:processConstructorElement
private void processConstructorElement(XNode resultChild, Class<?> resultType, List<ResultMapping> resultMappings) {
    List<XNode> argChildren = resultChild.getChildren();
    for (XNode argChild : argChildren) {
        List<ResultFlag> flags = new ArrayList<>();
        flags.add(ResultFlag.CONSTRUCTOR);
        if ("idArg".equals(argChild.getName())) {
            flags.add(ResultFlag.ID);
        }
        resultMappings.add(buildResultMappingFromContext(argChild, resultType, flags));
    }
}
```
关于这个`buildResultMappingFromContext`方法，下面会说明
#### 2.2 普通字段映射
```java fold title:buildResultMappingFromContext
private ResultMapping buildResultMappingFromContext(XNode context, Class<?> resultType, List<ResultFlag> flags) {
    String property;
    if (flags.contains(ResultFlag.CONSTRUCTOR)) {
        //<constructor>标签的字段属性是name而不是property
        property = context.getStringAttribute("name");
    } else {
        property = context.getStringAttribute("property");
    }
    String column = context.getStringAttribute("column");
    String javaType = context.getStringAttribute("javaType");
    String jdbcType = context.getStringAttribute("jdbcType");
    //处理select属性，只有<collection>和<association>有
    String nestedSelect = context.getStringAttribute("select");
    //处理resultMap属性，只有<collection>和<association>有
    String nestedResultMap = context.getStringAttribute("resultMap", () ->
            processNestedResultMappings(context, Collections.emptyList(), resultType));
    String notNullColumn = context.getStringAttribute("notNullColumn");
    String columnPrefix = context.getStringAttribute("columnPrefix");
    String typeHandler = context.getStringAttribute("typeHandler");
    String resultSet = context.getStringAttribute("resultSet");
    String foreignColumn = context.getStringAttribute("foreignColumn");
    boolean lazy = "lazy".equals(context.getStringAttribute("fetchType", 
                             configuration.isLazyLoadingEnabled() ? "lazy" : "eager"));
    // 结果集类型、typeHandler类型的解析
    Class<?> javaTypeClass = resolveClass(javaType);
    Class<? extends TypeHandler<?>> typeHandlerClass = resolveClass(typeHandler);
    JdbcType jdbcTypeEnum = resolveJdbcType(jdbcType);
    return builderAssistant.buildResultMapping(resultType, property, column, 
                   javaTypeClass, jdbcTypeEnum, nestedSelect, nestedResultMap, 
                   notNullColumn, columnPrefix, typeHandlerClass, 
                   flags, resultSet, foreignColumn, lazy);
}
```
这里其实就是逐个属性取出来然后设置到ResultMapping中，第28行的代码`builderAssistant.buildResultMapping()`方法点进去就会看到，它是利用了建造者模式去构建一个ResultMapping
```ad-note
另外值得注意的是，第16行代码`processNestedResultMappings`的作用是嵌套地去获取引用的`<resultMap>`，因为在`<association>`和`<collection>`标签中可以嵌套一个属性`<resultMap>`，表示返回的结果映射是引用另一个`<resultMap>`
```
#### 2.3 选择器字段映射
```java fold title:processDiscriminatorElement
private Discriminator processDiscriminatorElement(XNode context, Class<?> resultType, List<ResultMapping> resultMappings) {
    String column = context.getStringAttribute("column");
    String javaType = context.getStringAttribute("javaType");
    String jdbcType = context.getStringAttribute("jdbcType");
    String typeHandler = context.getStringAttribute("typeHandler");
    Class<?> javaTypeClass = resolveClass(javaType);
    Class<? extends TypeHandler<?>> typeHandlerClass = resolveClass(typeHandler);
    JdbcType jdbcTypeEnum = resolveJdbcType(jdbcType);
    // 解析<discriminator>的<case>子标签，并封装到Map中
    Map<String, String> discriminatorMap = new HashMap<>();
    for (XNode caseChild : context.getChildren()) {
        String value = caseChild.getStringAttribute("value");
        String resultMap = caseChild.getStringAttribute("resultMap", 
                processNestedResultMappings(caseChild, resultMappings, resultType));
        discriminatorMap.put(value, resultMap);
    }
    // 注意构造的是Discriminator而不是ResultMapping
    return builderAssistant.buildDiscriminator(resultType, column, 
             javaTypeClass, jdbcTypeEnum, typeHandlerClass, discriminatorMap);
}
```
### 3、ResultMapResolver
看名字，就知道它是用来解析ResultMap的，先来看看它的结构
```java fold title:ResultMapResolver
public class ResultMapResolver {
  private final MapperBuilderAssistant assistant;
  private final String id;
  private final Class<?> type;
  private final String extend;
  private final Discriminator discriminator;
  private final List<ResultMapping> resultMappings;
  private final Boolean autoMapping;
  //省略全参数构造器...

  //解析方法
  public ResultMap resolve() {
    return assistant.addResultMap(this.id, this.type, this.extend, this.discriminator, this.resultMappings, this.autoMapping);
  }

}
```
可以看到，实际上它自己并不进行解析，而是委托给MapperBuilderAssistant来进行处理
```ad-note
这个MapperBuilderAssistant负责的功能很多，像在解析映射节点时也是通过它来实现，还有后面解析Statement也会见到它的身影，它相当于是一个内部的工具类

关于这个类的功能解析，请看[[核心组件-MapperBuilderAssistant]]
```
