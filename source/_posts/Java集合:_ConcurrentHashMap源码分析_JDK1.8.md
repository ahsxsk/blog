title: Java集合：ConcurrentHashMap源码分析_JDK1.8.md
date: 2017-11-11 13:09:04
categories: [Java并发编程]
------------------

转载文章，原博客地址为： [ http://blog.csdn.net/u010887744/article/details/50637030
](http://blog.csdn.net/u010887744/article/details/50637030)

jdk1.8和jdk1.7对于ConcurrentHashMap的实现出现的重大变化，不再采用分段锁的方法，网上这方面的博客较少，这篇文章写得较好，转载扩撒
。

  

本文首写于有道云笔记，并在小组分享会分享，先整理发布，希望和大家交流探讨。 [ 云笔记地址
](http://note.youdao.com/share/?id=dde7a10b98aee57676408bc475ab0680&type=note)

概述：

1、设计首要目的：维护并发可读性（get、迭代相关）；次要目的：使空间消耗比HashMap相同或更好，且支持多线程高效率的初始插入（empty
table）。

2、HashTable  线程安全，但采用synchronized，多线程下效率低下。线程1put时，线程2无法put或get。

  

实现原理：

锁分离：

在HashMap的基础上，将数据分段存储，  ConcurrentHashMap由多个Segment组成，每个Segment都有把锁。
Segment下包含很多Node，也就是我们的键值对了。

  

** 如果还停留在锁分离、Segment，那已经out了。  **

Segment虽保留，但已经简化属性，仅仅是为了兼容旧版本。

  

  * ** CAS算法 ** ；  unsafe.compareAndSwapInt(this, valueOffset, expect, update);  CAS(Compare And Swap)，意思是如果valueOffset位置包含的值与expect值相同，则更新valueOffset位置的值为update，并返回true，否则不更新，返回false。 
  * 与Java8的HashMap有相通之处，底层依然由 ** “数组”+链表+红黑树 ** ； 
  * 底层结构存放的是 ** TreeBin ** 对象，而不是TreeNode对象； 
  * CAS作为知名无锁算法，那ConcurrentHashMap就没用锁了么？当然不是，hash值相同的链表的头结点还是会synchronized上锁。 

private  static  final  int  MAXIMUM_CAPACITY  = 1 << 30; // 2的30次方=1073741824

private  static  final  int  DEFAULT_CAPACITY  = 16;

static  final  int  MAX_ARRAY_SIZE  = Integer.  MAX_VALUE  \- 8; //
MAX_VALUE=2^31-1=2147483647

private  static  final  int  DEFAULT_CONCURRENCY_LEVEL  = 16;

private  static  final  float  LOAD_FACTOR  = 0.75f;

static  final  int  TREEIFY_THRESHOLD  ** = 8; ** //  链表转树阀值，大于8时

static  final  int  UNTREEIFY_THRESHOLD  ** = 6; ** //  树转链表阀值，小于等于6（tranfer时，
lc、hc=0两个计数器分别++记录原bin、新binTreeNode数量，<=UNTREEIFY_THRESHOLD 则untreeify(lo)）。【
仅在扩容tranfer时  才可能树转链表】

static  final  int  MIN_TREEIFY_CAPACITY  = 64;

private  static  final  int  MIN_TRANSFER_STRIDE  = 16;

private  static  int  RESIZE_STAMP_BITS  = 16;

private  static  final  int  MAX_RESIZERS  ** = (1 << (32 - ** **
RESIZE_STAMP_BITS  ** ** )) - 1; ** // 2^15-1，hel  p resize的最大线程数

private  static  final  int  RESIZE_STAMP_SHIFT  ** = 32 - ** **
RESIZE_STAMP_BITS  ** ** ; ** // 32-16=16，sizeCtl  中记录size大小的偏移量

static  final  int  MOVED  ** = -1; ** // hash for forwarding nodes（for
warding nodes的hash值）、标示位

static  final  int  TREEBIN  ** = -2; ** // hash for roots of tree
s（树根节点的hash值）

static  final  int  RESERVED  ** = -3; ** // hash for transient reservations
（ReservationNode的hash值）

static  final  int  HASH_BITS  = 0x7fffffff;  // usable bits of normal node
hash

static  final  int  NCPU  ** = Runtime.  getRuntime  ().availableProcessors();
** // 可用处理器数量

/**

* Table initialization and resizing control.  When negative, the 

* table is being initialized or resized:  \-  1 for initialization, 

* else  \-  (1 \+ the number of active resizing threads).  Otherwise, 

* when table is null, holds the initial table size to use upon 

* creation, or 0 for default. After initialization, holds the 

* next element count value upon which to resize the table. 

*/ 

private  transient  volatile  int  sizeCtl  ;

sizeCtl  是  控制标识符，不同的值表示不同的意义。

  * 负数代表正在进行初始化或扩容操作 
  * -1代表正在初始化 
  * -N 表示有N-1个线程正在进行扩容操作 
  * 正数或0代表hash表还没有被初始化，这个数值表示初始化或下一次进行扩容的大小，类似于扩容阈值。它的值  始终是当前ConcurrentHashMap容量的0.75倍  ，这与loadfactor是对应的。  实际容量  >=sizeCtl，则扩容。 

  

部分构造函数：

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. public  ConcurrentHashMap(  int  initialCapacity, 
  2. float  loadFactor,  int  concurrencyLevel) { 
  3. if  (!(loadFactor > 0  .0f) || initialCapacity < 0  || concurrencyLevel <=  0  ) 
  4. thrownew IllegalArgumentException(); 
  5. if  (initialCapacity < concurrencyLevel)  // Use at least as many bins 
  6. initialCapacity = concurrencyLevel;  // as estimated threads 
  7. long  size = (  long  )(  1.0  + (  long  )initialCapacity / loadFactor); 
  8. int  cap = (size >= (  long  )MAXIMUM_CAPACITY) ? 
  9. MAXIMUM_CAPACITY : tableSizeFor((  int  )size); 
  10. this  .sizeCtl = cap; 
  11. } 

  

concurrencyLevel  ：

concurrencyLevel，能够同时更新ConccurentHashMap且不产生锁竞争的最大线程数，在Java8之前实际上就是ConcurrentH
ashMap中的分段锁个数，即Segment[]的数组长度  。
正确地估计很重要，当低估，数据结构将根据额外的竞争，从而导致线程试图写入当前锁定的段时阻塞；
相反，如果高估了并发级别，你遇到过大的膨胀，由于段的不必要的数量;  这种膨胀可能会导致性能下降，由于高数缓存未命中。

在Java8里，仅仅是为了 ** 兼容旧版本而保留 ** 。唯一的作用就是保证构造map时初始容量不小于concurrencyLevel。

源码122行：

Also, for compatibility with previous  versions of this class, constructors
may optionally specify an  expected {@code concurrencyLevel} as an additional
hint for  internal sizing.

源码482行：

Mainly: We  leave untouched but unused constructor arguments refering to
concurrencyLevel .……

……

1、重要属性：

1.1 Node：

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. static  class  Node<K,V> implements  Map.Entry<K,V> { 
  2. final  int  hash; 
  3. final  K key; 
  4. volatile  V val;  // Java8增加volatile，保证可见性 
  5. volatile  Node<K,V> next; 
  6.   7. Node(inthash, K key, V val, Node<K,V> next) { 
  8. this  .hash = hash; 
  9. this  .key = key; 
  10. this  .val = val; 
  11. this  .next = next; 
  12. } 
  13.   14. public  final  K getKey()       {  return  key; } 
  15. public  final  V getValue()     {  return  val; } 
  16. // HashMap调用Objects.hashCode()，最终也是调用Object.hashCode()；效果一样 
  17. public  final  int  hashCode()   { returnkey.hashCode() ^ val.hashCode(); } 
  18. public  final  String toString(){ returnkey +  "="  + val; } 
  19. public  final  V setValue(V value) {  // 不允许修改value值，HashMap允许 
  20. throw  new  UnsupportedOperationException(); 
  21. } 
  22. // HashMap使用if (o == this)，且嵌套if；concurrent使用&&
  23. public  final  boolean  equals(Object o) { 
  24. Object k, v, u; Map.Entry<?,?> e; 
  25. return  ((oinstanceof Map.Entry) &&
  26. (k = (e = (Map.Entry<?,?>)o).getKey()) !=  null  &&
  27. (v = e.getValue()) !=  null  &&
  28. (k == key || k.equals(key)) &&
  29. (v == (u = val) || v.equals(u))); 
  30. } 
  31.   32. /** 
  33. * Virtualized support for map.get(); overridden in subclasses. 
  34. */ 
  35. Node<K,V> find(inth, Object k) {  // 增加find方法辅助get方法 
  36. Node<K,V> e =  this  ; 
  37. if  (k !=  null  ) { 
  38. do  { 
  39. K ek; 
  40. if  (e.hash == h &&
  41. ((ek = e.key) == k || (ek !=  null  && k.equals(ek)))) 
  42. returne; 
  43. }  while  ((e = e.next) !=  null  ); 
  44. } 
  45. returnnull; 
  46. } 
  47. } 

  

1.2 TreeNode  

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. // Nodes for use in TreeBins，链表>8，才可能转为TreeNode. 
  2. // HashMap的TreeNode继承至LinkedHashMap.Entry；而这里继承至自己实现的Node，将带有next指针，便于treebin访问。 
  3. static  final  class  TreeNode<K,V> extends  Node<K,V> { 
  4. TreeNode<K,V> parent;  // red-black tree links 
  5. TreeNode<K,V> left; 
  6. TreeNode<K,V> right; 
  7. TreeNode<K,V> prev;  // needed to unlink next upon deletion 
  8. boolean  red; 
  9.   10. TreeNode(inthash, K key, V val, Node<K,V> next, 
  11. TreeNode<K,V> parent) { 
  12. super  (hash, key, val, next); 
  13. this  .parent = parent; 
  14. } 
  15.   16. Node<K,V> find(inth, Object k) { 
  17. return  findTreeNode(h, k,  null  ); 
  18. } 
  19.   20. /** 
  21. * Returns the TreeNode (or null if not found) for the given key 
  22. * starting at given root. 
  23. */  // 查找hash为h，key为k的节点 
  24. final  TreeNode<K,V> findTreeNode(  int  h, Object k, Class<?> kc) { 
  25. if  (k !=  null  ) {  // 比HMap增加判空 
  26. TreeNode<K,V> p =  this  ; 
  27. do  { 
  28. intph, dir; K pk; TreeNode<K,V> q; 
  29. TreeNode<K,V> pl = p.left, pr = p.right; 
  30. if  ((ph = p.hash) > h) 
  31. p = pl; 
  32. elseif (ph < h) 
  33. p = pr; 
  34. elseif ((pk = p.key) == k || (pk !=  null  && k.equals(pk))) 
  35. returnp; 
  36. elseif (pl ==  null  ) 
  37. p = pr; 
  38. elseif (pr ==  null  ) 
  39. p = pl; 
  40. elseif ((kc !=  null  || 
  41. (kc = comparableClassFor(k)) !=  null  ) &&
  42. (dir = compareComparables(kc, k, pk)) !=  0  ) 
  43. p = (dir < 0  ) ? pl : pr; 
  44. elseif ((q = pr.findTreeNode(h, k, kc)) !=  null  ) 
  45. returnq; 
  46. else 
  47. p = pl; 
  48. }  while  (p !=  null  ); 
  49. } 
  50. return  null  ; 
  51. } 
  52. } 
  53. // 和HashMap相比，这里的TreeNode相当简洁；ConcurrentHashMap链表转树时，并不会直接转，正如注释（Nodes for use in TreeBins）所说，只是把这些节点包装成TreeNode放到TreeBin中，再由TreeBin来转化红黑树。 

  

1.3  TreeBin

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. // TreeBin用于封装维护TreeNode，包含putTreeVal、lookRoot、UNlookRoot、remove、balanceInsetion、balanceDeletion等方法，这里只分析其构造函数。 
  2. // 当链表转树时，用于封装TreeNode，也就是说，ConcurrentHashMap的红黑树存放的时TreeBin，而不是treeNode。 
  3. TreeBin(TreeNode<K,V> b) { 
  4. super  (TREEBIN,  null  ,  null  ,  null  );  //hash值为常量TREEBIN=-2,表示roots of trees 
  5. this  .first = b; 
  6. TreeNode<K,V> r =  null  ; 
  7. for  (TreeNode<K,V> x = b, next; x !=  null  ; x = next) { 
  8. next = (TreeNode<K,V>)x.next; 
  9. x.left = x.right =  null  ; 
  10. if  (r ==  null  ) { 
  11. x.parent =  null  ; 
  12. x.red =  false  ; 
  13. r = x; 
  14. } 
  15. else  { 
  16. K k = x.key; 
  17. inth = x.hash; 
  18. Class<?> kc =  null  ; 
  19. for  (TreeNode<K,V> p = r;;) { 
  20. intdir, ph; 
  21. K pk = p.key; 
  22. if  ((ph = p.hash) > h) 
  23. dir = -  1  ; 
  24. elseif (ph < h) 
  25. dir =  1  ; 
  26. elseif ((kc ==  null  &&
  27. (kc = comparableClassFor(k)) ==  null  ) || 
  28. (dir = compareComparables(kc, k, pk)) ==  0  ) 
  29. dir = tieBreakOrder(k, pk); 
  30. TreeNode<K,V> xp = p; 
  31. if  ((p = (dir <=  0  ) ? p.left : p.right) ==  null  ) { 
  32. x.parent = xp; 
  33. if  (dir <=  0  ) 
  34. xp.left = x; 
  35. else 
  36. xp.right = x; 
  37. r = balanceInsertion(r, x); 
  38. break  ; 
  39. } 
  40. } 
  41. } 
  42. } 
  43. this  .root = r; 
  44. assert  checkInvariants(root); 
  45. } 

  

1.4  treeifyBin

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. /** 
  2. * Replaces all linked nodes in bin at given index unless table is 
  3. * too small, in which case resizes instead.链表转树 
  4. */ 
  5. private  final  void  treeifyBin(Node<K,V>[] tab,  int  index) { 
  6. Node<K,V> b; intn, sc; 
  7. if  (tab !=  null  ) { 
  8. if  ((n = tab.length) < MIN_TREEIFY_CAPACITY) 
  9. tryPresize(n << 1  );  // 容量<64，则table两倍扩容，不转树了 
  10. else  if  ((b = tabAt(tab, index)) !=  null  && b.hash >=  0  ) { 
  11. synchronized  (b) {  // 读写锁 
  12. if  (tabAt(tab, index) == b) { 
  13. TreeNode<K,V> hd =  null  , tl =  null  ; 
  14. for  (Node<K,V> e = b; e !=  null  ; e = e.next) { 
  15. TreeNode<K,V> p = 
  16. new  TreeNode<K,V>(e.hash, e.key, e.val, 
  17. null  ,  null  ); 
  18. if  ((p.prev = tl) ==  null  ) 
  19. hd = p; 
  20. else 
  21. tl.next = p; 
  22. tl = p; 
  23. } 
  24. setTabAt(tab, index,  new  TreeBin<K,V>(hd)); 
  25. } 
  26. } 
  27. } 
  28. } 
  29. } 

  

1.5  ForwardingNode

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. // A node inserted at head of bins during transfer operations.连接两个table 
  2. // 并不是我们传统的包含key-value的节点，只是一个标志节点，并且指向nextTable，提供find方法而已。生命周期：仅存活于扩容操作且bin不为null时，一定会出现在每个bin的首位。 
  3. static  final  class  ForwardingNode<K,V> extends  Node<K,V> { 
  4. final  Node<K,V>[] nextTable; 
  5. ForwardingNode(Node<K,V>[] tab) { 
  6. super  (MOVED,  null  ,  null  ,  null  );  // 此节点hash=-1，key、value、next均为null 
  7. this  .nextTable = tab; 
  8. } 
  9.   10. Node<K,V> find(  int  h, Object k) { 
  11. // 查nextTable节点，outer避免深度递归 
  12. outer:  for  (Node<K,V>[] tab = nextTable;;) { 
  13. Node<K,V> e; intn; 
  14. if  (k ==  null  || tab ==  null  || (n = tab.length) ==  0  || 
  15. (e = tabAt(tab, (n -  1  ) & h)) ==  null  ) 
  16. returnnull; 
  17. for  (;;) {  // CAS算法多和死循环搭配！直到查到或null 
  18. int  eh; K ek; 
  19. if  ((eh = e.hash) == h &&
  20. ((ek = e.key) == k || (ek !=  null  && k.equals(ek)))) 
  21. returne; 
  22. if  (eh < 0  ) { 
  23. if  (e  instanceof  ForwardingNode) { 
  24. tab = ((ForwardingNode<K,V>)e).nextTable; 
  25. continue  outer; 
  26. } 
  27. else 
  28. return  e.find(h, k); 
  29. } 
  30. if  ((e = e.next) ==  null  ) 
  31. return  null  ; 
  32. } 
  33. } 
  34. } 
  35. } 

  

  

1.6  3个原子操作（调用频率很高）

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. @SuppressWarnings  (  "unchecked"  )  // ASHIFT等均为private static final 
  2. static  final  <K,V> Node<K,V> tabAt(Node<K,V>[] tab,  int  i) {  // 获取索引i处Node 
  3. return  (Node<K,V>)U.getObjectVolatile(tab, ((  long  )i << ASHIFT) + ABASE); 
  4. } 
  5. // 利用CAS算法设置i位置上的Node节点（将c和table[i]比较，相同则插入v）。 
  6. static  final  <K,V> boolean  casTabAt(Node<K,V>[] tab,  int  i, 
  7. Node<K,V> c, Node<K,V> v) { 
  8. return  U.compareAndSwapObject(tab, ((  long  )i << ASHIFT) + ABASE, c, v); 
  9. } 
  10. // 设置节点位置的值，仅在上锁区被调用 
  11. static  final  <K,V> void  setTabAt(Node<K,V>[] tab,  int  i, Node<K,V> v) { 
  12. U.putObjectVolatile(tab, ((  long  )i << ASHIFT) + ABASE, v); 
  13. } 

  

1.7  Unsafe

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. //在源码的6277行到最后，有着ConcurrentHashMap中极为重要的几个属性（SIZECTL），unsafe静态块控制其修改行为。Java8中，大量运用CAS进行变量、属性的无锁修改，大大提高性能。 
  2. // Unsafe mechanics 
  3. private  static  final  sun.misc.Unsafe U; 
  4. private  static  final  long  SIZECTL; 
  5. private  static  final  long  TRANSFERINDEX; 
  6. private  static  final  long  BASECOUNT; 
  7. private  static  final  long  CELLSBUSY; 
  8. private  static  final  long  CELLVALUE; 
  9. private  static  final  long  ABASE; 
  10. private  static  final  int  ASHIFT; 
  11.   12. static  { 
  13. try  { 
  14. U = sun.misc.Unsafe.getUnsafe(); 
  15. Class<?> k = ConcurrentHashMap.  class  ; 
  16. SIZECTL = U.objectFieldOffset (k.getDeclaredField(  "sizeCtl"  )); 
  17. TRANSFERINDEX=U.objectFieldOffset(k.getDeclaredField(  "transferIndex"  )); 
  18. BASECOUNT = U.objectFieldOffset (k.getDeclaredField(  "baseCount"  )); 
  19. CELLSBUSY = U.objectFieldOffset (k.getDeclaredField(  "cellsBusy"  )); 
  20. Class<?> ck = CounterCell.  class  ; 
  21. CELLVALUE = U.objectFieldOffset (ck.getDeclaredField(  "value"  )); 
  22. Class<?> ak = Node[].  class  ; 
  23. ABASE = U.arrayBaseOffset(ak); 
  24. intscale = U.arrayIndexScale(ak); 
  25. if  ((scale & (scale -  1  )) !=  0  ) 
  26. thrownew Error(  "data type scale not a power of two"  ); 
  27. ASHIFT =  31  - Integer.numberOfLeadingZeros(scale); 
  28. }  catch  (Exception e) { 
  29. thrownew Error(e); 
  30. } 
  31. } 

  
  

1.8  扩容相关

tryPresize  在  putAll以及treeifyBin中调用

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. private  final  void  tryPresize(  int  size) { 
  2. // 给定的容量若>=MAXIMUM_CAPACITY的一半，直接扩容到允许的最大值，否则调用函数扩容 
  3. int  c = (size >= (MAXIMUM_CAPACITY >>> 1  )) ? MAXIMUM_CAPACITY : 
  4. tableSizeFor(size + (size >>> 1  ) +  1  ); 
  5. int  sc; 
  6. while  ((sc = sizeCtl) >=  0  ) {  //没有正在初始化或扩容，或者说表还没有被初始化 
  7. Node<K,V>[] tab = table;  int  n; 
  8. if  (tab ==  null  || (n = tab.length) ==  0  ) { 
  9. n = (sc > c) ? sc : c;  // 扩容阀值取较大者 
  10. // 期间没有其他线程对表操作，则CAS将SIZECTL状态置为-1，表示正在进行初始化 
  11. if  (U.compareAndSwapInt(  this  , SIZECTL, sc, -  1  )) { 
  12. try  { 
  13. if  (table == tab) { 
  14. @SuppressWarnings  (  "unchecked"  ) 
  15. Node<K,V>[] nt = (Node<K,V>[])  new  Node<?,?>[n]; 
  16. table = nt; 
  17. sc = n - (n >>> 2  );  //无符号右移2位，此即0.75*n 
  18. } 
  19. }  finally  { 
  20. sizeCtl = sc;  // 更新扩容阀值 
  21. } 
  22. } 
  23. }  // 若欲扩容值不大于原阀值，或现有容量>=最值，什么都不用做了 
  24. else  if  (c <= sc || n >= MAXIMUM_CAPACITY) 
  25. break  ; 
  26. else  if  (tab == table) {  // table不为空，且在此期间其他线程未修改table 
  27. int  rs = resizeStamp(n); 
  28. if  (sc < 0  ) { 
  29. Node<K,V>[] nt;  //RESIZE_STAMP_SHIFT=16,MAX_RESIZERS=2^15-1 
  30. if  ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs +  1  || 
  31. sc == rs + MAX_RESIZERS || (nt = nextTable) ==  null  || 
  32. transferIndex <=  0  ) 
  33. break  ; 
  34. if  (U.compareAndSwapInt(  this  , SIZECTL, sc, sc +  1  )) 
  35. transfer(tab, nt); 
  36. } 
  37. else  if  (U.compareAndSwapInt(  this  , SIZECTL, sc, 
  38. (rs << RESIZE_STAMP_SHIFT) +  2  )) 
  39. transfer(tab,  null  ); 
  40. } 
  41. } 
  42. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. private  static  final  int  tableSizeFor(  int  c){  //和HashMap一样,返回>=n的最小2的自然数幂 
  2. int  n = c -  1  ; 
  3. n |= n >>> 1  ; 
  4. n |= n >>> 2  ; 
  5. n |= n >>> 4  ; 
  6. n |= n >>> 8  ; 
  7. n |= n >>> 16  ; 
  8. return  (n < 0  ) ?  1  : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n +  1  ; 
  9. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. /** 
  2. * Returns the stamp bits for resizing a table of size n. 
  3. * Must be negative when shifted left by RESIZE_STAMP_SHIFT. 
  4. */ 
  5. static  final  int  resizeStamp(  int  n) {  // 返回一个标志位 
  6. return  Integer.numberOfLeadingZeros(n) | (  1  << (RESIZE_STAMP_BITS -  1  )); 
  7. }  // numberOfLeadingZeros返回n对应32位二进制数左侧0的个数，如9（1001）返回28 
  8. // RESIZE_STAMP_BITS=16,(左侧0的个数)|(2^15) 

  

** ConcurrentHashMap无锁多线程扩容，减少扩容时的时间消耗。 **

** transfer扩容操作 ** ** ： ** 单线程构建两倍容量的nextTable；允许多线程复制原table元素到nextTable。 

  1. 为每个内核均分任务，并保证其不小于16； 
  2. 若nextTab为null，则初始化其为原table的2倍； 
  3. 死循环遍历，直到finishing。 
  * 节点为空，则插入ForwardingNode； 
  * 链表节点（fh>=0），分别插入nextTable的i和i+n的位置；【逆序链表？？】 
  * TreeBin节点（fh<0），判断是否需要untreefi，分别插入nextTable的i和i+n的位置；【逆序树？？】 
  * finishing时，nextTab赋给table，更新sizeCtl为新容量的0.75倍 ，完成扩容。 

  

** 以上说的都是单线程，  多线程  又是如何实现的呢？ **

遍历到ForwardingNode节点((fh = f.hash) == MOVED)，说明此节点被处理过了，直接跳过。这是控制并发扩容的核心  。  由于
给节点上了锁，只允许当前线程完成此节点的操作，处理完毕后，将对应值设为ForwardingNode（fwd），其他线程看到forward，直接向后遍历。如此
便完成了多线程的复制工作，也解决了线程安全问题。

  

private  transient  volatile  Node<K,V>[]  nextTable  ;  //仅仅在扩容使用，并且此时非空

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. // 将table每一个bin（桶位）的Node移动或复制到nextTable 
  2. // 只在addCount(long x, int check)、helpTransfer、tryPresize中调用 
  3. private  final  void  transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) { 
  4. int  n = tab.length, stride; 
  5. // 每核处理的量小于16，则强制赋值16 
  6. if  ((stride = (NCPU > 1  ) ? (n >>> 3  ) / NCPU : n) < MIN_TRANSFER_STRIDE) 
  7. stride = MIN_TRANSFER_STRIDE;  // subdivide range 
  8. if  (nextTab ==  null  ) {  // initiating 
  9. try  { 
  10. @SuppressWarnings  (  "unchecked"  ) 
  11. Node<K,V>[] nt = (Node<K,V>[])  new  Node<?,?>[n << 1  ];  //两倍 
  12. nextTab = nt; 
  13. }  catch  (Throwable ex) {  // try to cope with OOME 
  14. sizeCtl = Integer.MAX_VALUE; 
  15. return  ; 
  16. } 
  17. nextTable = nextTab; 
  18. transferIndex = n; 
  19. } 
  20. int  nextn = nextTab.length; 
  21. //连节点指针,标志位，fwd的hash值为-1，fwd.nextTable=nextTab。 
  22. ForwardingNode<K,V> fwd=  new  ForwardingNode<K,V>(nextTab); 
  23. boolean  advance=  true  ;  //并发扩容的关键属性,等于true,说明此节点已经处理过 
  24. boolean  finishing =  false  ;  // to ensure sweep before committing nextTab 
  25. for  (  int  i =  0  , bound =  0  ;;) {  // 死循环 
  26. Node<K,V> f;  int  fh; 
  27. while  (advance) {  // 控制--i，遍历原hash表中的节点 
  28. int  nextIndex, nextBound; 
  29. if  (--i >= bound || finishing) 
  30. advance =  false  ; 
  31. else  if  ((nextIndex = transferIndex) <=  0  ) { 
  32. i = -  1  ; 
  33. advance =  false  ; 
  34. }  //TRANSFERINDEX 即用CAS计算得到的transferIndex 
  35. else  if  (U.compareAndSwapInt 
  36. (  this  , TRANSFERINDEX, nextIndex, 
  37. nextBound = (nextIndex > stride ? 
  38. nextIndex - stride :  0  ))) { 
  39. bound = nextBound; 
  40. i = nextIndex -  1  ; 
  41. advance =  false  ; 
  42. } 
  43. } 
  44. if  (i < 0  || i >= n || i + n >= nextn) { 
  45. int  sc; 
  46. if  (finishing) {  // 所有节点复制完毕 
  47. nextTable =  null  ; 
  48. table = nextTab; 
  49. sizeCtl = (n << 1  ) - (n >>> 1  );  //扩容阀值设为原来的1.5倍，即现在的0.75倍 
  50. return  ;  // 仅有的2个跳出死循环出口之一 
  51. }  //CAS更新扩容阈值,sc-1表明新加入一个线程参与扩容 
  52. if  (U.compareAndSwapInt(  this  , SIZECTL, sc = sizeCtl, sc -  1  )) { 
  53. if  ((sc -  2  ) != resizeStamp(n) << RESIZE_STAMP_SHIFT) 
  54. return  ;  // 仅有的2个跳出死循环出口之一 
  55. finishing = advance =  true  ; 
  56. i = n;  // recheck before commit 
  57. } 
  58. } 
  59. else  if  ((f = tabAt(tab, i)) ==  null  )  //该节点为空，则插入ForwardingNode 
  60. advance = casTabAt(tab, i,  null  , fwd); 
  61. //遍历到ForwardingNode节点，说明此节点被处理过了，直接跳过。这是控制并发扩容的核心 
  62. else  if  ((fh = f.hash) == MOVED)  // MOVED=-1，hash for fwd 
  63. advance =  true  ;  // already processed 
  64. else  { 
  65. synchronized  (f) {  //上锁 
  66. if  (tabAt(tab, i) == f) { 
  67. Node<K,V> ln, hn;  //ln原位置节点，hn新位置节点 
  68. if  (fh >=  0  ) {  // 链表 
  69. int  runBit = fh & n;  // f.hash & n 
  70. Node<K,V> lastRun = f;  // lastRun和p两个链表，逆序？？ 
  71. for  (Node<K,V> p = f.next; p !=  null  ; p = p.next) { 
  72. int  b = p.hash & n;  // f.next.hash & n 
  73. if  (b != runBit) { 
  74. runBit = b; 
  75. lastRun = p; 
  76. } 
  77. } 
  78. if  (runBit ==  0  ) { 
  79. ln = lastRun; 
  80. hn =  null  ; 
  81. } 
  82. else  { 
  83. hn = lastRun; 
  84. ln =  null  ; 
  85. } 
  86. for  (Node<K,V> p = f; p != lastRun; p = p.next) { 
  87. int  ph = p.hash; K pk = p.key; V pv = p.val; 
  88. if  ((ph & n) ==  0  )  // 和HashMap确定扩容后的节点位置一样 
  89. ln =  new  Node<K,V>(ph, pk, pv, ln); 
  90. else 
  91. hn =  new  Node<K,V>(ph, pk, pv, hn);  //新位置节点 
  92. }  //类似HashMap，为何i+n？参见HashMap的笔记 
  93. setTabAt(nextTab, i, ln);  //在nextTable[i]插入原节点 
  94. setTabAt(nextTab, i + n, hn);  //在nextTable[i+n]插入新节点 
  95. //在nextTable[i]插入forwardNode节点，表示已经处理过该节点 
  96. setTabAt(tab, i, fwd); 
  97. //设置advance为true 返回到上面的while循环中 就可以执行--i操作 
  98. advance =  true  ; 
  99. } 
  100. else  if  (f  instanceof  TreeBin) {  //树 
  101. TreeBin<K,V> t = (TreeBin<K,V>)f; 
  102. TreeNode<K,V> lo =  null  , loTail =  null  ; 
  103. TreeNode<K,V> hi =  null  , hiTail =  null  ; 
  104. //lc、hc=0两计数器分别++记录原、新bin中TreeNode数量 
  105. int  lc =  0  , hc =  0  ; 
  106. for  (Node<K,V> e = t.first; e !=  null  ; e = e.next) { 
  107. int  h = e.hash; 
  108. TreeNode<K,V> p =  new  TreeNode<K,V>
  109. (h, e.key, e.val,  null  ,  null  ); 
  110. if  ((h & n) ==  0  ) { 
  111. if  ((p.prev = loTail) ==  null  ) 
  112. lo = p; 
  113. else 
  114. loTail.next = p; 
  115. loTail = p; 
  116. ++lc; 
  117. } 
  118. else  { 
  119. if  ((p.prev = hiTail) ==  null  ) 
  120. hi = p; 
  121. else 
  122. hiTail.next = p; 
  123. hiTail = p; 
  124. ++hc; 
  125. } 
  126. }  //扩容后树节点个数若<=6，将树转链表 
  127. ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) : 
  128. (hc !=  0  ) ?  new  TreeBin<K,V>(lo) : t; 
  129. hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) : 
  130. (lc !=  0  ) ?  new  TreeBin<K,V>(hi) : t; 
  131. setTabAt(nextTab, i, ln); 
  132. setTabAt(nextTab, i + n, hn); 
  133. setTabAt(tab, i, fwd); 
  134. advance =  true  ; 
  135. } 
  136. } 
  137. } 
  138. } 
  139. } 
  140. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. // 协助扩容方法。多线程下，当前线程检测到其他线程正进行扩容操作，则协助其一起扩容；（只有这种情况会被调用）从某种程度上说，其“优先级”很高，只要检测到扩容，就会放下其他工作，先扩容。 
  2. // 调用之前，nextTable一定已存在。 
  3. final  Node<K,V>[] helpTransfer(Node<K,V>[] tab, Node<K,V> f) { 
  4. Node<K,V>[] nextTab; intsc; 
  5. if  (tab !=  null  && (finstanceof ForwardingNode) &&
  6. (nextTab = ((ForwardingNode<K,V>)f).nextTable) !=  null  ) { 
  7. intrs = resizeStamp(tab.length);  //标志位 
  8. while  (nextTab == nextTable && table == tab &&
  9. (sc = sizeCtl) < 0  ) { 
  10. if  ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs +  1  || 
  11. sc == rs + MAX_RESIZERS || transferIndex <=  0  ) 
  12. break  ; 
  13. if  (U.compareAndSwapInt(  this  , SIZECTL, sc, sc +  1  )) { 
  14. transfer(tab, nextTab);  //调用扩容方法，直接进入复制阶段 
  15. break  ; 
  16. } 
  17. } 
  18. return  nextTab; 
  19. } 
  20. return  table; 
  21. } 

  
