title: Java_IO：ByteArrayOutputStream使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java_IO]
------------------

##  1 使用方法

ByteArrayInputStream 包含一个内部缓冲区，该缓冲区包含从流中读取的字节。内部计数器跟踪 read
方法要提供的下一个字节。ByteArrayOutputStream实现了一个输出流，其中的数据被写入一个 byte
数组。缓冲区会随着数据的不断写入而自动增长。可使用 toByteArray()和 toString()获取数据。

##  1.1 方法介绍

ByteArrayOutputStream提供的API如下：

    
    
    // 构造函数
        ByteArrayOutputStream()
        ByteArrayOutputStream(int size)
    
        void    close() //关闭字节流
        synchronized void    reset() //重置计数器
        int     size() //获取当前计数
        synchronized byte[]  toByteArray() //将字节流转换为字节数组
        String  toString(int hibyte) //将字节流转换为String
        String  toString(String charsetName)
        String  toString()
        synchronized void    write(byte[] buffer, int offset, int len) //写入字节数组buffer到字节流, offset是buffer的起始位置
        synchronized void    write(int oneByte) //写入一个字节到字节流
        synchronized void    writeTo(OutputStream out) //写输出流到其他输出流out
    }

###  1.2 使用示例

    
    
    public void testByteArrayOutputStream() {
        byte [] letter = {'h', 'i', 'j', 'k'};
        //新建字节流
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        //写入abcdefg
        int i = 'a'; //a
        while (i < 'h') {
            outputStream.write(i);
            i++;
        }
        System.out.println("当前字节流中的内容有: " + outputStream.toString());
    
        //写入多个
        outputStream.write(letter, 1, 3);
        System.out.println("写入letter数组中的第2,3,4个字母字节流中的内容有: " + outputStream.toString());
        System.out.println("当前output字节流中的字节数为: " + outputStream.size());
    
        byte [] byteArr = outputStream.toByteArray();
        i = 0;
        System.out.print("byte数组内容为: ");
        while (i < byteArr.length) {
            System.out.print(byteArr[i++] + " ");
        }
        System.out.println();
    
        OutputStream cloneOut = new ByteArrayOutputStream();
        try {
            outputStream.writeTo(cloneOut);
            System.out.println("cloneOut的内容为: " + cloneOut.toString());
        } catch (IOException e) {
            e.printStackTrace();
        }
    
    }

运行结果如下：

    
    
    当前字节流中的内容有: abcdefg
    写入letter数组中的第2,3,4个字母字节流中的内容有: abcdefgijk
    当前output字节流中的字节数为: 10
    byte数组内容为: 97 98 99 100 101 102 103 105 106 107
    cloneOut的内容为: abcdefgijk

##  2 源码分析

###  2.1构造函数

ByteArrayOutputStream有两个构造函数,区别是初始大小不同。

    
    
    /**
     * Creates a new byte array output stream. The buffer capacity is
     * initially 32 bytes, though its size increases if necessary.
     */
    public ByteArrayOutputStream() {
        this(32);
    }
    
    /**
     * Creates a new byte array output stream, with a buffer capacity of
     * the specified size, in bytes.
     *
     * @param   size   the initial size.
     * @exception  IllegalArgumentException if size is negative.
     */
    public ByteArrayOutputStream(int size) {
        if (size < 0) {
            throw new IllegalArgumentException("Negative initial size: "
                    + size);
        }
        buf = new byte[size];
    }

###  2.2 write方法

    
    
    /**
     * Writes the specified byte to this byte array output stream.
     *
     * @param   b   the byte to be written.
     */
    public synchronized void write(int b) {
        ensureCapacity(count + 1); //增加容量, 容量不够则加倍
        buf[count] = (byte) b; //写入字节
        count += 1;
    }
    
    /**
     * Writes <code>len</code> bytes from the specified byte array
     * starting at offset <code>off</code> to this byte array output stream.
     *
     * @param   b     the data.
     * @param   off   the start offset in the data.
     * @param   len   the number of bytes to write.
     */
    public synchronized void write(byte b[], int off, int len) {
        if ((off < 0) || (off > b.length) || (len < 0) ||
                ((off + len) - b.length > 0)) {
            throw new IndexOutOfBoundsException();
        }
        ensureCapacity(count + len); //增加容量,容量不够则加倍
        System.arraycopy(b, off, buf, count, len); //写入字节数组
        count += len;
    }

###  2.3 writeTo方法

    
    
    /**
     * Writes the complete contents of this byte array output stream to
     * the specified output stream argument, as if by calling the output
     * stream's write method using <code>out.write(buf, 0, count)</code>.
     *
     * @param      out   the output stream to which to write the data.
     * @exception  IOException  if an I/O error occurs.
     */
    public synchronized void writeTo(OutputStream out) throws IOException {
        out.write(buf, 0, count); //将 当前OutputStream的buf中内容写到out中
    }

###  2.4 toString , toByteArray方法

    
    
    /**
     * Creates a newly allocated byte array. Its size is the current
     * size of this output stream and the valid contents of the buffer
     * have been copied into it.
     *
     * @return  the current contents of this output stream, as a byte array.
     * @see     java.io.ByteArrayOutputStream#size()
     */
    public synchronized byte toByteArray()[] {
        return Arrays.copyOf(buf, count); //返回信得数组
    }
    
    /**
     * Converts the buffer's contents into a string decoding bytes using the
     * platform's default character set. The length of the new <tt>String</tt>
     * is a function of the character set, and hence may not be equal to the
     * size of the buffer.
     *
     * <p> This method always replaces malformed-input and unmappable-character
     * sequences with the default replacement string for the platform's
     * default character set. The {@linkplain java.nio.charset.CharsetDecoder}
     * class should be used when more control over the decoding process is
     * required.
     *
     * @return String decoded from the buffer's contents.
     * @since  JDK1.1
     */
    public synchronized String toString() {
        return new String(buf, 0, count); //返回String对象
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/io_02.html
](http://www.cnblogs.com/skywang12345/p/io_02.html)  
[2] [ http://www.cnblogs.com/skywang12345/p/io_03.html
](http://www.cnblogs.com/skywang12345/p/io_03.html)  
[3] [ http://blog.csdn.net/rcoder/article/details/6118313
](http://blog.csdn.net/rcoder/article/details/6118313)

