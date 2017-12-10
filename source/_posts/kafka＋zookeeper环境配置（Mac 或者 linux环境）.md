kafka＋zookeeper环境配置（Mac 或者 linux环境）

转自： [ http://www.cnblogs.com/super-d2/p/4534323.html
](http://www.cnblogs.com/super-d2/p/4534323.html)  
一.zookeeper下载与安装

1）下载

    
    
    adeMacBook-Pro:zookeeper_soft apple$ wget http://mirrors.cnnic.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz

2）解压

    
    
    tar zxvf zookeeper-3.4.6.tar.gz

3）配置

    
    
    cd zookeeper-3.4.6
    cp -rf conf/zoo_sample.cfg conf/zoo.cfg
    vim zoo.cfg
    zoo.cfg:
    
    # The number of milliseconds of each tick
    tickTime=2000
    # The number of ticks that the initial 
    # synchronization phase can take
    initLimit=10
    # The number of ticks that can pass between 
    # sending a request and getting an acknowledgement
    syncLimit=5
    # the directory where the snapshot is stored.
    # do not use /tmp for storage, /tmp here is just 
    # example sakes.
    dataDir=/Users/apple/Documents/soft/zookeeper_soft/zkdata #这个目录是预先创建的
    # the port at which the clients will connect
    clientPort=2181
    # the maximum number of client connections.
    # increase this if you need to handle more clients
    #maxClientCnxns=60
    #
    # Be sure to read the maintenance section of the 
    # administrator guide before turning on autopurge.
    #
    # http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance
    #
    # The number of snapshots to retain in dataDir
    #autopurge.snapRetainCount=3
    # Purge task interval in hours
    # Set to "0" to disable auto purge feature
    #autopurge.purgeInterval=1

4）启动zookeeper

    
    
    adeMacBook-Pro:bin apple$ sh zkServer.sh start

** 安装zookeeper最简单的方法就是使用Homebrew **
    
    
    brew install zookeeper

二 下载并且安装kafka（预先得安装配置好scala的环境，Mac环境参照： [
http://www.cnblogs.com/super-d2/p/4534208.html
](http://www.cnblogs.com/super-d2/p/4534208.html) ）

1).下载kafka:

    
    
    wget http://apache.fayea.com/kafka/0.8.2.1/kafka_2.10-0.8.2.1.tgz

2) 解压：

    
    
    tar -zxf kafka_2.10-0.8.2.1.tgz

3）启动kafka

    
    
    adeMacBook-Pro:kafka_2.10-0.8.2.1 apple$ sh bin/kafka-server-start.sh config/server.properties

备注：要挂到后台使用：

    
    
    sh bin/kafka-server-start.sh config/server.properties &

4)新建一个TOPIC

    
    
    adeMacBook-Pro:bin apple$ sh kafka-topics.sh --create --topic kafkatopic --replication-factor 1 --partitions 1 --zookeeper localhost:2181

备注：要挂到后台使用：

    
    
    sh kafka-topics.sh --create --topic kafkatopic --replication-factor 1 --partitions 1 --zookeeper localhost:2181 &

5) 把KAFKA的生产者启动起来：

    
    
    adeMacBook-Pro:bin apple$ sh kafka-console-producer.sh --broker-list localhost:9092 --sync --topic kafkatopic

备注：要挂到后台使用：

    
    
    sh kafka-console-producer.sh --broker-list localhost:9092 --sync --topic kafkatopic &

6）另开一个终端，把消费者启动起来：

    
    
    adeMacBook-Pro:bin apple$ sh kafka-console-consumer.sh --zookeeper localhost:2181 --topic kafkatopic --from-beginning

备注：要挂到后台使用：

    
    
    sh kafka-console-consumer.sh --zookeeper localhost:2181 --topic kafkatopic --from-beginning &

** kafka快速安装方法： **
    
    
    brew install kafka

