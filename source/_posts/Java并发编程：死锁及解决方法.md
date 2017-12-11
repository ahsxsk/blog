title: Java并发编程：死锁及解决方法
date: 2017-11-11 13:09:04
categories: [Java并发编程]
------------------

##  1 什么是死锁

死锁是多个进程\线程为了完成任务申请多个不可剥夺的资源并且以不正确的方式推进导致的一直互相等待对方释放资源的状态。下面以经典的哲学家就餐问题为例，描述死锁产
生的场景。

##  2 哲学家就餐问题

五个哲学家坐在一个圆桌上，每个哲学家两侧都放着1根筷子，总共有5只筷子。哲学家需要分别或者左右手的两只筷子才能就餐，就餐完成后将筷子放回原处，其他哲学家可以
获取放回的筷子。有这样一种状态，每个哲学家都获取了他右手的筷子，试图获取左手的筷子时都会失败（被他左手边的哲学家拿走了），然后所有哲学家都会一直等待他左手边
哲学家释放筷子，这就导致了死锁状态。

    
    
    public class PhilosopherEat {
        /*
         *筷子类
         */
        public static class Chop {
            private volatile boolean taken = false; //筷子状态
            ReentrantLock lock = new ReentrantLock(); //定义锁
            Condition isTaken = lock.newCondition();
    
            //拿起筷子
            public void take() throws InterruptedException {
                lock.lock();
                try {
                    while (taken) { //筷子已被其他哲学家拿走
                        isTaken.await();
                    }
                    taken = true; //标记筷子被拿走
                } finally {
                    lock.unlock();
                }
            }
    
            // 放下筷子
            public  void put() throws InterruptedException {
                lock.lock();
                try {
                    taken = false; //放下筷子
                    isTaken.signalAll(); //通知邻座的哲学家拿筷子
                } finally {
                    lock.unlock();
                }
            }
        }
        /*
         * 哲学家就餐类
         */
        public static class Philosopher implements Runnable {
            private Chop left; //左手的筷子
            private Chop right; //右手的筷子
            private int id; //哲学家编号
            private int ponderFactor; //思考时间
            private Random random = new Random(47);
            //暂停时间,模拟哲学家吃饭用时等
            private void pasue() throws InterruptedException {
                if (ponderFactor == 0) {
                    return;
                }
                //TimeUnit.MILLISECONDS.sleep(random.nextInt(ponderFactor * 250));
                TimeUnit.MILLISECONDS.sleep(10);
            }
    
            //构造方法
            public Philosopher(Chop left, Chop right, int id, int ponderFactor) {
                this.left = left;
                this.right = right;
                this.id = id;
                this.ponderFactor = ponderFactor;
            }
    
            @Override
            public void run() {
                try {
                    while (!Thread.interrupted()) {
                        System.out.println(this + " " + "thinking");
                        pasue();
                        right.take();
                        System.out.println(this + " " + "take right");
                        left.take();
                        System.out.println(this + " " + "take left");
                        System.out.println(this + " " + "eat");
                        pasue();
                        left.put();
                        System.out.println(this + " " + "put left");
                        right.put();
                        System.out.println(this + " " + "put right");
                    }
                } catch (InterruptedException e) {}
            }
        }
    
        public static void main(String[] args) {
            int size = 5;
            int ponder = 5;
            Chop [] chops = new Chop[5]; //5跟筷子
            for (int i = 0; i < 5; i++) {
                chops[i] = new Chop();
            }
            ExecutorService pool = Executors.newCachedThreadPool();
            for (int i = 0; i < size; i++) {
                pool.execute(new Philosopher(chops[i], chops[(i + 1) % 5], i, ponder));
            }
            try {
                System.out.println("quit");
                System.in.read();
            } catch (IOException e) {}
            pool.shutdown();
        }
    }

大部分情况下执行不会发生死锁，就餐和思考时间越短越容易发生死锁，这也是死锁问题的可怕之处，不易复现。

##  3 死锁的必要条件

死锁的必要条件有如下四个：

###  3.1 互斥条件

一个资源每次只能被一个线程使用，如IO等。

###  3.2 请求与保持条件

一个进程因请求资源而阻塞时，对已获得的资源保持不放。

###  3.3 不剥夺条件

进程已获得的资源，在未使用完之前，不能强行剥夺。

###  3.4 循环等待条件

若干进程之间形成一种头尾相接的循环等待资源关系。

##  4 解决死锁的方法

死锁的必要条件必须全部满足才会产生死锁，所以要解决死锁问题只需要任意破坏其中一个条件就可以解决死锁问题。

###  4.1 互斥条件

很多系统资源如IO等必须是互斥的，破坏互斥条件的成本较大。

###  4.2 请求与保持条件

可以通过一次性获取所有资源即对需要的资源进行原子申请可以解决死锁问题，这种方式对系统开销较大，不太理想。

###  4.3 不可剥夺条件

可以通过定时释放占有的资源解决死锁问题，但是这也会带来过多的资源占有释放操作。

###  4.4 循环等待条件

这是解决死锁常用的方法，例如哲学家就餐问题中，最后一个哲学家可以先拿左手的筷子，拿不到就会等待，他右手的筷子就可以供第一个哲学家使用。

    
    
    public static void main(String[] args) {
        int size = 5;
        int ponder = 5;
        Chop [] chops = new Chop[5]; //5跟筷子
        for (int i = 0; i < 5; i++) {
            chops[i] = new Chop();
        }
        ExecutorService pool = Executors.newCachedThreadPool();
        for (int i = 0; i < size; i++) {
            if (i < size - 1) {
                pool.execute(new Philosopher(chops[i], chops[(i + 1) % 5], i, ponder));
            } else {
                pool.execute(new Philosopher(chops[0], chops[i], i, ponder));
            }
        }
        try {
            System.out.println("quit");
            System.in.read();
        } catch (IOException e) {}
        pool.shutdown();
    }

