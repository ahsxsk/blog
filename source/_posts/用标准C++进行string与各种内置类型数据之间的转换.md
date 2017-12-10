title: 用标准C++进行string与各种内置类型数据之间的转换
date: 2015-01-01 13:09:04
tags: [以前]
-------------------------------------------------------
原文地址：http://blog.csdn.net/roger_77/article/details/639410，

要实现这个目标，非  ** stringstream ** 类莫属。这个类在<sstream>头文件中定义，

<sstream>库定义了三种类：istringstream、ostringstream和stringstream，分别用来进行流的输入、输出和输入输出操作
。另外，每个类都有一个对应的宽字符集版本。简单起见，我主要以stringstream为中心，因为每个转换都要涉及到输入和输出操作。示例1示范怎样使用一个st
ringstream对象进行从

** string到int类型的转换 **

注意，<sstream>使用string对象来代替字符数组。这样可以避免缓冲区溢出的危险。而且，传入参数和目标对象的类型被自动推导出来，即使使用了不正确的格
式化符也没有危险。

示例1：

std::stringstream stream;

string result="10000";  
int n = 0;  
stream << result;  
stream >> n;//n等于10000

** int到string类型的转换 **

string result;  
int n = 12345;  
stream << n;  
result =stream.str();// result等于"12345"

** 重复利用stringstream对象 **

如果你打算在多次转换中使用同一个stringstream对象，记住再每次转换前要使用clear()方法，在多次转换中重复使用同一个stringstream（
而不是每次都创建一个新的对象）对象最大的好处在于效率。stringstream对象的构造和析构函数通常是非常耗费CPU时间的。经试验，单单使用clear()
并不能清除stringstream对象的内容，仅仅是了该对象的状态，要重复使用同一个stringstream对象,需要使用str()重新初始化该对象。

示例2：

std::stringstream strsql;  
for (int i= 1; i < 10; ++i)  
{  
strsql << "insert into test_tab  values(";  
strsql  << i << ","<< (i+10) << ");";  
std::string str = strsql.str(); // 得到string  
res = sqlite3_exec(pDB,str.c_str(),0,0, &errMsg);

std::cout << strsql.str() << std::endl;

strsql.clear();  
strsql.str("");  
}

** 转换中使用模板 **

也可以轻松地定义函数模板来将一个任意的类型转换到特定的目标类型。例如，需要将各种数字值，如int、long、double等等转换成字符串，要使用以一个str
ing类型和一个任意值 _ t _ 为参数的to_string()函数。to_string()函数将 _ t _
转换为字符串并写入result中。使用str()成员函数来获取流内部缓冲的一份拷贝：

示例3：

template<class T>

void to_string(string & result,const T& t)

{

ostringstream oss;//创建一个流

oss<<t;//把值传递如流中

result=oss.str();//获取转换后的字符转并将其写入result  
}

这样，你就和衣轻松地将多种数值转换成字符串了：

to_string(s1,10.5);//double到string

to_string(s2,123);//int到string

to_string(s3,true);//bool到string

可以更进一步定义一个通用的转换模板，用于任意类型之间的转换。函数模板convert()含有两个模板参数out_type和in_value，功能是将in_va
lue值转换成out_type类型：

template<class out_type,class in_value>

out_type convert(const in_value & t)

{

stringstream stream;

stream<<t;//向流中传值

out_type result;//这里存储转换结果

stream>>result;//向result中写入值

return result;

}

这样使用convert()：

double d;

string salary;

string s=”12.56”;

d=convert<double>(s);//d等于12.56

salary=convert<string>(9000.0);//salary等于”9000”

** 结论 **

在过去留下来的程序代码和纯粹的C程序中，传统的<stdio.h>形式的转换伴随了我们很长的一段时间。但是，如文中所述，基于stringstream的转换拥有
类型安全和不会溢出这样抢眼的特性，使我们有充足得理由抛弃<stdio.h>而使用<sstream>。

当然现在还有一个更好的选择，那就是使用boost库中的lexical_cast,它是类型安全的转换。如下例：

#include <iostream>  

#include <sstream>

#include <string>

#include <cstdlib>

#include <boost/lexical_cast.hpp>

using namespace std;

using namespace boost;

int main(void)

try{

//以下是内置类型向string转换的解决方案

//lexical_cast优势明显

int ival;

char cval;

ostringstream out_string;

string str0;

string str1;

ival = 100;

cval = 'w';

out_string << ival << " " << cval;

str0 = out_string.str();

str1 = lexical_cast<string>(ival)

\+ lexical_cast<string>(cval);

cout << str0 << endl;

cout << str1 << endl;

//以下是string向内置类型转换的解决方案

//几乎和stringstrem相比，lexical_cast就是类型安全的，

int itmpe;

char ctmpe;

str0 = "100k";

str1 = "100h";

istringstream in_string( str0 );

in_string >> itmpe >> ctmpe;

cout << itmpe << " " << ctmpe << endl;

itmpe = lexical_cast<int>(str1);

ctmpe = lexical_cast<char>(str1);

system( "PAUSE" );

return 0;

}

catch(bad_lexical_cast e)

{

cout << e.what() << endl;

cin.get();

}

