title: Java集合：TreeMap使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java集合]
------------------

##  1 使用方法

TreeMap和HashMap一样是散列表，但是他们内部实现完全不同，TreeMap基于红黑树实现，是一个有序的散列表，而HashMap使用数组加链表实现是
无序的。

    
    
    public class TreeMap<K,V>
            extends AbstractMap<K,V>
            implements NavigableMap<K,V>, Cloneable, java.io.Serializable {}

TreeMap继承了AbstractMap，储的是key-value键值对；  
TreeMap实现了NavigableMap接口，支持多种导航方法，可以精准的获得键值对；  
TreeMap和HashMap一样实现了Cloneable和Serializable接口，可以复制和序列化。

##  1.1 方法介绍

TreeMap提供的API主要有如下：

    
    
    Entry<K, V>                ceilingEntry(K key) //返回键不小于key的最小键值对entry
    K                          ceilingKey(K key) //返回键不小于key的最小键
    void                       clear() //清空TreeMap
    Object                     clone() //克隆TreeMap
    Comparator<? super K>      comparator() //比较器
    boolean                    containsKey(Object key) //是否包含键为key的键值对
    NavigableSet<K>            descendingKeySet() //获取降序排列key的Set集合
    NavigableMap<K, V>         descendingMap() //获取降序排列的Map
    Set<Entry<K, V>>           entrySet() //获取键值对entry的Set集合
    Entry<K, V>                firstEntry() //第一个entry
    K                          firstKey() //第一个key
    Entry<K, V>                floorEntry(K key) //获取不大于key的最大键值对
    K                          floorKey(K key) //获取不大于key的最大Key
    V                          get(Object key) //获取键为key的值value
    NavigableMap<K, V>         headMap(K to, boolean inclusive) //获取从第一个节点开始到to的子Map, inclusive表示是否包含to节点
    SortedMap<K, V>            headMap(K toExclusive) //获取从第一个节点开始到to的子Map, 不包括toExclusive
    Entry<K, V>                higherEntry(K key) //获取键大于key的最小键值对
    K                          higherKey(K key) //获取键大于key的最小键
    boolean                    isEmpty() //判空
    Set<K>                     keySet() //获取key的Set集合
    Entry<K, V>                lastEntry() //最后一个键值对
    K                          lastKey() //最后一个键
    Entry<K, V>                lowerEntry(K key) //键小于key的最大键值对
    K                          lowerKey(K key) //键小于key的最大键值对
    NavigableSet<K>            navigableKeySet() //返回key的Set集合
    Entry<K, V>                pollFirstEntry() //获取第一个节点,并删除
    Entry<K, V>                pollLastEntry() //获取最后一个节点并删除
    V                          put(K key, V value) //插入一个节点
    V                          remove(Object key) //删除键为key的节点
    int                        size() //Map大小
    SortedMap<K, V>            subMap(K fromInclusive, K toExclusive) //获取从fromInclusive到toExclusive子Map,前闭后开
    NavigableMap<K, V>         subMap(K from, boolean fromInclusive, K to, boolean toInclusive)
    NavigableMap<K, V>         tailMap(K from, boolean inclusive) //获取从from开始到最后的子Map,inclusive标志是否包含from
    SortedMap<K, V>            tailMap(K fromInclusive)

