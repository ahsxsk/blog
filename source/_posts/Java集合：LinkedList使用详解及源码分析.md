title: Java集合：LinkedList使用详解及源码分析
date: 2017-11-11 13:09:04
tags: [Java集合]
------------------

##  1 使用方法

LinkedList基于双端链表实现，可以作为栈、队列或者双端队列使用。

    
    
    public class LinkedList<E>
        extends AbstractSequentialList<E>
        implements List<E>, Deque<E>, Cloneable, java.io.Serializable

LinkedList继承了AbstractSequentialList，实现了get等方法；  
LinkedList实现了Deque接口，可以作为双端队列使用；  
LinkedList实现Cloneable接口重写了接口定义的clone()方法，可以使用clone()复制链表。  
LinkedList实现 java.io.Serializable接口使LinkedList支持序列化。

##  1.1 方法介绍

LinkedList提供了增加，弹出，获取元素等操作，具体提供的方法如下：

    
    
    boolean       add(E object)  //在末尾增加一个元素
    void          add(int location, E object) //在指定位置增加元素
    boolean       addAll(Collection<? extends E> collection) //在末尾加入一组元素
    boolean       addAll(int location, Collection<? extends E> collection) //从指定位置开始加一组元素
    void          addFirst(E object) //在表头增加一个元素
    void          addLast(E object) //在表尾增加一个元素
    void          clear() //清空链表
    Object        clone() //复制一个元素
    boolean       contains(Object object) //判断是否包含object
    Iterator<E>   descendingIterator() //逆序迭代器
    E             element() //获取链表第一个元素,不存在会抛出异常
    E             get(int location) //获取location位置的元素,不存在会抛出异常
    E             getFirst() //获取链表第一个元素,不存在会抛出异常
    E             getLast() //获取链表最后一个元素,不存在会抛出异常
    int           indexOf(Object object) //获取object第一次出现的位置
    int           lastIndexOf(Object object) //获取object最后一次出现的位置
    ListIterator<E>     listIterator(int location) //从location开始的迭代器
    boolean       offer(E o) //在末尾增加一个元素
    boolean       offerFirst(E e) //在表头增加一个元素
    boolean       offerLast(E e) //在表尾增加一个元素
    E             peek() //获取表头元素,不存在不会抛出异常
    E             peekFirst() //获取表头元素,不存在不会抛出异常
    E             peekLast() //获取表尾元素,不存在不会抛出异常
    E             poll() //弹出表头元素
    E             pollFirst() //弹出表头元素
    E             pollLast() //弹出表尾元素
    E             pop() //弹出表头元素,不存在会抛异常
    void          push(E e) //在表头增加一个元素
    E             remove() //删除最后一个元素
    E             remove(int location) //删除location位置的元素
    boolean       remove(Object object) //删除第一个出现的object
    E             removeFirst() //删除第一个元素
    boolean       removeFirstOccurrence(Object o) //删除第一个出现的o
    E             removeLast() //删除最后一个元素
    boolean       removeLastOccurrence(Object o) //删除最后一个出现的o
    E             set(int location, E object) //将location位置设置为object
    int           size() //链表大小
    <T> T[]       toArray(T[] contents) //转换为T类型的数组
    Object[]     toArray() //转换为Object类型的数组

###  1.2 使用示例

    
    
    public class TestLinkedList {
        public void testLinkedList() throws Exception {
            LinkedList<String> linkedList = new LinkedList<String>();
            linkedList.add("a"); //在表尾增加元素
            linkedList.add("b");
            printLinkedList(linkedList);
            linkedList.addFirst("pre-a"); //在表头增加元素
            System.out.println("链表中包含 'a' 元素:" + linkedList.contains("a")); //包含元素判断
            System.out.println("链表的第一个元素: " + linkedList.peek());
            System.out.println("链表的最后一个元素: " + linkedList.peekLast());
            printLinkedList(linkedList);
            System.out.println("获取删除链表的第一个元素: " + linkedList.poll());
            printLinkedList(linkedList);
            System.out.println("获取并弹出链表的最后一个元素" + linkedList.pollLast());
            printLinkedList(linkedList);
            linkedList.offer("d");
            linkedList.offer("e");
            linkedList.offer("f");
            printLinkedList(linkedList);
            System.out.println("第三个元素为: " + linkedList.get(2)); //获取第三个元素
            System.out.println("将第四个元素设置为g: " + linkedList.set(3, "g"));
            printLinkedList(linkedList);
            //转换成数组
            String[] arr = (String[]) linkedList.toArray(new String[0]);
            for (String e: arr) {
                System.out.print(e + " ");
            }
        }
    
        protected void printLinkedList(LinkedList<String> linkedList) {
            Iterator<String> iterator = linkedList.iterator();
            System.out.print("linkList包含的元素有: ");
            while (iterator.hasNext()) {
                System.out.print(iterator.next() + " ");
            }
            System.out.println("\n");
        }
    }

