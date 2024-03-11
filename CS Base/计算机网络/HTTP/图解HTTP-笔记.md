#计算机网络 #HTTP
## 第1章 网络基础
### HTTP和TCP
HTTP位于TCP/IP协议族的应用层，它依赖于TCP协议，而TCP为了传输方便，会将一个把从应用层收到的HTTP报文分割成不同段的数据，并且打上标记，再转发给网络层
以下是传输过程：
![image.png|350](https://cdn.jsdelivr.net/gh/HoShum/PictureRepo/imgs/202403112205532.png)
### URI和URL
一言以蔽之，URL是URI的子集，通常我们在浏览器中输入的都是URL，而URI会包含更多的信息
这个就是绝对URI：
![image.png|430](https://cdn.jsdelivr.net/gh/HoShum/PictureRepo/imgs/202403112208561.png)

```ad-note
千万不要将URI和HTTP划等号，因为URI是资源标识符，除了HTTP协议之外，像FTP，SSH，TELNET等协议也是用URI来定位资源的
```
## 第2章 简单的HTTP协议
> 之所以是简单的HTTP协议，因为这一章涉及的是HTTP/1.1版本，也就是HTTP协议最基础的内容

这一章值得关注的只有两个地方：
* HTTP是不保存状态的协议，即协议本身不会对发送过的请求和响应作任何持久化处理，这样的好处是简单轻量，但是某些场景是需要用到状态（比如登录），因此后面又引入了Cookie技术
* 早期版本的HTTP协议是每请求响应一次都要重新建立一次TCP连接，这样显然造成了服务器额外的开销，后来的HTTP标准通过**keep-alive**的方法，支持了长连接，即只要任何一方没有明确提出断开连接，则会保持TCP的连接状态

```ad-note
在HTTP/1.1中，所有的连接默认都是持久连接
```
## 第3章 HTTP报文
