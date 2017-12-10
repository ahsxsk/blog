CFile类清空原有文件以及读取时末尾添加乱码的问题

** 1、文件清空写入  **

在向文件写内容时有时候希望将以前的全部清空，

这时候定义对象时

CFile file(m_Path,  CFile::modeCreate  |CFile::modeWrite);//指定路径以及文件操作方式  
file.Write(m_Content,m_Content.GetLength());//将编辑框的内容写入文件

modeCreate就是必须添加的。

如果没有添加，而第二次写入的长度没第一次长，那么就会出现末尾含有第一次写入内容。

** 2、读文件文件末尾添加乱码  **

今天用release模式编译了一个txt文件读取的文件发现总是在最后添加乱码，又实验了doc文件，也是最后乱码。在网上找了找资料“在char型字符串进行显示
时，它的尾部必须是以NULL为结束的，而在Debug模式下，系统本身有关于指针的冗余操作，因此它会给你自动截去后面的部分而给你补上结束符标志。在Releas
e模式下，系统是不会去管这些的，因此在显示时会出现些多的东西出来。 ”【 [
http://blog.csdn.net/caowei880123/article/details/6231436
](http://blog.csdn.net/caowei880123/article/details/6231436) 】

unsigned long Length = file.GetLength()+1;  
char* str = new char[Length];//自定义缓冲区  
memset(str,0,Length);  
file.Read(str,Length-1);//读取  
str[Length-1] = NULL;//  置为NULL

所以自己将文件最后一位置为结束标志NULL。就可以了。

