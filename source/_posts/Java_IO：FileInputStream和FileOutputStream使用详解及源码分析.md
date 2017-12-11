title: Java_IO：FileInputStream和FileOutputStream使用详解及源码分析
date: 2017-11-11 13:09:04
categories: [Java_IO]
------------------

##  1 使用方法

FileInputStream即文件输入流，使用它从文件中获得字节流，FileOutputStream即问价输出流，使用它将字节流写入文件。

##  1.1 方法介绍

FileInputStream提供的API如下：

    
    
    FileInputStream(File file)         // 创建“File对象”对应的“文件输入流”
    FileInputStream(FileDescriptor fd) // 创建“文件描述符”对应的“文件输入流”
    FileInputStream(String path)       // 创建“文件(路径为path)”对应的“文件输入流”
    
    int      available()             // 返回“剩余的可读取的字节数”或者“skip的字节数”
    void     close()                 // 关闭“文件输入流”
    FileChannel      getChannel()    // 返回“FileChannel”
    final FileDescriptor     getFD() // 返回“文件描述符”
    int      read()                  // 返回“文件输入流”的下一个字节
    int      read(byte[] buffer, int off, int len) // 读取“文件输入流”的数据并存在到buffer，从off开始存储，存储长度是len。
    long     skip(long n)    // 跳过n个字节

FileOutputStream提供的API如下：

    
    
    FileOutputStream(File file)                   // 创建“File对象”对应的“文件输入流”；默认“追加模式”是false，即“写到输出的流内容”不是以追加的方式添加到文件中。
    FileOutputStream(File file, boolean append)   // 创建“File对象”对应的“文件输入流”；指定“追加模式”。
    FileOutputStream(FileDescriptor fd)           // 创建“文件描述符”对应的“文件输入流”；默认“追加模式”是false，即“写到输出的流内容”不是以追加的方式添加到文件中。
    FileOutputStream(String path)                 // 创建“文件(路径为path)”对应的“文件输入流”；默认“追加模式”是false，即“写到输出的流内容”不是以追加的方式添加到文件中。
    FileOutputStream(String path, boolean append) // 创建“文件(路径为path)”对应的“文件输入流”；指定“追加模式”。
    
    void                    close()      // 关闭“输出流”
    FileChannel             getChannel() // 返回“FileChannel”
    final FileDescriptor    getFD()      // 返回“文件描述符”
    void                    write(byte[] buffer, int off, int len) // 将buffer写入到“文件输出流”中，从buffer的off开始写，写入长度是len。
    void                    write(int n)  // 写入字节n到“文件输出流”中

