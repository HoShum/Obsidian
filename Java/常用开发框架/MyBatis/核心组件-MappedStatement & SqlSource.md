#Java #MyBatis 
## MappedStatement
### 设计
之所以说它核心，是因为它对用的就是我们平时开发写mapper.xml文件时，对应的一个个`<select>`，`<update>`，`<delete>`标签的内容
可能你会有一个疑问，这里面的内容不就是我们写的SQL吗？
其实并不止是SQL，由于MyBatis支持动态SQL机制，因此MappedStatement不仅封装了SQL语句，还有像动态的参数，缓存等对象
### 结构
实际上这个类并不复杂，主要作用是用来封装结构，无其它子类
```java fold title:MappedStatement
public final class MappedStatement {

    // 当前mapper的来源(mapper.xml / Mapper.class的路径)
    private String resource;
    private Configuration configuration;
    private String id;
    // statement内部封装的SQL
    private SqlSource sqlSource;
    // 当前statement对应的mapper.xml或Mapper接口的namespace下的二级缓存
    private Cache cache;
    // 如果是select，则此处存放返回值的映射(resultMap和resultType都在这里)
    private List<ResultMap> resultMaps;
    // 执行此条SQL之前是否需要清空二级缓存
    private boolean flushCacheRequired;
    // 当前SQL是否使用二级缓存
    private boolean useCache;
    // ......

```
重点关注一下这个SqlSource
### 重要方法
## SqlSource
### 设计
它本身是一个接口，用来代表每条SQL，它只定义了一个方法
```java fold title:SqlSource
public interface SqlSource {
  BoundSql getBoundSql(Object parameterObject);
}
```
那么这个BoundSql又是什么呢？这里用一个图来说明
![image.png|660](https://cdn.jsdelivr.net/gh/HoShum/PictureRepo/imgs/202403031510792.png)
简单来说，SqlSource会带上动态SQL的标签，而BoundSql则会包含两部分，一是解析后的SQL语句，二是参数，最终会形成一条可以给SQL驱动执行的语句
但是我们写的SQL语句并不一定都是动态SQL语句，因此MyBatis也为SqlSource设计了不同的实现类
### StaticSqlSource
看名字就知道，这个就是静态SQL，不会有动态SQL的标签，因此结构也非常简单
```java fold title:StaticSqlSource
public class StaticSqlSource implements SqlSource {

    private final String sql;
    private final List<ParameterMapping> parameterMappings;
    private final Configuration configuration;

    // 构造方法

    @Override
    public BoundSql getBoundSql(Object parameterObject) {
        return new BoundSql(configuration, sql, parameterMappings, parameterObject);
    }
}
```
### DynamicSqlSource
这个就是动态SQL了
```java fold title:DynamicSqlSource
public class DynamicSqlSource implements SqlSource {

    private final Configuration configuration;
    private final SqlNode rootSqlNode;

    // 构造方法

    @Override
    public BoundSql getBoundSql(Object parameterObject) {
        DynamicContext context = new DynamicContext(configuration, parameterObject);
        rootSqlNode.apply(context);
        SqlSourceBuilder sqlSourceParser = new SqlSourceBuilder(configuration);
        Class<?> parameterType = parameterObject == null ? Object.class : parameterObject.getClass();
        SqlSource sqlSource = sqlSourceParser.parse(context.getSql(), parameterType, context.getBindings());
        BoundSql boundSql = sqlSource.getBoundSql(parameterObject);
        context.getBindings().forEach(boundSql::setAdditionalParameter);
        return boundSql;
    }
}
```
