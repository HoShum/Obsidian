# Vim教程
#Linux #Vim
## 替换
VIm提供如下语法供替换文本使用：
`:{range}s/{pattern}/{string}/{c,e,g,i}`
说明：
* range：就是指你要替换的文本的范围，比如`1,3`就表示1到3行，`1，$`就表示从头到尾，也可以用`%`来代替
* pattern：指目标字符串
* string：指要替换的字符串
* flag：标志
	* c：confirm，每次替换都要确认
	* i：ignore，忽略大小写
	* I：区分大小写
	* g：globe，表示全局替换（如果不加，只会替换每一行的第一个字符串）
	* e：如果找不到，不会报错，避免报错中断
```ad-note 
title: 示例
**Case1**：把张三替换成李四
`:%s/张三/李四/gie`
```
