# 记录一次MySQL允许外网访问
正常情况下，本地的MySQL是不允许外网访问的，需要做如下配置：
* 修改`my.cnf`或者`my.ini`配置文件，在`[mysqld]`下添加`bind-address=0.0.0.0
* 对用户授权，使用`GRANT ALL PRIVILEGES ON dbname.* TO 'username'@'%' IDENTIFIED BY 'password';
* 通过`select host,user from user;`查看你想登录的用户是否接收任意ip访问（%）
* 刷新数据库用户权限，使用`flush privileges;`

