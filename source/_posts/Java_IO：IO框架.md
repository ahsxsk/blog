title: Java_IO：IO框架
date: 2017-11-11 13:09:04
categories: [Java_IO]
------------------
Java IO：IO框架

Java 流处理分为字节流和字符流。字节流处理的单位是byte，而字符流处理的单位是以2个字节为单位的Unicode编码字符。字符流的操作效率比字节流高，字
符流按字符处理，字节流一次只能处理一个字节。下面是网上盗用的图（ [
http://blog.csdn.net/yczz/article/details/38761237
](http://blog.csdn.net/yczz/article/details/38761237) ）  
![IO框架图](http://img.blog.csdn.net/20160324162626046)

##  1 字节流 InputStream/OutputStream（创建一个输入/输出的Stream流）

InputStream是字节输入流的基类，是一个抽象类，它提供的方法有：  
int available() //返回stream中的可读字节数，inputstream类中的这个方法始终返回的是0，这个方法需要子类去实现。

    
    
    void close() //关闭stream方法，这个是每次在用完流之后必须调用的方法。
    int read() //方法是读取一个byte字节,但是返回的是int。
    int read(byte[]) //一次性读取内容到缓冲字节数组
    int read(byte[],int,int) //从数据流中的哪个位置offset开始读长度为len的内容到缓冲字节数组
    long skip(long) //从stream中跳过long类型参数个位置
    synchronized void mark(int) //用于标记stream的作用
    boolean markSupported() //返回的是boolean类型，因为不是所有的stream都可以调用mark方法的，这个方法就是用来判断stream是否可以调用mark方法和reset方法
    synchronized void reset() //这个方法和mark方法一起使用的，让stream回到mark的位置。

OutputStream是一个输出字节流，是一个抽象类，他提供的方法有：

    
    
    void write(int) //写入一个字节到stream中
    void write(byte[]) //写入一个byte数组到stream中
    void write(byte[],int,int) //把byte数组中从offset开始处写入长度为len的数据
    void close() //关闭流，这个是在操作完stream之后必须要调用的方法
    void flush() //这个方法是用来刷新stream中的数据，让缓冲区中的数据强制的输出

###  1.1 FileInputStream/FileOutputStream

把一个文件作为InputStream/OutputStream，实现对文件的读写操作。

###  1.2 FilterInputStream/FilterOutputStream

一个提供过滤功能的InputStream/OutputStream，并不常用，常用的是他们的子类BufferedInputStream、DataInputS
tream、BufferedOutputStream、DataOutputStream和PrintStream。  
BufferedInputStream提供了将原始数据分批加载到内存的功能，提高处理效率。  
DataInputStream提供了允许应用程序以与机器无关方式从底层输入流中读取基本 Java 数据类型。  
BufferedOutputStream通过字节数组来缓冲数据，当缓冲区满或者用户调用flush()函数时，它就会将缓冲区的数据写入到输出流中。  
DataOutputStream提供了允许应用程序以与机器无关方式从底层输入流中写入基本 Java 数据类型。  
PrintStream是用来装饰其它输出流。它能为其他输出流添加了功能，使它们能够方便地打印各种数据值表示形式。

###  1.3 ObjectInputStream/ObjectOutputStream

对基本数据或对象进行序列化操作。

###  1.4 PipedInputStream/PipedOutputStream

它们的作用是让多线程可以通过管道进行线程间的通讯。在使用管道通信时，必须将PipedOutputStream和PipedInputStream配套使用。  
使用管道通信时，大致的流程是：我们在线程A中向PipedOutputStream中写入数据，这些数据会自动的发送到与PipedOutputStream对应的
PipedInputStream中，进而存储在PipedInputStream的缓冲中；此时，线程B通过读取PipedInputStream中的数据。就可以
实现，线程A和线程B的通信。

###  1.5 ByteArrayInputStream/ByteArrayOutputStream

ByteArrayInputStream它包含一个内部缓冲区，该缓冲区包含从流中读取的字节;  
ByteArrayOutputStream中的数据被写入一个 byte 数组。

##  2 字符流 Reader/Writer

Reader/Writer和InputStream/OutputStream功能类似，Reader/Writer操作的是字符char而InputStream
/OutputStream操作的是字节byte。

###  2.1 FileReader/FileWriter

和FileInputStream/FileOutputStream对应。

###  2.2 BufferedReader/BufferedWriter

和BufferedInputStream/BufferedOutputStream对应。

###  2.3 PipedReader/PipedWriter

和PipedInputStream/PipedOutputStream对应。

###  2.4 InputStreamReader/OutputStreamWriter

实现InputStream/OutputStream和Reader/Writer转换。

###  2.5 CharArrayReader/CharArrayWriter

和ByteArrayInputStream/ByteArrayOutputStream对应。

##  参考

[1] [ http://blog.csdn.net/yczz/article/details/38761237
](http://blog.csdn.net/yczz/article/details/38761237)  
[2] [ http://blog.csdn.net/jiangwei0910410003/article/details/22376895
](http://blog.csdn.net/jiangwei0910410003/article/details/22376895)

