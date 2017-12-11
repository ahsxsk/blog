title: Java字符串：StringBuffer使用详解及源码分析
date: 2017-11-11 13:09:04
tags: [Java字符串]
------------------

##  1 使用方法

StringBuffer和StringBuilder功能基本相同，他们的区别在于StringBuffer是线程安全的而StringBuilder不是线程安全
的。他们的关系和HashMap-Hashtable、Vector-ArrrayList类似。

    
    
    public final class StringBuffer
            extends AbstractStringBuilder
            implements java.io.Serializable, CharSequence{}

StringBuffer和StringBuilder一样继承了AbstractStringBuilder并且实现了Serializable和CharSequ
ence。

##  1.1 方法介绍

StringBuffer提供的的API主要如下：

    
    
    //构造函数
    StringBuffer()
    StringBuffer(int capacity)
    StringBuffer(String string)
    StringBuffer(CharSequence cs)
    //追加
    synchronized StringBuffer     append(boolean b)
    synchronized StringBuffer     append(int i)
    synchronized StringBuffer     append(long l)
    synchronized StringBuffer     append(float f)
    synchronized StringBuffer     append(double d)
    synchronized StringBuffer     append(char ch)
    synchronized StringBuffer     append(char[] chars)
    synchronized StringBuffer     append(char[] chars, int start, int length)
    synchronized StringBuffer     append(Object obj)
    synchronized StringBuffer     append(String string)
    synchronized StringBuffer     append(StringBuffer sb)
    synchronized StringBuffer     append(CharSequence s)
    synchronized StringBuffer     append(CharSequence s, int start, int end)
    synchronized StringBuffer     appendCodePoint(int codePoint)
    synchronized int     capacity() //获取容量
    synchronized char     charAt(int index) //获取index下标的字符
    synchronized int     codePointAt(int index) //获取index下标的Unicode编码
    synchronized int     codePointBefore(int index)
    synchronized int     codePointCount(int beginIndex, int endIndex)
    synchronized StringBuffer     delete(int start, int end) //删除[start,end)的字符
    synchronized StringBuffer     deleteCharAt(int location) //删除location下标的字符
    synchronized void     ensureCapacity(int min) //确认货增加容量(length*2 + 2)
    synchronized void     getChars(int start, int end, char[] buffer, int idx) //将[start,end)中的字符添加的buffer的idx及以后的位置
    synchronized int     indexOf(String subString, int start) //获取提一次出现的位置
    int     indexOf(String string) //通过调用其他同步方法实现同步
    //插入字符串
    StringBuffer     insert(int index, boolean b)
    StringBuffer     insert(int index, int i)
    StringBuffer     insert(int index, long l)
    StringBuffer     insert(int index, float f)
    StringBuffer     insert(int index, double d)
    synchronized StringBuffer     insert(int index, char ch)
    synchronized StringBuffer     insert(int index, char[] chars)
    synchronized StringBuffer     insert(int index, char[] chars, int start, int length)
    synchronized StringBuffer     insert(int index, String string)
    StringBuffer     insert(int index, Object obj)
    synchronized StringBuffer     insert(int index, CharSequence s)
    synchronized StringBuffer     insert(int index, CharSequence s, int start, int end)
    int     lastIndexOf(String string)
    synchronized int     lastIndexOf(String subString, int start)
    int     length()
    synchronized int     offsetByCodePoints(int index, int codePointOffset)
    synchronized StringBuffer     replace(int start, int end, String string) //替换
    synchronized StringBuffer     reverse() //反转
    synchronized void     setCharAt(int index, char ch) //替换指定下标的字符
    synchronized void     setLength(int length)
    synchronized CharSequence     subSequence(int start, int end)
    synchronized String     substring(int start) //子串
    synchronized String     substring(int start, int end)
    synchronized String     toString()
    synchronized void     trimToSize()

###  1.2 使用示例

    
    
    public void testStringBuffer() {
        //构造并初始化
        StringBuffer StringBuffer = new StringBuffer("0123456");
        //获取容量
        System.out.println("StringBuffer的容量为: " + StringBuffer.capacity());
        //获取字符数量
        System.out.println("StringBuffer的字符数量为: " + StringBuffer.length());
        //获取指定index的字符
        System.out.println("StringBuffer的第2个字符为: " + StringBuffer.charAt(1));
        //子串第一次出现的位置
        System.out.println("\"23\"在StringBuffer中第一次出现的位置为: " + StringBuffer.indexOf("23"));
        //子串最后一次出现的位置,从后往前
        System.out.println("\"34\"在StringBuffer从第5个字符以前的字符串中第一次一次出现的位置为: "
                + StringBuffer.lastIndexOf("34", 5));
        //替换字符串
        System.out.println("将StringBuffer的第2-3个字符替换为abcde: " + StringBuffer.replace(1, 3, "abcde"));
        //设置指定位置字符
        StringBuffer.setCharAt(1, 'A');
        System.out.println("将第2个字符设置为A: " + StringBuffer);
        //删除滴定位置的字符串
        StringBuffer.delete(2,5);
        System.out.println("删除第3到第5个字符: " + StringBuffer);
        //追加字符
        System.out.println("StringBuffer尾部追加一个7" + StringBuffer.append("7"));
        //追加double
        System.out.println("StringBuffer尾部追加8.0d" + StringBuffer.append(8.0d));
        //插入字符串
        System.out.println("StringBuffer第3个字符看是追加test: " + StringBuffer.insert(2, "test"));
        String s = null;
        System.out.println("StringBuffer第3个字符看是追加null: " + StringBuffer.insert(2, s));
    }

