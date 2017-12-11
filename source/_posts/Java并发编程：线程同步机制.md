title: Java并发编程：线程同步机制
date: 2017-11-11 13:09:04
categories: [Java并发编程]
------------------

** Java中线程同步可以通过wait、notify、notifyAll等方法实现。这几个方法在最顶级的父类Object中实现，并且被声明为final，所以子类无法重写这几个方法。在实现线程同步时，一般需要配合synchronized关键字使用，定义同步代码块或者方法。JDK 1.5以后提供了Condition来实现线程间的协作，Condition提供的await、signal、signalAll方法相对于wait、notify、notifyAll的方法更加安全高效，Condition所使用的是ReentrantLock锁。 **

##  1 synchronized关键字和ReentrantLock类

理解synchronized关键字必须首先了解下Java的内存模型。  
** Java中每一个进程都有自己的主内存，进程中的每个线程有自己的线程内存，线程从主内存中获取数据在线程内存中计算完成后回写到主内存中。在并发情况下就可能造成数据过期数据的问题。 ** 具体例子看如下代码： 
    
    
    public class TestSync {
        public static int sum = 0;
        public static class MyThreadA implements Runnable {
            @Override
            public void run() {
                for (int j = 0; j < 10000; j++) {
                    sum++;
                }
            }
        }
    
        public static void main(String[] args) {
    
            ExecutorService executorService = Executors.newFixedThreadPool(10);
            for (int i = 0; i < 10; i++) { //10个任务交给线程池, 返回的数据预期为10*10000
                MyThreadA myThreadA = new MyThreadA();
                executorService.execute(myThreadA);
            }
            executorService.shutdown();
            System.out.println(sum);
        }
    }

执行结果如下：

    
    
    88625

从执行结果可以看出，并不是预期中的100000。原因就在数据过期的问题。例如线程A和线程B同时从主内存中获取sum的值为1500。线程A计算了1000次，此
时线程A内存中的sum为2500，并向主内存回写sum=2500，后交出CPU;线程B获得CPU开始计算了900次，此时线程B内存中的sum=2400,并向
主内存回写sum=2400,后交出CPU。此时主内存的sum=2400,而预期是1500+1000+900=3400。  
使用synchronized关键字改进代码如下：

    
    
    public class TestSync {
        public static int sum = 0;
        public static Object lock = new Object(); //自定义锁对象,代价较小
        public static class MyThreadA implements Runnable {
            @Override
            public void run() {
                synchronized (lock) { //同步代码块
                    for (int j = 0; j < 10000; j++) {
                        sum++;
                    }
                }
            }
        }
    
        public static void main(String[] args) {
    
            ExecutorService executorService = Executors.newFixedThreadPool(10);
            for (int i = 0; i < 10; i++) { //10个任务交给线程池, 返回的数据预期为10*10000
                MyThreadA myThreadA = new MyThreadA();
                executorService.execute(myThreadA);
            }
            executorService.shutdown();
            System.out.println(sum);
        }
    }

执行结果如下：

    
    
    100000

