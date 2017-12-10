Java集合：HashMap使用详解及源码分析

##  1 使用方法

HashMap是散列表，存储的内容为key-value键值对，key的值是唯一的，可以为null。

    
    
    public class HashMap<K,V> extends AbstractMap<K,V> implements Map<K,V>, Cloneable, Serializable {}

HashMap继承了AbstractMap并实现了Map、Cloneable以及Serializable接口，所以HashMap支持clone和序列化。

##  1.1 方法介绍

HashMap提供的API主要如下：

    
    
    void                 clear() //清空HashMap
    Object               clone() //复制HashMap
    boolean              containsKey(Object key) //判断是否存在key
    boolean              containsValue(Object value) //判断是否存在Value
    Set<Entry<K, V>>     entrySet() //返回HashMap的Entry组成的set集合
    V                    get(Object key) //获取键为key的元素值
    boolean              isEmpty() //判空
    Set<K>               keySet() //获取HashMap的key组成的set集合
    V                    put(K key, V value) //加入HashMap
    void                 putAll(Map<? extends K, ? extends V> map) //批量加入
    V                    remove(Object key) //删除键为key的Entry
    int                  size() //获取大小
    Collection<V>        values() //获取HashMap的value集合

###  1.2 使用示例

    
    
    public void testHashMap() {
        //新建hashMap
        HashMap hashMap = new HashMap(); //新建hashMap
        //添加元素
        hashMap.put(1, "one");
        hashMap.put(2, "two");
        hashMap.put(3, "three");
        hashMap.put(4, "four");
        //打印元素
        this.printMapByEntrySet(hashMap);
        //获取大小
        System.out.println("hashMap的大小为: " + hashMap.size());
        //是否包含key为4的元素
        System.out.println("hashMap是否包含key为4的元素: " + hashMap.containsKey(4));
        //是否包含值为5的元素
        System.out.println("hashMap是否包含value为two的元素: " + hashMap.containsValue("two"));
    
        hashMap.put(5, "five");
        hashMap.put(6, "six");
    
        //删除元素
        System.out.println("删除key为2的元素: " + hashMap.remove(2));
        //打印元素
        this.printMapByKeySet(hashMap);
        //clone
        HashMap cloneMap = (HashMap) hashMap.clone();
        //打印克隆map
        System.out.println("cloneMap的元素为: " + cloneMap);
        //清空map
        hashMap.clear();
        //判空
        System.out.println("hashMap是否为空: " + hashMap.isEmpty());
    }
    
    /**
     * 根据entrySet()获取Entry集合,然后遍历Set集合获取键值对
     * @param map
     */
    private void printMapByEntrySet(HashMap map) {
        Integer key = null;
        String value = null;
        Iterator iterator = map.entrySet().iterator(); //
        System.out.print("hashMap中含有的元素有: ");
        while (iterator.hasNext()) {
            Map.Entry entry = (Map.Entry) iterator.next();
            key = (Integer) entry.getKey();
            value = (String) entry.getValue();
            System.out.print("key/value : " + key + "/" + value + " ");
        }
        System.out.println();
    }
    
    /**
     * 使用keySet获取key的Set集合,利用key获取值
     * @param map
     */
    private void printMapByKeySet(HashMap map) {
        Integer key = null;
        String value = null;
        Iterator iterator = map.keySet().iterator();
        System.out.print("hashMap中含有的元素有: ");
        while (iterator.hasNext()) {
            key = (Integer) iterator.next();
            value = (String) map.get(key);
            System.out.print("key/value : " + key + "/" + value + " ");
        }
        System.out.println();
    }

运行结果如下：

    
    
    hashMap中含有的元素有: key/value : 1/one key/value : 2/two key/value : 3/three key/value : 4/four
    hashMap的大小为: 4
    hashMap是否包含key为4的元素: true
    hashMap是否包含value为two的元素: true
    删除key为2的元素: two
    hashMap中含有的元素有: key/value : 1/one key/value : 3/three key/value : 4/four key/value : 5/five key/value : 6/six
    cloneMap的元素为: {1=one, 3=three, 4=four, 5=five, 6=six}
    hashMap是否为空: true

##  2 源码分析

###  2.1构造函数

HashMap有四个构造函数，每个构造函数的不同之处在于初始容量和加载因子不同。初始容量为申请的HashMap初始大小，当加入元素后的容量大于加载因子和当前
容量的乘积是，HashMap需要再hash增大容量。

    
    
    /**
     * 申请初始容量为initialCapacity, 加载因子为loadFactor
     * @param initialCapacity 初始容量
     * @param loadFactor 加载因子
     * @throws IllegalArgumentException 非法参数异常
     */
    public HashMap(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal initial capacity: " +
                    initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY) //最大容量为2^30
            initialCapacity = MAXIMUM_CAPACITY;
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal load factor: " +
                    loadFactor);
        this.loadFactor = loadFactor; //加载因子
        this.threshold = tableSizeFor(initialCapacity); //容量大小, >=initialCapacity的最小的2的倍数
    }
    
    /**
     * 初始容量大小为initialCapacity, 加载因子为默认0.75
     * @param  initialCapacity the initial capacity.
     * @throws IllegalArgumentException if the initial capacity is negative.
     */
    public HashMap(int initialCapacity) {
        this(initialCapacity, DEFAULT_LOAD_FACTOR);
    }
    
    /**
     * 初始容量大小为0, 加载因子为0.75
     */
    public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
    }
    
    /**
     * 申请一个HashMap并且用m初始化
     *
     * @param   m the map whose mappings are to be placed in this map
     * @throws  NullPointerException if the specified map is null
     */
    public HashMap(Map<? extends K, ? extends V> m) {
        this.loadFactor = DEFAULT_LOAD_FACTOR;
        putMapEntries(m, false);
    }