2、 put相关：

  

理一下put的流程：

① ** 判空 ** ：null直接抛空指针异常；

② ** hash ** ：计算h=key.hashcode；调用spread计算hash=  (  h  ^  (  h  >>> 16  ))  &
HASH_BITS；

③ ** 遍历table **

  * 若table为空，则初始化，仅设置相关参数； 
  * @@@计算当前key存放位置，即table的下标i=(n - 1) & hash； 
  * 若待存放位置为null，casTabAt  无锁  插入； 
  * 若是forwarding nodes（检测到正在扩容），则helpTransfer（帮助其扩容）； 
  * else（待插入位置非空且不是forward节点，即碰撞了），将头节点上锁（保证了线程安全）：区分链表节点和树节点，分别插入（遇到hash值与key值都与新节点一致的情况，只需要更新value值即可。否则依次向后遍历，直到链表尾插入这个结点）； 
  * 若链表长度>8，则treeifyBin转树（Note：若length<64,直接tryPresize,两倍table.length;不转树）。 

④ ** addCount(1L, binCount)。 **

** Note： **

1、put操作共计两次hash操作，再利用“与&”操作计算Node的存放位置。

2、ConcurrentHashMap不允许key或value为null。

3、 ** addCount  (  long  x  ,  int  check  )  方法： **

