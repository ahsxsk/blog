title: Java字符串：StringBuilder使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java字符串]
------------------

##  1 使用方法

StringBuilder是可变字符串，和String的主要区别是他的字符串是可变的，例如拼接等操作不会重返回新的StringBuilder实例。

    
    
    public final class StringBuilder
            extends AbstractStringBuilder
            implements java.io.Serializable, CharSequence{}

StringBuilder继承了AbstractStringBuilder并且实现了Serializable和CharSequence。

##  1.1 方法介绍

StringBuilder提供的的API主要如下：

    
    
    //构造函数
    StringBuilder()
    StringBuilder(int capacity)
    StringBuilder(CharSequence seq)
    StringBuilder(String str)
    
    //尾部添加字符(串)
    StringBuilder     append(float f)
    StringBuilder     append(double d)
    StringBuilder     append(boolean b)
    StringBuilder     append(int i)
    StringBuilder     append(long l)
    StringBuilder     append(char c)
    StringBuilder     append(char[] chars)
    StringBuilder     append(char[] str, int offset, int len)
    StringBuilder     append(String str)
    StringBuilder     append(Object obj)
    StringBuilder     append(StringBuffer sb)
    StringBuilder     append(CharSequence csq)
    StringBuilder     append(CharSequence csq, int start, int end)
    StringBuilder     appendCodePoint(int codePoint)
    int     capacity() //容量
    char     charAt(int index) //获取index下标的字符
    int     codePointAt(int index) //获取index下标字符的Unicode编码
    int     codePointBefore(int index)
    int     codePointCount(int start, int end)
    StringBuilder     delete(int start, int end) //删除[start,end)之间的字符
    StringBuilder     deleteCharAt(int index) //删除index下标的字符
    void     getChars(int start, int end, char[] dst, int dstStart) //获取将[start,end)间的字符填充到到dst中,dstStart为开始位置
    int     indexOf(String subString, int start) //子串的第一次出现位置, 从start开始查找
    int     indexOf(String string) //子串的第一次出现位置
    //插入字符
    StringBuilder     insert(int offset, boolean b)
    StringBuilder     insert(int offset, int i)
    StringBuilder     insert(int offset, long l)
    StringBuilder     insert(int offset, float f)
    StringBuilder     insert(int offset, double d)
    StringBuilder     insert(int offset, char c)
    StringBuilder     insert(int offset, char[] ch)
    StringBuilder     insert(int offset, char[] str, int strOffset, int strLen)
    StringBuilder     insert(int offset, String str)
    StringBuilder     insert(int offset, Object obj)
    StringBuilder     insert(int offset, CharSequence s)
    StringBuilder     insert(int offset, CharSequence s, int start, int end)
    int     lastIndexOf(String string) //子串从后往前第一次出现的位置
    int     lastIndexOf(String subString, int start)
    int     length() //StringBuilder中字符数量
    StringBuilder     replace(int start, int end, String string) //将[start,end)替换为string
    StringBuilder     reverse() //反转字符串
    void     setCharAt(int index, char ch) //将index字符设置为ch
    CharSequence     subSequence(int start, int end) //获取子串
    String     substring(int start)
    String     substring(int start, int end)
    String     toString()
    void     trimToSize()

