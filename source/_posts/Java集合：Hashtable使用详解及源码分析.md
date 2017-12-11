title: Java集合：Hashtable使用详解及源码分析
date: 2017-11-11 13:09:04
tags: [Java集合]
------------------

##  1 使用方法

Hashtable是和HashMap类似的散列表，存储的内容为key-value键值对，key的值是唯一的，和HashMap不同的是key和value都不能
为null。Hashtable和HashMap的关系可以参考Vector和ArrayList的关系，操作和功能大部分相同，Hashtable是线程安全的但是
速度较慢，建议使用HashMap，如果遇到多线程情况则使用concurrentHashMap或者Collections提供静态函数SynchronizedM
ap等来保证线程安全。

    
    
    public class Hashtable<K,V>
            extends Dictionary<K,V>
            implements Map<K,V>, Cloneable, java.io.Serializable {}

HashMap继承了Dictionary并实现了Map、Cloneable以及Serializable接口，所以HashMap支持clone和序列化。

###  1.1 方法介绍

Hashtable提供的API主要有如下几种：

    
    
    synchronized void                clear() //清空Hashtable
    synchronized Object              clone() //复制Hashtable
    boolean             contains(Object value) //判断是否包含value
    synchronized boolean             containsKey(Object key) //是否包含key
    synchronized boolean             containsValue(Object value) //是否包含value
    synchronized Enumeration<V>      elements() //获取value组成的枚举
    synchronized Set<Entry<K, V>>    entrySet() //获取entry组成的Set集合
    synchronized boolean             equals(Object object) //判断相等
    synchronized V                   get(Object key) //获取键值为key的entry
    synchronized int                 hashCode() //获取hashCode
    synchronized boolean             isEmpty() //判空
    synchronized Set<K>              keySet() //获取key组成的Set集合
    synchronized Enumeration<K>      keys() //获取key组成的枚举
    synchronized V                   put(K key, V value) //添加元素
    synchronized void                putAll(Map<? extends K, ? extends V> map) //添加一组元素
    synchronized V                   remove(Object key) //删除键为key的元素
    synchronized int                 size() //获取大小
    synchronized String              toString() //返回Hashtable键值组成的字符串
    synchronized Collection<V>       values() //获取值组成的Collection集合

###  1.2 使用示例

    
    
    public void testHashtable() {
            //新建hashtable
            Hashtable hashtable = new Hashtable();
            //添加元素
            hashtable.put(1, "one");
            hashtable.put(2, "two");
            hashtable.put(3, "three");
            hashtable.put(4, "four");
            //打印元素
            this.printMapByEntrySet(hashtable);
            //获取大小
            System.out.println("hashtable的大小为: " + hashtable.size());
            //是否包含key为4的元素
            System.out.println("hashtable是否包含key为4的元素: " + hashtable.containsKey(4));
            //是否包含值为5的元素
            System.out.println("hashtable是否包含value为two的元素: " + hashtable.containsValue("two"));
    
            hashtable.put(5, "five");
            hashtable.put(6, "six");
    
            //删除元素
            System.out.println("删除key为2的元素: " + hashtable.remove(2));
            //打印元素
            this.printMapByKeySet(hashtable);
            //clone
            Hashtable cloneTable = (Hashtable) hashtable.clone();
            //打印克隆table
            System.out.println("clonetable的元素为: " + cloneTable);
            //打印克隆table的keys
            this.printHashtableKeysByEnum(cloneTable);
            //清空hashtable
            hashtable.clear();
            //判空
            System.out.println("hashtable是否为空: " + hashtable.isEmpty());
        }
    
        /**
         * 根据entrySet()获取Entry集合,然后遍历Set集合获取键值对
         * @param hashtable
         */
        private void printMapByEntrySet(Hashtable hashtable) {
            Integer key = null;
            String value = null;
            Iterator iterator = hashtable.entrySet().iterator(); //
            System.out.print("hashtable中含有的元素有: ");
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
         * @param hashtable
         */
        private void printMapByKeySet(Hashtable hashtable) {
            Integer key = null;
            String value = null;
            Iterator iterator = hashtable.keySet().iterator();
            System.out.print("hashtable中含有的元素有: ");
            while (iterator.hasNext()) {
                key = (Integer) iterator.next();
                value = (String) hashtable.get(key);
                System.out.print("key/value : " + key + "/" + value + " ");
            }
            System.out.println();
        }
    
        /**
         * 使用枚举获取hashtable的keys
         * @param hashtable
         */
        private void printHashtableKeysByEnum(Hashtable hashtable) {
            Enumeration enumeration = hashtable.keys();
            System.out.print("hashtable的key有: ");
            while (enumeration.hasMoreElements()) {
                System.out.print(enumeration.nextElement() + " ");
            }
            System.out.println();
        }
    }

