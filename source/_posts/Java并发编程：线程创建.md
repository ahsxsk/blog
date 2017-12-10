Java并发编程：线程创建

Java中创建线程最常用的方法有继承Thread类和实现Runnable两种。Thread类实际也是实现了Runnable方法，由于无法继承多个父类但是可以
继承多个接口，所有创建进程大多是实现Runnable接口

>   * 继承Thread类

>

>>     * 创建线程示例

>>     * Thread类源码分析

>

>   * 实现Runnable接口

>

>>     * 创建线程示例

>>     * Runnable接口源码分析

* * *

##  1 继承Thread类

###  1.1 创建线程示例

例如有15张票，有三个窗口，每个窗口卖五张票，可以使用继承Thread类实现多线程处理。

    
    
    import java.io.*;
    import java.lang.Thread;
    public class ExtendThread {
        public static class MultiThread extends Thread {
        private int total = 5;
        private String name;
        MultiThread(String name) {
            // TODO Auto-generated constructor stub
            super(name);
        }
        @Override
        public void run () {
            while (total > 0) {
                System.out.println("Ticket:" + total-- + " is saled by Thread:" + Thread.currentThread().getName());
            }
        }
    }
        public static void main(String[] args) {
            // TODO Auto-generated method stub
            MultiThread mt1 = new MultiThread("Thread1");
            MultiThread mt2 = new MultiThread("Thread2");
            MultiThread mt3 = new MultiThread("Thread3");
            mt1.start();
            mt2.start();
            mt3.start();
        }
    }
    运行结果如下：
    Ticket:5 is saled by Thread:Thread2
    Ticket:5 is saled by Thread:Thread1
    Ticket:5 is saled by Thread:Thread3
    Ticket:4 is saled by Thread:Thread3
    Ticket:3 is saled by Thread:Thread3
    Ticket:4 is saled by Thread:Thread1
    Ticket:4 is saled by Thread:Thread2
    Ticket:3 is saled by Thread:Thread1
    Ticket:2 is saled by Thread:Thread3
    Ticket:1 is saled by Thread:Thread3
    Ticket:2 is saled by Thread:Thread1
    Ticket:1 is saled by Thread:Thread1
    Ticket:3 is saled by Thread:Thread2
    Ticket:2 is saled by Thread:Thread2
    Ticket:1 is saled by Thread:Thread2

###  1.2 Thread类源码分析

####  1.2.1 类声明

    
    
    public class Thread extends Object implements Runnable；

从类声明可以看出Thread实现了Runnable接口。

####  1.2.2 构造函数

