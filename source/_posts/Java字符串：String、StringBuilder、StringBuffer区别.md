title: Java字符串：String、StringBuilder、StringBuffer区别
date: 2017-11-11 13:09:04
tags: [Java字符串]
------------------

在学习String、StringBuilder、StringBuffer这三个类的时候在github上看到如下几个问题：

###  1\. 成员变量、局部变量在什么场景下用哪个更合适

###  2\. 他们之间效率如何，为什么

###  3\. 有没有存在特殊情况

###  4\. 编译器对他们的优化

下面尝试对这几个问题进行回答  

###  回答1：

String是不可变的字符串，任何拼接、修改操作都是返回的新的String对象，原对象并没有改变；StringBuilder和StringBuffer是可变
字符串，修改操作改变的是原有的对象。StringBuilder和StringBuffer的区别是StringBuffer是线程安全的，他的大部分API都使用
synchronized 关键字修饰。所以针对这三个类的使用场景归纳如下  
1）修改操作较少的场景可以用String；  
2）单线程情况下字符串需要大量操作的适合使用StringBuilder；  
3）多线程操作情况下大量操作字符串适合使用StringBuffer。

###  回答2：

String的修改、拼接等操作由于需要重新申请新对象所以速度一般情况下比StringBuilder和StringBuffer慢。StringBuffer
API采用synchronized修饰，一般速度会比StringBuilder慢。

###  回答3：

用例子回答这个问题

    
    
    String s = “a” + “b” + “c” + “d”;
    StringBuilder sb = new StringBuilder("a").append("b").append("c").append("d");

回答2指出StringBuilder速度比String快，这两个语句执行效率情况如下：

    
    
    public void testSpeed() {
        long t1 = System.nanoTime();
        String s = "a" + "b" + "c" + "d";
        long t2 = System.nanoTime();
        System.out.println("String耗时为: " + (t2 - t1));
        long t3 = System.nanoTime();
        StringBuilder sb = new StringBuilder("a").append("b").append("c").append("d");
        long t4 = System.nanoTime();
        System.out.println("StringBuilder耗时为: " + (t4 -t3));
    }

执行结果为：

    
    
    String耗时为: 3611
    StringBuilder耗时为: 13617

###  回答4：

回答3中指出了String效率可能会比StringBuilder高，产生这种情况的原因是JVM对此进行了优化。理论上说String s = “a” +
“b” + “c” + “d”; 这条语句会产生4个对象，实际向JVM将这条语句优化为String s = “abcd”;所以效率高。

