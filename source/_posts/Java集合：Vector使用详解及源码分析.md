Java集合：Vector使用详解及源码分析

##  1 使用方法

Vector和ArrayList类似，是数组队列，可以实现容量的动态增长。Vector类继承了AbstractList抽象类并且实现了List、Random
Access，Cloneable以及java.io.Serializable接口。  
public class ArrayList extends AbstractList implements List, RandomAccess,
Cloneable, java.io.Serializable  
AbstractList类继承了AbstractCollection类并实现了List接口。  
实现RandomAccess接口使Vector拥有随机访问的能力，即通过下表索引访问数组元素。  
实现Cloneable接口重写了接口定义的clone()方法，Vector可以使用clone()复制数组。  
实现 java.io.Serializable接口使Vector支持序列化。  
** Vector和ArrayList的最大不同是Vector是线程安全的而ArrayList不是。Vector几乎所有的方法都使用synchronized关键字是来保证线程安全使它的性能比不上ArrayList。 **   
** Vector和ArrayList不同还体现在动态增长的策略上。ArrayList的基本增长策略是oldCapacity*1.5+1，如果还不够则容量为实际需要容量；Vector的基本增长策略是oldCapacity+设定好的增长幅度，如果没设定则新容量增长为oldCapacity*2，如果还不够则为实际需要的容量。 **   
现在很少使用Vector。

##  1.1 方法介绍

ArrayList提供了增加、删除、判空等操作，具体提供的方法如下：

    
    
    synchronized boolean        add(E object) //增加元素
    void                        add(int location, E object) //指定位置增加元素
    synchronized boolean        addAll(Collection<? extends E> collection) //将集合中的元素加入到数组的最后
    synchronized boolean        addAll(int location, Collection<? extends E> collection) //指定位置增加一盒中所有元素
    synchronized void           addElement(E object) //增加元素
    synchronized int            capacity() //数组容量
    void                        clear() //清空数组
    synchronized Object         clone() //复制元素
    boolean                     contains(Object object) //判断是否包含元素
    synchronized boolean        containsAll(Collection<?> collection) //判断是否包含集合中所有元素
    synchronized void           copyInto(Object[] elements) //将数组中的元素复制到element中
    synchronized E              elementAt(int location) //获取location位置的元素
    Enumeration<E>              elements() //返回一个包含数组元素的枚举
    synchronized void           ensureCapacity(int minimumCapacity) //增加数组空间
    synchronized boolean        equals(Object object) //比较元素
    synchronized E              firstElement() //获取第一个元素
    E                           get(int location) //获取location下标的元素
    synchronized int            hashCode() //获取对象的hashCode
    synchronized int            indexOf(Object object, int location) //从location开始第一次出现object的位置
    int                         indexOf(Object object) //第一次出现object的位置
    synchronized void           insertElementAt(E object, int location) //在location位置插入object
    synchronized boolean        isEmpty() //判空
    synchronized E              lastElement() //获取最后元素
    synchronized int            lastIndexOf(Object object, int location) //location之前最后出现object的位置
    synchronized int            lastIndexOf(Object object) //最后一次出现object的位置
    synchronized E              remove(int location) //删除location位置的元素
    boolean                     remove(Object object) //删除第一次出现的object
    synchronized boolean        removeAll(Collection<?> collection) //删除collection出现的所有元素
    synchronized void           removeAllElements() //将所有元素置为null
    synchronized boolean        removeElement(Object object) //同remove
    synchronized void           removeElementAt(int location) //同remove
    synchronized boolean        retainAll(Collection<?> collection) //删除除了collection中元素之外的所有元素
    synchronized E              set(int location, E object) //设置location位置的元素为object
    synchronized void           setElementAt(E object, int location) //同set
    synchronized void           setSize(int length) //设置数组大小,若length大于实际长度则空余元素置为null
    synchronized int            size() //获取实际大小
    synchronized List<E>        subList(int start, int end) //获取子串
    synchronized <T> T[]        toArray(T[] contents) //转换成数组
    synchronized Object[]       toArray() //
    synchronized void           trimToSize() //将数组容量改为实际数组大小

###  1.2 使用示例

    
    
    public class TestVector {
        public void testVector() {
            Vector vector = new Vector<>(10); //申请一个初始容量大小为10的Vector
            for (int i = 0; i < 5; i++) { //初始化元素为
                vector.add(i);
            }
            System.out.println("此时数组实际大小为: " + vector.size());
            printVector("Vector此时元素有", vector);
            vector.set(4,44); //设置第5个元素为44
            vector.add(2,22); //在第3个元素位置增加22
            printVector("Vector此时元素有", vector);
            vector.add(2);
            System.out.println("第1次出现2的位置为: " + vector.indexOf(2));
            vector.remove(2); //删除第3个元素
            vector.remove((Object)44); //删除第一次出现的44
            printVector("Vector此时元素有", vector);
            int size = vector.size();
            for (int i = size; i < size + 6; i++) {
                vector.add(i);
            }
            printVector("Vector此时元素有", vector);
            System.out.println("Vector此时大小为: " +  vector.size());
            System.out.println("Vector此时的容量为: " + vector.capacity()); //原有容量为10, 超出容量后新容量为2倍
    
            //转为数组
            Integer [] arr = (Integer[]) vector.toArray(new Integer[0]);
            System.out.print("遍历数组结果: ");
            for (Integer i:arr) {
                System.out.print(i + " ");
            }
        }
    
        /**
         * 打印Vector
         * @param vector
         */
        protected void printVector(String comment, List vector) {
            System.out.print(comment + ": ");
            for (int i = 0; i < vector.size(); i++) {
                System.out.print(vector.get(i) + " ");
            }
            System.out.println("");
        }
    }

