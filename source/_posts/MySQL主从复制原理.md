title: MySQL主从复制原理
date: 2017-11-11 13:09:04
tags: [MySQL]
------------------
MySQL主从复制原理

当一台MySQL服务器无法满足现有的访问量时，一般会采用主从服务器模式，通过数据库代理做到读写分离。主服务器负责处理写入请求，从服务器服务器负责处理读取请求
。大部分情况是读取量远大于写入量，一般会配置多个从服务器。参考《高性能MySQL》，本文介绍了MySQL主从复制的原理和常见的拓扑结构。

##  1 MySQL主从复制的过程

MySQL主从负责依赖binlog，要想实现复制必须打开binlog。主从复制的过程中由主服务器（Master）的IO进程配合从服务器（Slave）的IO进
程和SQL进程共同完成，具体不知如下：  
1）Slave的IO进程向Master请求指定日志文件指定位置后的日志内容；  
2）Master收到请求后，通过Master的IO进程读取Slave请求的数据并返回给Slave的IO进程，除了请求的内容还会给Slave返回本次读取到的b
inlog文件名称和位置；  
3）Slave的IO进程收到返回内容后将日志内容添加到relay-log后面，并将文件位置信息保存到master-info中；  
4）Slave的SQL进程发现relay-log有新内容后就会取出relay-log中的语句执行。  
![mysql主从复制过程](http://img.blog.csdn.net/20160217195636237)

##  2 MySQL主从复制级别

MySQL主从复制分为基于语句复制、基于行复制和混合复制三种。

###  2.1 基于语句复制

基于语句复制是MySQL根据binlog中的语句在Slave上重做这些操作，MySQL默认级别。优点是快速简单binlog文件小，缺点是使用到UUID()、
USER()以及部分UPDATE操作时没法正确的复制等。

###  2.2 基于行复制

采用行复制时，binlog中记录的将不再是操作语句而是记录每一行的修改，这样避免了基于语句复制的缺点，保证每条修改都能被正确复制。但是行复制的binlog可
能会很大，比如说alter操作会在日志中记录所有行的变化，binlog就会过大。

###  2.3 混合复制

混合复制是前两种复制方式的结合，MySQL会根据执行的每一条具体的sql语句来区分对待记录的日志形式，也就是在语句复制和行复制之间选择一种。当使用语句复制无
法准确复制会自动切换到行复制，如下几种情况会自动切换。  
1）当函数中包含 UUID() 时；  
2）2个及以上包含 AUTO_INCREMENT 字段的表被更新时；  
3）执行 INSERT DELAYED 语句时；  
4）用 UDF 时；  
5）视图中必须要求运用 row 时，例如建立视图时使用了 UUID() 函数；  
6）当 DML 语句更新一个 NDB 表时；

##  3 主从复制常见的拓扑结构

常见的主从复制拓扑结构有一主多从、主动、级联等模式

###  3.1 一主多从模式

一主多从模式中有且只有一个Master有一组Slave，当前大部分主从复制采用这种模式。这种模式扩展方便，主从延时少。当写操作较少而读操作较多时采用这种方式
较合适，但是当Slave过多时会导致Master负载较重以及消耗较多带宽的问题。

###  3.2 主动模式

主动模式的两台服务器，既是master，又是另一台服务器的slave。这样，任何一方所做的变更，都会通过复制应用到另外一方的数据库中。

###  3.3 级联模式

当读压力较大时，连接到Master上的Slave较多，会给Master带来较大压力。采用级联的方式即Master只连接一定数量的Slave，这些Slave又
充当其他Slave的Master。级联模式减少了Master的压力但是也会带来主从复制延时较大的问题。

##  参考

[1] [ http://blog.csdn.net/hguisu/article/details/7325124
](http://blog.csdn.net/hguisu/article/details/7325124)  
[2] [ http://database.51cto.com/art/200906/128162.htm
](http://database.51cto.com/art/200906/128162.htm)  
[3] [ http://wangwei007.blog.51cto.com/68019/965575
](http://wangwei007.blog.51cto.com/68019/965575)

