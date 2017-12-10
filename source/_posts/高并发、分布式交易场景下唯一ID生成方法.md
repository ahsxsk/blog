title: 高并发、分布式交易场景下唯一ID生成方法
date: 2016-11-11 13:09:04
tags: [系统设计]
------------------------------------------------------
##  介绍

可以单机产生分布式全局唯一Id,核心的方法为模仿Twitter
snowflake，分析介绍见[1][2]。单机产生id的好处是避免了从数据库中获取序列码产生的传输问题，以及单点问题。常见的分布式Id生成器方案见[3]。  
Id的组成如下：

>   * 1 ms级时间 17位 20160329201902024

>   * 2 IDC标志位 2位 12

>   * 3 服务器标志位 3位 002

>   * 4 流水码 4位 0-4095 仿Twitter snowflake ms内最多产生4096的seq

>   * 5 用户Id埋点 4位 (userId: 12345678) 4567 交易场景下根据userId查询较多,方便分表

示例：201603292019020241200200014567 共30位  
具体实现： [ https://github.com/ahsxsk/IdGenerator
](https://github.com/ahsxsk/IdGenerator)

##  性能

>   * CPU： 2.5 GHz Intel Core i5

>   * 内存： 8 GB 1600 MHz DDR3

>   * 单线程：每秒20W-40W

>   * 2线程：每秒2W-5W

>   * 128线程：每秒5W-10W

####  分析

1 由性能可以看出 单线程 > 128线程 > 2线程  
2 i5处理器为双核，所以同时最多有2个线程执行代码  
3 获取Id为CPU密集型任务，没有IO，线程不需要等待IO  
4 多线程切换上下文时浪费大量时间，所以多线程获取Id比单线程慢  
5 128线程和2线程线程切换造成的时间浪费稍比2线程多，但是128线程获取了更多的CPU时间分片，所以速度比2线程快。

##  参考：

[1] [ http://www.lanindex.com/twitter-snowflake%EF%BC%8C64%E4%BD%8D%E8%87%AA%E
5%A2%9Eid%E7%AE%97%E6%B3%95%E8%AF%A6%E8%A7%A3/ ](http://www.lanindex.com
/twitter-snowflake%EF%BC%8C64%E4%BD%8D%E8%87%AA%E5%A2%9Eid%E7%AE%97%E6%B3%95%E
8%AF%A6%E8%A7%A3/)  
[2] [ https://github.com/twitter/snowflake
](https://github.com/twitter/snowflake)  
[3] [ http://www.cnblogs.com/heyuquan/p/3261250.html
](http://www.cnblogs.com/heyuquan/p/3261250.html)

