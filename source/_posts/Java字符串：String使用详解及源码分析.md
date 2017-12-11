title: Java字符串：String使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java字符串]
------------------

##  1 使用方法

String类型的字符串是不可变字符串，提供了较多操作API。

    
    
    public final class String
        implements java.io.Serializable, Comparable<String>, CharSequence {}

String可以序列化,可以使用compareTo比较字符串。

##  1.1 方法介绍

String提供了的API主要如下：

    
    
    public char    charAt(int index) //index位置的字符
    public int    compareTo(String anotherString) //按字典顺序比较两个字符串
    public String    concat(String str) //拼接字符串
    public boolean    contains(CharSequence s) //是否包含s
    public boolean    contentEquals(StringBuffer sb) //比较当前String和cs是否相同
    public boolean    contentEquals(CharSequence cs) //同上
    public static String    copyValueOf(char[] data, int offset, int count) //返回从offset开始的count个字符组成的字符串String
    public boolean    endsWith(String suffix) //是否以suffix结尾
    public boolean    equals(Object anObject) //比较字符串
    public static String    format(String format, Object[] args) //将args格式化为format
    public int    hashCode() //hash code
    public int    indexOf(int ch) //第一次出现ch所在的下标
    public int    indexOf(int ch, int fromIndex)
    public int    indexOf(String str) //第一次出现str的下标
    public int    indexOf(String str, int fromIndex)
    public int    lastIndexOf(int ch) //最后一次出现ch的下标
    public int    lastIndexOf(int ch, int fromIndex)
    public int    lastIndexOf(String str) //租后一次出现str的下标
    public int    lastIndexOf(String str, int fromIndex)
    public int    length() //长度
    public boolean    matches(String regex) //正则匹配
    public int    offsetByCodePoints(int index, int codePointOffset)
    public boolean    regionMatches(int toffset, String other, int ooffset, int len) //比较指定子串
    public boolean    regionMatches(boolean ignoreCase, int toffset, String other, int ooffset, int len)
    public String    replace(char oldChar, char newChar) //替换oldChar为newChar
    public String    replace(CharSequence target, CharSequence replacement) //替换
    public String    replaceAll(String regex, String replacement)
    public String    replaceFirst(String regex, String replacement)
    public boolean    startsWith(String prefix, int toffset) //从toffset开始是否以prefix开头
    public boolean    startsWith(String prefix)
    public CharSequence    subSequence(int beginIndex, int endIndex) //获取子串
    public String    substring(int beginIndex)
    public String    substring(int beginIndex, int endIndex)
    public char[]    toCharArray()
    public String    toLowerCase(Locale locale) //转为小写字母
    public String    toLowerCase()
    public String    toString()
    public String    toUpperCase(Locale locale) //转为大写字母
    public String    toUpperCase()
    public String    trim()
    public static String    valueOf(Object obj) //转换为string
    public void    getBytes(int srcBegin, int srcEnd, byte[] dst, int dstBegin) //获取byte数组
    public byte[]    getBytes(String charsetName)
    public byte[]    getBytes(Charset charset)
    public byte[]    getBytes()
    public void    getChars(int srcBegin, int srcEnd, char[] dst, int dstBegin)
    public boolean    isEmpty() //判空

###  1.2 使用示例

    
    
    public void testString () {
        String myStr = new String("MYSTR");
        //myStr的长度
        System.out.println("myStr的长度为: " + myStr.length());
        //myStr判空
        System.out.println("myStr是否为空: " + myStr.isEmpty());
        //获取指定位置的字符
        System.out.println("myStr的第4个字符为: " + myStr.charAt(3));
        //将myStr转换为数组
        char [] chars = myStr.toCharArray();
        try {
            printChars(chars);
        } catch (Exception e) {
            System.out.println("myStr转换数组失败!");
        }
        System.out.println();
        //格式化字符串
        System.out.println("格式化myStr: " + String.format("%s-%d-%b", myStr, 3, true));
        //追加字符串
        System.out.println("myStr追加字符ING!: " + myStr.concat("ING!"));
        //拼接的字符串为一个新的对象,不影响原有字符串
        System.out.println("myStr的字符串为: " + myStr);
        //获取子串
        System.out.println("myStr第2到5个字符的子串为: " + myStr.substring(1,5));
        //替换
        System.out.println("替换Y为y: " + myStr.replace("Y", "y"));
        //比较
        System.out.println("myStr字符串和\"MySTR\"是否相等: " + myStr.compareTo("MySTR"));
        //忽略大小写比较
        System.out.println("myStr字符串和\"MySTR\"是否相等: " + myStr.compareToIgnoreCase("MySTR"));
        //获取字符的index
        System.out.println("\"ST\"在myStr中第一次出现的位置: " + myStr.indexOf("ST"));
        //获取Unicode编码
        System.out.printf("%s0x%x", "第一个字符M的Unicode编码为: ",myStr.codePointAt(0));
    }
    
    /**
     * 打印字符数组
     * @param chars
     * @throws NullPointerException
     */
    public void printChars(char[] chars) throws Exception {
        if (chars == null) {
            throw new NullPointerException();
        }
        for (int i = 0; i < chars.length; i++) {
            System.out.printf("char[%d]=%c ", i, chars[i]);
        }
    }

