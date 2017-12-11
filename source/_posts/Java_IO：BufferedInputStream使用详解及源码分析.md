title: Java_IO：BufferedInputStream使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java_IO]
------------------
Java IO：BufferedInputStream使用详解及源码分析

##  使用方法

BufferedInputStream继承于FilterInputStream，提供缓冲输入流功能。缓冲输入流相对于普通输入流的优势是，它提供了一个缓冲数组
，每次调用read方法的时候，它首先尝试从缓冲区里读取数据，若读取失败（缓冲区无可读数据），则选择从物理数据源（譬如文件）读取新数据（这里会尝试尽可能读取多
的字节）放入到缓冲区中，最后再将缓冲区中的内容部分或全部返回给用户.由于从缓冲区里读取数据远比直接从物理数据源（譬如文件）读取速度快。

###  方法介绍

BufferedInputStream提供的API如下：

    
    
    //构造方法
    BufferedInputStream(InputStream in)
    BufferedInputStream(InputStream in, int size)
    
    //下一字节是否可读
    synchronized int     available()
    //关闭
    void     close()
    //标记, readlimit为mark后最多可读取的字节数
    synchronized void     mark(int readlimit)
    //是否支持mark, true
    boolean     markSupported()
    //读取一个字节
    synchronized int     read()
    //读取多个字节到b
    synchronized int     read(byte[] b, int off, int len)
    //重置会mark位置
    synchronized void     reset()
    //跳过n个字节
    synchronized long     skip(long n)