①利用CAS快速更新baseCount的值；

②check>=0.则检验是否需要扩容；  if  sizeCtl<0（正在进行初始化或扩容操作）【nexttable
null等情况break；如果有线程正在扩容，则协助扩容】；  else if  仅当前线程在扩容，调用协助扩容函数，注其参数nextTable为null。

  

public  V put(K  key  , V  value  ) {

return  putVal  (  key  ,  value  ,  false  );

}

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. final  V <span style=  "background-color: rgb(255, 255, 51);"  >putVal</span>(K key, V value,  boolean  onlyIfAbsent) { 
  2. // 不允许key、value为空 
  3. if  (key ==  null  || value ==  null  )  throw  new  NullPointerException(); 
  4. int  hash = spread(key.hashCode());  //返回(h^(h>>>16))&HASH_BITS 
  5. int  binCount =  0  ; 
  6. for  (Node<K,V>[] tab = table;;) {  // 死循环，直到插入成功 
  7. Node<K,V> f;  int  n, i, fh; 
  8. if  (tab ==  null  || (n = tab.length) ==  0  ) 
  9. tab = initTable();  // table为空，初始化table 
  10. else  if  ((f = tabAt(tab, i = (n -  1  ) & hash)) ==  null  ) {  // 索引处无值 
  11. if  (casTabAt(tab, i,  null  , 
  12. new  Node<K,V>(hash, key, value,  null  ))) 
  13. break  ;  // no lock when adding to empty bin 
  14. } 
  15. else  if  ((fh = f.hash) == MOVED)  // MOVED=-1;//hash for forwarding nodes 
  16. tab = helpTransfer(tab, f);  //检测到正在扩容，则帮助其扩容 
  17. else  { 
  18. V oldVal =  null  ; 
  19. synchronized  (f) {  // 节点上锁（hash值相同的链表的头节点） 
  20. if  (tabAt(tab, i) == f) { 
  21. if  (fh >=  0  ) {  // 链表节点 
  22. binCount =  1  ; 
  23. for  (Node<K,V> e = f;; ++binCount) { 
  24. K ek;  // hash和key相同，则修改value 
  25. if  (e.hash == hash &&
  26. ((ek = e.key) == key ||(ek !=  null  && key.equals(ek)))) { 
  27. oldVal = e.val; 
  28. if  (!onlyIfAbsent)  //仅putIfAbsent()方法中onlyIfAbsent为true 
  29. e.val = value;  //putIfAbsent()包含key则返回get，否则put并返回 
  30. break  ; 
  31. } 
  32. Node<K,V> pred = e; 
  33. if  ((e = e.next) ==  null  ) {  //已遍历到链表尾部，直接插入 
  34. pred.next =  new  Node<K,V>(hash, key, value,  null  ); 
  35. break  ; 
  36. } 
  37. } 
  38. } 
  39. else  if  (f  instanceof  TreeBin) {  // 树节点 
  40. Node<K,V> p; 
  41. binCount =  2  ; 
  42. if  ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,value)) !=  null  ) { 
  43. oldVal = p.val; 
  44. if  (!onlyIfAbsent) 
  45. p.val = value; 
  46. } 
  47. } 
  48. } 
  49. } 
  50. if  (binCount !=  0  ) { 
  51. if  (binCount >= TREEIFY_THRESHOLD)  //实则是>8,执行else,说明该桶位本就有Node 
  52. treeifyBin(tab, i);  //若length<64,直接tryPresize,两倍table.length;不转树 
  53. if  (oldVal !=  null  ) 
  54. return  oldVal; 
  55. break  ; 
  56. } 
  57. } 
  58. } 
  59. addCount(1L, binCount); 
  60. return  null  ; 
  61. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. // Initializes table, using the size recorded in sizeCtl. 
  2. private  final  Node<K,V>[] <span style=  "background-color: rgb(255, 255, 51);"  >initTable</span>() {  // 仅仅设置参数，并未实质初始化 
  3. Node<K,V>[] tab; intsc; 
  4. while  ((tab = table) ==  null  || tab.length ==  0  ) { 
  5. if  ((sc = sizeCtl) < 0  )  // 其他线程正在初始化，此线程挂起 
  6. Thread.yield();  // lost initialization race; just spin 
  7. //CAS方法把sizectl置为-1，表示本线程正在进行初始化 
  8. elseif (U.compareAndSwapInt(  this  , SIZECTL, sc, -  1  )) { 
  9. try  { 
  10. if  ((tab = table) ==  null  || tab.length ==  0  ) { 
  11. intn = (sc > 0  ) ? sc : DEFAULT_CAPACITY;  //DEFAULT_CAPACITY=16 
  12. @SuppressWarnings  (  "unchecked"  ) 
  13. Node<K,V>[] nt = (Node<K,V>[])  new  Node<?,?>[n]; 
  14. table = tab = nt; 
  15. sc = n - (n >>> 2  );  // 扩容阀值，0.75*n 
  16. } 
  17. }  finally  { 
  18. sizeCtl = sc; 
  19. } 
  20. break  ; 
  21. } 
  22. } 
  23. return  tab; 
  24. } 

  

