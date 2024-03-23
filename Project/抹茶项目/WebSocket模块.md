#项目 #WebSocket
## WebSocket协议


## WebSocket服务器
由于Netty本身已经集成了对WebSocket的处理，因此使用Netty来构建比较方便
```java fold:WebSocketServer
@Slf4j
@Component
public class WebSocketServer {
    private final static NioEventLoopGroup BOSS = new NioEventLoopGroup(1);
    private final static NioEventLoopGroup WORKER = new NioEventLoopGroup(2);
    private final static int PORT = 8090;

    @PostConstruct
    public void start() {
        this.startServer();
    }

    private void startServer() {
        ServerBootstrap bootStrap = new ServerBootstrap();
        bootStrap.group(BOSS, WORKER);
        bootStrap.channel(NioServerSocketChannel.class);
        bootStrap.childHandler(new ChannelInitializer<SocketChannel>() {
            @Override
            protected void initChannel(SocketChannel socketChannel) throws Exception {
                ChannelPipeline pipeline = socketChannel.pipeline();
                //HTTP报文解码
                pipeline.addLast(new HttpServerCodec());
                //处理HTTP报文聚合
                pipeline.addLast(new HttpObjectAggregator(8192));
                //处理心跳
                pipeline.addLast(new IdleStateHandler(30, 0, 0));
                //处理WebSocket报文，"/"表示处理所有请求
                pipeline.addLast(new WebSocketServerProtocolHandler("/"));
                //处理业务
                pipeline.addLast(new WebSocketServerHandler());
            }
        });
        try {
            bootStrap.bind(PORT).sync();
            log.info("WebSocket服务器启动成功");
        } catch (InterruptedException e) {
            log.error("", e);
        }
    }

}
```
* 这里值得注意的是，由于WebSocket是基于HTTP来升级的，因此需要先处理HTTP报文，而Netty也是集成了对HTTP的处理，因此非常简单
* `WebSocketServerProtocolHandler` 就是Netty用来处理HTTP报文升级的处理器；而由于WebSocket有主题的概念，因此这里的`/` 表示的就是接收任何主题
* `WebSocketServerHandler` 是用来处理业务的处理器

```ad-note

这里我一开始有个疑问，就是WebSocket
```
## 业务处理器
接下来是编写处理业务的处理器
```java fold:WebSocketServerHandler
@Slf4j
@Sharable
public class WebSocketServerHandler extends SimpleChannelInboundHandler<TextWebSocketFrame> {

    @Override
    protected void channelRead0(ChannelHandlerContext channelHandlerContext, TextWebSocketFrame textWebSocketFrame) throws Exception {
        //编写业务代码...
    }
}
```
这里有两点需要注意：
1. `TextWebSocketFrame` 是Netty集成来表示WebSocket帧的报文
2. 当使用了`@Sharable`注解，则表示该处理器在当前pipeline是共用的，即单例