# Spring相关
## 如何扫描路径
场景：Spring整合MyBatis，需要配置mapper.xml文件的扫描路径，代码如下：
```java 
@Bean
public SqlSessionFactory sqlSessionFactory() throws Exception {
    SqlSessionFactoryBean sessionFactoryBean = new SqlSessionFactoryBean();
    sessionFactoryBean.setDataSource(dataSource());
    // 设置Mapper.xml文件路径
    PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
    Resource[] resources = resolver.getResources("classpath*:/mapper/**/*.xml");
    sessionFactoryBean.setMapperLocations(resources);
    return sessionFactoryBean.getObject();
}
```

