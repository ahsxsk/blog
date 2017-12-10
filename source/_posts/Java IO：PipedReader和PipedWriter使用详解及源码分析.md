Java IO：PipedReader和PipedWriter使用详解及源码分析

##  使用方法

PipedReader和PipedWriter即管道输入流和输出流，可用于线程间管道通信。它们和PipedInputStream/PipedOutputSt
ream区别是前者操作的是字符后者是字节。

###  方法介绍

PipedReader提供的API如下：

    
    
    //构造方法
    PipedReader(PipedWriter src)    //使用默认的buf的大小和传入的pw构造pr
    PipedReader(PipedWriter src, int pipeSize)      //使用指定的buf的大小和传入的pw构造pr
    PipedReader()       //使用默认大小构造pr
    PipedReader(int pipeSize)       //使用指定大小构造pr
    
    //关闭流
    void close()
    //绑定Writer
    void connect(PipedWriter src)
    //是否可读
    synchronized boolean ready()
    //读取一个字符
    synchronized int read()
    //读取多个字符到cbuf
    synchronized int read(char cbuf[], int off, int len)
    //Writer调用, 向Reader缓冲区写数据
    synchronized void receive(int c)
    synchronized void receive(char c[], int off, int len)
    synchronized void receivedLast()

PipedWriter提供的API如下：

    
    
    //构造方法
    PipedWriter(PipedReader snk)
    PipedWriter()
    
    //绑定Reader Writer
    synchronized void connect(PipedReader snk)
    //关闭流
    void close()
    //刷新流,唤醒Reader
    synchronized void flush()
    //写入1个字符,实际是写到绑定Reader的缓冲区
    void write(int c)
    //写入多个字符到Reader缓冲区
    void write(char cbuf[], int off, int len)