###  1.2 使用示例

    
    
    @Component
    public class TestStringBuilder {
        public void testStringBuilder() {
            //构造并初始化
            StringBuilder stringBuilder = new StringBuilder("0123456");
            //获取容量
            System.out.println("stringBuilder的容量为: " + stringBuilder.capacity());
            //获取字符数量
            System.out.println("stringBuilder的字符数量为: " + stringBuilder.length());
            //获取指定index的字符
            System.out.println("stringBuilder的第2个字符为: " + stringBuilder.charAt(1));
            //子串第一次出现的位置
            System.out.println("\"23\"在stringBuilder中第一次出现的位置为: " + stringBuilder.indexOf("23"));
            //子串最后一次出现的位置,从后往前
            System.out.println("\"34\"在stringBuilder从第5个字符以前的字符串中第一次一次出现的位置为: "
                    + stringBuilder.lastIndexOf("34", 5));
            //替换字符串
            System.out.println("将stringBuilder的第2-3个字符替换为abcde: " + stringBuilder.replace(1, 3, "abcde"));
            //设置指定位置字符
            stringBuilder.setCharAt(1, 'A');
            System.out.println("将第2个字符设置为A: " + stringBuilder);
            //删除滴定位置的字符串
            stringBuilder.delete(2,5);
            System.out.println("删除第3到第5个字符: " + stringBuilder);
            //追加字符
            System.out.println("stringBuilder尾部追加一个7" + stringBuilder.append("7"));
            //追加double
            System.out.println("stringBuilder尾部追加8.0d" + stringBuilder.append(8.0d));
            //插入字符串
            System.out.println("stringBuilder第3个字符看是追加test: " + stringBuilder.insert(2, "test"));
        }
    }

运行结果如下：

    
    
    stringBuilder的容量为: 23
    stringBuilder的字符数量为: 7
    stringBuilder的第2个字符为: 1
    "23"在stringBuilder中第一次出现的位置为: 2
    "34"在stringBuilder从第5个字符以前的字符串中第一次一次出现的位置为: 3
    将stringBuilder的第2-3个字符替换为abcde: 0abcde3456
    将第2个字符设置为A: 0Abcde3456
    删除第3到第5个字符: 0Ae3456
    stringBuilder尾部追加一个70Ae34567
    stringBuilder尾部追加8.0d0Ae345678.0
    stringBuilder第3个字符看是追加test: 0Ateste345678.0

##  2 源码分析

###  2.1构造函数

StringBuilder的构造函数有多个，基本的区别是初始容量大小和是否用字符串进行初始化，下面列举3个典型的构造方法。

    
    
    /**
     * Constructs a string builder with no characters in it and an
     * initial capacity of 16 characters.
     */
    public StringBuilder() {
        super(16);
    }
    
    /**
     * Constructs a string builder with no characters in it and an
     * initial capacity specified by the {@code capacity} argument.
     *
     * @param      capacity  the initial capacity.
     * @throws     NegativeArraySizeException  if the {@code capacity}
     *               argument is less than {@code 0}.
     */
    public StringBuilder(int capacity) {
        super(capacity);
    }
    
    /**
     * Constructs a string builder initialized to the contents of the
     * specified string. The initial capacity of the string builder is
     * {@code 16} plus the length of the string argument.
     *
     * @param   str   the initial contents of the buffer.
     */
    public StringBuilder(String str) {
        super(str.length() + 16);
        append(str);
    }

###  2.2 insert方法

insert方法有插入字符串、整形、布尔型等多个重载方法，实现方法都是调用父类AbstractStringBuilder的insert方法。

####  2.2.1 插入一个对象

    
    
    /**
     * 插入一个对象(int/boolean/double....etc)
     * @throws StringIndexOutOfBoundsException {@inheritDoc}
     */
    @Override
    public StringBuilder insert(int offset, Object obj) {
        super.insert(offset, obj); //调用AbstractStringBuilder类中的insert方法
        return this;
    }
    
    /**
     * 父类AbstractStringBuilder中的方法
     * @param offset
     * @param obj
     * @return
     */
    public AbstractStringBuilder insert(int offset, Object obj) {
        return insert(offset, String.valueOf(obj)); //调用insert(int offset, String str)
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
            str = "null"; //str为null时
        int len = str.length();
        ensureCapacityInternal(count + len); //确定容量是否够用,不够则增加(length*2 + 2)
        System.arraycopy(value, offset, value, offset + len, count - offset); //offset开始的字符后移len位
        str.getChars(value, offset); //str字符填充
        count += len;
        return this;
    }