运行结果如下：

    
    
    StringBuffer的容量为: 23
    StringBuffer的字符数量为: 7
    StringBuffer的第2个字符为: 1
    "23"在StringBuffer中第一次出现的位置为: 2
    "34"在StringBuffer从第5个字符以前的字符串中第一次一次出现的位置为: 3
    将StringBuffer的第2-3个字符替换为abcde: 0abcde3456
    将第2个字符设置为A: 0Abcde3456
    删除第3到第5个字符: 0Ae3456
    StringBuffer尾部追加一个70Ae34567
    StringBuffer尾部追加8.0d0Ae345678.0
    StringBuffer第3个字符看是追加test: 0Ateste345678.0
    StringBuffer第3个字符看是追加null: 0Anullteste345678.0

##  2 源码分析

###  2.1构造函数

StringBuffer和StringBuilder的构造方法也几乎是相同的。

    
    
    /**
     * Constructs a string buffer with no characters in it and an
     * initial capacity of 16 characters.
     */
    public StringBuffer() {
        super(16);
    }
    
    /**
     * Constructs a string buffer with no characters in it and
     * the specified initial capacity.
     *
     * @param      capacity  the initial capacity.
     * @exception  NegativeArraySizeException  if the {@code capacity}
     *               argument is less than {@code 0}.
     */
    public StringBuffer(int capacity) {
        super(capacity);
    }
    
    /**
     * Constructs a string buffer initialized to the contents of the
     * specified string. The initial capacity of the string buffer is
     * {@code 16} plus the length of the string argument.
     *
     * @param   str   the initial contents of the buffer.
     */
    public StringBuffer(String str) {
        super(str.length() + 16);
        append(str);
    }

###  2.2 insert方法

insert方法有插入字符串、整形、布尔型等多个重载方法，实现方法都是调用父类AbstractStringBuilder的insert方法。

####  2.2.1 插入一个对象

    
    
    /**
     * @throws StringIndexOutOfBoundsException {@inheritDoc}
     */
    @Override
    public  StringBuffer insert(int offset, boolean b) {
        // Note, synchronization achieved via invocation of StringBuffer insert(int, String)
        // after conversion of b to String by super class method
        // Ditto for toStringCache clearing
        super.insert(offset, b); //调用父类的insert
        return this;
    }
    /**
     * Inserts the string representation of the {@code boolean}
     * argument into this sequence.
     * <p>
     * The overall effect is exactly as if the second argument were
     * converted to a string by the method {@link String#valueOf(boolean)},
     * and the characters of that string were then
     * {@link #insert(int,String) inserted} into this character
     * sequence at the indicated offset.
     * <p>
     * The {@code offset} argument must be greater than or equal to
     * {@code 0}, and less than or equal to the {@linkplain #length() length}
     * of this sequence.
     *
     * @param      offset   the offset.
     * @param      b        a {@code boolean}.
     * @return     a reference to this object.
     * @throws     StringIndexOutOfBoundsException  if the offset is invalid.
     */
    public AbstractStringBuilder insert(int offset, boolean b) {
        return insert(offset, String.valueOf(b)); //子类中insert(int, String),已经重写,调用子类的方法,子类已经保证同步
    }

####  2.2.2 插入一个字符串

    
    
    /**
     * @throws StringIndexOutOfBoundsException {@inheritDoc}
     */
    @Override
    public synchronized StringBuffer insert(int offset, String str) {
        toStringCache = null;
        super.insert(offset, str);
        return this;
    }
    /**
     * Inserts the string into this character sequence.
     * <p>
     * The characters of the {@code String} argument are inserted, in
     * order, into this sequence at the indicated offset, moving up any
     * characters originally above that position and increasing the length
     * of this sequence by the length of the argument. If
     * {@code str} is {@code null}, then the four characters
     * {@code "null"} are inserted into this sequence.
     * <p>
     * The character at index <i>k</i> in the new character sequence is
     * equal to:
     * <ul>
     * <li>the character at index <i>k</i> in the old character sequence, if
     * <i>k</i> is less than {@code offset}
     * <li>the character at index <i>k</i>{@code -offset} in the
     * argument {@code str}, if <i>k</i> is not less than
     * {@code offset} but is less than {@code offset+str.length()}
     * <li>the character at index <i>k</i>{@code -str.length()} in the
     * old character sequence, if <i>k</i> is not less than
     * {@code offset+str.length()}
     * </ul><p>
     * The {@code offset} argument must be greater than or equal to
     * {@code 0}, and less than or equal to the {@linkplain #length() length}
     * of this sequence.
     *
     * @param      offset   the offset.
     * @param      str      a string.
     * @return     a reference to this object.
     * @throws     StringIndexOutOfBoundsException  if the offset is invalid.
     */
    public AbstractStringBuilder insert(int offset, String str) {
        if ((offset < 0) || (offset > length()))
            throw new StringIndexOutOfBoundsException(offset);
        if (str == null)
            str = "null";
        int len = str.length();
        ensureCapacityInternal(count + len);
        System.arraycopy(value, offset, value, offset + len, count - offset);
        str.getChars(value, offset);
        count += len;
        return this;
    }

