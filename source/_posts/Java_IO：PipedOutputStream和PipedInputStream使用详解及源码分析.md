title: Java_IO：PipedOutputStream和PipedInputStream使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java_IO]
------------------
Java IO：PipedOutputStream和PipedInputStream使用详解及源码分析

##  1 使用方法

PipedOutputStream和PipedInputStream是管道输出流和管道输入流，配合使用可以实现线程间通信。  
使用管道实现线程间通信的主要流程如下：建立输出流out和输入流in，将out和in绑定，out中写入的数据则会同步写入的in的缓冲区（实际情况是，out中写
入数据就是往in的缓冲区写数据，out中没有数据缓冲区）。

##  1.1 方法介绍

PipedOutputStream提供的API如下：

    
    
    //构造函数
    public PipedOutputStream(PipedInputStream snk);
    public PipedOutputStream();
    
    public synchronized void connect(PipedInputStream snk); //将PipedOutputStream 和 PipedInputSteam绑定
    public void write(int b); //向output写入b
    public void write(byte b[], int off, int len); //向output写入字节数组b
    
    public synchronized void flush();//刷新缓冲区,通知其他input读取数据
    public void close();// 关闭
    PipedOutputStream提供的API如下：
    //构造函数
    public PipedInputStream(PipedOutputStream src);
    public PipedInputStream(PipedOutputStream src, int pipeSize);
    
    public void connect(PipedOutputStream src); //将PipedOutputStream 和 PipedInputSteam绑定
    protected synchronized void receive(int b); //向input缓冲区写入b
    synchronized void receive(byte b[], int off, int len); //向input写入字节数组b
    
    public synchronized int read(); //读取缓冲区下一个字节
    public synchronized int read(byte b[], int off, int len) //读取缓冲区字节数组到b
    public synchronized int available();// 缓冲区可读字节数组的个数
    public void close(); // 关闭