运行结果如下：

    
    
    myStr的长度为: 5
    myStr是否为空: false
    myStr的第4个字符为: T
    char[0]=M char[1]=Y char[2]=S char[3]=T char[4]=R
    格式化myStr: MYSTR-3-true
    myStr追加字符ING!: MYSTRING!
    myStr的字符串为: MYSTR
    myStr第2到5个字符的子串为: YSTR
    替换Y为y: MySTR
    myStr字符串和"MySTR"是否相等: -32
    myStr字符串和"MySTR"是否相等: 0
    "ST"在myStr中第一次出现的位置: 2
    第一个字符M的Unicode编码为: 0x4d

##  2 源码分析

String的字符串是不可变的，拼接替换等操作都会返回新的String实例，不会影响原有的字符串。

    
    
    /** The value is used for character storage. */
    private final char value[]; //final类型

###  2.1构造函数

String包含的构造函数很多，主要区别是是否初始化和初始化方式。下面列举两个代表行的例子。

    
    
    /**
     * 申请一个空的String
     * Initializes a newly created {@code String} object so that it represents
     * an empty character sequence.  Note that use of this constructor is
     * unnecessary since Strings are immutable.
     */
    public String() {
        this.value = new char[0];
    }
    
    /**
     * Allocates a new {@code String} that contains characters from a subarray
     * of the character array argument. The {@code offset} argument is the
     * index of the first character of the subarray and the {@code count}
     * argument specifies the length of the subarray. The contents of the
     * subarray are copied; subsequent modification of the character array does
     * not affect the newly created string.
     *
     * @param  value
     *         Array that is the source of characters
     *
     * @param  offset
     *         The initial offset
     *
     * @param  count
     *         The length
     *
     * @throws  IndexOutOfBoundsException
     *          If the {@code offset} and {@code count} arguments index
     *          characters outside the bounds of the {@code value} array
     */
    public String(char value[], int offset, int count) {
        if (offset < 0) {
            throw new StringIndexOutOfBoundsException(offset);
        }
        if (count < 0) {
            throw new StringIndexOutOfBoundsException(count);
        }
        // Note: offset or count might be near -1>>>1.
        if (offset > value.length - count) {
            throw new StringIndexOutOfBoundsException(offset + count);
        }
        this.value = Arrays.copyOfRange(value, offset, offset+count);
    }

###  2.2 compareTo方法

    
    
    /**
     * Compares two strings lexicographically.
     * The comparison is based on the Unicode value of each character in
     * the strings. The character sequence represented by this
     * {@code String} object is compared lexicographically to the
     * character sequence represented by the argument string. The result is
     * a negative integer if this {@code String} object
     * lexicographically precedes the argument string. The result is a
     * positive integer if this {@code String} object lexicographically
     * follows the argument string. The result is zero if the strings
     * are equal; {@code compareTo} returns {@code 0} exactly when
     * the {@link #equals(Object)} method would return {@code true}.
     * <p>
     * This is the definition of lexicographic ordering. If two strings are
     * different, then either they have different characters at some index
     * that is a valid index for both strings, or their lengths are different,
     * or both. If they have different characters at one or more index
     * positions, let <i>k</i> be the smallest such index; then the string
     * whose character at position <i>k</i> has the smaller value, as
     * determined by using the &lt; operator, lexicographically precedes the
     * other string. In this case, {@code compareTo} returns the
     * difference of the two character values at position {@code k} in
     * the two string -- that is, the value:
     * <blockquote><pre>
     * this.charAt(k)-anotherString.charAt(k)
     * </pre></blockquote>
     * If there is no index position at which they differ, then the shorter
     * string lexicographically precedes the longer string. In this case,
     * {@code compareTo} returns the difference of the lengths of the
     * strings -- that is, the value:
     * <blockquote><pre>
     * this.length()-anotherString.length()
     * </pre></blockquote>
     *
     * @param   anotherString   the {@code String} to be compared.
     * @return  the value {@code 0} if the argument string is equal to
     *          this string; a value less than {@code 0} if this string
     *          is lexicographically less than the string argument; and a
     *          value greater than {@code 0} if this string is
     *          lexicographically greater than the string argument.
     */
    public int compareTo(String anotherString) {
        int len1 = value.length;
        int len2 = anotherString.value.length;
        int lim = Math.min(len1, len2);
        char v1[] = value;
        char v2[] = anotherString.value;
    
        int k = 0;
        while (k < lim) {
            char c1 = v1[k];
            char c2 = v2[k];
            if (c1 != c2) {
                return c1 - c2;
            }
            k++;
        }
        return len1 - len2;
    }

