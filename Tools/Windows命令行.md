# Windows命令行
#Windows #命令行
本文档主要记录Windows环境下一些常用的命令行操作
## 杀死进程
开发时，经常会被某个程序的端口占用，此时就需要找到这个进程，并杀死这个进程
```
netstat -ano findstr | 8080 #找到8080的端口的进程
taskkill /f /pid [进程pid] #杀死该进程
```