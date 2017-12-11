title: Java并发编程：生产者-消费者模式
date: 2017-11-11 13:09:04
tags: [Java并发编程]
------------------

生产者消费者模型是并发编程的经典模型，生产者模型的核心思想是生产者生产的产品通过一块共享的资源与消费者交互，通过共享资源的交互实现了生产者与消费者的解耦。现
在的消息队列使用的也是这种思想。  
本文实现了如下描述的生产者-消费者模型：  
1、生产者和消费者各有1个；  
2、通信所使用的队列大小一定（200），并且队列不能溢出；  
3、生产者和我消费者的消费速度不做假设，生产速度和消费速度大小大概率不一致；  
4、生产者生产完商品后会通知消费者取商品，消费者消费完后会通知生产者生产商品；  
5、队列承载不了本次生产的商品时生产者会进入wait，队列里的商品不够本次消费时消费者会进入wait。

具体代码可解释如下：

    
    
    public class ProduceConsumer {
        //定义产品类
        public static class Product {
            private int name; //产品名称,编号
    
            @Override
            public String toString() {
                return "Product:" + name;
            }
        }
    
        //仓库类,主要逻辑在这里实现
        public static class WareHouse {
            private static Queue<Product> products = new LinkedList<Product>(); //产品队列
            private final int MAX = 200; //仓库最大容量
            private static int currentCount = 0; //当前仓储量
            private static int name = 1; //产品编号
            private static Lock lock = new ReentrantLock(); //自定义锁对象
            private static Condition condition = lock.newCondition();
            //生产产品
            public void produce(Product product, int amount) {
                lock.lock();
                try {
                    while (currentCount + amount > MAX) { //队列满
                        System.out.println(Thread.currentThread().getName() + "生产后的产品总量大于承载能力, wait");
                        try {
                            condition.await(); //进入等待
                            System.out.println(Thread.currentThread().getName() + "Get signal");
                        } catch (InterruptedException e) {
                            System.out.println(e.getStackTrace());
                        }
                    }
                    for (int i = 0; i < amount; i++) {
                        product.name = name++; //设置产品编号
                        products.add(product); //向队列中加入产品
                        currentCount++; //仓储数量增加
                    }
                    System.out.println(Thread.currentThread().getName() + "生产了 " + amount + " 个商品, 现在库存为: " + currentCount);
                    condition.signalAll(); //通知消费者
                    System.out.println(Thread.currentThread().getName() + " signalAll...");
                } finally {
                    lock.unlock();
                }
            }
    
            //消费产品
            public void consume(int amount) {
                lock.lock();
                try {
                    while (currentCount < amount) { //商品不够本次消费
                        System.out.println(Thread.currentThread().getName() + "要消费数量为: " + amount + "仓储数量: " + currentCount + " 仓储数量不足, wait");
                        try {
                            condition.await(); //进入等待
                            System.out.println(Thread.currentThread().getName() + "Get signal");
                        } catch (InterruptedException e) {
                        }
                    }
                    for (int i = 0; i < amount; i++) {
                        Product product = products.poll();
                        currentCount--; //减仓储
                    }
                    System.out.println(Thread.currentThread().getName() + "消费了 " + amount + " 个商品, 现在库存为: " + currentCount);
                    condition.signalAll(); //通知生产者
                    System.out.println(Thread.currentThread().getName() + "signalAll...");
                } finally {
                    lock.unlock();
                }
            }
        }
    
        //生产者类
        public static class Producer implements Runnable {
            @Override
            public void run() {
                int amount = (int) (Math.random() * 100); //最多生产仓储量的一半
                Product product = new Product();
                WareHouse wareHouse = new WareHouse();
                wareHouse.produce(product, amount);
            }
        }
    
        //消费者类
        public static class Consumer implements  Runnable{
            @Override
            public void run() {
                int amount = (int) (Math.random() * 100); //最多生产仓储量的一半
                WareHouse wareHouse = new WareHouse();
                wareHouse.consume(amount);
            }
        }
    
        public static void main(String[] args) {
            //生产者线程池
            ExecutorService producerPool = Executors.newFixedThreadPool(1);
            ExecutorService consumerPool = Executors.newSingleThreadExecutor();
            int i = 0;
            while (true) {
                Producer producer = new Producer();
                producerPool.execute(producer);
                Consumer consumer = new Consumer();
                consumerPool.execute(consumer);
                if (i++ > 200) {
                    break;
                }
            }
        }
    }

部分执行结果如下：

    
    
    pool-1-thread-1生产了 44 个商品, 现在库存为: 44
    pool-1-thread-1 signalAll...
    pool-2-thread-1消费了 44 个商品, 现在库存为: 0
    pool-2-thread-1signalAll...
    pool-1-thread-1生产了 3 个商品, 现在库存为: 3
    pool-1-thread-1 signalAll...
    pool-2-thread-1要消费数量为: 54仓储数量: 3 仓储数量不足, wait
    pool-1-thread-1生产了 91 个商品, 现在库存为: 94
    pool-1-thread-1 signalAll...
    pool-2-thread-1Get signal
    pool-2-thread-1消费了 54 个商品, 现在库存为: 40
    pool-2-thread-1signalAll...
    pool-1-thread-1生产了 34 个商品, 现在库存为: 74
    pool-1-thread-1 signalAll...
    pool-2-thread-1要消费数量为: 95仓储数量: 74 仓储数量不足, wait
    pool-1-thread-1生产了 62 个商品, 现在库存为: 136
    pool-1-thread-1 signalAll...
    pool-2-thread-1Get signal
    pool-2-thread-1消费了 95 个商品, 现在库存为: 41
    pool-2-thread-1signalAll...
    pool-2-thread-1要消费数量为: 89仓储数量: 41 仓储数量不足, wait
    pool-1-thread-1生产了 82 个商品, 现在库存为: 123
    pool-1-thread-1 signalAll...
    pool-1-thread-1生产了 14 个商品, 现在库存为: 137
    pool-1-thread-1 signalAll...
    pool-1-thread-1生产了 28 个商品, 现在库存为: 165
    pool-1-thread-1 signalAll...
    pool-1-thread-1生产了 19 个商品, 现在库存为: 184
    pool-1-thread-1 signalAll...
    pool-1-thread-1生产后的产品总量大于承载能力, wait
    pool-2-thread-1Get signal
    pool-2-thread-1消费了 89 个商品, 现在库存为: 95

这段代码里控制了生产者消费者的速度都不能超过100即仓储总量的一半，否则可能发生消费者和生产者相互等待的情况。例如：仓储现在已有110个商品，消费者需要消费
120个，所以消费者进入wait；此时生产者线程获得cpu，并且需要生产100个商品，由于现在剩下的仓储只有90个，所以生产者线程此时也进入wait，导致两
个线程相互等待。大家看看怎么解决。