###  2.3 concat方法

    
    
    /**
     * Concatenates the specified string to the end of this string.
     * <p>
     * If the length of the argument string is {@code 0}, then this
     * {@code String} object is returned. Otherwise, a
     * {@code String} object is returned that represents a character
     * sequence that is the concatenation of the character sequence
     * represented by this {@code String} object and the character
     * sequence represented by the argument string.<p>
     * Examples:
     * <blockquote><pre>
     * "cares".concat("s") returns "caress"
     * "to".concat("get").concat("her") returns "together"
     * </pre></blockquote>
     *
     * @param   str   the {@code String} that is concatenated to the end
     *                of this {@code String}.
     * @return  a string that represents the concatenation of this object's
     *          characters followed by the string argument's characters.
     */
    public String concat(String str) {
        int otherLen = str.length();
        if (otherLen == 0) { //判空
            return this;
        }
        int len = value.length;
        char buf[] = Arrays.copyOf(value, len + otherLen); //获取原字符串的字符数组
        str.getChars(buf, len); //将str存到buf的尾部
        return new String(buf, true); //返回新String
    }

###  2.4 replace方法

replace方法有很多重载方法，下面只分析其中一种。

    
    
    /**
     * Returns a string resulting from replacing all occurrences of
     * {@code oldChar} in this string with {@code newChar}.
     * <p>
     * If the character {@code oldChar} does not occur in the
     * character sequence represented by this {@code String} object,
     * then a reference to this {@code String} object is returned.
     * Otherwise, a {@code String} object is returned that
     * represents a character sequence identical to the character sequence
     * represented by this {@code String} object, except that every
     * occurrence of {@code oldChar} is replaced by an occurrence
     * of {@code newChar}.
     * <p>
     * Examples:
     * <blockquote><pre>
     * "mesquite in your cellar".replace('e', 'o')
     *         returns "mosquito in your collar"
     * "the war of baronets".replace('r', 'y')
     *         returns "the way of bayonets"
     * "sparring with a purple porpoise".replace('p', 't')
     *         returns "starring with a turtle tortoise"
     * "JonL".replace('q', 'x') returns "JonL" (no change)
     * </pre></blockquote>
     *
     * @param   oldChar   the old character.
     * @param   newChar   the new character.
     * @return  a string derived from this string by replacing every
     *          occurrence of {@code oldChar} with {@code newChar}.
     */
    public String replace(char oldChar, char newChar) {
        if (oldChar != newChar) { //新老字符相同则返回原字符串
            int len = value.length;
            int i = -1;
            char[] val = value; /* avoid getfield opcode */
    
            while (++i < len) { //找到第一个需要替换的字符
                if (val[i] == oldChar) {
                    break;
                }
            }
            if (i < len) {
                char buf[] = new char[len];
                for (int j = 0; j < i; j++) { //第一个之前的字符直接存储
                    buf[j] = val[j];
                }
                while (i < len) { //替换并且查找
                    char c = val[i];
                    buf[i] = (c == oldChar) ? newChar : c;
                    i++;
                }
                return new String(buf, true); //返回新字符串
            }
        }
        return this;
    }

##  参考：

[1] [ http://blog.csdn.net/mazhimazh/article/details/17715677
](http://blog.csdn.net/mazhimazh/article/details/17715677)  
[2] [ http://www.cnblogs.com/skywang12345/p/string01.html
](http://www.cnblogs.com/skywang12345/p/string01.html)

