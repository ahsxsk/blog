Java IO：BufferedOutputStream使用详解及源码分析

##  使用方法

BufferedOutputStream继承于FilterOutputStream，提供缓冲输出流功能。缓冲输出流相对于普通输出流的优势是，它提供了一个缓冲
数组，只有缓冲数组满了或者手动flush时才会向磁盘写数据，避免频繁IO。核心思想是，提供一个缓冲数组，写入时首先操作缓冲数组。

###  方法介绍

BufferedOutputStream提供的API如下：

    
    
    //构造函数
    BufferedOutputStream(OutputStream out) //默认缓冲数组大小为8192
    BufferedOutputStream(OutputStream out, int size)
    
    synchronized void     close() //关闭
    synchronized void     flush() //刷盘
    synchronized void     write(byte[] b, int off, int len) //向输出流写数据
    synchronized void     write(int b)

###  使用示例

    
    
    public void testBufferedOutput() {
        try {
            final byte [] letters = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n'};
            /*
             *创建文件输出流out,缓冲区大小为8
             */
            OutputStream out = new BufferedOutputStream(new FileOutputStream(new File("buff.txt")), 8);
            /*将letters前6个字符写入到输出流*/
            out.write(letters, 0 ,6);
            /*此时不会写入任何数据到磁盘文件*/
            readFile();
            /*继续写入4个字符*/
            for (int i = 0; i < 4; i++) {
                out.write('g' + i);
            }
            /*此时只会写入8个字符到磁盘文件*/
            readFile();
            /*此时会把所有内容写入磁盘文件*/
            out.flush();
            readFile();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void readFile() {
        try {
            InputStream in = new FileInputStream("buff.txt");
            byte [] bytes = new byte[20];
            in.read(bytes, 0, bytes.length);
            System.out.println("文件中的内容为: "  + new String(bytes));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

运行结果如下：

    
    
    文件中的内容为:
    文件中的内容为: abcdefgh
    文件中的内容为: abcdefghij

##  源码分析

###  构造方法

BufferedOutputStream的构造方法有两个，区别是字节缓冲数组大小。

    
    
    /**
     * Creates a new buffered output stream to write data to the
     * specified underlying output stream.
     *
     * @param   out   the underlying output stream.
     */
    public BufferedOutputStream(OutputStream out) {
        this(out, 8192);
    }
    
    /**
     * Creates a new buffered output stream to write data to the
     * specified underlying output stream with the specified buffer
     * size.
     *
     * @param   out    the underlying output stream.
     * @param   size   the buffer size.
     * @exception IllegalArgumentException if size &lt;= 0.
     */
    public BufferedOutputStream(OutputStream out, int size) {
        super(out);
        if (size <= 0) {
            throw new IllegalArgumentException("Buffer size <= 0");
        }
        buf = new byte[size];
    }

###  write方法

write方法有两个重载方法，分别是协议一个字节的write(int b)和写入一个字节数组的write(byte b[], int off, int
len)。下面分析第二个方法的源码。

    
    
    /**
     * Writes <code>len</code> bytes from the specified byte array
     * starting at offset <code>off</code> to this buffered output stream.
     *
     * <p> Ordinarily this method stores bytes from the given array into this
     * stream's buffer, flushing the buffer to the underlying output stream as
     * needed.  If the requested length is at least as large as this stream's
     * buffer, however, then this method will flush the buffer and write the
     * bytes directly to the underlying output stream.  Thus redundant
     * <code>BufferedOutputStream</code>s will not copy data unnecessarily.
     *
     * @param      b     the data.
     * @param      off   the start offset in the data.
     * @param      len   the number of bytes to write.
     * @exception  IOException  if an I/O error occurs.
     */
    public synchronized void write(byte b[], int off, int len) throws IOException {
        if (len >= buf.length) { //如果写入长度比buf长度长,直接写入文件，不走缓冲区
            /* If the request length exceeds the size of the output buffer,
               flush the output buffer and then write the data directly.
               In this way buffered streams will cascade harmlessly. */
            flushBuffer(); //将原有缓冲区内容刷盘
            out.write(b, off, len); //直接写入文件
            return;
        }
        if (len > buf.length - count) { //可用空间不足,先刷盘
            flushBuffer();
        }
        System.arraycopy(b, off, buf, count, len); //复制写入
        count += len;
    }
    /** Flush the internal buffer */
    private void flushBuffer() throws IOException {
        if (count > 0) {
            out.write(buf, 0, count);
            count = 0;
        }
    }

###  flush方法

    
    
    /**
     * Flushes this buffered output stream. This forces any buffered
     * output bytes to be written out to the underlying output stream.
     *
     * @exception  IOException  if an I/O error occurs.
     * @see        java.io.FilterOutputStream#out
     */
    public synchronized void flush() throws IOException {
        flushBuffer(); //刷盘
        out.flush(); //未做任何实现
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/io_13.html
](http://www.cnblogs.com/skywang12345/p/io_13.html)  
[2] [ http://czj4451.iteye.com/blog/1545159
](http://czj4451.iteye.com/blog/1545159)

