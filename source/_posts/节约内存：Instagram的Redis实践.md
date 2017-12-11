title: 节约内存：Instagram的Redis实践
date: 2015-01-01 13:09:04
categories: [Redis]
------------------

Instagram  可以说是网拍App的始祖级应用，也是当前最火热的拍照App之一，Instagram的照片数量已经达到3亿，而在Instagram里，我们需要知道每一张照片的作者是谁，下面就是Instagram团队如何使用Redis来解决这个问题并进行内存优化的。

首先，这个通过图片ID反查用户UID的应用有以下几点需求：

  * 查询速度要足够快 
  * 数据要能全部放到内存里，最好是一台EC2的 high-memory 机型就能存储（17GB或者34GB的，68GB的太浪费了） 
  * 要合适Instagram现有的架构（Instagram对  [ Redis ](http://blog.nosqlfan.com/categories/redis) 有一定的使用经验，比如 [ 这个应用 ](http://blog.nosqlfan.com/html/2007.html) ） 
  * 支持持久化，这样在服务器重启后不需要再预热 

Instagram的开发者首先否定了数据库存储的方案，他们保持了KISS原则（Keep It Simple and
Stupid），因为这个应用根本用不到数据库的update功能，事务功能和关联查询等等牛X功能，所以不必为这些用不到的功能去选择维护一个数据库。

于是他们选择了Redis，Redis是一个支持持久化的内存数据库，所有的数据都被存储在内存中（忘掉VM吧
），而最简单的实现就是使用Redis的String结构来做一个key-value存储就行了。像这样：

    
    
    SET media:1155315 939
    GET media:1155315
    > 939

其中1155315是图片ID，939是用户ID，我们将每一张图片ID为作key，用户uid作为value来存成key-value对。然后他们进行了测试，将数
据按上面的方法存储，1,000,000数据会用掉70MB内存，300,000,000张照片就会用掉21GB的内存。对比预算的17GB还是超支了。

（  NoSQLFan：  其实这里我们可以看到一个优化点，我们可以将key值前面相同的media去掉，只存数字，这样key的长度就减少了，减少key值对内
存的开销【注：Redis的key值不会做字符串到数字的转换，所以这里节省的，仅仅是media:这6个字节的开销】。经过实验，  [ 内存占用
](http://blog.nosqlfan.com/categories/%E5%86%85%E5%AD%98%E5%8D%A0%E7%94%A8)
会降到50MB，总的内存占用是15GB，是满足需求的，但是Instagram后面的改进任然有必要  ）

于是Instagram的开发者向Redis的开发者之一 [ Pieter Noordhuis
](https://twitter.com/#!/pnoordhuis) 询问优化方案，得到的回复是使用Hash结构。具体的做法就是将数据分段，每一段使用一
个Hash结构存储，由于Hash结构会在单个Hash元素在不足一定数量时进行压缩存储，所以可以大量  [ 节约内存
](http://blog.nosqlfan.com/categories/%E8%8A%82%E7%BA%A6%E5%86%85%E5%AD%98)
。这一点在上面的String结构里是不存在的。而这个一定数量是由配置文件中的  [ hash
](http://blog.nosqlfan.com/categories/hash) -zipmap-max-entries参数来控制的。经过开发者们的实验
，将hash-zipmap-max-entries设置为1000时，性能比较好，超过1000后HSET命令就会导致CPU消耗变得非常大。

于是他们改变了方案，将数据存成如下结构：

    
    
    HSET "mediabucket:1155" "1155315" "939"
    HGET "mediabucket:1155" "1155315"
    > "939"

通过取7位的图片ID的前四位为Hash结构的key值，保证了每个Hash内部只包含3位的key，也就是1000个。

再做一次实验，结果是每1,000,000个key只消耗了16MB的内存。总内存使用也降到了5GB，满足了应用需求。

（  NoSQLFan：同样的，这里我们还是可以再进行优化，首先是将Hash结构的key值变成纯数字，这样key长度减少了12个字节，其次是将Hash结构中
的subkey值变成三位数，这又减少了4个字节的开销，如下所示。经过实验，内存占用量会降到10MB，总内存占用为3GB  ）

    
    
    HSET "1155" "315" "939"
    HGET "1155" "315"
    > "939"

优化无止境，只要肯琢磨。希望你在使用存储产品时也能如此爱惜内存。

来源： [ instagram-engineering.tumblr.com ](http://instagram-
engineering.tumblr.com/post/12202313862/storing-hundreds-of-millions-of-
simple-key-value-pairs)

From: http://blog.nosqlfan.com/html/3379.html