###  2.3 append方法

    
    
    public synchronized StringBuffer append(String str) {
        toStringCache = null;
        super.append(str);
        return this;
    }
    /**
     * Appends the specified string to this character sequence.
     * <p>
     * The characters of the {@code String} argument are appended, in
     * order, increasing the length of this sequence by the length of the
     * argument. If {@code str} is {@code null}, then the four
     * characters {@code "null"} are appended.
     * <p>
     * Let <i>n</i> be the length of this character sequence just prior to
     * execution of the {@code append} method. Then the character at
     * index <i>k</i> in the new character sequence is equal to the character
     * at index <i>k</i> in the old character sequence, if <i>k</i> is less
     * than <i>n</i>; otherwise, it is equal to the character at index
     * <i>k-n</i> in the argument {@code str}.
     *
     * @param   str   a string.
     * @return  a reference to this object.
     */
    public AbstractStringBuilder append(String str) {
        if (str == null)
            return appendNull();
        int len = str.length();
        ensureCapacityInternal(count + len);
        str.getChars(0, len, value, count);
        count += len;
        return this;
    }

###  2.4 replace方法

    
    
    /**
     * @throws StringIndexOutOfBoundsException {@inheritDoc}
     * @since      1.2
     */
    @Override
    public synchronized StringBuffer replace(int start, int end, String str) {
        toStringCache = null;
        super.replace(start, end, str);
        return this;
    }
    /**
     * Replaces the characters in a substring of this sequence
     * with characters in the specified {@code String}. The substring
     * begins at the specified {@code start} and extends to the character
     * at index {@code end - 1} or to the end of the
     * sequence if no such character exists. First the
     * characters in the substring are removed and then the specified
     * {@code String} is inserted at {@code start}. (This
     * sequence will be lengthened to accommodate the
     * specified String if necessary.)
     *
     * @param      start    The beginning index, inclusive.
     * @param      end      The ending index, exclusive.
     * @param      str   String that will replace previous contents.
     * @return     This object.
     * @throws     StringIndexOutOfBoundsException  if {@code start}
     *             is negative, greater than {@code length()}, or
     *             greater than {@code end}.
     */
    public AbstractStringBuilder replace(int start, int end, String str) {
        if (start < 0)
            throw new StringIndexOutOfBoundsException(start);
        if (start > count)
            throw new StringIndexOutOfBoundsException("start > length()");
        if (start > end)
            throw new StringIndexOutOfBoundsException("start > end");
    
        if (end > count)
            end = count;
        int len = str.length();
        int newCount = count + len - (end - start);
        ensureCapacityInternal(newCount);
    
        System.arraycopy(value, end, value, start + len, count - end);
        str.getChars(value, start);
        count = newCount;
        return this;
    }

###  2.5 delete方法

    
    
    /**
     * @throws StringIndexOutOfBoundsException {@inheritDoc}
     * @since      1.2
     */
    @Override
    public synchronized StringBuffer delete(int start, int end) {
        toStringCache = null;
        super.delete(start, end);
        return this;
    }
    /**
     * Removes the characters in a substring of this sequence.
     * The substring begins at the specified {@code start} and extends to
     * the character at index {@code end - 1} or to the end of the
     * sequence if no such character exists. If
     * {@code start} is equal to {@code end}, no changes are made.
     *
     * @param      start  The beginning index, inclusive.
     * @param      end    The ending index, exclusive.
     * @return     This object.
     * @throws     StringIndexOutOfBoundsException  if {@code start}
     *             is negative, greater than {@code length()}, or
     *             greater than {@code end}.
     */
    public AbstractStringBuilder delete(int start, int end) {
        if (start < 0)
            throw new StringIndexOutOfBoundsException(start);
        if (end > count)
            end = count;
        if (start > end)
            throw new StringIndexOutOfBoundsException();
        int len = end - start;
        if (len > 0) {
            System.arraycopy(value, start+len, value, start, count-end);
            count -= len;
        }
        return this;
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/string03.html
](http://www.cnblogs.com/skywang12345/p/string03.html)  
[2] [ http://blog.csdn.net/linbooooo1987/article/details/7531517
](http://blog.csdn.net/linbooooo1987/article/details/7531517)