####  2.2.2 插入一个字符串

    
    
    /**
     * 插入字符串
     * @throws IndexOutOfBoundsException {@inheritDoc}
     */
    @Override
    public StringBuilder insert(int dstOffset, CharSequence s,
                                int start, int end)
    {
        super.insert(dstOffset, s, start, end);
        return this;
    }
    /**
     * Inserts the string representation of a subarray of the {@code str}
     * array argument into this sequence. The subarray begins at the
     * specified {@code offset} and extends {@code len} {@code char}s.
     * The characters of the subarray are inserted into this sequence at
     * the position indicated by {@code index}. The length of this
     * sequence increases by {@code len} {@code char}s.
     *
     * @param      index    position at which to insert subarray.
     * @param      str       A {@code char} array.
     * @param      offset   the index of the first {@code char} in subarray to
     *             be inserted.
     * @param      len      the number of {@code char}s in the subarray to
     *             be inserted.
     * @return     This object
     * @throws     StringIndexOutOfBoundsException  if {@code index}
     *             is negative or greater than {@code length()}, or
     *             {@code offset} or {@code len} are negative, or
     *             {@code (offset+len)} is greater than
     *             {@code str.length}.
     */
    public AbstractStringBuilder insert(int index, char[] str, int offset,
                                        int len)
    {
        if ((index < 0) || (index > length()))
            throw new StringIndexOutOfBoundsException(index);
        if ((offset < 0) || (len < 0) || (offset > str.length - len))
            throw new StringIndexOutOfBoundsException(
                    "offset " + offset + ", len " + len + ", str.length "
                            + str.length);
        ensureCapacityInternal(count + len); //确定容量
        System.arraycopy(value, index, value, index + len, count - index); //后移len位
        System.arraycopy(str, offset, value, index, len); //将str从offset开始的len个字符复制到value
        count += len;
        return this;
    }

###  2.3 append方法

append和insert方法类似，也有很多重载版本，主要是追加对象或者字符串，也是调用父类的方法。

    
    
    /**
     * Appends the specified {@code StringBuffer} to this sequence.
     * <p>
     * The characters of the {@code StringBuffer} argument are appended,
     * in order, to this sequence, increasing the
     * length of this sequence by the length of the argument.
     * If {@code sb} is {@code null}, then the four characters
     * {@code "null"} are appended to this sequence.
     * <p>
     * Let <i>n</i> be the length of this character sequence just prior to
     * execution of the {@code append} method. Then the character at index
     * <i>k</i> in the new character sequence is equal to the character at
     * index <i>k</i> in the old character sequence, if <i>k</i> is less than
     * <i>n</i>; otherwise, it is equal to the character at index <i>k-n</i>
     * in the argument {@code sb}.
     *
     * @param   sb   the {@code StringBuffer} to append.
     * @return  a reference to this object.
     */
    public StringBuilder append(StringBuffer sb) {
        super.append(sb);
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
        ensureCapacityInternal(count + len); //确定容量
        str.getChars(0, len, value, count); //将str追缴到value最后
        count += len;
        return this;
    }

###  2.4 replace方法

    
    
    /**
     * @throws StringIndexOutOfBoundsException {@inheritDoc}
     */
    @Override
    public StringBuilder replace(int start, int end, String str) {
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
        int newCount = count + len - (end - start); //新数组长度
        ensureCapacityInternal(newCount); //确定容量
    
        System.arraycopy(value, end, value, start + len, count - end); //将value从end开始的字符移动到start+len的位置,共count -end个
        str.getChars(value, start); //填充字符
        count = newCount;
        return this;
    }

###  2.5 delete方法

    
    
    /**
     * @throws StringIndexOutOfBoundsException {@inheritDoc}
     */
    @Override
    public StringBuilder delete(int start, int end) {
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
            //将value从start+len开始的count-end个字符复制到start开始的位置,即向前覆盖掉要删除的字符串
            System.arraycopy(value, start+len, value, start, count-end);
            count -= len;
        }
        return this;
    }

##  参考：

[1] [ http://blog.csdn.net/jiutianhe/article/details/42171103
](http://blog.csdn.net/jiutianhe/article/details/42171103)  
[2] [ http://www.cnblogs.com/skywang12345/p/string02.html
](http://www.cnblogs.com/skywang12345/p/string02.html)