###  1.2 使用示例

    
    
    /**
     * 生产者线程
     */
    public class Producer extends Thread {
        //输出流
        private PipedOutputStream out = new PipedOutputStream();
    
        //构造方法
        public Producer(PipedOutputStream out) {
            this.out = out;
        }
        @Override
        public void run() {
            writeMessage();
        }
    
        private void writeMessage() {
            StringBuilder sb = new StringBuilder("Hello World!!!");
            try {
                out.write(sb.toString().getBytes());
                out.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    
    }
    /**
     * 消费线程
     */
    public class Consumer extends Thread {
        //输入流, 默认缓冲区大小为1024
        private PipedInputStream in = new PipedInputStream();
    
        //构造方法
        public Consumer(PipedInputStream in) {
            this.in = in;
        }
    
        @Override
        public void run() {
            readMessage();
        }
        private void readMessage() {
            byte [] buf = new byte[1024];
            try {
                int len = in.read(buf);
                System.out.println("缓冲区的内容为: " + new String(buf, 0, len));
                in.close();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
            }
        }
    }
    
    @org.junit.Test
    public void testPiped() {
        /**
         * 流程
         * 1 建立输入输出流
         * 2 绑定输入输出流
         * 3 向缓冲区写数据
         * 4 读取缓冲区数据
         */
        PipedOutputStream out = new PipedOutputStream();
        PipedInputStream in = new PipedInputStream();
        Producer producer = new Producer(out);
        Consumer consumer = new Consumer(in);
    
        try {
            out.connect(in);
            producer.start();
            consumer.start();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

运行结果如下：

    
    
    缓冲区的内容为: Hello World!!!

##  2 源码分析

按照演示程序运行过程分析源码，主要有 ** 构造方法、connect、out写、in读 ** 等。

###  2.1 PipedOutputStream构造方法

    
    
    /**
     * Creates a piped output stream connected to the specified piped
     * input stream. Data bytes written to this stream will then be
     * available as input from <code>snk</code>.
     *
     * @param      snk   The piped input stream to connect to.
     * @exception  IOException  if an I/O error occurs.
     */
    public PipedOutputStream(PipedInputStream snk)  throws IOException {
        connect(snk);
    }
    
    /**
     * Creates a piped output stream that is not yet connected to a
     * piped input stream. It must be connected to a piped input stream,
     * either by the receiver or the sender, before being used.
     *
     * @see     java.io.PipedInputStream#connect(java.io.PipedOutputStream)
     * @see     java.io.PipedOutputStream#connect(java.io.PipedInputStream)
     */
    public PipedOutputStream() {
    }

###  2.2 PipedInputStream构造方法

    
    
    /**
     * Creates a <code>PipedInputStream</code> so that it is
     * connected to the piped output stream
     * <code>src</code> and uses the specified pipe size for
     * the pipe's buffer.
     * Data bytes written to <code>src</code> will then
     * be available as input from this stream.
     *
     * @param      src   the stream to connect to.
     * @param      pipeSize the size of the pipe's buffer.
     * @exception  IOException  if an I/O error occurs.
     * @exception  IllegalArgumentException if {@code pipeSize <= 0}.
     * @since      1.6
     */
    public PipedInputStream(PipedOutputStream src, int pipeSize)
            throws IOException {
        initPipe(pipeSize);
        connect(src);
    }
    public PipedInputStream(PipedOutputStream src) throws IOException {
        this(src, DEFAULT_PIPE_SIZE);
    }
    
    /**
     * Creates a <code>PipedInputStream</code> so that it is not yet
     * {@linkplain #connect(java.io.PipedOutputStream) connected} and
     * uses the specified pipe size for the pipe's buffer.
     * It must be {@linkplain java.io.PipedOutputStream#connect(
     * java.io.PipedInputStream)
     * connected} to a <code>PipedOutputStream</code> before being used.
     *
     * @param      pipeSize the size of the pipe's buffer.
     * @exception  IllegalArgumentException if {@code pipeSize <= 0}.
     * @since      1.6
     */
    public PipedInputStream(int pipeSize) {
        initPipe(pipeSize);
    }
    public PipedInputStream() {
        initPipe(DEFAULT_PIPE_SIZE);
    }

###  2.3 PipedOutputStream connect方法

    
    
    /**
     * Connects this piped output stream to a receiver. If this object
     * is already connected to some other piped input stream, an
     * <code>IOException</code> is thrown.
     * <p>
     * If <code>snk</code> is an unconnected piped input stream and
     * <code>src</code> is an unconnected piped output stream, they may
     * be connected by either the call:
     * <blockquote><pre>
     * src.connect(snk)</pre></blockquote>
     * or the call:
     * <blockquote><pre>
     * snk.connect(src)</pre></blockquote>
     * The two calls have the same effect.
     *
     * @param      snk   the piped input stream to connect to.
     * @exception  IOException  if an I/O error occurs.
     */
    public synchronized void connect(PipedInputStream snk) throws IOException {
        if (snk == null) {
            throw new NullPointerException();
        } else if (sink != null || snk.connected) {
            throw new IOException("Already connected");
        }
        sink = snk; //设置输入流
        snk.in = -1; //写入缓冲区下标
        snk.out = 0; //读取缓冲区下标
        snk.connected = true; //设置连接状态
    }

###  2.4 PipedOutputStream write方法

    
    
    /**
     * Writes the specified <code>byte</code> to the piped output stream.
     * <p>
     * Implements the <code>write</code> method of <code>OutputStream</code>.
     *
     * @param      b   the <code>byte</code> to be written.
     * @exception IOException if the pipe is <a href=#BROKEN> broken</a>,
     *          {@link #connect(java.io.PipedInputStream) unconnected},
     *          closed, or if an I/O error occurs.
     */
    public void write(int b)  throws IOException {
        if (sink == null) {
            throw new IOException("Pipe not connected");
        }
        sink.receive(b); //直接调用输入流方法操作输入流缓冲区
    }
    
    /**
     * Receives a byte of data.  This method will block if no input is
     * available.
     * @param b the byte being received
     * @exception IOException If the pipe is <a href="#BROKEN"> <code>broken</code></a>,
     *          {@link #connect(java.io.PipedOutputStream) unconnected},
     *          closed, or if an I/O error occurs.
     * @since     JDK1.1
     */
    protected synchronized void receive(int b) throws IOException {
        checkStateForReceive(); //检查可写入状态
        writeSide = Thread.currentThread(); //获取输入流线程
        if (in == out) //满,即缓冲区数据已读取完
            awaitSpace();
        if (in < 0) { //缓冲区为空
            in = 0;
            out = 0;
        }
        buffer[in++] = (byte)(b & 0xFF); //写入,限定为8位
        if (in >= buffer.length) { //
            in = 0;
        }
    }

###  2.5 PipedInputStream read方法

    
    
    /**
     * Reads the next byte of data from this piped input stream. The
     * value byte is returned as an <code>int</code> in the range
     * <code>0</code> to <code>255</code>.
     * This method blocks until input data is available, the end of the
     * stream is detected, or an exception is thrown.
     *
     * @return     the next byte of data, or <code>-1</code> if the end of the
     *             stream is reached.
     * @exception  IOException  if the pipe is
     *           {@link #connect(java.io.PipedOutputStream) unconnected},
     *           <a href="#BROKEN"> <code>broken</code></a>, closed,
     *           or if an I/O error occurs.
     */
    public synchronized int read()  throws IOException {
        if (!connected) {
            throw new IOException("Pipe not connected");
        } else if (closedByReader) {
            throw new IOException("Pipe closed");
        } else if (writeSide != null && !writeSide.isAlive()
                && !closedByWriter && (in < 0)) {
            throw new IOException("Write end dead");
        }
    
        readSide = Thread.currentThread(); //获取当前读取线程
        int trials = 2;
        while (in < 0) { //没有可读内容
            if (closedByWriter) {
                /* closed by writer, return EOF */
                return -1;
            }
            if ((writeSide != null) && (!writeSide.isAlive()) && (--trials < 0)) {
                throw new IOException("Pipe broken");
            }
            /* might be a writer waiting */
            notifyAll(); //通知写入
            try {
                wait(1000);
            } catch (InterruptedException ex) {
                throw new java.io.InterruptedIOException();
            }
        }
        int ret = buffer[out++] & 0xFF; //读取字节
        if (out >= buffer.length) { //超过缓冲区长度,则从头开始读,写的时候一样,所以能保证读写一样顺序
            out = 0;
        }
        if (in == out) { //没有可读内容
            /* now empty */
            in = -1; //receive中将out置为0
        }
    
        return ret;
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/io_04.html
](http://www.cnblogs.com/skywang12345/p/io_04.html)  
[2] [ http://www.2cto.com/kf/201402/279143.html
](http://www.2cto.com/kf/201402/279143.html)  
[3] [ http://www.cnblogs.com/meng72ndsc/archive/2010/12/23/1915358.html
](http://www.cnblogs.com/meng72ndsc/archive/2010/12/23/1915358.html)

