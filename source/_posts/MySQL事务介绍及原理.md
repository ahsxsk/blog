title: MySQL事务介绍及原理
date: 2017-11-11 13:09:04
categories: [MySQL]
------------------

##  1 为什么要事务

事务是一组不可被分割执行的SQL语句集合，如果有必要，可以撤销。银行转账是经典的解释事务的例子。用户A给用户B转账5000元主要步骤可以概括为如下两步。  
第一，账户A账户减去5000元；  
第二，账户B账户增加5000元；  
这两步要么成功，要么全不成功，否则都会导致数据不一致。这就可以用到事务来保证，如果是不同银行之间的转账还需要用到分布式事务。

##  2 事务的性质

事务的机制通常被概括为“ACID”原则即原子性（A）、稳定性（C）、隔离性（I）和持久性（D）。  
原子性：构成事务的的所有操作必须是一个逻辑单元，要么全部执行，要么全部不执行。  
稳定性：数据库在事务执行前后状态都必须是稳定的。  
隔离性：事务之间不会相互影响。  
持久性：事务执行成功后必须全部写入磁盘。

##  3 事务隔离性实现原理

数据库事务会导致脏读、不可重复读和幻影读等问题。  
脏读：事务还没提交，他的修改已经被其他事务看到。  
不可重复读：同一事务中两个相同SQL读取的内容可能不同。两次读取之间其他事务提交了修改可能会造成读取数据不一致。  
幻影数据：同一个事务突然发现他以前没发现的数据。和不可重复读很类似，不过修改数据改成增加数据。  
针对可能的问题，InnoDB提供了四种不同级别的机制保证数据隔离性。  
** 事务的隔离用是通过锁机制实现的，不同于MyISAM使用表级别的锁，InnoDB采用更细粒度的行级别锁，提高了数据表的性能。InnoDB的锁通过锁定索引来实现，如果查询条件中有主键则锁定主键，如果有索引则先锁定对应索引然后再锁定对应的主键（可能造成死锁），如果连索引都没有则会锁定整个数据表。 **

###  3.1 READ UNCOMMIT

READ UNCOMMIT允许某个事务看到其他事务并没有提交的数据。可能会导致脏读、不可重复读、幻影数据。  
原理：READ UNCOMMIT不会采用任何锁。

###  3.2 READ COMMIT

    
    
    **可能有误，学习时没看到多版本并发控制（MVCC），学习后更新**
    

READ COMMIT允许某个事务看到其他事务已经提交的数据。可能会导致不可重复读和幻影数据。  
原理：数据的读是不加锁的，但是数据的写入、修改、删除加锁，避免了脏读。

###  3.3 REPEATABLE READ

    
    
    **可能有误，学习时没看到多版本并发控制（MVCC），学习后更新**
    InnoDB中REPEATABLE READ级别同一个事务的两次相同读取肯定是一样的，其他事务的提交不会对本次事务有影响。
    

原理：数据的读、写都会加锁，当前事务如果占据了锁，其他事务必须等待本次事务提交完成释放锁后才能对相同的数据行进行操作。

###  3.4 SERIALIZABLE

    
    
    **可能有误，学习时没看到多版本并发控制（MVCC），学习后更新**
    

SERIALIZABLE 级别在InnoDB中和REPEATABLE READ采用相同的实现。

##  4 原子性、稳定性和持久性实现原理

原子性、稳定性和持久性是通过redo 和 undo
日志文件实现的，不管是redo还是undo文件都会有一个缓存我们称之为redo_buf和undo_buf。同样，数据库文件也会有缓存称之为data_buf。

###  4.1 undo 日志文件

undo记录了数据在事务开始之前的值，当事务执行失败或者ROLLBACK时可以通过undo记录的值来恢复数据。例如 AA和BB的初始值分别为3，5。

    
    
    A 事务开始
    B 记录AA=3到undo_buf
    C 修改AA=1
    D 记录BB=5到undo_buf
    E 修改BB=7
    F 将undo_buf写到undo(磁盘)
    G 将data_buf写到datafile(磁盘)
    H 事务提交

通过undo可以保证原子性、稳定性和持久性  
** 如果事务在F之前崩溃由于数据还没写入磁盘，所以数据不会被破坏。 **   
** 如果事务在G之前崩溃或者回滚则可以根据undo恢复到初始状态。 **   
数据在任务提交之前写到磁盘保证了持久性。  
但是单纯使用undo保证原子性和持久性需要在事务提交之前将数据写到磁盘，浪费大量I/O。

###  4.2 redo/undo 日志文件

引入redo日志记录数据修改后的值，可以避免数据在事务提交之前必须写入到磁盘的需求，减少I/O。

    
    
    A 事务开始
    B 记录AA=3到undo_buf
    C 修改AA=1 记录redo_buf
    D 记录BB=5到undo_buf
    E 修改BB=7 记录redo_buf
    F 将redo_buf写到redo（磁盘）
    G 事务提交

** 通过undo保证事务的原子性，redo保证持久性。 **   
** F之前崩溃由于所有数据都在内存，恢复后重新冲磁盘载入之前的数据，数据没有被破坏。 **   
** FG之间的崩溃可以使用redo来恢复。 **   
** G之前的回滚都可以使用undo来完成。 **

##  5 事务操作命令

如果需要使用事务就必须选用支持事务的数据库引擎如InnoDB和Falcon，MyISAM并不支持事务。  
在默认情况下MySQL开启的是autocommit模式，也就是隐含的将每条语句当做一个事务处理，每条SQL都会被自动提交。当我们使用BEGIN或者START
TRANSCATION时会把自动提交挂起，直到显示的调用COMMIT。使用事务可以有如下两种方法：

    
    
    BEGIN; //开始事务，挂起自动提交
    insert into t_cart_shopcart (user_id, sku_id, amount, shop_id,  status) values(10001, 10001, 1, 10001, 0);
    insert into t_cart_shopcart (user_id, sku_id, amount, shop_id,  status) values(10001, 10002, 1, 10001, 0);
    COMMIT; //提交事务，恢复自动提交
    
    
    set autocommit = 0; //挂起自动提交
    insert into t_cart_shopcart (user_id, sku_id, amount, shop_id,  status) values(10001, 10001, 1, 10001, 0);
    insert into t_cart_shopcart (user_id, sku_id, amount, shop_id,  status) values(10001, 10002, 1, 10001, 0);
    COMMIT; //提交事务
    set autocommit = 1; //恢复自动提交

这两种方式效果相同。

#  参考

[1] [ http://www.cnblogs.com/Bozh/archive/2013/03/18/2966494.html
](http://www.cnblogs.com/Bozh/archive/2013/03/18/2966494.html)  
[2] [ http://www.letiantian.me/2014-06-18-db-undo-redo-checkpoint/
](http://www.letiantian.me/2014-06-18-db-undo-redo-checkpoint/)  
[3] [ http://blog.csdn.net/mchdba/article/details/12242685
](http://blog.csdn.net/mchdba/article/details/12242685)  
[4] 《MySQL技术内幕》  
[5] [ http://tech.meituan.com/innodb-lock.html ](http://tech.meituan.com
/innodb-lock.html)