Thread类的构造函数有8个，这里只介绍他的无参构造函数Thread()，其他构造函数可以到 ** [
http://docs.oracle.com/javase/7/docs/api/
](http://docs.oracle.com/javase/7/docs/api/) ** 学习了解。

    
    
    public Thread() {
        init(null, null, "Thread-" + nextThreadNum(), 0);
    }

由init得第三个参数可以看出线程名称命名规则是Thread-加上线程数组合。 init函数的内部实现如下：

    
    
    /**
         * Initializes a Thread.
         *
         * @param g the Thread group
         * @param target the object whose run() method gets called
         * @param name the name of the new Thread
         * @param stackSize the desired stack size for the new thread, or
         *        zero to indicate that this parameter is to be ignored.
         */
    　　　　//ThreadGroup：线程组表示一个线程的集合。此外，线程组也可以包含其他线程组。线程组构成一棵树，在树中，除了初始线程组外，每个线程组都有一个父线程组。
        private void init(ThreadGroup g, Runnable target, String name,
                          long stackSize) {
        Thread parent = currentThread();
        SecurityManager security = System.getSecurityManager();
        if (g == null) {
            /* Determine if it's an applet or not */
    
            /* If there is a security manager, ask the security manager
               what to do. */
            if (security != null) {
            g = security.getThreadGroup();
            }
    
            /* If the security doesn't have a strong opinion of the matter
               use the parent thread group. */
            if (g == null) {
            g = parent.getThreadGroup();
            }
        }
    
        /* checkAccess regardless of whether or not threadgroup is
               explicitly passed in. */
        g.checkAccess();
    
        /*
         * Do we have the required permissions?
         */
        if (security != null) {
            if (isCCLOverridden(getClass())) {
                security.checkPermission(SUBCLASS_IMPLEMENTATION_PERMISSION);
            }
        }
    
            g.addUnstarted();
    
        this.group = g;
    
    　　　　//每个线程都有一个优先级，高优先级线程的执行优先于低优先级线程。每个线程都可以或不可以标记为一个守护程序。当某个线程中运行的代码创建一个新 Thread 对象时，该新线程的初始优先级被设定为创建线程的优先级，并且当且仅当创建线程是守护线程时，新线程才是守护程序。
        this.daemon = parent.isDaemon();
        this.priority = parent.getPriority();
        this.name = name.toCharArray();
        if (security == null || isCCLOverridden(parent.getClass()))
            this.contextClassLoader = parent.getContextClassLoader();
        else
            this.contextClassLoader = parent.contextClassLoader;
        this.inheritedAccessControlContext = AccessController.getContext();
        this.target = target;
        setPriority(priority);
            if (parent.inheritableThreadLocals != null)
            this.inheritableThreadLocals =
            ThreadLocal.createInheritedMap(parent.inheritableThreadLocals);
            /* Stash the specified stack size in case the VM cares */
            this.stackSize = stackSize;
    
            /* Set thread ID */
            tid = nextThreadID();
        }

####  1.2.3 run()方法

run定义了线程实际完成的功能，具体源码如下：

    
    
    public void run() {
        if (target != null) {
            target.run();
        }
    }

target是接口Runnable实现的引用，由于run方法并未做任何实现，所以继承Thread类必须实现run方法。

####  1.2.4 start()方法

start方法作用为启动一个线程，源码如下：

    
    
    public synchronized void start() {
            if (threadStatus != 0 || this != me)
                throw new IllegalThreadStateException();
            group.add(this);
            start0();
            if (stopBeforeStart) {
            stop0(throwableFromStop);
        }
     }

start方法内部调用了本地方法start0创建线程，在创建线程之前会检查当前线程对象是否已经运行过start方法，确保一个线程对象只会运行一次start方
法。如果多次运行start方法，就会导致有多个线程同时操作相同的堆栈计数器等，导致无法预期的结果。

####  1.2.5 yield()、wait()、sleep() 方法

yield方法使正在运行的线程变成就绪状态， ** 建议先运行其他线程 **
。但是这种方式只是建议，并不一定会让其他线程先运行，也有可能当前线程继续运行，yield方法只会让 ** 相同优先级的线程优先执行 ** 。  
wait方法不属于Thread类，他是Object类的方法。这个方法释放线程锁，知道收到notify通知为止。  
sleep方法会使线程休眠一段时间，但是休眠期间不会主动释放cpu资源。  
这里面内容挺多，忙完这段时间，把和这几个方法相关的线程调度、同步锁等知识温习分享下。

####  1.2.6 join()方法

join方法的作用是强行运行要join的线程，阻塞当前线程知道join的线程执行完毕。如下示例：

    
    
    import java.io.*;
    import java.lang.Thread;
    
    public class TestJoin {
        public static class MultiThreadA extends Thread {
            private String name;
            private int count = 5;
    
            public MultiThreadA(String name) {
                this.name = name;
            }
    
            @Override
            public void run() {
                while (count-- > 0) {
                    try {
                        Thread.currentThread().sleep(500);
                    } catch (Exception e) {
                        // TODO: handle exception
                    }
                    System.out.println(name + count);
                }
            }
        }
        public static class MultiThreadB extends Thread {
            private String name;
            private int count = 5;
            MultiThreadA a;
    
            public MultiThreadB(MultiThreadA a) {
            // TODO Auto-generated constructor stub
                this.a = a;
            }
    
            @Override
            public void run() {
                try {
                    Thread.currentThread().sleep(505);
                } catch (Exception e) {
                    // TODO: handle exception
                }
                System.out.println("Begin ThreadB");
                try {
                    a.join();
                } catch (InterruptedException e) {
                    // TODO: handle exception
                    System.out.println("getException");
                }
                System.out.println("End ThreadB");
            }
        }
        public static void main(String[] args) {
            // TODO Auto-generated method stub
            MultiThreadA tA = new MultiThreadA("ThreadA");
            MultiThreadB tB = new MultiThreadB(tA);
            tA.start();
            tB.start();
        }
    }
    执行结果如下：
    ThreadA4
    Begin ThreadB
    ThreadA3
    ThreadA2
    ThreadA1
    ThreadA0
    End ThreadB

ThreadA首先打印了一条，然后ThreadB运行，遇到a.join()后运行ThreadA直到运行结束才会再次运行ThreadB。

##  2、实现Runnable接口

通过实现Runnable接口可以创建线程，实现的过程和Thread类内部实现很相似。

###  2.1 创建线程示例

Thread类演示了每个窗口售票不相互影响，各自卖五张票。如果需要三个窗口协同卖5张票，可以通过Runnalble共享变量，示例如下：

    
    
    import java.io.*;
    import java.lang.Thread;
    
    public class TestRunnable {
        public static class MyThread implements Runnable {
            private String name;
            private int total = 5;
    
            public MyThread(String name) {
                // TODO Auto-generated constructor stub
                this.name = name;
            }
    
            @Override
            public synchronized void run() {
                try {
                    Thread.currentThread().sleep(10);
                } catch (Exception e) {
                    // TODO: handle exception
                }
                while (total > 0) {
                    System.out.println("ticket:" + total + " is sold!");
                    total--;
                }
            }
        }
        public static void main(String[] args) {
            // TODO Auto-generated method stub
            MyThread mt = new MyThread("myThread");
            Thread a = new Thread(mt);
            Thread b = new Thread(mt);
            Thread c = new Thread(mt);
            a.start();
            b.start();
            c.start();
        }
    }
    运行结果如下：
    ticket:5 is sold!
    ticket:4 is sold!
    ticket:3 is sold!
    ticket:2 is sold!
    ticket:1 is sold!

三个线程共同完成5张票的售卖。

###  2.2 Runnable源码分析

Runnable接口中只有一个抽象run方法，所以不管是实现Runnable接口或者继承Thread类都需要重写run方法。

    
    
    public interface Runnable {
         public abstract void run();
     }

* * *

参考：

