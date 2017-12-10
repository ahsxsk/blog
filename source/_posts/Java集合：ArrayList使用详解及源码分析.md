Java集合：ArrayList使用详解及源码分析

##  1 使用方法

ArrayList是数组队列，可以实现容量的动态增长。ArrayList类继承了AbstractList抽象类并且实现了List、RandomAccess，
Cloneable以及java.io.Serializable接口。  
public class ArrayList extends AbstractList implements List, RandomAccess,
Cloneable, java.io.Serializable  
AbstractList类继承了AbstractCollection类并实现了List接口。  
实现RandomAccess接口使ArrayList拥有随机访问的能力，即通过下表索引访问数组元素。  
实现Cloneable接口重写了接口定义的clone()方法，ArrayList可以使用clone()复制数组。  
实现 java.io.Serializable接口使ArrayList支持序列化。

##  1.1 方法介绍

ArrayList提供了增加、删除、判空等操作，具体提供的方法如下：

    
    
    // Collection中定义的API
    boolean             add(E object)  //增加元素
    boolean             addAll(Collection<? extends E> collection) //复制另一个Collection中的所有元素
    void                clear() //清空数组
    boolean             contains(Object object) //判断数组中是否包含object
    boolean             containsAll(Collection<?> collection) //判断另一个数组是否是这个数组的子集
    boolean             equals(Object object) //判断元素是否相等
    int                 hashCode() //获取hash code
    boolean             isEmpty() //判空
    Iterator<E>         iterator() //迭代器
    boolean             remove(Object object) //删除元素
    boolean             removeAll(Collection<?> collection)  //删除collection包含的元素
    boolean             retainAll(Collection<?> collection) //保留collection包含的元素
    int                 size() //获取数组大小
    <T> T[]             toArray(T[] array)  //转换成T类型的数组
    Object[]            toArray() //转换成Object类型的数组
    // AbstractCollection中定义的API
    void                add(int location, E object) //指定位置增加元素
    boolean             addAll(int location, Collection<? extends E> collection) //指定位置开始增加多个元素
    E                   get(int location) //获取location位置的元素
    int                 indexOf(Object object) //获取object首次出现的位置
    int                 lastIndexOf(Object object) //获取object最后一次出现的位置
    ListIterator<E>     listIterator(int location) //迭代器，从location起始
    ListIterator<E>     listIterator() //迭代器
    E                   remove(int location) //删除location位置的元素
    E                   set(int location, E object) //重置location位置的元素为object
    List<E>             subList(int start, int end) //获取[start, end)之间的元素
    // ArrayList新增的API
    Object               clone() //复制元素
    void                 ensureCapacity(int minimumCapacity) //最低容量
    void                 trimToSize() //修剪数组大小为当前元素个数
    void                 removeRange(int fromIndex, int toIndex) //删除[fromIndex, toIndex)之间的元素

###  1.2 使用示例

    
    
    package com;
    
    import java.util.ArrayList;
    import java.util.Iterator;
    import java.util.List;
    
    public class Main {
    
        public static void main(String[] args) {
       // write your code here
            List list = new ArrayList<>(20); //申请一个初始容量为20的ArrayList
            String element; //要填充的元素
            for (int i = 0; i < 10; i++) {
                element = "num-" + i;
                list.add(element); // 填充list
            }
            list.add(10, "num-10"); //在指定位置增加元素
    
            //使用Iterator遍历list
            for (Iterator iter = list.iterator(); iter.hasNext();) {
                System.out.print(iter.next() + " ");
            }
            System.out.println(" ");
    
            System.out.println("The second element is: " + list.get(1)); //获取第2个元素
            System.out.println("array size is: " + list.size()); //获取list大小
            System.out.println("is array list contains num-15:" + list.contains("num-15")); //判断list是否含有num-15
            list.set(2,"num-3-1"); //将第三个元素设置为num-3-1
    
            String[] arr = (String[])list.toArray(new String[0]); //将ArrayList转换为数组
            for (String str:arr) { //遍历数组
                System.out.print(str + " ");
            }
        }
    }

运行结果如下：

    
    
    num-0 num-1 num-2 num-3 num-4 num-5 num-6 num-7 num-8 num-9 num-10
    The second element is: num-1
    array size is: 11
    is array list contains num-15:false
    num-0 num-1 num-3-1 num-3 num-4 num-5 num-6 num-7 num-8 num-9 num-10

##  2 源码分析

###  2.1构造函数

ArrayList有三个构造函数，提供三种创建ArrayList实例的方法。

    
    
    /**
     * 获取一个初始长度为initialCapacity的空ArrayList
     * @param initialCapacity
     */
    public ArrayList(int initialCapacity) {
        if (initialCapacity > 0) {
            this.elementData = new Object[initialCapacity];
        } else if (initialCapacity == 0) {
            this.elementData = EMPTY_ELEMENTDATA;
        } else {
            throw new IllegalArgumentException("Illegal Capacity: "+
                    initialCapacity);
        }
    }
    
    /**
     * 返回一个空ArrayList
     */
    public ArrayList() {
        this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
    }
    
    /**
     * 返回一个用ArrayList,并且用集合c进行初始化
     * @param c
     */
    public ArrayList(Collection<? extends E> c) {
        elementData = c.toArray();
        if ((size = elementData.length) != 0) {
            // c.toArray might (incorrectly) not return Object[] (see 6260652)
            if (elementData.getClass() != Object[].class)
                elementData = Arrays.copyOf(elementData, size, Object[].class);
        } else {
            // replace with empty array.
            this.elementData = EMPTY_ELEMENTDATA;
        }
    }

###  2.2 add方法

    
    
    /**
     * 增加元素
     * @param e
     * @return
     */
    public boolean add(E e) {
        ensureCapacityInternal(size + 1);  // 确定ArrayList长度
        elementData[size++] = e; //向数组中增加元素
        return true;
    }

###  2.3 remove方法

    
    
    /**
     * 删除元素
     * @param index
     * @return
     */
    public E remove(int index) {
        rangeCheck(index); //检查下标是否合法
    
        modCount++;
        E oldValue = elementData(index); //获取删除的元素
    
        int numMoved = size - index - 1;
        if (numMoved > 0) //移动元素
            System.arraycopy(elementData, index+1, elementData, index,
                    numMoved);
        elementData[--size] = null; // clear to let GC do its work
    
        return oldValue;
    }

###  2.4 toArray方法

toArray有两个重载方法，一个不带参数返回Object数字，另一个带参数，返回任意类型的数组。

    
    
    /**
     * 返回Object对象的数组
     * @return
     */
    public Object[] toArray() {
        return Arrays.copyOf(elementData, size);
    }
    
    /**
     * 返回任意对象类型的数组
     * @param a
     * @param <T>
     * @return
     */
    public <T> T[] toArray(T[] a) {
        if (a.length < size) //传入数组大小小于size时,直接返回一个新数组
            // Make a new array of a's runtime type, but my contents:
            return (T[]) Arrays.copyOf(elementData, size, a.getClass());
        System.arraycopy(elementData, 0, a, 0, size); //传入数组大小大于size,将ArrayList中的内容复制到数组中
        if (a.length > size)
            a[size] = null;
        return a;
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/3308556.html
](http://www.cnblogs.com/skywang12345/p/3308556.html)  
[2] [ http://blog.chinaunix.net/uid-29702073-id-4334609.html
](http://blog.chinaunix.net/uid-29702073-id-4334609.html)  
[3] [ http://www.cnblogs.com/hzmark/archive/2012/12/20/ArrayList.html
](http://www.cnblogs.com/hzmark/archive/2012/12/20/ArrayList.html)