###  1.2 使用示例

    
    
    public void testTreeMap() {
        //新建treeMap
        TreeMap treeMap = new TreeMap();
        //添加元素
        treeMap.put(11, "eleven");
        treeMap.put(1, "one");
        treeMap.put(2, "two");
        treeMap.put(3, "three");
        treeMap.put(4, "four");
        //打印元素
        this.printMapByEntrySet(treeMap);
        //获取大小
        System.out.println("treeMap的大小为: " + treeMap.size());
        //是否包含key为4的元素
        System.out.println("treeMap是否包含key为4的元素: " + treeMap.containsKey(4));
        //是否包含值为5的元素
        System.out.println("treeMap是否包含value为two的元素: " + treeMap.containsValue("two"));
    
        treeMap.put(5, "five");
        treeMap.put(6, "six");
        treeMap.put(9, "nine");
        treeMap.put(11, "eleven");
    
        //获取treeMap中键不小于8最小的entry
        System.out.println("treeMap中键不小于8的最小entry为: " + treeMap.ceilingEntry(8));
        //获取第一个entry
        System.out.println("treeMap中第一个entry为: " + treeMap.firstEntry());
        //获取从from开始到to结束的子map,前闭后开
        System.out.println("从2开始到9结束的子map为: " + treeMap.subMap(2,9));
        //删除元素
        System.out.println("删除key为2的元素: " + treeMap.remove(2));
        //获取并删除最后一个元素
        System.out.println("获取并删除最后一个元素" + treeMap.pollLastEntry());
        //打印元素
        this.printMapByKeySet(treeMap);
        //clone
        TreeMap cloneMap = (TreeMap) treeMap.clone();
        //打印克隆map
        System.out.println("cloneMap的元素为: " + cloneMap);
        //清空map
        treeMap.clear();
        //判空
        System.out.println("treeMap是否为空: " + treeMap.isEmpty());
    }
    
    /**
     * 根据entrySet()获取Entry集合,然后遍历Set集合获取键值对
     * @param map
     */
    private void printMapByEntrySet(TreeMap map) {
        Integer key = null;
        String value = null;
        Iterator iterator = map.entrySet().iterator(); //
        System.out.print("treeMap中含有的元素有: ");
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
    private void printMapByKeySet(TreeMap map) {
        Integer key = null;
        String value = null;
        Iterator iterator = map.keySet().iterator();
        System.out.print("treeMap中含有的元素有: ");
        while (iterator.hasNext()) {
            key = (Integer) iterator.next();
            value = (String) map.get(key);
            System.out.print("key/value : " + key + "/" + value + " ");
        }
        System.out.println();
    }

运行结果如下：

    
    
    treeMap中含有的元素有: key/value : 1/one key/value : 2/two key/value : 3/three key/value : 4/four key/value : 11/eleven
    treeMap的大小为: 5
    treeMap是否包含key为4的元素: true
    treeMap是否包含value为two的元素: true
    treeMap中键不小于8的最小entry为: 9=nine
    treeMap中第一个entry为: 1=one
    从2开始到9结束的子map为: {2=two, 3=three, 4=four, 5=five, 6=six}
    删除key为2的元素: two
    获取并删除最后一个元素11=eleven
    treeMap中含有的元素有: key/value : 1/one key/value : 3/three key/value : 4/four key/value : 5/five key/value : 6/six key/value : 9/nine
    cloneMap的元素为: {1=one, 3=three, 4=four, 5=five, 6=six, 9=nine}
    treeMap是否为空: true

##  2 源码分析

###  2.1构造函数

TreeMap有四个构造函数，这四个构造函数的区别在于使用什么样的构造器，以及是否要初始化，源码中有注释解释。

    
    
    /**
     * Constructs a new, empty tree map, using the natural ordering of its
     * keys.  All keys inserted into the map must implement the {@link
     * Comparable} interface.  Furthermore, all such keys must be
     * <em>mutually comparable</em>: {@code k1.compareTo(k2)} must not throw
     * a {@code ClassCastException} for any keys {@code k1} and
     * {@code k2} in the map.  If the user attempts to put a key into the
     * map that violates this constraint (for example, the user attempts to
     * put a string key into a map whose keys are integers), the
     * {@code put(Object key, Object value)} call will throw a
     * {@code ClassCastException}.
     */
    public TreeMap() {
        comparator = null;
    }
    
    /**
     * Constructs a new, empty tree map, ordered according to the given
     * comparator.  All keys inserted into the map must be <em>mutually
     * comparable</em> by the given comparator: {@code comparator.compare(k1,
     * k2)} must not throw a {@code ClassCastException} for any keys
     * {@code k1} and {@code k2} in the map.  If the user attempts to put
     * a key into the map that violates this constraint, the {@code put(Object
     * key, Object value)} call will throw a
     * {@code ClassCastException}.
     *
     * @param comparator the comparator that will be used to order this map.
     *        If {@code null}, the {@linkplain Comparable natural
     *        ordering} of the keys will be used.
     */
    public TreeMap(Comparator<? super K> comparator) {
        this.comparator = comparator;
    }
    
    /**
     * Constructs a new tree map containing the same mappings as the given
     * map, ordered according to the <em>natural ordering</em> of its keys.
     * All keys inserted into the new map must implement the {@link
     * Comparable} interface.  Furthermore, all such keys must be
     * <em>mutually comparable</em>: {@code k1.compareTo(k2)} must not throw
     * a {@code ClassCastException} for any keys {@code k1} and
     * {@code k2} in the map.  This method runs in n*log(n) time.
     *
     * @param  m the map whose mappings are to be placed in this map
     * @throws ClassCastException if the keys in m are not {@link Comparable},
     *         or are not mutually comparable
     * @throws NullPointerException if the specified map is null
     */
    public TreeMap(Map<? extends K, ? extends V> m) {
        comparator = null;
        putAll(m);
    }
    
    /**
     * Constructs a new tree map containing the same mappings and
     * using the same ordering as the specified sorted map.  This
     * method runs in linear time.
     *
     * @param  m the sorted map whose mappings are to be placed in this map,
     *         and whose comparator is to be used to sort this map
     * @throws NullPointerException if the specified map is null
     */
    public TreeMap(SortedMap<K, ? extends V> m) {
        comparator = m.comparator();
        try {
            buildFromSorted(m.size(), m.entrySet().iterator(), null, null);
        } catch (java.io.IOException cannotHappen) {
        } catch (ClassNotFoundException cannotHappen) {
        }
    }
    ###2.2 put方法
    /*
    * Associates the specified value with the specified key in this map.
    * If the map previously contained a mapping for the key, the old
    * value is replaced.
    *
            * @param key key with which the specified value is to be associated
    * @param value value to be associated with the specified key
    *
            * @return the previous value associated with {@code key}, or
    *         {@code null} if there was no mapping for {@code key}.
            *         (A {@code null} return can also indicate that the map
    *         previously associated {@code null} with {@code key}.)
            * @throws ClassCastException if the specified key cannot be compared
    *         with the keys currently in the map
    * @throws NullPointerException if the specified key is null
            *         and this map uses natural ordering, or its comparator
    *         does not permit null keys
    */
    }
    public V put(K key, V value) {
        Entry<K,V> t = root;
        if (t == null) { //空树,插入根节点
            compare(key, key); // type (and possibly null) check
    
            root = new Entry<>(key, value, null);
            size = 1;
            modCount++;
            return null;
        }
        int cmp;
        Entry<K,V> parent; //父节点
        // split comparator and comparable paths
        Comparator<? super K> cpr = comparator;
        if (cpr != null) { //如果有自定义的比较器则使用自定义比较器比较key
            do {
                parent = t;
                cmp = cpr.compare(key, t.key); //首先比较父节点
                if (cmp < 0) //比父节点小,则比较左孩子
                    t = t.left;
                else if (cmp > 0) //比父节点大比较则比较右孩子
                    t = t.right;
                else
                    return t.setValue(value); //键相同则替换原value
            } while (t != null); //t==null时则找到要插入的节点
        }
        else {
            if (key == null) //同上
                throw new NullPointerException();
            @SuppressWarnings("unchecked")
            Comparable<? super K> k = (Comparable<? super K>) key;
            do {
                parent = t;
                cmp = k.compareTo(t.key);
                if (cmp < 0)
                    t = t.left;
                else if (cmp > 0)
                    t = t.right;
                else
                    return t.setValue(value);
            } while (t != null);
        }
        Entry<K,V> e = new Entry<>(key, value, parent); //插入的节点
        if (cmp < 0) //比较为小于0,则将新节点设为上一个t的左孩子,反之右孩子
            parent.left = e;
        else
            parent.right = e;
        fixAfterInsertion(e); //恢复红黑数的特性
        size++;
        modCount++;
        return null;
    }