###  2.2 put方法

    
    
    /**
     * 为HashMap插入一个键为key,值为value的元素
     * @param key
     * @param value
     * @return
     */
    public V put(K key, V value) {
        return putVal(hash(key), key, value, false, true);
    }
    /**
     * Implements Map.put and related methods
     *
     * @param hash hash for key
     * @param key the key
     * @param value the value to put
     * @param onlyIfAbsent if true, don't change existing value
     * @param evict if false, the table is in creation mode.
     * @return previous value, or null if none
     */
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0) //hash数组为null或者长度为0
            n = (tab = resize()).length; //初始化数组
        if ((p = tab[i = (n - 1) & hash]) == null) //下标不存在,则这个下表所对应的元素为一个新节点
            tab[i] = newNode(hash, key, value, null);
        else { //将元素节点链接到链表最后
            Node<K,V> e; K k;
            if (p.hash == hash &&
                    ((k = p.key) == key || (key != null && key.equals(k)))) //键已经存在
                e = p;
            else if (p instanceof TreeNode) //TreeNode节点
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) { //将元素节点链接到最后
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                            ((k = e.key) == key || (key != null && key.equals(k)))) //键存在
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold) //超过容量值
            resize();
        afterNodeInsertion(evict);
        return null;
    }

###  2.3 get方法

    
    
    /**
     * 获取键为key的键值对的值
     * @param key
     * @return
     */
    public V get(Object key) {
        Node<K,V> e;
        return (e = getNode(hash(key), key)) == null ? null : e.value;
    }
    
    /**
     * Implements Map.get and related methods
     *
     * @param hash hash for key
     * @param key the key
     * @return the node, or null if none
     */
    final Node<K,V> getNode(int hash, Object key) {
        Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
        if ((tab = table) != null && (n = tab.length) > 0 &&
                (first = tab[(n - 1) & hash]) != null) {
            if (first.hash == hash && // always check first node
                    ((k = first.key) == key || (key != null && key.equals(k))))
                return first;
            if ((e = first.next) != null) {
                if (first instanceof TreeNode)
                    return ((TreeNode<K,V>)first).getTreeNode(hash, key);
                do {
                    if (e.hash == hash &&
                            ((k = e.key) == key || (key != null && key.equals(k))))
                        return e;
                } while ((e = e.next) != null);
            }
        }
        return null;
    }
    2.4 remove方法
    /**
     * 删除键为key的键值对
     * @param key
     * @return
     */
    public V remove(Object key) {
        Node<K,V> e;
        return (e = removeNode(hash(key), key, null, false, true)) == null ?
                null : e.value;
    }
    
    /**
     * Implements Map.remove and related methods
     *
     * @param hash hash for key
     * @param key the key
     * @param value the value to match if matchValue, else ignored
     * @param matchValue if true only remove if value is equal
     * @param movable if false do not move other nodes while removing
     * @return the node, or null if none
     */
    final Node<K,V> removeNode(int hash, Object key, Object value,
                               boolean matchValue, boolean movable) {
        Node<K, V>[] tab;
        Node<K, V> p;
        int n, index;
        if ((tab = table) != null && (n = tab.length) > 0 &&
                (p = tab[index = (n - 1) & hash]) != null) { //hash表不为空,长度 > 0,下标对应的元素存在
            Node<K, V> node = null, e;
            K k;
            V v;
            if (p.hash == hash &&
                    ((k = p.key) == key || (key != null && key.equals(k)))) //判断第一个元素
                node = p;
            else if ((e = p.next) != null) { //同一下标有多个元素,遍历链表
                if (p instanceof TreeNode)
                    node = ((TreeNode<K, V>) p).getTreeNode(hash, key);
                else {
                    do {
                        if (e.hash == hash &&
                                ((k = e.key) == key ||
                                        (key != null && key.equals(k)))) {
                            node = e;
                            break;
                        }
                        p = e;
                    } while ((e = e.next) != null);
                }
            }
            if (node != null && (!matchValue || (v = node.value) == value ||
                    (value != null && value.equals(v)))) { //删除元素
                if (node instanceof TreeNode)
                    ((TreeNode<K, V>) node).removeTreeNode(this, tab, movable);
                else if (node == p)
                    tab[index] = node.next;
                else
                    p.next = node.next;
                ++modCount;
                --size;
                afterNodeRemoval(node);
                return node;
            }
        }
    }

##  3 HashMap和Hashtable区别

HashMap和Hashtable从功能上来说几乎完全相同，主要区别在于Hashtable是线程安全的而HashMap不是。  
1）HashMap的key和Value可以接受null，Hashtable不行；  
2）Hashtable除了构造函数外几乎所有的方法都加上了synchronized保证线程安全，HashMap没有线程安全保证；  
3） Hashtable由于使用了synchronized导致在单线程情况下速度较慢；  
4） Hashtable构造时默认大小为11，HashMap为16；

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/3310835.html
](http://www.cnblogs.com/skywang12345/p/3310835.html)  
[2] [ http://blog.csdn.net/mazhimazh/article/details/17876641
](http://blog.csdn.net/mazhimazh/article/details/17876641)  
[3] [ http://blog.csdn.net/ns_code/article/details/36034955
](http://blog.csdn.net/ns_code/article/details/36034955)

