#Java #MyBatis 
## 设计
之所以说它核心，是因为它对用的就是我们平时开发写mapper.xml文件时，对应的一个个`<select>`，`<update>`，`<delete>`标签的内容
## 结构
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
重点关注一下这个SqlSource，[[核心组件-SqlSource]]
## 重要方法