###  2.3 get方法

    
    
    /**
     * Returns the value to which the specified key is mapped,
     * or {@code null} if this map contains no mapping for the key.
     *
     * <p>More formally, if this map contains a mapping from a key
     * {@code k} to a value {@code v} such that {@code key} compares
     * equal to {@code k} according to the map's ordering, then this
     * method returns {@code v}; otherwise it returns {@code null}.
     * (There can be at most one such mapping.)
     *
     * <p>A return value of {@code null} does not <em>necessarily</em>
     * indicate that the map contains no mapping for the key; it's also
     * possible that the map explicitly maps the key to {@code null}.
     * The {@link #containsKey containsKey} operation may be used to
     * distinguish these two cases.
     *
     * @throws ClassCastException if the specified key cannot be compared
     *         with the keys currently in the map
     * @throws NullPointerException if the specified key is null
     *         and this map uses natural ordering, or its comparator
     *         does not permit null keys
     */
    public V get(Object key) {
        Entry<K,V> p = getEntry(key);
        return (p==null ? null : p.value);
    }
    
    final Entry<K,V> getEntry(Object key) {
        // Offload comparator-based version for sake of performance
        if (comparator != null)
            return getEntryUsingComparator(key); //有比较器,大部分情况下都是没有比较器的,所以拆出来
        if (key == null)
            throw new NullPointerException();
        @SuppressWarnings("unchecked")
        Comparable<? super K> k = (Comparable<? super K>) key;
        Entry<K,V> p = root;
        while (p != null) {
            int cmp = k.compareTo(p.key);
            if (cmp < 0)
                p = p.left;
            else if (cmp > 0)
                p = p.right;
            else
                return p;
        }
        return null;
    }
    
    /**
     * Version of getEntry using comparator. Split off from getEntry
     * for performance. (This is not worth doing for most methods,
     * that are less dependent on comparator performance, but is
     * worthwhile here.)
     */
    final Entry<K,V> getEntryUsingComparator(Object key) {
        @SuppressWarnings("unchecked")
        K k = (K) key;
        Comparator<? super K> cpr = comparator;
        if (cpr != null) {
            Entry<K,V> p = root;
            while (p != null) {
                int cmp = cpr.compare(k, p.key);
                if (cmp < 0)
                    p = p.left;
                else if (cmp > 0)
                    p = p.right;
                else
                    return p;
            }
        }
        return null;
    }

