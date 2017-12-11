title: Java_IO：CharArrayReader使用及源码分析
date: 2017-11-11 13:09:04
categories: [Java_IO]
------------------

##  使用方法

CharArrayReader即字符数组输入流，用于从输入流读取字符，和ByteArrayInputStream的区别就是前者以字符为单位后者是字节。

###  方法介绍

CharArrayReader提供的API如下：

    
    
    //构造方法
    CharArrayReader(char[] buf)
    CharArrayReader(char[] buf, int offset, int length)
    //关闭输入流
    void      close()
    //mark
    void      mark(int readLimit)
    boolean   markSupported()
    //读取下一个字符
    int       read()
    //读取多个字符
    int       read(char[] b, int off, int len)
    //是否可读
    boolean   ready()
    //返回mark的位置
    void      reset()
    //跳过n个字符
    long      skip(long n)
    

###  使用示例

    
    
    public void testCharArrayReader() {
        try {
            char [] letters = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n'};
            //创建输入流
            CharArrayReader reader = new CharArrayReader(letters);
            //读取第一个字符
            System.out.printf("第一个字符为: %c\n", reader.read());
            //mark
            reader.mark(10);
            //读取bcd到tmp
            char [] tmp = new char[3];
            reader.read(tmp, 0, 3);
            System.out.println("读取三个字符到tmp: " + new String(tmp));
            //读取reset后的第一个字符(b)
            reader.reset();
            System.out.printf("reset后第一个字符为: %c\n", reader.read());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

运行结果如下：

    
    
    第一个字符为: a
    读取三个字符到tmp: bcd
    reset后第一个字符为: b

##  源码分析

###  构造方法

CharArrayReader的构造方法有两个，区别是初始化输入流的内容不同。

    
    
    /**
     * Creates a CharArrayReader from the specified array of chars.
     * 以buf中所有字符初始化输入流
     * @param buf       Input buffer (not copied)
     */
    public CharArrayReader(char buf[]) {
        this.buf = buf;
        this.pos = 0;
        this.count = buf.length;
    }
    
    /**
     * Creates a CharArrayReader from the specified array of chars.
     * 以buf中部分字符为输入流
     * @throws IllegalArgumentException
     *         If <tt>offset</tt> is negative or greater than
     *         <tt>buf.length</tt>, or if <tt>length</tt> is negative, or if
     *         the sum of these two values is negative.
     *
     * @param buf       Input buffer (not copied)
     * @param offset    Offset of the first char to read
     * @param length    Number of chars to read
     */
    public CharArrayReader(char buf[], int offset, int length) {
        if ((offset < 0) || (offset > buf.length) || (length < 0) ||
                ((offset + length) < 0)) {
            throw new IllegalArgumentException();
        }
        //以buf中从offset开始length长度的字符初始化输入流
        this.buf = buf;
        this.pos = offset;
        this.count = Math.min(offset + length, buf.length);
        this.markedPos = offset;
    }

###  read方法

read方法有读取下一个字符和读取多个字符两种重载方法，下面分析读取多个字符的源码。

    
    
    /**
     * Reads characters into a portion of an array.
     * @param b  Destination buffer
     * @param off  Offset at which to start storing characters
     * @param len   Maximum number of characters to read
     * @return  The actual number of characters read, or -1 if
     *          the end of the stream has been reached
     *
     * @exception   IOException  If an I/O error occurs
     */
    public int read(char b[], int off, int len) throws IOException {
        synchronized (lock) {
            ensureOpen(); //确保输入流正常
            if ((off < 0) || (off > b.length) || (len < 0) ||
                    ((off + len) > b.length) || ((off + len) < 0)) {
                throw new IndexOutOfBoundsException();
            } else if (len == 0) {
                return 0;
            }
    
            if (pos >= count) { //没有可读字符
                return -1;
            }
            if (pos + len > count) { //可读字符不足len,只读剩下的字符
                len = count - pos;
            }
            if (len <= 0) {
                return 0;
            }
            System.arraycopy(buf, pos, b, off, len); //读取
            pos += len;
            return len;
        }
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/io_18.html
](http://www.cnblogs.com/skywang12345/p/io_18.html)