运行结果如下：

    
    
    hashtable中含有的元素有: key/value : 4/four key/value : 3/three key/value : 2/two key/value : 1/one
    hashtable的大小为: 4
    hashtable是否包含key为4的元素: true
    hashtable是否包含value为two的元素: true
    删除key为2的元素: two
    hashtable中含有的元素有: key/value : 6/six key/value : 5/five key/value : 4/four key/value : 3/three key/value : 1/one
    clonetable的元素为: {6=six, 5=five, 4=four, 3=three, 1=one}
    hashtable的key有: 6 5 4 3 1
    hashtable是否为空: true

##  2 源码分析

###  2.1构造函数

Hashtable有四个构造函数，每个构造函数的不同之处和hashMap构造函数类似在于初始容量和加载因子不同。初始容量为申请的Hashtable初始大小，
当加入元素后的容量大于加载因子和当前容量的乘积是，Hashtable需要再hash增大容量。

    
    
    /**
     * 构造一个空的Hashtable,容量为initialCapacity,加载因子为loadFactor
     *
     * @param      initialCapacity   the initial capacity of the hashtable.
     * @param      loadFactor        the load factor of the hashtable.
     * @exception  IllegalArgumentException  if the initial capacity is less
     *             than zero, or if the load factor is nonpositive.
     */
    public Hashtable(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0) //非法参数检查
            throw new IllegalArgumentException("Illegal Capacity: "+
                    initialCapacity);
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal Load: "+loadFactor);
    
        if (initialCapacity==0) //最少容量为1
            initialCapacity = 1;
        this.loadFactor = loadFactor;
        table = new Entry<?,?>[initialCapacity]; //元素数组
        //再hash阈值,和HashMap不同.HashMap构造时阈值为大于或者等于initialCapacity的最小的2的倍数
        threshold = (int)Math.min(initialCapacity * loadFactor, MAX_ARRAY_SIZE + 1);
    }
    
    /**
     * 构造一个初始容量为initialCapacity,加载因子为0.75的Hashtable.
     *
     * @param     initialCapacity   the initial capacity of the hashtable.
     * @exception IllegalArgumentException if the initial capacity is less
     *              than zero.
     */
    public Hashtable(int initialCapacity) {
        this(initialCapacity, 0.75f);
    }
    
    /**
     * Constructs a new, empty hashtable with a default initial capacity (11)
     * and load factor (0.75).
     */
    public Hashtable() {
        this(11, 0.75f);
    }
    
    /**
     * 构造并使用t初始化一个Hashtable,大小为t大小两倍和者11中的较大数,加载因子为0.75.
     *
     * @param t the map whose mappings are to be placed in this map.
     * @throws NullPointerException if the specified map is null.
     * @since   1.2
     */
    public Hashtable(Map<? extends K, ? extends V> t) {
        this(Math.max(2*t.size(), 11), 0.75f);
        putAll(t);
    }