2.4 remove方法

    
    
    /**
     * Removes the mapping for this key from this TreeMap if present.
     *
     * @param  key key for which mapping should be removed
     * @return the previous value associated with {@code key}, or
     *         {@code null} if there was no mapping for {@code key}.
     *         (A {@code null} return can also indicate that the map
     *         previously associated {@code null} with {@code key}.)
     * @throws ClassCastException if the specified key cannot be compared
     *         with the keys currently in the map
     * @throws NullPointerException if the specified key is null
     *         and this map uses natural ordering, or its comparator
     *         does not permit null keys
     */
    public V remove(Object key) {
        Entry<K,V> p = getEntry(key); //获取节点
        if (p == null)
            return null;
    
        V oldValue = p.value;
        deleteEntry(p); //删除节点
        return oldValue;
    }
    
    /**
     * Delete node p, and then rebalance the tree.
     */
    private void deleteEntry(Entry<K,V> p) {
        modCount++;
        size--;
    
        // If strictly internal, copy successor's element to p and then make p
        // point to successor.
        if (p.left != null && p.right != null) { //有左右孩子, 则将后继节点的值复制给父节点,然后处理他的后继节点
            Entry<K,V> s = successor(p); //获取后继节点
            p.key = s.key;
            p.value = s.value;
            p = s;
        } // p has 2 children
    
        // Start fixup at replacement node, if it exists.
        Entry<K,V> replacement = (p.left != null ? p.left : p.right);
    
        if (replacement != null) { //后继节点有子节点
            // Link replacement to parent
            replacement.parent = p.parent; //将 后继节点的子节点的父节点 设置为后继节点的父节点
            if (p.parent == null) //后继节点为根节点
                root = replacement;
            else if (p == p.parent.left)
                p.parent.left  = replacement;
            else
                p.parent.right = replacement;
    
            // Null out links so they are OK to use by fixAfterDeletion.
            p.left = p.right = p.parent = null; //删除掉后继节点, help GC
    
            // Fix replacement
            if (p.color == BLACK) //如果后继节点的颜色为黑色
                //根据红黑树的特性"从一个节点到该节点的子孙节点的所有路径上包含相同数目的黑节点", 删除的黑节点,会破坏平衡性
                fixAfterDeletion(replacement); //重新染色, 平衡的红黑树
        } else if (p.parent == null) { // return if we are the only node.
            root = null;
        } else { //  No children. Use self as phantom replacement and unlink.
            if (p.color == BLACK)
                fixAfterDeletion(p);
    
            if (p.parent != null) {
                if (p == p.parent.left)
                    p.parent.left = null;
                else if (p == p.parent.right)
                    p.parent.right = null;
                p.parent = null;
            }
        }
    }
    
    /**
     * 红黑树的后继节点为
     * 1 如果有右孩子, 则为右孩子的最深左孩子
     * 2 如果没有右孩子, 则为最浅的以t为右子树节点的节点
     * Returns the successor of the specified Entry, or null if no such.
     */
    static <K,V> TreeMap.Entry<K,V> successor(Entry<K,V> t) {
        if (t == null)
            return null;
        else if (t.right != null) {
            Entry<K,V> p = t.right;
            while (p.left != null)
                p = p.left;
            return p;
        } else {
            Entry<K,V> p = t.parent;
            Entry<K,V> ch = t;
            while (p != null && ch == p.right) {
                ch = p;
                p = p.parent;
            }
            return p;
        }
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/3310928.html
](http://www.cnblogs.com/skywang12345/p/3310928.html)

[2] [ http://blog.csdn.net/ns_code/article/details/36421085
](http://blog.csdn.net/ns_code/article/details/36421085)

