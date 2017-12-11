title: Redis事务介绍
date: 2017-11-11 13:09:04
categories: [Redis]
------------------

##  1 什么是Redis事务

Redis通过MULTI、EXEC、DISCARD以及WATCH命令提供事务功能。Redis的事务提供一次性、按顺序执行命令的机制，并且不会中断事务去执行其
他命令。Redis事务和我们常理解的事务还是有些区别的，即事务中的部分命令执行失败不会导致事务回滚。Redis事务的核心思想是维护一个事务命令队列，将事务中
的所有命令先预存到队列中，等待EXEC一起执行或者DISCARD清空队列。

##  2 Redis事务命令

事务的执行分为三个步骤，事务开始、命令入队列以及事务执行。

###  2.1 MULTI（事务开始）

当Redis服务器接收到某个客户端发送过来的MULTI命令后就会将这个客户端的状态标志为事务状态（REDIS_MULTI），事务状态的客户端会将除了MULT
I、EXEC、DISCARD以及WATCH命令都加入到命令队列中。如果有错误命令，会导致事务取消。例如：

    
    
    127.0.0.1:6379> MULTI
    OK
    127.0.0.1:6379> set name "shi ke"
    QUEUED
    127.0.0.1:6379> set firstName "shi"
    QUEUED
    127.0.0.1:6379> err set
    (error) ERR unknown command 'err'
    127.0.0.1:6379> get name
    QUEUED
    127.0.0.1:6379> get firstName
    QUEUED
    127.0.0.1:6379> exec
    (error) EXECABORT Transaction discarded because of previous errors.

###  2.2 EXEC （事务执行）

当Redis服务器接收到客户端的EXEC命令后会遍历这个服务器的所有事务命令并且依次执行，返回结果，将客户端状态改回非事务。需要注意的是Redis服务器不保
证每个命令都能执行成功，已经执行成功的会改变数据库库状态，不提供回滚功能。

###  2.3 DISCARD （事务取消）

当Redis服务器收到DISCARD命令后会清空该客户端的事务命令队列并且将客户端状态修改成非事务。例如：

    
    
    127.0.0.1:6379> MULTI
    OK
    127.0.0.1:6379> set name "keshi"
    QUEUED
    127.0.0.1:6379> DISCARD
    OK
    127.0.0.1:6379> EXEC
    (error) ERR EXEC without MULTI

###  2.4 WATCH （监控）

在事务开始之前可以用WATCH命令监控特定的键，当有其他客户端修改了监控的键，那么服务器将拒绝执行这个客户端接下来的一个事务。例如：

    
    
    redis-cli-1                          redis-cli-2
    127.0.0.1:6379> WATCH name
    OK
    127.0.0.1:6379> MULTI
    OK
    127.0.0.1:6379> get name
    QUEUED
    127.0.0.1:6379> set firstName "Yang"  127.0.0.1:6379> set name "Yang Li"
    QUEUED
    127.0.0.1:6379> EXEC
    (nil)
    127.0.0.1:6379> get firstName
    "shike"
    127.0.0.1:6379> get name
    "Yang Li"

##  3 Redis事务的ACID原则

事务的ACID即事务的原子性、一致性、隔离性、持久性，Redis事务能够保证原子性、一致性、隔离性但是不会保证持久性。

###  3.1 原子性

事务的原子性是指一组操作要么全部执行，要么全不执行。Redis可以保证一组数据同时执行或者不执行。 **
但是不同于MySQL等关系数据库事务操作，Redis不提供回滚操作即部分操作失败不会引起整个事务回滚。 **

###  3.2 一致性

事务的一致性指数据库中的数据全部符合数据库的规范，不会出现不符合规范的数据存在。Redis通过严格的错误检测保证事务的一致性。  
第一、入队时的错误回直接导致整个事务失败，保证一致性。  
第二、执行时错误会跳过错误命令，继续执行其他命令。  
第三、服务器重启，如果有持久化则通过RDB、AOF文件恢复数据，否则数据库为空。

###  3.3 隔离性

Redis事务在执行之前只是将命令存在操作队列中，不会真正去操作数据库，所有事务之间不会相互影响。

###  3.4 持久性

Redis事务是否具有持久性是由他的持久化策略决定的，当且仅当采用AOF模式并且appendfsync设为always时才具有持久性，具体原因请看Redis
持久化介绍（ [ http://blog.csdn.net/sk199048/article/details/50589491
](http://blog.csdn.net/sk199048/article/details/50589491) ）

