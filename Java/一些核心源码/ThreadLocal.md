# ThreadLocal笔记
#Java #ThreadLocal
## 基本使用
ThreadLocal一般的使用场景是用来给线程保存一些变量，方便传递使用，比如说：
* 在一个事务场景中，可能涉及到查询或修改多次数据库，而这些操作都需要保证是同一个数据库连接，此时就可以使用ThreadLocal来保存一些上下文的信息
* SpringSecurity在执行鉴权时会经过一连串的处理方法，而为了保存一些上下文的信息，同样会使用到ThreadLocal来保存
* 在MyBatis的PageHelper插件中，也是使用ThreadLocal来保存分页的信息

```ad-note
可以说，在很多框架的源码中，是大量使用到ThreadLocal来保存中间变量的
```
要使用ThreadLocal很简单，主要就以下几个方法：
* 获取：`get()`
* 保存：`set(T value)`
* 清除：`remove()`

此外，一般会将ThreadLocal声明为`static`来使用
## 核心源码
ThreadLocal的源码并不复杂，但是要想搞明白，就需要先搞清楚它的结构
而ThreadLocal的结构又需要结合着Thread来看，因为ThreadLocal的数据是保存到一个叫`ThreadLocalMap`的集合里的，但是比较奇怪的一点是，这个结构是定义在`ThreadLocal`里面，但是它的引用却是放在了`Thread`里面

```java fold:ThreadLocal#ThreadLocalMap
//...
    static class ThreadLocalMap {

        static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
//...
```
可以看到，它是一个静态内部类，且修饰符是default，并不暴露到外面
值得注意的是，这个`Entry`是继承了`WeakReference`，它有以下几个意思：
* Entry本身**不是弱引用**，但Entry会包含一个弱引用，具体看`super(k)`，表明Entry的key是一个弱引用，而这个key就是`ThreadLocal`
* 当一个对象实例只有一个弱引用时，一旦发生GC，就会被回收，而这也是为什么ThreadLocal会发生内存泄露的原因

```ad-info
到这里你就会发现，ThreadLocalMap是一个key为ThreadLocal，value为Object的结构
```
接下来我们进入`get()`方法一探究竟
```java fold:ThreadLocal#get()
//...
    public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
//...
```
可以看到，它会先获取当前线程，然后进入`getEntry()`
```java fold:ThreadLocal#getEntry()
//...
    ThreadLocalMap getMap(Thread t) {
        return t.threadLocals;
    }
//...
```
**也就是说，Thread持有ThreadLocalMap**
这也是为什么，当我们使用ThreadLocal来get()时，并不需要传入key，因为它是跟线程绑定的
让我们再来看看set()方法
```java fold:ThreadLocal#set(T value)
//...
    public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            map.set(this, value);
        } else {
            createMap(t, value);
        }
    }
//...
```
这里很清晰的看到，它是自己本身为key，去放进**对应线程的**ThreadLocalMap中的

整理一下，它的结构如下：
![image.png](https://cdn.jsdelivr.net/gh/HoShum/PictureRepo/imgs/202404031010634.png)
>请注意这里的虚线，表示的是弱引用

## 内存泄露
为什么ThreadLocal会发生内存泄露呢，其实就跟这个弱引用有关，下面用一段代码来说明
```java
public class ThreadLocalMemoryLeak {
    private static final int TASK_LOOP_SIZE = 500;

    /*线程池*/
    final static ThreadPoolExecutor poolExecutor
            = new ThreadPoolExecutor(5, 5, 1, TimeUnit.MINUTES, new LinkedBlockingQueue<>());

    static class LocalVariable {
        private byte[] a = new byte[1024*1024*5];/*5M大小的数组*/
    }

    ThreadLocal<LocalVariable> threadLocalLV;

    public static void main(String[] args) throws InterruptedException {
        SleepTools.ms(4000);
        for (int i = 0; i < TASK_LOOP_SIZE; ++i) {
            poolExecutor.execute(new Runnable() {
                public void run() {
                    SleepTools.ms(500);
                    LocalVariable localVariable = new LocalVariable();
                   	ThreadLocalMemoryLeak oom = new ThreadLocalMemoryLeak();
                    oom.threadLocalLV = new ThreadLocal<>();
                   	oom.threadLocalLV.set(new LocalVariable());
										//如果不想内存泄露，需要方法执行完进行remove
                		//oom.threadLocalLV.remove();
                    System.out.println("use local varaible");
                }
            });
            SleepTools.ms(100);
        }
        System.out.println("pool execute over");
    }
}
```
这段代码的大意就是，使用一个线程池，每个线程都通过ThreadLocal保存一份5M大小的数组的数据
当每个线程的`run`方法执行完后，该线程的栈帧就会从JVM的栈中移除，而此时对应的`threalLocalLV`引用会变为null，又因为它是一个弱引用，一旦发生GC，它在堆中的实例就会被回收，此时ThreadLocalMap就变成了 null -> value，自然内存就无法释放了
因此，为了避免这个问题，一般建议在方法执行完成前手动进行释放