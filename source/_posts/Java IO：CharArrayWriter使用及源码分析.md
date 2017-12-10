Java IO：CharArrayWriter使用及源码分析

##  使用方法

CharArrayWriter即字符数组输出流，用于向输出流写写入字符，和ByteArrayOutputStream的区别就是前者写入的是字符后者写入的是字
节。

###  方法介绍

CharArrayWriter提供的API如下：

    
    
    //构造方法
    CharArrayWriter()
    CharArrayWriter(int initialSize)
    
    //追加写
    CharArrayWriter     append(CharSequence csq, int start, int end)
    CharArrayWriter     append(char c)
    CharArrayWriter     append(CharSequence csq)
    //关闭,未做实现
    void     close()
    //未做实现
    void     flush()
    //清空输出流
    void     reset()
    //输出流大小
    int     size()
    //返回char数组
    char[]     toCharArray()
    //返回String
    String     toString()
    //写入
    void     write(char[] buffer, int offset, int len)
    void     write(int oneChar)
    void     write(String str, int offset, int count)
    //写入到其他Writer
    void     writeTo(Writer out)
    

###  使用示例

    
    
    public void testCharArrayWriter() {
        try {
            char [] letters = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n'};
            //创建输出流Writer
            CharArrayWriter writer = new CharArrayWriter();
            //写入'1'
            writer.write('1');
            System.out.println("输出流的内容为: " + writer);
            //写入字符串'2345'
            writer.write("2345");
            System.out.println("输出流的内容为: " + writer);
            //追加4567
            writer.append("456").append("7");
            System.out.println("输出流的内容为: " + writer);
            //写入abc
            writer.write(letters, 0, 3);
            System.out.println("输出流的内容为: " + writer);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

运行结果如下：

    
    
    输出流的内容为: 1
    输出流的内容为: 12345
    输出流的内容为: 123454567
    输出流的内容为: 123454567abc

##  源码分析

###  构造方法

CharArrayWriter的构造方法有两个，区别是字符数组大小设置。

    
    
    /**
     * Creates a new CharArrayWriter.
     */
    public CharArrayWriter() {
        this(32);
    }
    
    /**
     * Creates a new CharArrayWriter with the specified initial size.
     *
     * @param initialSize  an int specifying the initial buffer size.
     * @exception IllegalArgumentException if initialSize is negative
     */
    public CharArrayWriter(int initialSize) {
        if (initialSize < 0) {
            throw new IllegalArgumentException("Negative initial size: "
                    + initialSize);
        }
        buf = new char[initialSize];
    }

###  write方法

write有多种重载方法，重点分析其中一种。

    
    
    /**
     * Writes characters to the buffer.
     * @param c the data to be written
     * @param off       the start offset in the data
     * @param len       the number of chars that are written
     */
    public void write(char c[], int off, int len) {
        if ((off < 0) || (off > c.length) || (len < 0) ||
                ((off + len) > c.length) || ((off + len) < 0)) {
            throw new IndexOutOfBoundsException();
        } else if (len == 0) {
            return;
        }
        synchronized (lock) { //线程安全
            int newcount = count + len;
            if (newcount > buf.length) {
                //数组扩容方案是: 2倍和实际需要大小中的最大值
                buf = Arrays.copyOf(buf, Math.max(buf.length << 1, newcount));
            }
            System.arraycopy(c, off, buf, count, len); //写入
            count = newcount;
        }
    }

###  append方法

将要追加的字符（串）写在输出流最后。

    
    
    /**
     * Appends the specified character sequence to this writer.
     * @param  csq
     *         The character sequence to append.  If <tt>csq</tt> is
     *         <tt>null</tt>, then the four characters <tt>"null"</tt> are
     *         appended to this writer.
     *
     * @return  This writer
     *
     * @since  1.5
     */
    public CharArrayWriter append(CharSequence csq) {
        String s = (csq == null ? "null" : csq.toString());
        write(s, 0, s.length()); //写入
        return this; //可以拼接追加
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/io_19.html
](http://www.cnblogs.com/skywang12345/p/io_19.html)