###  1.2 使用示例

    
    
    /**
     * 在源码所在目录生成一个test.txt,并写入abcdefghijklmn123456
     */
    public void testFileOutputStream() {
        try {
            byte [] content = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'};
            //床架test.txt文件
            File file = new File("test.txt");
            //创建文件输出流
            FileOutputStream outputStream = new FileOutputStream(file);
            outputStream.write(content, 0, 14);
            //PrintStream写入方便
            PrintStream printStream = new PrintStream(outputStream);
            printStream.print("123456");
            printStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    /**
     * 测试文件输入流
     */
    public void testFileInputStream() {
        try {
            //新建输入流,文件中的内容为abcdefghijklmn123456
            FileInputStream inputStream = new FileInputStream("test.txt");
            //读取一个字节a
            System.out.println("读取一个字节: " + inputStream.read());
            //跳过两个字节 b c
            inputStream.skip(2);
            //读取三个字节到buff中def
            byte [] buff = new byte[3];
            inputStream.read(buff, 0, 3);
            System.out.println("buff中的内容为: " + new String(buff));
            inputStream.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    
    }

运行结果如下：

    
    
    读取一个字节: 97
    buff中的内容为: def

##  2 源码分析

###  2.1FileInputStream源码分析

####  2.1.1 构造方法

FileInputStream提供三个构造方法，区别是传入的参数类型（文件路径，FIle对象，文件描述符对象）。

    
    
    /**
     * Creates a <code>FileInputStream</code> by
     * opening a connection to an actual file,
     * the file named by the path name <code>name</code>
     * in the file system.  A new <code>FileDescriptor</code>
     * object is created to represent this file
     * connection.
     * <p>
     * First, if there is a security
     * manager, its <code>checkRead</code> method
     * is called with the <code>name</code> argument
     * as its argument.
     * <p>
     * If the named file does not exist, is a directory rather than a regular
     * file, or for some other reason cannot be opened for reading then a
     * <code>FileNotFoundException</code> is thrown.
     *
     * @param      name   the system-dependent file name.
     * @exception  FileNotFoundException  if the file does not exist,
     *                   is a directory rather than a regular file,
     *                   or for some other reason cannot be opened for
     *                   reading.
     * @exception  SecurityException      if a security manager exists and its
     *               <code>checkRead</code> method denies read access
     *               to the file.
     * @see        java.lang.SecurityManager#checkRead(java.lang.String)
     */
    public FileInputStream(String name) throws FileNotFoundException {
        this(name != null ? new File(name) : null);
    }
    /**
     * Creates a <code>FileInputStream</code> by
     * opening a connection to an actual file,
     * the file named by the <code>File</code>
     * object <code>file</code> in the file system.
     * A new <code>FileDescriptor</code> object
     * is created to represent this file connection.
     * <p>
     * First, if there is a security manager,
     * its <code>checkRead</code> method  is called
     * with the path represented by the <code>file</code>
     * argument as its argument.
     * <p>
     * argument as its argument.
     * <p>
     * If the named file does not exist, is a directory rather than a regular
     * file, or for some other reason cannot be opened for reading then a
     * <code>FileNotFoundException</code> is thrown.
     *
     * @param      file   the file to be opened for reading.
     * @exception  FileNotFoundException  if the file does not exist,
     *                   is a directory rather than a regular file,
     *                   or for some other reason cannot be opened for
     *                   reading.
     * @exception  SecurityException      if a security manager exists and its
     *               <code>checkRead</code> method denies read access to the file.
     * @see        java.io.File#getPath()
     * @see        java.lang.SecurityManager#checkRead(java.lang.String)
     */
    public FileInputStream(File file) throws FileNotFoundException {
        String name = (file != null ? file.getPath() : null);
        SecurityManager security = System.getSecurityManager();
        if (security != null) {
            security.checkRead(name);
        }
        if (name == null) {
            throw new NullPointerException();
        }
        if (file.isInvalid()) {
            throw new FileNotFoundException("Invalid file path");
        }
        fd = new FileDescriptor();
        fd.attach(this);
        path = name;
        open(name);
    }
    /**
     * Creates a <code>FileInputStream</code> by using the file descriptor
     * <code>fdObj</code>, which represents an existing connection to an
     * actual file in the file system.
     * <p>
     * If there is a security manager, its <code>checkRead</code> method is
     * called with the file descriptor <code>fdObj</code> as its argument to
     * see if it's ok to read the file descriptor. If read access is denied
     * to the file descriptor a <code>SecurityException</code> is thrown.
     * <p>
     * If <code>fdObj</code> is null then a <code>NullPointerException</code>
     * is thrown.
     * <p>
     * This constructor does not throw an exception if <code>fdObj</code>
     * is {@link java.io.FileDescriptor#valid() invalid}.
     * However, if the methods are invoked on the resulting stream to attempt
     * I/O on the stream, an <code>IOException</code> is thrown.
     *
     * @param      fdObj   the file descriptor to be opened for reading.
     * @throws     SecurityException      if a security manager exists and its
     *                 <code>checkRead</code> method denies read access to the
     *                 file descriptor.
     * @see        SecurityManager#checkRead(java.io.FileDescriptor)
     */
    public FileInputStream(FileDescriptor fdObj) {
        SecurityManager security = System.getSecurityManager();
        if (fdObj == null) {
            throw new NullPointerException();
        }
        if (security != null) {
            security.checkRead(fdObj);
        }
        fd = fdObj;
        path = null;
    
        /*
         * FileDescriptor is being shared by streams.
         * Register this stream with FileDescriptor tracker.
         */
        fd.attach(this);
    }

###  2.2 FileOutputStream源码分析

####  2.1.1 构造方法

    
    
    public FileOutputStream(String name) throws FileNotFoundException {
        this(name != null ? new File(name) : null, false);
    }
    
    /**
     * Creates a file output stream to write to the file with the specified
     * name.  If the second argument is <code>true</code>, then
     * bytes will be written to the end of the file rather than the beginning.
     * A new <code>FileDescriptor</code> object is created to represent this
     * file connection.
     * <p>
     * First, if there is a security manager, its <code>checkWrite</code>
     * method is called with <code>name</code> as its argument.
     * <p>
     * If the file exists but is a directory rather than a regular file, does
     * not exist but cannot be created, or cannot be opened for any other
     * reason then a <code>FileNotFoundException</code> is thrown.
     *
     * @param     name        the system-dependent file name
     * @param     append      if <code>true</code>, then bytes will be written
     *                   to the end of the file rather than the beginning
     * @exception  FileNotFoundException  if the file exists but is a directory
     *                   rather than a regular file, does not exist but cannot
     *                   be created, or cannot be opened for any other reason.
     * @exception  SecurityException  if a security manager exists and its
     *               <code>checkWrite</code> method denies write access
     *               to the file.
     * @see        java.lang.SecurityManager#checkWrite(java.lang.String)
     * @since     JDK1.1
     */
    public FileOutputStream(String name, boolean append)
            throws FileNotFoundException
    {
        this(name != null ? new File(name) : null, append);
    }
    
    public FileOutputStream(File file) throws FileNotFoundException {
        this(file, false);
    }
    
    /**
     * Creates a file output stream to write to the file represented by
     * the specified <code>File</code> object. If the second argument is
     * <code>true</code>, then bytes will be written to the end of the file
     * rather than the beginning. A new <code>FileDescriptor</code> object is
     * created to represent this file connection.
     * <p>
     * First, if there is a security manager, its <code>checkWrite</code>
     * method is called with the path represented by the <code>file</code>
     * argument as its argument.
     * <p>
     * If the file exists but is a directory rather than a regular file, does
     * not exist but cannot be created, or cannot be opened for any other
     * reason then a <code>FileNotFoundException</code> is thrown.
     *
     * @param      file               the file to be opened for writing.
     * @param     append      if <code>true</code>, then bytes will be written
     *                   to the end of the file rather than the beginning
     * @exception  FileNotFoundException  if the file exists but is a directory
     *                   rather than a regular file, does not exist but cannot
     *                   be created, or cannot be opened for any other reason
     * @exception  SecurityException  if a security manager exists and its
     *                   be created, or cannot be opened for any other reason
     * @exception  SecurityException  if a security manager exists and its
     *               <code>checkWrite</code> method denies write access
     *               to the file.
     * @see        java.io.File#getPath()
     * @see        java.lang.SecurityException
     * @see        java.lang.SecurityManager#checkWrite(java.lang.String)
     * @since 1.4
     */
    public FileOutputStream(File file, boolean append)
            throws FileNotFoundException
    {
        String name = (file != null ? file.getPath() : null);
        SecurityManager security = System.getSecurityManager();
        if (security != null) {
            security.checkWrite(name);
        }
        if (name == null) {
            throw new NullPointerException();
        }
        if (file.isInvalid()) {
            throw new FileNotFoundException("Invalid file path");
        }
        this.fd = new FileDescriptor();
        fd.attach(this);
        this.append = append;
        this.path = name;
    
        open(name, append);
    }
    
    /**
     * Creates a file output stream to write to the specified file
     * descriptor, which represents an existing connection to an actual
     * file in the file system.
     * <p>
     * First, if there is a security manager, its <code>checkWrite</code>
     * method is called with the file descriptor <code>fdObj</code>
     * argument as its argument.
     * <p>
     * If <code>fdObj</code> is null then a <code>NullPointerException</code>
     * is thrown.
     * <p>
     * This constructor does not throw an exception if <code>fdObj</code>
     * is {@link java.io.FileDescriptor#valid() invalid}.
     * However, if the methods are invoked on the resulting stream to attempt
     * I/O on the stream, an <code>IOException</code> is thrown.
     *
     * @param      fdObj   the file descriptor to be opened for writing
     * @exception  SecurityException  if a security manager exists and its
     *               <code>checkWrite</code> method denies
     *               write access to the file descriptor
     * @see        java.lang.SecurityManager#checkWrite(java.io.FileDescriptor)
     */
    public FileOutputStream(FileDescriptor fdObj) {
        SecurityManager security = System.getSecurityManager();
        if (fdObj == null) {
            throw new NullPointerException();
        }
        if (security != null) {
            security.checkWrite(fdObj);
        }
        this.fd = fdObj;
        this.append = false;
        this.path = null;
    
        fd.attach(this);
    }

##  参考：

[1] [ http://www.cnblogs.com/skywang12345/p/io_07.html
](http://www.cnblogs.com/skywang12345/p/io_07.html)  
[2] [
http://wangkuiwu.github.io/2012/05/07/FileInputStreamAndFileOutputStream/
](http://wangkuiwu.github.io/2012/05/07/FileInputStreamAndFileOutputStream/)

