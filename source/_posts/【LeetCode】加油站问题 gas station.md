【LeetCode】加油站问题 gas station

加油站问题解释和分析请看陈立人待字闺中博客 [ http://mp.weixin.qq.com/s?__biz=MjM5ODIzNDQ3Mw==&mid=2
00400990&idx=1&sn=fad0aaa933a5fdf0f62dcead4a4cb877#rd ](http://mp.weixin.qq.co
m/s?__biz=MjM5ODIzNDQ3Mw==&mid=200400990&idx=1&sn=fad0aaa933a5fdf0f62dcead4a4c
b877#rd)

  

核心思想是：

1、总加油量要大于总消耗量。

2、如果在第 i 站无法到达第 i + 1 站，那么从 i-1，i-2……等第 i 站前面的站开始出发必然都到不了第 i+1
站。所以只有可能从第i+1站开始，才有可能走一圈。

3、如果低 i+1站能够到达第n站，并且总加油量大于总消耗量，那么从 i+1站到第n站结余的油量必然能够满足从0站到 i+1站的需求。（0和n是同一个站）。

  

下面是C++代码。

    
    
    /**************************************************
    *INPUT
    *	gas[i]:第i站加油量
    *	cost:从i站到i+1站消耗量
    *	len:加油站个数
    *RETURN
    *	-1：失败
    *	start：从第i站出发可以走一圈
    ****************************************************/
    int canCompleteCircuit(int* gas, int* cost, int len)
    {
    	if(gas == NULL || cosr == NULL || len <= 0)
    		return -1;
    	int tank = 0;	//邮箱油量
    	int total = 0;  //总加油量-消耗量
    	int start = 0;  //出发站
    	for(int i = 0; i < len; i++)
    	{
    		tank = gas[i] - cost[i];
    		total = gas[i] - cost[i];
    		if(tank < 0)
    		{
    			start = (i + 1) % len;
    			tank = 0
    		}
    	}
    	if(total < 0)
    		return -1;
    	else
    		return start;
    }

  

参考资料：

[ http://blog.csdn.net/jellyyin/article/details/12245429
](http://blog.csdn.net/jellyyin/article/details/12245429)  

[ http://mp.weixin.qq.com/s?__biz=MjM5ODIzNDQ3Mw==&mid=200400990&idx=1&sn=fad0
aaa933a5fdf0f62dcead4a4cb877#rd ](http://mp.weixin.qq.com/s?__biz=MjM5ODIzNDQ3
Mw==&mid=200400990&idx=1&sn=fad0aaa933a5fdf0f62dcead4a4cb877#rd)  

