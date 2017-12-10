Java并发编程：阻塞队列及实现生产者-消费者模式

##  1 什么是阻塞队列

JDK 1.5的java.util.concurrent包提供了多种阻塞队列。阻塞队列相对于PriorityQueue、LinkedList等非阻塞队列的特
点是提供了，队列阻塞的操作，优化了队列为空向队列取数据或者队列满向队列加数据时的阻塞操作。 ** 以生产者-
消费者模式为例，当队列为空时消费者线程会被挂起，等到队列中有数据时会自动的恢复并消费。 **

###  1.1 常见的阻塞队列

BlockingQueue接口的主要实现有如下几种：  
** ArrayBlockingQueue ** ：基于数组的有界阻塞队列，构造时可以指定队列大小，默认为非公平（不保证等待最久的任务最先处理）。   
** LinkedBlockingQueue ** ：基于链表的有界阻塞队列，如果不指定大小则默认为Integer.MAX_VALUE，基本可以认为是无界的。   
** PriorityBlockingQueue ** ：优先级排序的无界阻塞队列，元素出队列的顺序按照优先级排序。   
** DelayQueue ** ：基于优先级队列的无界阻塞队列。队列中的元素只有到达规定的延时才能从队列中取出。   
** SynchronousQueue ** ：不存储元素的阻塞队列，只有前一个将队列中的元素取走时才能加入新的元素。 

###  1.2 阻塞队列常见的方法

常见的非阻塞队列的操作列表如下：  
** add(E e) ** :将元素e插入到队列末尾，如果插入成功，则返回true；如果插入失败（即队列已满），则会抛出异常；   
** remove() ** ：移除队首元素，若移除成功，则返回true；如果移除失败（队列为空），则会抛出异常；   
** offer(E e) ** ：将元素e插入到队列末尾，如果插入成功，则返回true；如果插入失败（即队列已满），则返回false；   
** poll() ** ：移除并获取队首元素，若成功，则返回队首元素；否则返回null；   
** peek() ** ：获取队首元素，若成功，则返回队首元素；否则返回null   
阻塞队列实现了非阻塞队列的操作方法，为了实现“阻塞”提供了take和put方法。  
** take() ** ：获取并移除队首元素，如果队列为空则阻塞直到队列中有元素。   
** put() ** ：向队尾添加元素，如果队列满则等待直到可以添加。 

##  2 LinkedBlockingQueue源码分析

LinkedBlockingQueue是阻塞队列中比较常用的，ThreadPoolExecutor类的实现中多是用的这个队列。下面通过源码分下阻塞队列的工作
原理。

###  2.1 构造方法源码分析

LinkedBlockingQueue共有三个构造方法，分别功能为默认大小，指定大小以及带初始化的构造方法。

    
    
    /**
         * Creates a {@code LinkedBlockingQueue} with a capacity of
         * {@link Integer#MAX_VALUE}.
         */
        public LinkedBlockingQueue() {
            this(Integer.MAX_VALUE); //无参的构造函数,最大容量为Integer(4字节)的最大表示值
        }
    
        /**
         * Creates a {@code LinkedBlockingQueue} with the given (fixed) capacity.
         *
         * @param capacity the capacity of this queue
         * @throws IllegalArgumentException if {@code capacity} is not greater
         *         than zero
         */
        public LinkedBlockingQueue(int capacity) { //指定容量的构造函数,大小为capacity
            if (capacity <= 0) throw new IllegalArgumentException();
            this.capacity = capacity;
            last = head = new Node<E>(null);
        }
    
        /**
         * Creates a {@code LinkedBlockingQueue} with a capacity of
         * {@link Integer#MAX_VALUE}, initially containing the elements of the
         * given collection,
         * added in traversal order of the collection's iterator.
         *
         * @param c the collection of elements to initially contain
         * @throws NullPointerException if the specified collection or any
         *         of its elements are null
         */
        public LinkedBlockingQueue(Collection<? extends E> c) { //带初始化的构造方法,可以将指定集合中的元素初始化到阻塞队列中
            this(Integer.MAX_VALUE);  //最大容量为Integer(4字节)的最大表示值 
            final ReentrantLock putLock = this.putLock;
            putLock.lock(); // Never contended, but necessary for visibility
            try {
                int n = 0;
                for (E e : c) {
                    if (e == null)
                        throw new NullPointerException();
                    if (n == capacity)
                        throw new IllegalStateException("Queue full");
                    enqueue(new Node<E>(e));
                    ++n;
                }
                count.set(n);
            } finally {
                putLock.unlock();
            }
        }
    }

###  2.2 put方法源码分析

