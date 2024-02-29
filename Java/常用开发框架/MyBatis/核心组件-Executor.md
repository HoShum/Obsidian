#Java #MyBatis 
Executor是MyBatis中的核心组件，MyBatis对SQL的查询和更新都是依托它来完成的
## 接口设计
Executor本身是一个接口，其定义了最核心的功能
```java 
public interface Executor {
    
    // 执行insert update delete语句
    int update(MappedStatement ms, Object parameter) throws SQLException;
    // 执行select（带二级缓存）
    <E> List<E> query(MappedStatement ms, Object parameter, RowBounds rowBounds, 
                      ResultHandler resultHandler, CacheKey cacheKey, BoundSql boundSql) throws SQLException;
    // 执行select（不带缓存）
    <E> List<E> query(MappedStatement ms, Object parameter, RowBounds rowBounds, 
                      ResultHandler resultHandler) throws SQLException;
    // 开启事务
    Transaction getTransaction();
    // 提交事务
    void commit(boolean required) throws SQLException;
    // 回滚事务
    void rollback(boolean required) throws SQLException;

    // ......
}
```