执行结果符合预期。原因是线程进入同步代码块后会获取对象锁，阻止其他线程进入执行，线程执行完for循环并向主内存回写sum后才会退出退出同步代码块，其他线程才
会执行。  
ReentrantLock类提供的锁机制可以完成所有synchronized关键字能实现的功能并且针对synchronized的限制 —
它无法中断一个正在等候获得锁的线程，也无法通过投票得到锁，如果不想等下去，也就没法得到锁，做出了改进，提高了高争用条件下的执行效率。具体分析请参考（ [
https://www.ibm.com/developerworks/cn/java/j-jtp10264/
](https://www.ibm.com/developerworks/cn/java/j-jtp10264/) ）；

##  2 wait()、notify()、notifyAll() 介绍及代码演示（介绍纯属copy其他博客， 地址： [
http://blog.csdn.net/ns_code/article/details/17225469
](http://blog.csdn.net/ns_code/article/details/17225469) ）

###  2.1 wait方法介绍

** 该方法用来将当前线程置入休眠状态，直到接到通知或被中断为止。在调用wait（）之前，线程必须要获得该对象的对象级别锁，即只能在同步方法或同步块中调用wait（）方法。进入wait（）方法后，当前线程释放锁。在从wait（）返回前，线程与其他线程竞争重新获得锁。如果调用wait（）时，没有持有适当的锁，则抛出IllegalMonitorStateException，它是RuntimeException的一个子类，因此，不需要try-catch结构。 **

###  2.2 notify方法介绍

** 该方法用来通知那些可能等待该对象的对象锁的其他线程。如果有多个线程等待，则线程规划器任意挑选出其中一个wait（）状态的线程来发出通知，并使它等待获取该对象的对象锁（notify后，当前线程不会马上释放该对象锁，wait所在的线程并不能马上获取该对象锁，要等到程序退出synchronized代码块后，当前线程才会释放锁，wait所在的线程也才可以获取该对象锁），但不惊动其他同样在等待被该对象notify的线程们。当第一个获得了该对象锁的wait线程运行完毕以后，它会释放掉该对象锁，此时如果该对象没有再次使用notify语句，则即便该对象已经空闲，其他wait状态等待的线程由于没有得到该对象的通知，会继续阻塞在wait状态，直到这个对象发出一个notify或notifyAll。 ** 这里需要注意：它们等待的是被notify或notifyAll，而不是锁。这与下面的notifyAll（）方法执行后的情况不同。 

###  2.3 notifyAll方法介绍

** 该方法与notify（）方法的工作方式相同，重要的一点差异是：notifyAll使所有原来在该对象上wait的线程统统退出wait的状态（即全部被唤醒，不再等待notify或notifyAll，但由于此时还没有获取到该对象锁，因此还不能继续往下执行），变成等待获取该对象上的锁，一旦该对象锁被释放（notifyAll线程退出调用了notifyAll的synchronized代码块的时候），他们就会去竞争。如果其中一个线程获得了该对象锁，它就会继续往下执行，在它退出synchronized代码块，释放锁后，其他的已经被唤醒的线程将会继续竞争获取该锁，一直进行下去，直到所有被唤醒的线程都执行完毕。 **

###  2.4 更深入的理解

** 如果线程调用了对象的wait（）方法，那么线程便会处于该对象的等待池中，等待池中的线程不会去竞争该对象的锁。当有线程调用了对象的notifyAll（）方法（唤醒所有wait线程）或notify（）方法（只随机唤醒一个wait线程），被唤醒的的线程便会进入该对象的锁池中，锁池中的线程会去竞争该对象锁。 **   
** 优先级高的线程竞争到对象锁的概率大，假若某线程没有竞争到该对象锁，它还会留在锁池中，唯有线程再次调用wait（）方法，它才会重新回到等待池中。而竞争到对象锁的线程则继续往下执行，直到执行完了synchronized代码块，它会释放掉该对象锁，这时锁池中的线程会继续竞争该对象锁。 **

###  2.5 代码展示

3线程交替wait，相互唤醒。

    
    
    public class Main {
        private static Object lock = new Object(); //自定义锁对象
        public static class MyThreadA implements Runnable {
            public String name;
            public MyThreadA(String name) {
                this.name = name;
            }
            @Override
            public void run() {
                synchronized (lock) {
                    for (int i = 0; i < 11; i++) {
                        if (i % 3 == 0 && i != 0) {
                            System.out.println(Thread.currentThread().getName() + " : "+ i);
                            try {
                                lock.wait();
                            } catch (InterruptedException e) {
                            }
                        }
                        //System.out.println(Thread.currentThread().getName() + " : " + i + "notify");
                        lock.notify();
                    }
                }
            }
        }
    
        public static void main(String[] args) {
            ExecutorService executorService = Executors.newFixedThreadPool(3);
            for (int i = 0; i < 3; i++) {
                MyThreadA myThreadA = new MyThreadA("thread a");
                executorService.execute(myThreadA);
            }
            //executorService.shutdown();
        }

执行结果如下：

    
    
    pool-1-thread-1 : 3
    pool-1-thread-2 : 3
    pool-1-thread-3 : 3
    pool-1-thread-1 : 6
    pool-1-thread-3 : 6
    pool-1-thread-1 : 9
    pool-1-thread-3 : 9
    pool-1-thread-2 : 6

线程2打印6后进入wait,没有其他线程notify导致一直等待。

##  3 await()、signal()、signalAll()介绍及代码演示

这三个方法的作用和wait、notify、notifyAll类似，采用这三个方法是需要使用的同步锁是Lock。

    
    
    public class Main {
        private static Lock lock = new ReentrantLock(); //自定义锁对象
        private static Condition condition = lock.newCondition();
        public static class MyThreadA implements Runnable {
            public String name;
            public MyThreadA(String name) {
                this.name = name;
            }
            @Override
            public void run() {
                lock.lock();
                try {
                    for (int i = 0; i < 11; i++) {
                        if (i % 3 == 0 && i != 0) {
                            System.out.println(Thread.currentThread().getName() + " : " + i);
                            try {
                                condition.await();
                            } catch (InterruptedException e) {}
                        }
                        //System.out.println(Thread.currentThread().getName() + " : " + i + "notify");
                        condition.signalAll();
                    }
                } finally {
                    lock.unlock();
                }
            }
        }
    
    
        public static void main(String[] args) {
            ExecutorService executorService = Executors.newFixedThreadPool(3);
            for (int i = 0; i < 3; i++) {
                MyThreadA myThreadA = new MyThreadA("thread a");
                executorService.execute(myThreadA);
            }
            executorService.shutdown();
        }
    }
    

执行结果如下：

    
    
    pool-1-thread-1 : 3
    pool-1-thread-2 : 3
    pool-1-thread-1 : 6
    pool-1-thread-2 : 6
    pool-1-thread-1 : 9
    pool-1-thread-2 : 9
    pool-1-thread-3 : 3
    pool-1-thread-3 : 6

和使用wait、notify类似，最后一个线程有可能会陷入一直等待的状态。

##  4、下一篇分别用上面描述的两种方法实现经典的生产者-消费者模型

