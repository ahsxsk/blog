title: Java并发编程：ThreadPoolExecutor类及方法源码分析
date: 2017-11-11 13:09:04
tags: [Java并发编程]
------------------

ThreadPoolExecutor是jdk自带线程池实现类，现有的Executors工具类实现的几种线程池核心都是调用ThreadPoolExecutor
类。ThreadPoolExecutor在jdk1.7及以后做了部分修改， ** 本文以JDK1.8为准 ** 。

##  1 构造函数

ThreadPoolExecutor类共有4个构造函数，其他三个构造函数都是调用下参数最全的一个，下面只介绍参数最全的的一个。

    
    
     public ThreadPoolExecutor(int corePoolSize,  //参数的意义已经在上一篇中介绍
                                  int maximumPoolSize,
                                  long keepAliveTime,
                                  TimeUnit unit,
                                  BlockingQueue<Runnable> workQueue,
                                  ThreadFactory threadFactory,
                                  RejectedExecutionHandler handler) {
            if (corePoolSize < 0 ||  //参数检查
                maximumPoolSize <= 0 ||
                maximumPoolSize < corePoolSize ||
                keepAliveTime < 0)
                throw new IllegalArgumentException();
            if (workQueue == null || threadFactory == null || handler == null)
                throw new NullPointerException();
            this.corePoolSize = corePoolSize; //设置基本线程数
            this.maximumPoolSize = maximumPoolSize; //设置最大线程数
            this.workQueue = workQueue;  //设置任务队列
            this.keepAliveTime = unit.toNanos(keepAliveTime); //设置存活时间
            this.threadFactory = threadFactory; //设置线程工厂
            this.handler = handler; //设局拒绝策略
        }

##  2 ThreadPoolExecutor类的方法

ThreadPoolExecutor类的主要方法有提交任务的execute()方法和submit()方法，终止线程的shutdown()方法和shutdow
mNow方法。  
** execute方法用于提交任务，在Executor接口中声明并在ThreadPoolExecutor类中实现。 **   
** submit方法用于提交任务并且有返回结果，在ExecutorService中声明并且在AbstractExecutorService类中实现，ThreadPoolExecutor类并没有重写。 **   
** shutdown方法用于关闭线程池，但是允许正在运行的任务运行完，将状态置为SHUTDOWN。 **   
** shutdownNow方法在关闭线程池时尝试终止正在运行的任务，将状态置为STOP。 **

##  3 ThreadPoolExecutor类重要方法源码分析

###  3.1 execute方法源码分析

execute方法在JDK1.7及以后具体实现做了重大修改，分析execute源码之前先列举ThreadPoolExecutor类定义的一些常量。

    
    
          private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0)); //采用原子整型来记录线程数量及状态
        private static final int COUNT_BITS = Integer.SIZE - 3;  //线程池中线程数量存在低29位，高3位是线程池状态
        private static final int CAPACITY   = (1 << COUNT_BITS) - 1;
    
        // runState is stored in the high-order bits
        private static final int RUNNING    = -1 << COUNT_BITS; //
        private static final int SHUTDOWN   =  0 << COUNT_BITS;
        private static final int STOP       =  1 << COUNT_BITS;
        private static final int TIDYING    =  2 << COUNT_BITS;
        private static final int TERMINATED =  3 << COUNT_BITS;
    
        // Packing and unpacking ctl
        private static int runStateOf(int c)    { return c & ~CAPACITY; }
        private static int workerCountOf(int c)  { return c & CAPACITY; }
        private static int ctlOf(int rs, int wc) { return rs | wc; }

** 线程池的五种状态： **   
** RUNNING 在ThreadPoolExecutor被实例化的时候就是这个状态。 **   
** SHUTDOWN 通常是已经执行过shutdown()方法，不再接受新任务，等待线程池中和队列中任务完成。 **   
** STOP 通常是已经执行过shutdownNow()方法，不接受新任务，队列中的任务也不再执行，并尝试终止线程池中的线程。 **   
** TIDYING 线程池为空，就会到达这个状态，执行terminated()方法。 **   
** TERMINATED terminated()执行完毕，就会到达这个状态。 **   
下面直接上代码，代码分析放在注释里：

    
    
    public void execute(Runnable command) {
            if (command == null) //参数检查
                throw new NullPointerException();
            int c = ctl.get(); //获取当前记录线程池状态和池中线程数量的变量
            if (workerCountOf(c) < corePoolSize) { //如果当前线程池中线程数量小于基本线程数量
                if (addWorker(command, true))  //新起一个线程处理任务，并将这个任务作为这个线程的第一个任务
                    return;
                c = ctl.get(); //增加线程失败，再次获取变量。（其他线程可能改变了线程池中线程数量，线程也可能die）
            }
            if (isRunning(c) && workQueue.offer(command)) { //如果线程池还是RUNNING状态就将任务加入工作队列
                int recheck = ctl.get(); //需要double check主要是时间差的问题，在上一句和这一句中间其他线程可能改变了线程池状态
                if (! isRunning(recheck) && remove(command)) //如果线程池状态不再是RUNNING，则从工作队列移除这个任务
                    reject(command); //移除任务成功，对这个任务使用拒绝策略
                else if (workerCountOf(recheck) == 0) //如果线程池状态是RUNNING，并且线程数量为0，说明基本线程数为0
                    addWorker(null, false); //线程池启动一个线程,启动后并不直接处理任务，并且判断界限变为maximumPoolSize
            }
            else if (!addWorker(command, false))  //如果工作队列已满，则增加线程处理，线程判断条件变为maximumPoolSize
                reject(command);
        }

