title: Java并发编程：线程池创建及源码分析
date: 2017-11-11 13:09:04
tags: [Java并发编程]
------------------

Java5引入了线程池的顶级接口Executor，ExecutorService继承了Executor接口并增加了自己的方法。Executors工具类为Ex
ecutor，ExecutorService，ScheduledExecutorService，ThreadFactory和Callable类提供了一些工具
方法，通过这个工具类提供的方法可以方便的创建线程池。

##  1 使用线程池的好处

使用线程池的好处主要有三点：  
第一，降低资源消耗。通过预先创建的线程池，避免了高频率的创建和销毁线程，最大可能的重用线程。  
第二，提高响应速度。有任务到达的时候可以直接使用线程池中的空闲线程，避免即时创建线程导致的效率降低。  
第三，方便线程管理。通过线程池可以对线程进行统一创建、监控。

##  2 创建线程池

Executors工具类为创建线程池提供了 ** newCachedThreadPool，newFixedThreadPool，newSingleThrea
dExecutor以及newScheduledThreadPool ** 四个工厂方法创建不同类型的线程池。

###  2.1 newCachedThreadPool示例

这个方法创建的是一个可以动态改变大小的线程池。当任务较多时会增加线程池中线程的数量，如果需要处理的任务较少，导致线程60s没有运行，JVM则会回收线程。

    
    
    import java.io.*;
    import java.util.concurrent.*;
    public class TestThreadPool {
        public static class MyThread implements Runnable {
        @Override
            public void run() {
                System.out.println(Thread.currentThread().getName() + " is running...");
            }
        }
        public static void main(String[] args) {
            // TODO Auto-generated method stub
            ExecutorService MyThreadPool =  
                Executors.newCachedThreadPool();
            for (int i = 0; i < 5; i++) {
                MyThread t = new MyThread();
                MyThreadPool.execute(t);
            }
        }
    }

执行结果如下：

    
    
    pool-1-thread-3 is running...
    pool-1-thread-5 is running...
    pool-1-thread-4 is running...
    pool-1-thread-2 is running...
    pool-1-thread-1 is running...

由执行结果可知，线程池为了处理5个任务启动了5个线程。

###  2.2 newFixedThreadPool 示例

这个方法可以创建一个大小固定的线程池，当需要处理的任务书大于空闲线程个数时会暂时存在等待队列中直到有空闲的线程。

    
    
    import java.io.*;
    import java.util.concurrent.*;
    public class TestThreadPool {
        public static class MyThread implements Runnable {
        @Override
            public void run() {
                System.out.println(Thread.currentThread().getName() + " is running...");
            }
        }
        public static void main(String[] args) {
            // TODO Auto-generated method stub
            //ExecutorService MyThreadPool = Executors.newCachedThreadPool();
            //创建大小为3的线程池
            ExecutorService MyThreadPool = Executors.newFixedThreadPool(3);
            for (int i = 0; i < 5; i++) {
                MyThread t = new MyThread();
                MyThreadPool.execute(t);
            }
            MyThreadPool.shutdown();
        }
    }

执行结果如下：

    
    
    pool-1-thread-2 is running...
    pool-1-thread-3 is running...
    pool-1-thread-1 is running...
    pool-1-thread-3 is running...
    pool-1-thread-2 is running...

由执行结果可知，5个任务1\2\3号线程同时执行，当2\3号线程空闲后执行最后两个任务。

###  2.3 newSingleThreadExecutor示例

这个方法和2.2中的方法类似，不过本方法产生固定大小为1的线程池，所有任务由一个线程完成。

    
    
    import java.io.*;
    import java.util.concurrent.*;
    public class TestThreadPool {
        public static class MyThread implements Runnable {
            @Override
            public void run() {
                System.out.println(Thread.currentThread().getName() + " is running...");
            }
        }
        public static void main(String[] args) {
            // TODO Auto-generated method stub
            //ExecutorService MyThreadPool = Executors.newCachedThreadPool();
            //创建大小为3的线程池
            //ExecutorService MyThreadPool = Executors.newFixedThreadPool(3);
            ExecutorService MyThreadPool = Executors.newSingleThreadExecutor();
            for (int i = 0; i < 5; i++) {
                MyThread t = new MyThread();
                MyThreadPool.execute(t);
            }
            MyThreadPool.shutdown();
        }
    }