###  使用示例

    
    
    public void testBufferedInput() {
        try {
            /**
             * 建立输入流 BufferedInputStream, 缓冲区大小为8
             * buffer.txt内容为
             * abcdefghij
             */
            InputStream in = new BufferedInputStream(new FileInputStream(new File("buff.txt")), 8);
            /*从字节流中读取5个字节*/
            byte [] tmp = new byte[5];
            in.read(tmp, 0, 5);
            System.out.println("字节流的前5个字节为: " + new String(tmp));
            /*标记测试*/
            in.mark(6);
            /*读取5个字节*/
            in.read(tmp, 0, 5);
            System.out.println("字节流中第6到10个字节为: " +  new String(tmp));
            /*reset*/
            in.reset();
            System.out.printf("reset后读取的第一个字节为: %c" , in.read());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

运行结果如下：

    
    
    字节流的前5个字节为: abcde
    字节流中第6到10个字节为: fghij
    reset后读取的第一个字节为: f

##  源码分析

###  构造方法

BufferedInputStream的构造方法有两个，区别是缓冲区大小设置。

    
    
    /**
     * Creates a <code>BufferedInputStream</code>
     * and saves its  argument, the input stream
     * <code>in</code>, for later use. An internal
     * buffer array is created and  stored in <code>buf</code>.
     *
     * @param   in   the underlying input stream.
     */
    public BufferedInputStream(InputStream in) {
        this(in, DEFAULT_BUFFER_SIZE); //默认8192, 8M
    }
    
    /**
     * Creates a <code>BufferedInputStream</code>
     * with the specified buffer size,
     * and saves its  argument, the input stream
     * <code>in</code>, for later use.  An internal
     * buffer array of length  <code>size</code>
     * is created and stored in <code>buf</code>.
     *
     * @param   in     the underlying input stream.
     * @param   size   the buffer size.
     * @exception IllegalArgumentException if {@code size <= 0}.
     */
    public BufferedInputStream(InputStream in, int size) {
        super(in);
        if (size <= 0) {
            throw new IllegalArgumentException("Buffer size <= 0");
        }
        buf = new byte[size];
    }

###  read方法

read方法有每次读取一个字节和一次读取多个字节两种重载。下面主要分析读取多个字节的read方法。 ** _ 重点在于fill()方法 _ ** 。

    
    
    /**
     * Reads bytes from this byte-input stream into the specified byte array,
     * starting at the given offset.
     *
     * <p> This method implements the general contract of the corresponding
     * <code>{@link InputStream#read(byte[], int, int) read}</code> method of
     * the <code>{@link InputStream}</code> class.  As an additional
     * convenience, it attempts to read as many bytes as possible by repeatedly
     * invoking the <code>read</code> method of the underlying stream.  This
     * iterated <code>read</code> continues until one of the following
     * conditions becomes true: <ul>
     *
     * @param      b     destination buffer.
     * @param      off   offset at which to start storing bytes.
     * @param      len   maximum number of bytes to read.
     * @return     the number of bytes read, or <code>-1</code> if the end of the stream has been reached.
     * @exception  IOException  if this input stream has been closed by invoking its {@link #close()} method,
     *                   or an I/O error occurs.
     */
    public synchronized int read(byte b[], int off, int len)
            throws IOException
    {
        getBufIfOpen(); // Check for closed stream
        if ((off | len | (off + len) | (b.length - (off + len))) < 0) {
            throw new IndexOutOfBoundsException();
        } else if (len == 0) {
            return 0;
        }
    
        int n = 0;
        for (;;) {
            int nread = read1(b, off + n, len - n); //读取len长度的字节到b中
            if (nread <= 0)
                return (n == 0) ? nread : n;
            n += nread;
            if (n >= len)
                return n;
            // if not closed but no bytes available, return
            InputStream input = in;
            if (input != null && input.available() <= 0)
                return n;
        }
    }
    
    /**
     * Check to make sure that buffer has not been nulled out due to
     * close; if not return it;
     */
    private byte[] getBufIfOpen() throws IOException {
        byte[] buffer = buf;
        if (buffer == null)
            throw new IOException("Stream closed");
        return buffer;
    }
    
    /**
     * Read characters into a portion of an array, reading from the underlying
     * stream at most once if necessary.
     */
    private int read1(byte[] b, int off, int len) throws IOException {
        int avail = count - pos; //缓冲区中可读字节数
        if (avail <= 0) { //没可读字节
            /* If the requested length is at least as large as the buffer, and
               if there is no mark/reset activity, do not bother to copy the
               bytes into the local buffer.  In this way buffered streams will
               cascade harmlessly. */
            if (len >= getBufIfOpen().length && markpos < 0) { //没mark并且请求长度大于buff长度
                return getInIfOpen().read(b, off, len); //直接从文件中读取,不走缓冲区
            }
            fill(); //修改或者扩展缓冲区
            avail = count - pos; //可读字节数
            if (avail <= 0) return -1;
        }
        int cnt = (avail < len) ? avail : len; //取最小值, 缓冲区中可能没有足够可读的字节
        System.arraycopy(getBufIfOpen(), pos, b, off, cnt); //复制
        pos += cnt;
        return cnt;
    }
    
    /**
     * Fills the buffer with more data, taking into account
     * shuffling and other tricks for dealing with marks.
     * Assumes that it is being called by a synchronized method.
     * This method also assumes that all data has already been read in,
     * hence pos > count.
     */
    private void fill() throws IOException {
        /**
         * 填充字符时如果没有mark标记, 则直接清空缓冲区,然后将输入流的数据写入缓冲区
         * 如果有mark标记,则分如下几种情况
         * 1 普通mark,直接将标记以前的字符用标记以后的字符覆盖,剩余的空间读取输入流的内容填充
         * 2 当前位置pos >= buffer的长度 >= marklimit,说明mark已经失效,直接清空缓冲区,然后读取输入流内容
         * 3 buffer长度超出限制,抛出异常
         * 4 marklimit比buffer的长度还大,此时mark还没失效,则扩大buffer空间
         */
        byte[] buffer = getBufIfOpen();
        if (markpos < 0)
            pos = 0;            /* no mark: throw away the buffer */
        else if (pos >= buffer.length)  /* no room left in buffer */
            if (markpos > 0) {  /* can throw away early part of the buffer */
                int sz = pos - markpos;
                System.arraycopy(buffer, markpos, buffer, 0, sz);
                pos = sz;
                markpos = 0;
            } else if (buffer.length >= marklimit) {
                markpos = -1;   /* buffer got too big, invalidate mark */
                pos = 0;        /* drop buffer contents */
            } else if (buffer.length >= MAX_BUFFER_SIZE) {
                throw new OutOfMemoryError("Required array size too large");
            } else {            /* grow buffer */
                int nsz = (pos <= MAX_BUFFER_SIZE - pos)
                        pos * 2 : MAX_BUFFER_SIZE; //扩大后的大小
                if (nsz > marklimit)
                    nsz = marklimit;
                byte nbuf[] = new byte[nsz];
                System.arraycopy(buffer, 0, nbuf, 0, pos); //将buffer的数据复制到nbuf中
                if (!bufUpdater.compareAndSet(this, buffer, nbuf)) {
                    // Can't replace buf if there was an async close.
                    // Note: This would need to be changed if fill()
                    // is ever made accessible to multiple threads.
                    // But for now, the only way CAS can fail is via close.
                    // assert buf == null;
                    throw new IOException("Stream closed");
                }
                buffer = nbuf; //修改缓冲区
            }
        count = pos;
        int n = getInIfOpen().read(buffer, pos, buffer.length - pos); //读取输入流中内容填充缓冲区
        if (n > 0)
            count = n + pos;
    }

###  mark\reset方法

    
    
    /**
     * See the general contract of the <code>mark</code>
     * method of <code>InputStream</code>.
     *
     * @param   readlimit   the maximum limit of bytes that can be read before
     *                      the mark position becomes invalid.
     * @see     java.io.BufferedInputStream#reset()
     */
    public synchronized void mark(int readlimit) {
        marklimit = readlimit;
        markpos = pos;
    }
    
    /**
     * See the general contract of the <code>reset</code>
     * method of <code>InputStream</code>.
     * <p>
     * If <code>markpos</code> is <code>-1</code>
     * (no mark has been set or the mark has been
     * invalidated), an <code>IOException</code>
     * is thrown. Otherwise, <code>pos</code> is
     * set equal to <code>markpos</code>.
     *
     * @exception  IOException  if this stream has not been marked or,
     *                  if the mark has been invalidated, or the stream
     *                  has been closed by invoking its {@link #close()}
     *                  method, or an I/O error occurs.
     * @see        java.io.BufferedInputStream#mark(int)
     */
    public synchronized void reset() throws IOException {
        getBufIfOpen(); // Cause exception if closed
        if (markpos < 0)
            throw new IOException("Resetting to invalid mark");
        pos = markpos;
    }

##  参考：

[1] [ http://zhhphappy.iteye.com/blog/1562427
](http://zhhphappy.iteye.com/blog/1562427)  
[2] [ http://blog.sina.com.cn/s/blog_67f995260101huxz.html
](http://blog.sina.com.cn/s/blog_67f995260101huxz.html)  
[3] [ http://www.cnblogs.com/skywang12345/p/io_12.html
](http://www.cnblogs.com/skywang12345/p/io_12.html)