忽略细节后总的逻辑如下：  
** 第一，线程池中线程数量小于基本线程数（corePoolSize），则启动新线程处理新的任务。 **   
** 第二，线程池中线程数不小于基本线程数，则将任务加入工作队列。 **   
** 第三，工作队列如果已满，判断线程数如果小于最大线程数（maximumPoolSize），则启动新线程处理当前任务。 **   
execute方法中最核心的方法就是addWorker方法，这个方法负责创建线程，下面重点分析洗addWorker源码。

    
    
       private boolean addWorker(Runnable firstTask, boolean core) {
            retry:
            for (;;) {
                int c = ctl.get();
                int rs = runStateOf(c); //获取线程池状态
    
                // Check if queue empty only if necessary.
                if (rs >= SHUTDOWN &&
                    ! (rs == SHUTDOWN && //队列没有任务并且没有提交新任务则不会创建新线程
                       firstTask == null &&
                       ! workQueue.isEmpty()))
                    return false;
    
                for (;;) {
                    int wc = workerCountOf(c);
                    if (wc >= CAPACITY ||
                        wc >= (core ? corePoolSize : maximumPoolSize)) //线程数量大于线程池容量或者传入的最大池数量则不会创建新线程
                        return false;
                    if (compareAndIncrementWorkerCount(c)) //如果线程池的状态和线程数量都没有改变，则将线程数量+1并且开始真正创建线程
                        break retry;
                    c = ctl.get();  // Re-read ctl，线程数量或者线程池状态改变重新获取线程状态
                    if (runStateOf(c) != rs) //线程池状态改变则重新判断是否要创建新线程
                        continue retry;
                    // else CAS failed due to workerCount change; retry inner loop
                }
            }
    
            boolean workerStarted = false;
            boolean workerAdded = false;
            //private final class Worker extends AbstractQueuedSynchronizer implements Runnable
            Worker w = null;
            try {
                w = new Worker(firstTask);
                final Thread t = w.thread;
                if (t != null) {
                    final ReentrantLock mainLock = this.mainLock;
                    mainLock.lock(); //加锁，防止其他线程同事操作
                    try {
                        // Recheck while holding lock.
                        // Back out on ThreadFactory failure or if
                        // shut down before lock acquired.
                        int rs = runStateOf(ctl.get());//获取线程状态
    
                        if (rs < SHUTDOWN ||
                            (rs == SHUTDOWN && firstTask == null)) { //检查线程池状态
                            if (t.isAlive()) // precheck that t is startable
                                throw new IllegalThreadStateException();
                            workers.add(w);  //添加创建好的worker对象
                            int s = workers.size();
                            if (s > largestPoolSize) //更新线程池最大数量记录
                                largestPoolSize = s;
                            workerAdded = true;
                        }
                    } finally {
                        mainLock.unlock();
                    }
                    if (workerAdded) {
                        t.start();  //启动线程
                        workerStarted = true;
                    }
                }
            } finally {
                if (! workerStarted) //线程未启动成功，失败处理
                    addWorkerFailed(w);
            }
            return workerStarted;
        }

###  3.2 shutdown方法源码分析

** shutdown方法关闭线程池时将线程池的状态置为SHUTDOWN，不再接受新任务，等待队列中的任务执行完成。 **
    
    
    public void shutdown() {
            final ReentrantLock mainLock = this.mainLock;
            mainLock.lock();
            try {
                checkShutdownAccess(); //检查当前线程是否有权限终端线程池中的所有线程
                advanceRunState(SHUTDOWN); //将线程池状态改为SHUTDOWN
                interruptIdleWorkers(); //中断空闲线程
                onShutdown(); // hook for ScheduledThreadPoolExecutor
            } finally {
                mainLock.unlock();
            }
            tryTerminate(); //将线程池状态置为TERMINATED
        }

###  3.3 shutdownNow方法源码分析

** shutdownNow方法关闭线程池时将线程池的状态置为STOP，并且停止队列中正在进行的任务。 **
    
    
    public List<Runnable> shutdownNow() {
            List<Runnable> tasks;
            final ReentrantLock mainLock = this.mainLock;
            mainLock.lock();
            try {
                checkShutdownAccess();
                advanceRunState(STOP); //将线程池状态改为STOP
    
                interruptWorkers();
                tasks = drainQueue(); //和shutdown方法的区别就在于shutdownNow会停止正在处理的任务
            } finally {
                mainLock.unlock();
            }
            tryTerminate();
            return tasks;
        }