执行结果如下：

    
    
    pool-1-thread-1 is running...
    pool-1-thread-1 is running...
    pool-1-thread-1 is running...
    pool-1-thread-1 is running...
    pool-1-thread-1 is running...

5个任务全是由线程1完成的。

###  2.4 newScheduledThreadPool示例

这个方法创建的是一个大小固定，但是支持延时和周期操作的线程池。

    
    
    import java.io.*;
    import java.util.concurrent.*;
    
    import org.omg.CORBA.PUBLIC_MEMBER;
    public class TestThreadPool {
        public static class MyThread implements Runnable {
            @Override
            public void run() {
            System.out.println(Thread.currentThread().getName() + " is running... 1");
            }
        }
        public static class Scheduled1 implements Runnable {
            @Override
            public void run() {
                System.out.println(Thread.currentThread().getName() + " is running... 2");
            }
        }
    
        public static void main(String[] args) {
            // TODO Auto-generated method stub
            //ExecutorService MyThreadPool = Executors.newCachedThreadPool();
            //创建大小为3的线程池
            //ExecutorService MyThreadPool = Executors.newFixedThreadPool(3);
            ScheduledThreadPoolExecutor MyThreadPool = new ScheduledThreadPoolExecutor(2);
            Runnable r1 = new MyThread();
            Runnable r2 = new Scheduled1();
            MyThreadPool.scheduleAtFixedRate(r1, 1000, 2000, TimeUnit.MILLISECONDS);
            MyThreadPool.scheduleAtFixedRate(r2, 1000, 5000, TimeUnit.MILLISECONDS);
        }
    }

执行结果如下：

    
    
    pool-1-thread-1 is running... 1
    pool-1-thread-2 is running... 2
    pool-1-thread-1 is running... 1
    pool-1-thread-1 is running... 1
    pool-1-thread-2 is running... 2
    pool-1-thread-1 is running... 1
    pool-1-thread-1 is running... 1

##  3 几种线程池源码分析

第二节介绍的几种线程池创建方法都是通过调用ThreadPoolExecutor方法实现的，区别是调用ThreadPoolExecutor时传递的参数不同。

###  3.1ThreadPoolExecutor使用方法介绍

ThreadPoolExecutor的的构造方法如下：

    
    
    ThreadPoolExecutor(int corePoolSize, int maximumPoolSize, long keepAliveTime, TimeUnit unit, BlockingQueue<Runnable> workQueue, ThreadFactory threadFactory, RejectedExecutionHandler handler)

corePoolSize: 线程池中基本线程数。线程池初始化会创建corePoolSize个基本线程用于处理任务。  
maximumPoolSize：线程池最大容量。线程池最多允许存在的线程数。  
keepAliveTime：线程空闲回收时间。线程池中除了基本线程的外的线程空闲时间达到keepAliveTime时就会由JVM自动销毁回收。  
unit：时间单位。keepAliveTime的时间单位。  
workQueue：线程的排队队列。常见的线程队列有无界队列（LinkedBlockingQueue），同步队列（SynchronousQueue），有界队
列（ArrayBlockingQueue）。任务的提交策略由选用哪种任务队列决定。  
threadFactory：线程工厂。创建线程的方法，可以通过这个参数为线程命名一个有意义的名称。  
handler：饱和处理策略。当线程池和队列都满时的处理策略。

###  3.2 newCachedThreadPool源码分析

    
    
     public static ExecutorService newCachedThreadPool() {
        return new ThreadPoolExecutor(0, Integer.MAX_VALUE,60L, TimeUnit.SECONDS,new SynchronousQueue<Runnable>());
    }