运行结果如下：

    
    
    此时数组实际大小为: 5
    Vector此时元素有: 0 1 2 3 4
    Vector此时元素有: 0 1 22 2 3 44
    第1次出现2的位置为: 3
    Vector此时元素有: 0 1 2 3 2
    Vector此时元素有: 0 1 2 3 2 5 6 7 8 9 10
    Vector此时大小为: 11
    Vector此时的容量为: 20
    遍历数组结果: 0 1 2 3 2 5 6 7 8 9 10

##  2 源码分析

###  2.1构造函数

    
    
    /**
     * 构造一个初始容量为initialCapacity,动态增长为capacityIncrement的Vector
     * @param initialCapacity
     * @param capacityIncrement
     */
    public Vector(int initialCapacity, int capacityIncrement) {
        super();
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal Capacity: "+
                    initialCapacity);
        this.elementData = new Object[initialCapacity];
        this.capacityIncrement = capacityIncrement;
    }
    
    /**
     * 初始容量为initialCapacity,动态增长容量为0
     * @param initialCapacity
     */
    public Vector(int initialCapacity) {
        this(initialCapacity, 0);
    }
    
    /**
     * 初始容量为10,动态增长为0
     */
    public Vector() {
        this(10);
    }
    
    /**
     * 申请一个Vector,并用c初始化
     * @param c
     */
    public Vector(Collection<? extends E> c) {
        elementData = c.toArray();
        elementCount = elementData.length;
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class) //bug 6260652,toArray可能不会返回Object数组,这是重新复制
            elementData = Arrays.copyOf(elementData, elementCount, Object[].class);
    }

###  2.2 add方法

    
    
    /**
     * 添加e到Vector末尾
     * @param e
     * @return
     */
    public synchronized boolean add(E e) {
        modCount++;
        ensureCapacityHelper(elementCount + 1); //增加容量
        elementData[elementCount++] = e;
        return true;
    }
    
    /**
     * 在index位置插入element
     * @param index
     * @param element
     */
    public void add(int index, E element) {
        insertElementAt(element, index);
    }
    
    /**
     * 在index位置插入obj
     * @param obj
     * @param index
     */
    public synchronized void insertElementAt(E obj, int index) {
        modCount++;
        if (index > elementCount) {
            throw new ArrayIndexOutOfBoundsException(index
                    + " > " + elementCount);
        }
        ensureCapacityHelper(elementCount + 1);
         //将elementData元素从index开始，复制到elementData的index+1开始，总共          elementCount - index长度，即后移1位
        System.arraycopy(elementData, index, elementData, index + 1, elementCount - index);
        elementData[index] = obj;
        elementCount++;
    }

###  2.3 set方法

    
    
    /**
     * 将index位置的元素置为element
     * @param index
     * @param element
     * @return
     */
    public synchronized E set(int index, E element) {
        if (index >= elementCount)
            throw new ArrayIndexOutOfBoundsException(index);
    
        E oldValue = elementData(index);
        elementData[index] = element;
        return oldValue;
    }

###  2.4 remove方法

    
    
    /**
     * 删除index位置的元素
     * @param index
     * @return
     */
    public synchronized E remove(int index) {
        modCount++;
        if (index >= elementCount)
            throw new ArrayIndexOutOfBoundsException(index);
        E oldValue = elementData(index); //获取元素
    
        int numMoved = elementCount - index - 1;
        if (numMoved > 0) //不是删除最后一个元素,则所有元素前移1位
            System.arraycopy(elementData, index+1, elementData, index,
                    numMoved);
        elementData[--elementCount] = null; // Let gc do its work
    
        return oldValue;
    }

###  2.5 toArray方法

    
    
    /**
     * 返回T类型的数组,参数不能是基本类型
     * @param a
     * @param <T>
     * @return
     */
    public synchronized <T> T[] toArray(T[] a) {
        if (a.length < elementCount) //a长度小于Vector已有的元素个数,重新申请一个数组
            return (T[]) Arrays.copyOf(elementData, elementCount, a.getClass());
    
        System.arraycopy(elementData, 0, a, 0, elementCount); //将元素复制到a中
    
        if (a.length > elementCount)
            a[elementCount] = null;
    
        return a;
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/3308833.html
](http://www.cnblogs.com/skywang12345/p/3308833.html)  
[2] [ http://blog.csdn.net/ns_code/article/details/35793865
](http://blog.csdn.net/ns_code/article/details/35793865)  
[3] [ http://blog.csdn.net/mazhimazh/article/details/19568867
](http://blog.csdn.net/mazhimazh/article/details/19568867)