put方法内部通过Condition的await和signal方法实现了线程之间的同步，和使用线程同步实现生产者消费者的代码逻辑差不多。同步队列采用了两把锁
，读锁（takeLock）和写锁（putLock）。

    
    
    /**
     * Inserts the specified element at the tail of this queue, waiting if
     * necessary for space to become available.
     *
     * @throws InterruptedException {@inheritDoc}
     * @throws NullPointerException {@inheritDoc}
     */
    public void put(E e) throws InterruptedException {
        if (e == null) throw new NullPointerException();
        // Note: convention in all put/take/etc is to preset local var
        // holding count negative to indicate failure unless set.
        int c = -1;
        Node<E> node = new Node<E>(e);
        final ReentrantLock putLock = this.putLock; //定义可重入   写锁
        final AtomicInteger count = this.count; //原子类
        putLock.lockInterruptibly(); //进入临界区,他和lock的区别是lockInterruptibly不处理中断而是向上层抛出异常
        try {
            /*
             * Note that count is used in wait guard even though it is
             * not protected by lock. This works because count can
             * only decrease at this point (all other puts are shut
             * out by lock), and we (or some other waiting put) are
             * signalled if it ever changes from capacity. Similarly
             * for all other uses of count in other wait guards.
             */
            while (count.get() == capacity) { //容量已满,线程进入阻塞状态,交出锁并且交出CPU
                notFull.await();  //写锁的Condition
            }
            enqueue(node); //加入队列
            c = count.getAndIncrement();
            if (c + 1 < capacity) //队列未满,唤醒一个等待写入的线程
                notFull.signal();
        } finally {
            putLock.unlock();
        }
        if (c == 0) //队列第一次不为空,唤醒一个等待读取的线程
            signalNotEmpty(); 
    }

###  2.3 take方法源码分析

    
    
    public E take() throws InterruptedException {
        E x;
        int c = -1;
        final AtomicInteger count = this.count;
        final ReentrantLock takeLock = this.takeLock; //定义可重入锁  读锁
        takeLock.lockInterruptibly(); //进入临界区,他和lock的区别是lockInterruptibly不处理中断而是向上层抛出异常
        try {
            while (count.get() == 0) { //如果队列为空, 读取线程进入阻塞状态,交出读锁和CPU
                notEmpty.await();
            }
            x = dequeue(); //获取队首元素
            c = count.getAndDecrement();
            if (c > 1) //如果取完队列中还存在数据,则唤醒其他等待读取的线程
                notEmpty.signal();
        } finally {
            takeLock.unlock();
        }
        if (c == capacity) //没取之前队列为满的,取完之后要唤醒一个写入线程
            signalNotFull();
        return x;
    }

##  3 生产者-消费者模式实现

使用阻塞队列实现生产者-
消费者模式不需要我们自己编码控制读写线程的阻塞和唤醒操作，由上节分析的take()、put()方法可知，阻塞队列内部替我们实现了线程的阻塞和唤醒操作。

    
    
    public class BlockingQueue {
        private static LinkedBlockingQueue<Integer> queue = new LinkedBlockingQueue<Integer>(); //阻塞队列
    
        public static class Consumer implements Runnable {
            @Override
            public void run() {
                try {
                        Integer element = queue.take();
                        System.out.println(Thread.currentThread().getName() + "消费了一个产品...");
                } catch (InterruptedException e) {}
            }
        }
    
        public static class Producer implements Runnable {
            @Override
            public void run() {
                try {
                    queue.put(1);
                    System.out.println(Thread.currentThread().getName() + "生产了一个产品...");
                } catch (InterruptedException e) {}
            }
        }
    
        public static void main(String[] args) {
            ExecutorService comsumerPool = Executors.newSingleThreadExecutor();
            ExecutorService producerPool = Executors.newSingleThreadExecutor();
            Producer producer = new Producer();
            Consumer consumer = new Consumer();
            int i = 0;
            while (true) {
                comsumerPool.execute(consumer);
                producerPool.execute(producer);
                if (i++ > 200) {
                    break;
                }
            }
            try {
                TimeUnit.SECONDS.sleep(10);
            } catch (InterruptedException e) {}
    
            comsumerPool.shutdownNow();
            producerPool.shutdownNow();
        }
    }

部分执行结果如下：

    
    
    pool-2-thread-1生产了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...
    pool-1-thread-1消费了一个产品...
    pool-2-thread-1生产了一个产品...

由执行结果看出，阻塞队列很好的完成了生产者消费者模型，并且代码实现简单。

##  参考：

[1] [ http://www.cnblogs.com/dolphin0520/p/3932906.html
](http://www.cnblogs.com/dolphin0520/p/3932906.html)  
[2] [ http://www.infoq.com/cn/articles/java-blocking-queue
](http://www.infoq.com/cn/articles/java-blocking-queue)  
[3] [ http://blog.csdn.net/ghsau/article/details/8108292
](http://blog.csdn.net/ghsau/article/details/8108292)  
[4] [ http://blog.csdn.net/ns_code/article/details/17511147
](http://blog.csdn.net/ns_code/article/details/17511147)