###  2.2 put方法

    
    
    /**
     * 向Hashtable中添加元素
     *
     * @param      key     the hashtable key
     * @param      value   the value
     * @return     the previous value of the specified key in this hashtable,
     *             or <code>null</code> if it did not have one
     * @exception  NullPointerException  if the key or value is
     *               <code>null</code>
     * @see     Object#equals(Object)
     * @see     #get(Object)
     */
    public synchronized V put(K key, V value) {
        // Make sure the value is not null
        if (value == null) {
            throw new NullPointerException();
        }
    
        // Makes sure the key is not already in the hashtable.
        Entry<?,?> tab[] = table;
        int hash = key.hashCode();
        int index = (hash & 0x7FFFFFFF) % tab.length;
        @SuppressWarnings("unchecked")
        Entry<K,V> entry = (Entry<K,V>)tab[index];
        for(; entry != null ; entry = entry.next) {
            if ((entry.hash == hash) && entry.key.equals(key)) {
                V old = entry.value;
                entry.value = value;
                return old;
            }
        }
    
        addEntry(hash, key, value, index);
        return null;
    }
    
    private void addEntry(int hash, K key, V value, int index) {
        modCount++;
    
        Entry<?,?> tab[] = table;
        if (count >= threshold) {
            // Rehash the table if the threshold is exceeded
            rehash();
    
            tab = table;
            hash = key.hashCode();
            index = (hash & 0x7FFFFFFF) % tab.length;
        }
    
        // Creates the new entry.
        @SuppressWarnings("unchecked")
        Entry<K,V> e = (Entry<K,V>) tab[index];
        tab[index] = new Entry<>(hash, key, value, e);
        count++;
    }

###  2.3 get方法

    
    
    /**
     * Returns the value to which the specified key is mapped,
     * or {@code null} if this map contains no mapping for the key.
     *
     * <p>More formally, if this map contains a mapping from a key
     * {@code k} to a value {@code v} such that {@code (key.equals(k))},
     * then this method returns {@code v}; otherwise it returns
     * {@code null}.  (There can be at most one such mapping.)
     *
     * @param key the key whose associated value is to be returned
     * @return the value to which the specified key is mapped, or
     *         {@code null} if this map contains no mapping for the key
     * @throws NullPointerException if the specified key is null
     * @see     #put(Object, Object)
     */
    @SuppressWarnings("unchecked")
    public synchronized V get(Object key) {
        Entry<?,?> tab[] = table;
        int hash = key.hashCode();
        int index = (hash & 0x7FFFFFFF) % tab.length; //获取下标
        for (Entry<?,?> e = tab[index] ; e != null ; e = e.next) { //遍历链表
            if ((e.hash == hash) && e.key.equals(key)) {
                return (V)e.value;
            }
        }
        return null;
    }

2.4 remove方法

    
    
    /**
     * Removes the key (and its corresponding value) from this
     * hashtable. This method does nothing if the key is not in the hashtable.
     *
     * @param   key   the key that needs to be removed
     * @return  the value to which the key had been mapped in this hashtable,
     *          or <code>null</code> if the key did not have a mapping
     * @throws  NullPointerException  if the key is <code>null</code>
     */
    public synchronized V remove(Object key) {
        Entry<?,?> tab[] = table;
        int hash = key.hashCode();
        int index = (hash & 0x7FFFFFFF) % tab.length;
        @SuppressWarnings("unchecked")
        Entry<K,V> e = (Entry<K,V>)tab[index];
        for(Entry<K,V> prev = null ; e != null ; prev = e, e = e.next) {
            if ((e.hash == hash) && e.key.equals(key)) {
                modCount++;
                if (prev != null) { //不是链表的第一个元素, 跳过要删除的节点
                    prev.next = e.next;
                } else {
                    tab[index] = e.next; //第一个节点
                }
                count--;
                V oldValue = e.value;
                e.value = null; //删除节点的value, help GC
                return oldValue;
            }
        }
        return null;
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/3310887.html
](http://www.cnblogs.com/skywang12345/p/3310887.html)  
[2] [ http://blog.csdn.net/ns_code/article/details/36191279
](http://blog.csdn.net/ns_code/article/details/36191279)  
[3] 《Java编程思想》第4版

