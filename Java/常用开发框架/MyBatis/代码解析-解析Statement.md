#Java #MyBatis 
## 前情提要
MyBatis在解析mapper.xml文件时，在最后会对Statement，即我们平时开发经常写的动态SQL语句进行解析
```java fold title:XMLMapperBuilder#configurationElement
  private void configurationElement(XNode context) {
    try {
      String namespace = context.getStringAttribute("namespace");
      if (namespace == null || namespace.isEmpty()) {
        throw new BuilderException("Mapper's namespace cannot be empty");
      }
      builderAssistant.setCurrentNamespace(namespace);
      cacheRefElement(context.evalNode("cache-ref"));
      cacheElement(context.evalNode("cache"));
      parameterMapElement(context.evalNodes("/mapper/parameterMap"));
      resultMapElements(context.evalNodes("/mapper/resultMap"));
      sqlElement(context.evalNodes("/mapper/sql"));
      //解析Statement
      buildStatementFromContext(context.evalNodes("select|insert|update|delete"));
    } catch (Exception e) {
      throw new BuilderException("Error parsing Mapper XML. The XML location is '" + resource + "'. Cause: " + e, e);
    }
  }
```
接下来要关注的重点就是这个buildStatementFromContext
## 构造Statement
```java fold title:buildStatementFromContext
private void buildStatementFromContext(List<XNode> list, String requiredDatabaseId) {
    for (XNode context : list) {
        //构造XMLStatementBuilder来解析Statement
        final XMLStatementBuilder statementParser = new XMLStatementBuilder(configuration, 
                builderAssistant, context, requiredDatabaseId);
        try {
            //借助XMLStatementBuilder解析一个一个的statement标签
            statementParser.parseStatementNode();
        } catch (IncompleteElementException e) {
            // statement解析失败，只会记录到Configuration中，但不会抛出异常
            configuration.addIncompleteStatement(statementParser);
        }
    }
}
```