运行结果如下：

    
    
    linkList包含的元素有: a b
    
    链表中包含 'a' 元素:true
    链表的第一个元素: pre-a
    链表的最后一个元素: b
    linkList包含的元素有: pre-a a b
    
    获取删除链表的第一个元素: pre-a
    linkList包含的元素有: a b
    
    获取并弹出链表的最后一个元素b
    linkList包含的元素有: a
    
    linkList包含的元素有: a d e f
    
    第三个元素为: e
    将第四个元素设置为g: f
    linkList包含的元素有: a d e g
    
    a d e g 

##  2 源码分析

###  2.1 add方法

    
    
    public boolean add(E e) { //在末尾增加一个元素
        linkLast(e);
        return true;
    }
    
    void linkLast(E e) {
        final Node<E> l = last; //末尾元素
        final Node<E> newNode = new Node<>(l, e, null); //申请一个值为e的元素,前一个元素为l,后一个为null
        last = newNode; //新元素为最后一个元素
        if (l == null) //空链表
            first = newNode;
        else
            l.next = newNode;
        size++; //链表长度增加
        modCount++;
    }

###  2.2 addFirst方法

    
    
    public void addFirst(E e) { //在表头增加元素
        linkFirst(e);
    }
    
    private void linkFirst(E e) {
        final Node<E> f = first; //表头元素
        final Node<E> newNode = new Node<>(null, e, f); //申请一个值为e的元素,前一个元素为null,后一个元素为f
        first = newNode; //新元素为表头元素
        if (f == null) //空链表
            last = newNode;
        else
            f.prev = newNode;
        size++; //长度增加
        modCount++;
    }

###  2.3 peek方法

    
    
    public E peek() {
            final Node<E> f = first; //获取表头元素
            return (f == null) ? null : f.item; //返回null或者表头元素的值
    }

###  2.4 poll方法

    
    
    public E poll() {
        final Node<E> f = first;
        return (f == null) ? null : unlinkFirst(f);
    }
    
    private E unlinkFirst(Node<E> f) {
        // assert f == first && f != null;
        final E element = f.item; //获取第一个元素的值
        final Node<E> next = f.next; //获取第二个元素
        f.item = null; //将第一个元素置为null
        f.next = null; // help GC,
        first = next; //将原有的第二个元素设为头元素
        if (next == null) //原链表只有一个元素,此时链表为空
            last = null;
        else
            next.prev = null; //头元素的前置元素为null
        size--;
        modCount++;
        return element;
    }

###  2.5 toArray(T[] contents) 方法

    
    
    public <T> T[] toArray(T[] a) {
        if (a.length < size) //a长度小于链表长度,则重新申请一个长度为size的数组
            a = (T[])java.lang.reflect.Array.newInstance(
                    a.getClass().getComponentType(), size);
        int i = 0;
        Object[] result = a;
        for (Node<E> x = first; x != null; x = x.next) //为数组赋值
            result[i++] = x.item;
    
        if (a.length > size) //如果长度大于链表长度,最后一个元素后一个设为null,表示数组结束
            a[size] = null;
    
        return a;
    }

##  参考：

[1] [ http://blog.csdn.net/crave_shy/article/details/17440835
](http://blog.csdn.net/crave_shy/article/details/17440835)  
[2] [ http://blog.csdn.net/wanghao109/article/details/13287877
](http://blog.csdn.net/wanghao109/article/details/13287877)  
[3] [ http://fjohnny.iteye.com/blog/696750
](http://fjohnny.iteye.com/blog/696750)

