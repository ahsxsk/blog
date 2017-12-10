Java集合：集合框架

Java集合源码位于Java.util包下，主要包括List、Set、Map、Iterator以及工具类Arrays和Collections。Java集合框
架的顶级接口包括Collection和Map两个，其中Collection的子接口包括List、Set和Queue。具体结构如下：  
![Java集合框架](http://img.blog.csdn.net/20160218204126299)

##  1 Collection接口

Collection是集合的顶级接口之一，他继承了Iterable接口，并声明了集合中一些常用的方法，例如size()，contains(Object
o)等方法。Java SDK提供了继承与Collection的子接口List、Set或者Queue，并通过实现子接口实现了具体集合类。所有实现Collect
ion接口的类都必须提供两个标准的构造函数：无参数的构造函数用于创建一个空的Collection，有一个
Collection参数的构造函数用于创建一个新的Collection，这个新的Collection与传入的Collection有相同的元素。后
一个构造函数允许用户复制一个Collection。

###  1.1 List接口

List接口继承与Collection接口，它是一个允许有重复元素的的列表，能够控制元素的插入位置，通过索引来访问List中的元素。常见的List的实现有L
inkedList，ArrayList，Vector和Stack。

###  1.2 Set接口

Set接口同样继承与Collection接口，它不允许有重复的元素。常用实现类有HashSet和TreeSet，HashSet是通过Map中的HashMap
实现的，而TreeSet是通过Map中的TreeMap实现的。另外，TreeSet还实现了SortedSet接口，因此是有序的集合。

###  1.3 Queue接口

Queue接口继承与Collection接口，提供一种先进先出的机制，常见的实现类有ArrayBlockingQueue、ConcurrentLinkedQ
ueue等，这些实现类都处于concurrent包下，用于线程同步机制的实现。

##  2 Map接口

Map接口是和Collection接口并行的顶级集合接口，他提供key-
value映射机制。Map接口常见的实现类有HashTable、Hashmap以及Weakhashmap等。

参考：  
[1] [ http://blog.csdn.net/softwave/article/details/4166598
](http://blog.csdn.net/softwave/article/details/4166598)  
[2] [ http://blog.csdn.net/mazhimazh/article/details/17730517
](http://blog.csdn.net/mazhimazh/article/details/17730517)  
[3] [ http://blog.csdn.net/ns_code/article/details/35564663
](http://blog.csdn.net/ns_code/article/details/35564663)