newCachedThreadPool是一个静态方法，内部返回了一个ThreadPoolExecutor实例。  
ThreadPoolExecutor的具体参数如下：  
corePoolSize：0，线程池的基本线程数为0。线程池不会维护固定大小的基本线程。  
maximumPoolSize：Integer.MAX_VALUE,2^31 - 1。线程池的大小可以认为是无限大的。  
keepAliveTime：60L，保活时间为60。当基本线程外的线程超过60个时间单位没有处理任务则回收。  
unit：TimeUnit.SECONDS，时间单位为秒。  
workQueue：SynchronousQueue，同步队列。等待队列为同步队列，只有线程将队列中的任务取走时新的任务才会入队列。  
** 由源码分析可知，newCachedThreadPool方法创建的线程池是一个无线大小的线程池，他会根据任务的多少动态增减线程池中线程的数量。 **

###  3.3 newFixedThreadPool源码分析

    
    
    public static ExecutorService newFixedThreadPool(int nThreads) {
        return new ThreadPoolExecutor(nThreads, nThreads, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());
    }

ThreadPoolExecutor的具体参数如下：  
corePoolSize：nThreads，线程池的基本线程数为nThreads。  
maximumPoolSize：nThreads。线程池的包含的最大数量和基本线程数量是一样的。  
keepAliveTime：0L，保活时间为0。由于不存在线程池中数量大于基本线程数量的情况，所以JVM不会制动回收线程。  
unit：TimeUnit.SECONDS，时间单位为秒。  
workQueue：LinkedBlockingQueue，无界队列。队列的大小可以认为是无限的。  
** 由源码分析可知，newFixedThreadPool方法创建的是一个大小固定的线程池，当线程池中线程数量大于基本线程数时，任务会加入等workQueue。 **

###  3.4 newSingleThreadExecutor源码分析

    
    
       public static ExecutorService newSingleThreadExecutor() {
        return new FinalizableDelegatedExecutorService (new ThreadPoolExecutor(1, 1, 0L, TimeUnit.MILLISECONDS,new LinkedBlockingQueue<Runnable>()));
      }

ThreadPoolExecutor的具体参数如下：  
corePoolSize：1，线程池的基本线程数为1。  
maximumPoolSize：1。线程池的包含的最大数量和基本线程数量是一样的，并且最多只允许有1个线程。  
keepAliveTime：0L，保活时间为0。由于不存在线程池中数量大于基本线程数量的情况，所以JVM不会制动回收线程。  
unit：TimeUnit.SECONDS，时间单位为秒。  
workQueue：LinkedBlockingQueue，无界队列。队列的大小可以认为是无限的。  
由源码分析可知，newFixedThreadPool方法和newFixedThreadPool方法几乎一样，只是线程池大小固定为1。

##  4
ThreadPoolExecutor、AbstractExecutorService、ExecutorService和Executor的关系及下一篇预告。

Executor是线程池的顶级接口，他只声明了execute方法。  
ExecutorService继承了Executor接口并声明了submit的方法。  
AbstractExecutorService类实现了ExecutorService的几乎所有方法。  
ThreadPoolExecutor继承了AbstractExecutorService类。

下一篇会详细分析ThreadPoolExecutor。

##  5 参考

[1] [ http://blog.csdn.net/sd0902/article/details/8395677
](http://blog.csdn.net/sd0902/article/details/8395677)  
[2] [ http://www.infoq.com/cn/articles/java-threadPool#anch92136
](http://www.infoq.com/cn/articles/java-threadPool#anch92136)  
[3] [ http://www.cnblogs.com/nayitian/p/3262031.html
](http://www.cnblogs.com/nayitian/p/3262031.html)  
[4] [ http://www.cnblogs.com/dolphin0520/p/3932921.html
](http://www.cnblogs.com/dolphin0520/p/3932921.html)

