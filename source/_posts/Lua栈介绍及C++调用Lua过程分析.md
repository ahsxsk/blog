Lua栈介绍及C++调用Lua过程分析

[ ** _ C++向Lua传递数组 _ **
](http://blog.csdn.net/sk199048/article/details/26368103) 中描述了C++调用Lua过程。

今天在群里看到有人问下面这段代码是什么意思？

    
    
    <span style="white-space:pre">	</span>lua_newtable(L); 
    	lua_pushnumber(L, -1); //push -1 into stack
    	lua_rawseti(L, -2, 0); //set array[0] by -1
    	for(int i = 0; i < len; i++)
    	{
    		lua_pushinteger(L, id[i]); //push 
    		lua_rawseti(L, -2, i+1); //
    	}

\-----------------------------------------------------------------------------
----------------------------------------------------------------------------

首先从Lua栈说起。

Lua和C/C++交互使用的是Lua栈，在 _ [ lua的堆栈（摘要） ](http://wind-
catalpa.blog.163.com/blog/static/1147535432013119103150929/) _ （http://wind-
catalpa.blog.163.com/blog/static/1147535432013119103150929/）中介绍了交互过程：

假设在一个lua文件中有如下定义

\-- hello.lua 文件

myName = "beauty girl"

![lua的堆栈（摘要） -     哃步呼吸 -
留住来去无影的思绪](http://img.my.csdn.net/uploads/201212/26/1356522919_2602.jpg)

  

请注意红色数字，代表通信顺序：

1） C++  想获取  Lua  的  myName  字符串的值，所以它把  myName  放到  Lua  堆栈（栈顶），以便  Lua  能看到

2） Lua  从堆栈（栈顶）中获取  myName  ，此时栈顶再次变为空

3） Lua  拿着这个  myName  去  Lua  全局表查找  myName  对应的字符串

4） 全局表返回一个字符串”beauty girl”

5） Lua  把取得的“  beauty girl  ”字符串放到堆栈（栈顶）

6） C++  可以从  Lua  堆栈中取得“  beauty girl  ”

  

若有9个元素分别入栈，则：

1. 正数索引，栈底是  1  ，然后一直到栈顶是逐渐  +1  ，最后变成  9  （  9  大于  1  ）

2. 负数索引，栈底是  -9  ，然后一直到栈顶是逐渐  +1  ，最后变成  -1  （  -1  大于  -9  ）

  

索引相关：

1. 正数索引，不需要知道栈的大小，我们就能知道栈底在哪，栈底的索引永远是1

2. 负数索引，不需要知道栈的大小，我们就能知道栈顶在哪，栈顶的索引永远是-1

\-----------------------------------------------------------------------------
------------------------------------------------------------------------------
------

下面我主要分析的是Lua栈内数据的变化。索引采用负数索引。

    
    
    lua_newtable(L); 

索引

栈内数据

-1 
table

这条语句将创建一个空table并将其压入栈。

  

    
    
    lua_pushnumber(L, -1); //push -1 into stack

索引

站内数据

-1 
-1 

-2 
table

现在栈顶元素变成了-1，table变为Lua栈中第二个元素。

  

    
    
    lua_rawseti(L, -2, 0); //set array[0] by -1

将栈顶元素（-1）赋值给栈内索引-2位置的元素（table）的第0个位置，并将栈顶元素弹出。

    
    
    lua_rawseti(L, index, n);

即table[n] = -1;

Lua栈变为如下状态：

索引

栈内数据

-1 
table

此时Lua栈中只有一个元素table。table不再是空的，它的第0个元素为-1。

\-----------------------------------------------------------------------------
------------------------------------------------------------------------

这条语句是真正接收C++数组的部分。假设id[] = {3, 4, 2};  

    
    
    <span style="white-space:pre">	</span>for(int i = 0; i < len; i++)
    	{
    		lua_pushinteger(L, id[i]); //push 
    		lua_rawseti(L, -2, i+1); //
    	}
    
    
    lua_pushinterger()操作之后栈变化。

索引

栈内数据

-1 
3

-2 
table

同样执行  lua_rawseti(L, -2, i+1);  之后  

索引

栈内数据

-1 
table

table[0] = -1; table[1] = 3；

for循环栈内变化也循环，table内容不断增加。

  

参考资料：

[1] http://blog.csdn.net/mm_lvw/article/details/5837403

[2] http://www.cnblogs.com/stephen-liu74/archive/2012/07/25/2470025.html

[3] http://wind-catalpa.blog.163.com/blog/static/1147535432013119103150929/  
  
  