3、 get、contains相关

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. public  V <span style=  "background-color: rgb(255, 255, 51);"  >get</span>(Object key) { 
  2. Node<K,V>[] tab; Node<K,V> e, p; intn, eh; K ek; 
  3. inth = spread(key.hashCode()); 
  4. if  ((tab = table) !=  null  && (n = tab.length) > 0  &&
  5. (e = tabAt(tab, (n -  1  ) & h)) !=  null  ) {  //tabAt(i),获取索引i处Node 
  6. if  ((eh = e.hash) == h) { 
  7. if  ((ek = e.key) == key || (ek !=  null  && key.equals(ek))) 
  8. returne.val; 
  9. } 
  10. elseif (eh < 0  )  // 树 
  11. return  (p = e.find(h, key)) !=  null  ? p.val :  null  ; 
  12. while  ((e = e.next) !=  null  ) {  // 链表 
  13. if  (e.hash == h &&
  14. ((ek = e.key) == key || (ek !=  null  && key.equals(ek)))) 
  15. returne.val; 
  16. } 
  17. } 
  18. return  null  ; 
  19. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. public  boolean  containsKey(Object key) {  return  get(key) !=  null  ;} 
  2. public  boolean  containsValue(Object value) {} 

  

理一下get的流程：

①spread计算hash值；

②table不为空；

③tabAt(i)处桶位不为空；

④check first，是则返回当前Node的value；否则分别根据树、链表查询。

  

4、 Size相关：

由于ConcurrentHashMap在统计size时  可能正被  多个线程操作，而我们又不可能让他停下来让我们计算，所以只能计量一个估计值。

  

计数辅助：

//  Table of counter cells. When non-null, size is a power of 2

private  transient  volatile  CounterCell[]  counterCells  ;

@  sun.misc.  Contended  static  final  class  CounterCell  {

volatile  long  value  ;

CounterCell(  long  x  ) {  value  =  x  ; }

}

final  long  sumCount  (){

CounterCell  as  [] =  counterCells  ;

long  sum  =  baseCount  ;

if  (  as  !=  null  ){

for  (  int  i  = 0;  i  < as  .  length  ;  i  ++){

CounterCell  a  ;

if  ((  a  =  as  [  i  ]) !=  null  )

sum  +=  a  .  value  ;

}

}

return  sum  ;

}

private  final  void  full  AddCount  (  long  x  ,  boolean  wasUncontended
) {}

public  int  size() {  // 旧版本方法，和推荐的mappingCount返回的值基本无区别

long  n  = sumCount();

return  ((  n  < 0L) ? 0 :

(  n  > (  long  )Integer.  MAX_VALUE  ) ? Integer.  MAX_VALUE  :

(  int  )  n  );

}

// 返回Mappings中的元素个数，官方建议用来  替代size  。此方法返回的是一个估计值；如果sumCount时有线程插入或删除，实际数量是和
mappingCount  不同的。since 1.8

public  long  mappingCount  () {

long  n  = sumCount();

return  (  n  < 0L) ? 0L :  n  ;  // ignore transient negative values

}

private  transient  volatile  long  baseCount  ;

//ConcurrentHashMap中元素个数,基于CAS无锁更新,但返回的不一定是当前Map的真实元素个数。

  

5、remove、clear相关：

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. public  void  clear() {  // 移除所有元素 
  2. long  delta = 0L;  // negative number of deletions 
  3. inti =  0  ; 
  4. Node<K,V>[] tab = table; 
  5. while  (tab !=  null  && i < tab.length) { 
  6. intfh; 
  7. Node<K,V> f = tabAt(tab, i); 
  8. if  (f ==  null  )  // 为空，直接跳过 
  9. ++i; 
  10. else  if  ((fh = f.hash) == MOVED) {  //检测到其他线程正对其扩容 
  11. //则协助其扩容，然后重置计数器，重新挨个删除元素，避免删除了元素，其他线程又新增元素。 
  12. tab = helpTransfer(tab, f); 
  13. i =  0  ;  // restart 
  14. } 
  15. else  { 
  16. synchronized  (f) {  // 上锁 
  17. if  (tabAt(tab, i) == f) {  // 其他线程没有在此期间操作f 
  18. Node<K,V> p = (fh >=  0  ? f : 
  19. (finstanceof TreeBin) ? 
  20. ((TreeBin<K,V>)f).first :  null  ); 
  21. while  (p !=  null  ) {  // 首先删除链、树的末尾元素，避免产生大量垃圾 
  22. \--delta; 
  23. p = p.next; 
  24. } 
  25. setTabAt(tab, i++,  null  );  // 利用CAS无锁置null 
  26. } 
  27. } 
  28. } 
  29. } 
  30. if  (delta != 0L) 
  31. addCount(delta, -  1  );  // 无实际意义，参数check<=1，直接return。 
  32. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. public  V remove(Object key) {  // key为null，将在计算hashCode时报空指针异常 
  2. return  replaceNode(key,  null  ,  null  ); 
  3. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. public  boolean  remove(Object key, Object value) { 
  2. if  (key ==  null  ) 
  3. thrownew NullPointerException(); 
  4. returnvalue !=  null  && replaceNode(key,  null  , value) !=  null  ; 
  5. } 

  

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. // remove核心方法，注意，这里的cv才是key-value中的value！ 
  2. final  V replaceNode(Object key, V value, Object cv) { 
  3. inthash = spread(key.hashCode()); 
  4. for  (Node<K,V>[] tab = table;;) { 
  5. Node<K,V> f; intn, i, fh; 
  6. if  (tab ==  null  || (n = tab.length) ==  0  || 
  7. (f = tabAt(tab, i = (n -  1  ) & hash)) ==  null  ) 
  8. break  ;  // 该桶位第一个元素为空，直接跳过 
  9. elseif ((fh = f.hash) == MOVED) 
  10. tab = helpTransfer(tab, f);  // 先协助扩容再说 
  11. else  { 
  12. V oldVal =  null  ; 
  13. booleanvalidated =  false  ; 
  14. synchronized  (f) { 
  15. if  (tabAt(tab, i) == f) { 
  16. if  (fh >=  0  ) { 
  17. validated =  true  ; 
  18. //pred没看出来有什么用，全是别人赋值给他，他却不影响其他参数 
  19. for  (Node<K,V> e = f, pred =  null  ;;) { 
  20. K ek; 
  21. if  (e.hash == hash &&((ek = e.key) == key || 
  22. (ek !=  null  && key.equals(ek)))){  //hash且可以相等 
  23. V ev = e.val; 
  24. // value为null或value和查到的值相等 
  25. if  (cv ==  null  || cv == ev || 
  26. (ev !=  null  && cv.equals(ev))) { 
  27. oldVal = ev; 
  28. if  (value !=  null  )  // replace中调用 
  29. e.val = value; 
  30. elseif (pred !=  null  ) 
  31. pred.next = e.next; 
  32. else 
  33. setTabAt(tab, i, e.next); 
  34. } 
  35. break  ; 
  36. } 
  37. pred = e; 
  38. if  ((e = e.next) ==  null  ) 
  39. break  ; 
  40. } 
  41. } 
  42. elseif (finstanceof TreeBin) {  // 以树的方式find、remove 
  43. validated =  true  ; 
  44. TreeBin<K,V> t = (TreeBin<K,V>)f; 
  45. TreeNode<K,V> r, p; 
  46. if  ((r = t.root) !=  null  &&
  47. (p = r.findTreeNode(hash, key,  null  )) !=  null  ) { 
  48. V pv = p.val; 
  49. if  (cv ==  null  || cv == pv || 
  50. (pv !=  null  && cv.equals(pv))) { 
  51. oldVal = pv; 
  52. if  (value !=  null  ) 
  53. p.val = value; 
  54. elseif (t.removeTreeNode(p)) 
  55. setTabAt(tab, i, untreeify(t.first)); 
  56. } 
  57. } 
  58. } 
  59. } 
  60. } 
  61. if  (validated) { 
  62. if  (oldVal !=  null  ) { 
  63. if  (value ==  null  ) 
  64. addCount(-1L, -  1  ); 
  65. returnoldVal; 
  66. } 
  67. break  ; 
  68. } 
  69. } 
  70. } 
  71. return  null  ; 
  72. } 

** [java] ** [ view plain ](http://blog.csdn.net/u010887744/article/details/50637030#) [ copy ](http://blog.csdn.net/u010887744/article/details/50637030#)

[ ![在CODE上查看代码片](https://code.csdn.net/assets/CODE_ico.png)
](https://code.csdn.net/snippets/1574859) [
![派生到我的代码片](https://code.csdn.net/assets/ico_fork.svg)
](https://code.csdn.net/snippets/1574859/fork)

  1. public  boolean  replace(K key, V oldValue, V newValue) {} 

  

6、其他函数：

public  boolean  isEmpty  () {

return  sumCount() <= 0L;  // ignore transient negative values

}

  

参考资料:

[ http://ifeve.com/concurrenthashmap/  ](http://ifeve.com/concurrenthashmap/)

[ http://ifeve.com/java-concurrent-hashmap-2/ ](http://ifeve.com/java-
concurrent-hashmap-2/)

、、、、、、、、、

[ http://ashkrit.blogspot.com/2014/12/what-is-new-in-
java8-concurrenthashmap.html  ](http://ashkrit.blogspot.com/2014/12/what-is-
new-in-java8-concurrenthashmap.html)

[ http://blog.csdn.net/u010723709/article/details/48007881
](http://blog.csdn.net/u010723709/article/details/48007881)

[ http://yucchi.jp/blog/?p=2048  ](http://yucchi.jp/blog/?p=2048)

[ http://blog.csdn.net/q291611265/article/details/47985145
](http://blog.csdn.net/q291611265/article/details/47985145)

、、、、、、、、、、

SynchronizedMap： [ http://blog.sina.com.cn/s/blog_5157093c0100hm3y.html
](http://blog.sina.com.cn/s/blog_5157093c0100hm3y.html)

[ http://blog.csdn.net/yangfanend/article/details/7165742
](http://blog.csdn.net/yangfanend/article/details/7165742)

[ http://blog.csdn.net/xuefeng0707/article/details/40797085
](http://blog.csdn.net/xuefeng0707/article/details/40797085)

  

    
    
    <a target=_blank id="L1" href="http://blog.csdn.net/u010887744/article/details/50637030#L1" rel="#L1" style="color: rgb(102, 102, 102); text-decoration: none;">  1</a>
    <a target=_blank id="L2" href="http://blog.csdn.net/u010887744/article/details/50637030#L2" rel="#L2" style="color: rgb(102, 102, 102); text-decoration: none;">  2</a>
    <a target=_blank id="L3" href="http://blog.csdn.net/u010887744/article/details/50637030#L3" rel="#L3" style="color: rgb(102, 102, 102); text-decoration: none;">  3</a>
    <a target=_blank id="L4" href="http://blog.csdn.net/u010887744/article/details/50637030#L4" rel="#L4" style="color: rgb(102, 102, 102); text-decoration: none;">  4</a>
    <a target=_blank id="L5" href="http://blog.csdn.net/u010887744/article/details/50637030#L5" rel="#L5" style="color: rgb(102, 102, 102); text-decoration: none;">  5</a>
    <a target=_blank id="L6" href="http://blog.csdn.net/u010887744/article/details/50637030#L6" rel="#L6" style="color: rgb(102, 102, 102); text-decoration: none;">  6</a>
    <a target=_blank id="L7" href="http://blog.csdn.net/u010887744/article/details/50637030#L7" rel="#L7" style="color: rgb(102, 102, 102); text-decoration: none;">  7</a>
    <a target=_blank id="L8" href="http://blog.csdn.net/u010887744/article/details/50637030#L8" rel="#L8" style="color: rgb(102, 102, 102); text-decoration: none;">  8</a>
    <a target=_blank id="L9" href="http://blog.csdn.net/u010887744/article/details/50637030#L9" rel="#L9" style="color: rgb(102, 102, 102); text-decoration: none;">  9</a>
    <a target=_blank id="L10" href="http://blog.csdn.net/u010887744/article/details/50637030#L10" rel="#L10" style="color: rgb(102, 102, 102); text-decoration: none;"> 10</a>
    <a target=_blank id="L11" href="http://blog.csdn.net/u010887744/article/details/50637030#L11" rel="#L11" style="color: rgb(102, 102, 102); text-decoration: none;"> 11</a>
    
    
    ArrayList源码分析（jdk1.8）：http://blog.csdn.net/u010887744/article/details/49496093
    
    HashMap源码分析（jdk1.8）：http://write.blog.csdn.net/postedit/50346257
    
    ConcurrentHashMap源码分析--Java8：http://blog.csdn.net/u010887744/article/details/50637030
    
    
    
    
    每篇文章都包含 有道云笔记地址，可直接保存。
    
    
    
    
    在线查阅JDK源码：
    
    JDK8：https://github.com/zxiaofan/JDK1.8-Src
    
    JDK7：https://github.com/zxiaofan/JDK_Src_1.7
    
    
    
    
    史上最全Java集合关系图：http://blog.csdn.net/u010887744/article/details/50575735

#####  [ 来自CODE的代码片 ](https://code.csdn.net/snippets/1574871)

SourceCode

    
    
    <a target=_blank id="L1" href="http://blog.csdn.net/u010887744/article/details/50637030#L1" rel="#L1" style="color: rgb(102, 102, 102); text-decoration: none;">  1</a>
    <a target=_blank id="L2" href="http://blog.csdn.net/u010887744/article/details/50637030#L2" rel="#L2" style="color: rgb(102, 102, 102); text-decoration: none;">  2</a>
    <a target=_blank id="L3" href="http://blog.csdn.net/u010887744/article/details/50637030#L3" rel="#L3" style="color: rgb(102, 102, 102); text-decoration: none;">  3</a>
    <a target=_blank id="L4" href="http://blog.csdn.net/u010887744/article/details/50637030#L4" rel="#L4" style="color: rgb(102, 102, 102); text-decoration: none;">  4</a>
    <a target=_blank id="L5" href="http://blog.csdn.net/u010887744/article/details/50637030#L5" rel="#L5" style="color: rgb(102, 102, 102); text-decoration: none;">  5</a>
    <a target=_blank id="L6" href="http://blog.csdn.net/u010887744/article/details/50637030#L6" rel="#L6" style="color: rgb(102, 102, 102); text-decoration: none;">  6</a>
    <a target=_blank id="L7" href="http://blog.csdn.net/u010887744/article/details/50637030#L7" rel="#L7" style="color: rgb(102, 102, 102); text-decoration: none;">  7</a>
    <a target=_blank id="L8" href="http://blog.csdn.net/u010887744/article/details/50637030#L8" rel="#L8" style="color: rgb(102, 102, 102); text-decoration: none;">  8</a>
    <a target=_blank id="L9" href="http://blog.csdn.net/u010887744/article/details/50637030#L9" rel="#L9" style="color: rgb(102, 102, 102); text-decoration: none;">  9</a>
    <a target=_blank id="L10" href="http://blog.csdn.net/u010887744/article/details/50637030#L10" rel="#L10" style="color: rgb(102, 102, 102); text-decoration: none;"> 10</a>
    
    
    转载请注明出处，谢谢。
    
    
    
    
    【 CSDN 】：csdn.zxiaofan.cn
    
    【GitHub】：github.zxiaofan.cn
    
    
    
    
    域名备案中，上述网址极不稳定，GitHub请直接访问【github.com/zxiaofan】
    
    
    
    
    如有任何问题，欢迎留言。祝君好运！
    
    Life is all about choices！ 
    
    将来的你一定会感激现在拼命的自己！

#####  [ 来自CODE的代码片 ](https://code.csdn.net/snippets/637064)

txt

  

