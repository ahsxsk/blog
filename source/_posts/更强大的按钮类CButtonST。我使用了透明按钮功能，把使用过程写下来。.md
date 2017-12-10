title: 更强大的按钮类CButtonST。我使用了透明按钮功能，把使用过程写下来
date: 2015-01-01 13:09:04
tags: [以前]
-----------------

1、使用按钮类CButtonST。CButtonST类主要包括BtnST.h、BtnST.cpp、BCMenu.h和BCMenu.cpp四个文件。先将上述4
个文件复制到自己的工程，然后在要使用这个类的项目中添加这四个文件。添加步骤：（1）选中【头文件】（【源文件】）->【右键】->【添加】->【现有项】。

2、在SdtAfx.h文件最后添加#include "BtnST.h"。

3、添加按钮，设ID为IDC_BUTTON1。

4、在Dlg类中添加成员变量。 CButtonST m_btn;

5、选中对话框。【右键】->【类向导】->【虚函数】->【OnInitDialog】。在函数中添加如下代码：

m_btn.SubclassDlgItem(IDC_BUTTON1,this);

m_btn.DrawTransparent(TRUE);

补充：

1、CButtonST类文件地址：

http://pan.baidu.com/share/link?shareid=4206748532&uk=2116186952

2、参考文件地址： [ http://ishare.iask.sina.com.cn/f/13016659.html
](http://ishare.iask.sina.com.cn/f/13016659.html)

参考文件更为强大，含有示例源代码。

3、如果编译出现 i 未定义错误，只需要在提示错误的地方添加 int 定义。

4、联系方式：sk199048@163.com

