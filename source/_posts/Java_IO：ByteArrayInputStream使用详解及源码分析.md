title: Java_IO：ByteArrayInputStream使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java_IO]
------------------

##  1 使用方法

ByteArrayInputStream 包含一个内部缓冲区，该缓冲区包含从流中读取的字节。内部计数器跟踪 read
方法要提供的下一个字节。ByteArrayOutputStream实现了一个输出流，其中的数据被写入一个 byte
数组。缓冲区会随着数据的不断写入而自动增长。可使用 toByteArray()和 toString()获取数据。

###  1.1 方法介绍

ByteArrayInputStream提供的API如下：

    
    
    // 构造函数
        ByteArrayInputStream(byte[] buf)
        ByteArrayInputStream(byte[] buf, int offset, int length)
    
        synchronized int         available() //能否读取字节流的下一字节
        void                     close() //关闭字节流
        synchronized void        mark(int readlimit) //保存当前位置
        boolean                  markSupported() //是否支持mark
        synchronized int         read() //读取下一字节
        synchronized int         read(byte[] buffer, int offset, int length) //将字节流写入buffer数组
        synchronized void        reset() //重置索引到mark位置
        synchronized long        skip(long byteCount) //跳过n个字节
    }

###  1.2 使用示例

    
    
    public class TestByteArray {
        // 对应英文字母“abcddefghijklmnopqrsttuvwxyz”
        private final byte[] ArrayLetters = {
                0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
                0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A
        };
    
        public void testByteArrayInputStream() {
            //创建字节流,以ArrayLetters初始化
            ByteArrayInputStream inputStream = new ByteArrayInputStream(ArrayLetters);
    
            //读取5个字节
            int i = 0;
            System.out.print("前5个字节为: ");
            while (i++ < 5) {
                //是否可读
                if (inputStream.available() >= 0) {
                    int buf = inputStream.read();
                    System.out.printf("0x%s ", Integer.toHexString(buf));
                }
            }
            System.out.println();
    
            //是否支持标记
            if (!inputStream.markSupported()) {
                System.out.println("该字节流不支持标记");
            } else {
                System.out.println("该字节流支持标记");
            }
    
            //标记, 已经读取5个字节,标记处为0x66
            System.out.println("标记该字节流为位置为0x66(f)");
            inputStream.mark(0);
    
            //跳过2个字节
            inputStream.skip(2);
    
            //读取5个字节到buffer
            byte [] buffer = new byte[5];
            inputStream.read(buffer, 0, 5);
            System.out.println("buffer: " + new String(buffer));
    
            //重置
            inputStream.reset();
            inputStream.read(buffer, 0, 5);
            System.out.println("重置后读取5个字符为: " + new String(buffer));
        }
    }

运行结果如下：

    
    
    前5个字节为: 0x61 0x62 0x63 0x64 0x65
    该字节流支持标记
    标记该字节流为位置为0x66(f)
    buffer: hijkl
    重置后读取5个字符为: fghij

##  2 源码分析

###  2.1构造函数

ByteArrayInputStream有两个构造函数，区别是初始化内容选择。

    
    
    /**
     * Creates a <code>ByteArrayInputStream</code>
     * so that it  uses <code>buf</code> as its
     * buffer array.
     * The buffer array is not copied.
     * The initial value of <code>pos</code>
     * is <code>0</code> and the initial value
     * of  <code>count</code> is the length of
     * <code>buf</code>.
     *
     * @param   buf   the input buffer.
     */
    public ByteArrayInputStream(byte buf[]) {
        this.buf = buf; //缓冲数组
        this.pos = 0; //当前位置
        this.count = buf.length; //输入流字节数
    }
    
    /**
     * Creates <code>ByteArrayInputStream</code>
     * that uses <code>buf</code> as its
     * buffer array. The initial value of <code>pos</code>
     * is <code>offset</code> and the initial value
     * of <code>count</code> is the minimum of <code>offset+length</code>
     * and <code>buf.length</code>.
     * The buffer array is not copied. The buffer's mark is
     * set to the specified offset.
     *
     * @param   buf      the input buffer.
     * @param   offset   the offset in the buffer of the first byte to read.
     * @param   length   the maximum number of bytes to read from the buffer.
     */
    public ByteArrayInputStream(byte buf[], int offset, int length) {
        this.buf = buf; //缓冲数组
        this.pos = offset; //当前位置为传入buf的offset
        this.count = Math.min(offset + length, buf.length); //输入流字节数
        this.mark = offset; //标记
    }

###  2.2 read方法

read方法有两个，不带参数的read()每次读取字节流中一个字节，带参数的read(byte b[], int off, int
len)将字节流从当前位置开始，写入len个字节到b中，写入开始位置为off。

    
    
    /**
     * 读取字节流当前字节
     * @return 一个字节
     */
    public synchronized int read() {
        return (pos < count) ? (buf[pos++] & 0xff) : -1; //&0xff为限制返回值为一个字节,即8位
    }
    
    /**
     * 将字节流当前位置开始的len个字节写入到 b从off开始的len个位置
     * @param b
     * @param off
     * @param len
     * @return
     */
    public synchronized int read(byte b[], int off, int len) {
        if (b == null) {
            throw new NullPointerException();
        } else if (off < 0 || len < 0 || len > b.length - off) {
            throw new IndexOutOfBoundsException();
        }
    
        if (pos >= count) { //超出字节流范围
            return -1;
        }
    
        int avail = count - pos; //可读取的字节数量
        if (len > avail) {
            len = avail;
        }
        if (len <= 0) {
            return 0;
        }
        System.arraycopy(buf, pos, b, off, len); //将buf从pos位置开始的字节复制到b从off开始的位置,共复制len长
        pos += len;
        return len;
    }

###  2.4 skip方法

    
    
    /**
     * Skips <code>n</code> bytes of input from this input stream. Fewer
     * bytes might be skipped if the end of the input stream is reached.
     * The actual number <code>k</code>
     * of bytes to be skipped is equal to the smaller
     * of <code>n</code> and  <code>count-pos</code>.
     * The value <code>k</code> is added into <code>pos</code>
     * and <code>k</code> is returned.
     *
     * @param   n   the number of bytes to be skipped.
     * @return  the actual number of bytes skipped.
     */
    public synchronized long skip(long n) {
        long k = count - pos; //剩余字节数
        if (n < k) {
            k = n < 0 ? 0 : n;
        }
    
        pos += k;
        return k;
    }

###  2.5 mark和reset方法

    
    
    /**
     * Set the current marked position in the stream.
     * ByteArrayInputStream objects are marked at position zero by
     * default when constructed.  They may be marked at another
     * position within the buffer by this method.
     * <p>
     * If no mark has been set, then the value of the mark is the
     * offset passed to the constructor (or 0 if the offset was not
     * supplied).
     *
     * <p> Note: The <code>readAheadLimit</code> for this class
     *  has no meaning.
     *
     * @since   JDK1.1
     */
    public void mark(int readAheadLimit) {
        mark = pos;
    }
    
    /**
     * Resets the buffer to the marked position.  The marked position
     * is 0 unless another position was marked or an offset was specified
     * in the constructor.
     */
    public synchronized void reset() {
        pos = mark;
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/io_02.html
](http://www.cnblogs.com/skywang12345/p/io_02.html)  
[2] [ http://www.cnblogs.com/skywang12345/p/io_03.html
](http://www.cnblogs.com/skywang12345/p/io_03.html)  
[3] [ http://blog.csdn.net/rcoder/article/details/6118313
](http://blog.csdn.net/rcoder/article/details/6118313)