###  使用示例

    
    
    /**
     * 写线程
     */
    public class Producer extends Thread {
        //输出流
        private PipedWriter writer = new PipedWriter();
        public Producer(PipedWriter writer) {
            this.writer = writer;
        }
    
        @Override
        public void run() {
            try {
                StringBuilder sb = new StringBuilder();
                sb.append("Hello World!");
                writer.write(sb.toString());
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    /**
     * 读取线程
     */
    public class Consumer extends Thread{
        //输入流
        private PipedReader reader = new PipedReader();
    
        public Consumer(PipedReader reader) {
            this.reader = reader;
        }
    
        @Override
        public void run() {
            try {
                char [] cbuf = new char[20];
                reader.read(cbuf, 0, cbuf.length);
                System.out.println("管道流中的数据为: " + new String(cbuf));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    @org.junit.Test
    public void testPipedReaderWriter() {
        /**
         * 管道流通信核心是,Writer和Reader公用一块缓冲区,缓冲区在Reader中申请,
         * 由Writer调用和它绑定的Reader的Receive方法进行写.
         *
         * 线程间通过管道流通信的步骤为
         * 1 建立输入输出流
         * 2 绑定输入输出流
         * 3 Writer写
         * 4 Reader读
         */
        PipedReader reader = new PipedReader();
        PipedWriter writer = new PipedWriter();
        Producer producer = new Producer(writer);
        Consumer consumer = new Consumer(reader);
    
        try {
            writer.connect(reader);
            producer.start();
            consumer.start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

运行结果如下：

    
    
    管道流中的数据为: Hello World!

##  源码分析

按照演示程序运行过程分析源码，主要有 ** 构造方法、connect、writer写、reader读 ** 等。

###  构造方法

####  PipedWriter构造方法

PipedWriter构造方法有两个，区别是是否指定需要连接的PipedReader对象。

    
    
    /**
     * Creates a piped writer connected to the specified piped
     * reader. Data characters written to this stream will then be
     * available as input from <code>snk</code>.
     *
     * @param      snk   The piped reader to connect to.
     * @exception  IOException  if an I/O error occurs.
     */
    public PipedWriter(PipedReader snk)  throws IOException {
        connect(snk);
    }
    
    /**
     * Creates a piped writer that is not yet connected to a
     * piped reader. It must be connected to a piped reader,
     * either by the receiver or the sender, before being used.
     *
     * @see     java.io.PipedReader#connect(java.io.PipedWriter)
     * @see     java.io.PipedWriter#connect(java.io.PipedReader)
     */
    public PipedWriter() {
    }

####  PipedReader 构造方法

PipedReader构造方法有四个，区别是是否指定要连接的PipedWriter对象以及缓冲区大小设置，默认缓冲区大小为1024。

    
    
    /**
     * Creates a <code>PipedReader</code> so that it is connected
     * to the piped writer <code>src</code> and uses the specified
     * pipe size for the pipe's buffer. Data written to <code>src</code>
     * will then be  available as input from this stream.
    
     * @param      src       the stream to connect to.
     * @param      pipeSize  the size of the pipe's buffer.
     * @exception  IOException  if an I/O error occurs.
     * @exception  IllegalArgumentException if {@code pipeSize <= 0}.
     * @since      1.6
     */
    public PipedReader(PipedWriter src, int pipeSize) throws IOException {
        initPipe(pipeSize); //设置缓冲区大小
        connect(src);  //连接对应的PipedWriter
    }
    
    public PipedReader(PipedWriter src) throws IOException {
        this(src, DEFAULT_PIPE_SIZE); //默认缓冲区大小
    }
    
    /**
     * Creates a <code>PipedReader</code> so that it is not yet
     * {@link #connect(java.io.PipedWriter) connected} and uses
     * the specified pipe size for the pipe's buffer.
     * It must be  {@linkplain java.io.PipedWriter#connect(
     * java.io.PipedReader) connected} to a <code>PipedWriter</code>
     * before being used.
     *
     * @param   pipeSize the size of the pipe's buffer.
     * @exception  IllegalArgumentException if {@code pipeSize <= 0}.
     * @since      1.6
     */
    public PipedReader(int pipeSize) {
        initPipe(pipeSize); //指定大小
    }
    
    public PipedReader() {
        initPipe(DEFAULT_PIPE_SIZE); //默认1024
    }

###  connect方法

PipedWriter和PipedReader都有connect方法，两者作用相同。实际上PipedReader的connect方法是调用PipedWrit
er中connect方法实现的。

####  PipedWriter connect方法

    
    
    /**
     * Connects this piped writer to a receiver. If this object
     * is already connected to some other piped reader, an
     * <code>IOException</code> is thrown.
     * <p>
     * If <code>snk</code> is an unconnected piped reader and
     * <code>src</code> is an unconnected piped writer, they may
     * be connected by either the call:
     * <blockquote><pre>
     * src.connect(snk)</pre></blockquote>
     * or the call:
     * <blockquote><pre>
     * snk.connect(src)</pre></blockquote>
     * The two calls have the same effect.
     *
     * @param      snk   the piped reader to connect to.
     * @exception  IOException  if an I/O error occurs.
     */
    public synchronized void connect(PipedReader snk) throws IOException {
        if (snk == null) {
            throw new NullPointerException();
        } else if (sink != null || snk.connected) {
            throw new IOException("Already connected");
        } else if (snk.closedByReader || closed) {
            throw new IOException("Pipe closed");
        }
    
        sink = snk; //绑定对应的PipedReader
        snk.in = -1; //写入操作下标
        snk.out = 0; //读取操作下标
        snk.connected = true; //连接状态
    }

####  PipedReader connect方法

    
    
    /**
     * Causes this piped reader to be connected
     * to the piped  writer <code>src</code>.
     * If this object is already connected to some
     * other piped writer, an <code>IOException</code>
     * is thrown.
     * @param      src   The piped writer to connect to.
     * @exception  IOException  if an I/O error occurs.
     */
    public void connect(PipedWriter src) throws IOException {
        src.connect(this); //调用PipedWriter的方法
    }

###  PipedWriter write方法

write有写入一个字符和写入多个字符两种重载方法，实现原理都一样，调用和它绑定的PipedReader的receive方法向缓冲区写数据，下面分析写入多个
字符的write方法。

    
    
    /**
     * Writes the specified <code>char</code> to the piped output stream.
     * If a thread was reading data characters from the connected piped input
     * stream, but the thread is no longer alive, then an
     * <code>IOException</code> is thrown.
     * <p>
     * Implements the <code>write</code> method of <code>Writer</code>.
     *
     * @param      c   the <code>char</code> to be written.
     * @exception  IOException  if the pipe is
     *          <a href=PipedOutputStream.html#BROKEN> <code>broken</code></a>,
     *          {@link #connect(java.io.PipedReader) unconnected}, closed
     *          or an I/O error occurs.
     */
    public void write(int c)  throws IOException {
        if (sink == null) {
            throw new IOException("Pipe not connected");
        }
        sink.receive(c); //调用PipedReader的receive方法
    }
    
    /**
     * Receives a char of data. This method will block if no input is
     * available.
     */
    synchronized void receive(int c) throws IOException {
        if (!connected) {
            throw new IOException("Pipe not connected");
        } else if (closedByWriter || closedByReader) {
            throw new IOException("Pipe closed");
        } else if (readSide != null && !readSide.isAlive()) {
            throw new IOException("Read end dead");
        }
    
        writeSide = Thread.currentThread(); //获取当前线程
        while (in == out) { //满，唤醒读者。（有点疑惑）
            if ((readSide != null) && !readSide.isAlive()) {
                throw new IOException("Pipe broken");
            }
            /* full: kick any waiting readers */
            notifyAll();
            try {
                wait(1000);
            } catch (InterruptedException ex) {
                throw new java.io.InterruptedIOException();
            }
        }
        if (in < 0) {
            in = 0;
            out = 0;
        }
        buffer[in++] = (char) c;
        if (in >= buffer.length) {
            in = 0;
        }
    }

###  PipedReader read方法

read方法同样有读取一个字符和读取多个字符两种重载方法，下面分析读取一个字符的read。

    
    
    /**
     * Reads the next character of data from this piped stream.
     * If no character is available because the end of the stream
     * has been reached, the value <code>-1</code> is returned.
     * This method blocks until input data is available, the end of
     * the stream is detected, or an exception is thrown.
     *
     * @return     the next character of data, or <code>-1</code> if the end of the
     *             stream is reached.
     * @exception  IOException  if the pipe is
     *          <a href=PipedInputStream.html#BROKEN> <code>broken</code></a>,
     *          {@link #connect(java.io.PipedWriter) unconnected}, closed,
     *          or an I/O error occurs.
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
    
        readSide = Thread.currentThread();
        int trials = 2;
        while (in < 0) { //缓冲区为空
            if (closedByWriter) {
                /* closed by writer, return EOF */
                return -1;
            }
            if ((writeSide != null) && (!writeSide.isAlive()) && (--trials < 0)) {
                throw new IOException("Pipe broken");
            }
            /* might be a writer waiting */
            notifyAll(); //唤醒写者
            try {
                wait(1000);
            } catch (InterruptedException ex) {
                throw new java.io.InterruptedIOException();
            }
        }
        int ret = buffer[out++]; //读
        if (out >= buffer.length) {
            out = 0;
        }
        if (in == out) { //所有字符都被读取
            /* now empty */
            in = -1;
        }
        return ret;
    }

##  参考：

[1] [ http://www.2cto.com/kf/201312/263319.html
](http://www.2cto.com/kf/201312/263319.html)  
[2] [ http://www.cnblogs.com/skywang12345/p/io_20.html
](http://www.cnblogs.com/skywang12345/p/io_20.html)

