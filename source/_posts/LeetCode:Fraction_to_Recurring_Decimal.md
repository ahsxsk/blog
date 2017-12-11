title: LeetCode:Fraction_to_Recurring_Decimal
date: 2017-11-11 13:09:04
categories: [LeetCode]
------------------

##  1、题干

Given two integers representing the numerator and denominator of a fraction,
return the fraction in string format.

If the fractional part is repeating, enclose the repeating part in
parentheses.

For example,

  * Given numerator = 1, denominator = 2, return “0.5”. 
  * Given numerator = 2, denominator = 1, return “2”. 
  * Given numerator = 2, denominator = 3, return “0.(6)”. 

题干的意思是，给两个整数numerator，denominator，分别作为分子和分母，现在需要计算他的小数形式，并返回String类型，如果是循环小数，将
循环部分用小括号包起来。

##  2、解题思路

本题的难点在小数部分计算，具体思路如下：  
1）设两个变量分别存放每次计算完成的余数（remainder）和商（integer）,并将余数加入到一个数组中。  
2）每次计算后先到数组中查是否有相同的余数，如果有则说明出现循环小数。  
3）计算循环小数循环的位数，循环的位数是余数数组的长度减去重复余数上一次（也只会出现一次）出现的下标。

##  3、注意事项

1）负数情况  
2）Math.abs()处理Integer.MIN_VALUE返回的还是负值，整形衣橱

##  4、源码及注释

    
    
    /**
     * Fraction to Recurring Decimal
     * @param numerator
     * @param denominator
     * @return
     */
    public String fractionToDecimal(int numerator, int denominator) {
        if (numerator == 0) { //分子为0
            return "0";
        }
    
        if (denominator == 0) { //分母为0,返回空
            return "";
        }
    
        String result = ""; //存放最终结果
    
        if (numerator < 0 ^ denominator < 0) { //有一个是负数
            result += "-";
        }
    
        long first = Math.abs(Long.valueOf(numerator)); //分子
        long second = Math.abs(Long.valueOf(denominator)); //分母
    
        long integer = first / second; //整数部分
        long remainder = first % second; //余数
        if (remainder == 0) { //能够整除
            result += String.valueOf(integer);
            return result;
        } else { //有小数
            result = result + String.valueOf(integer) + ".";
        }
        List list = new ArrayList<>(); //存放余数, 下表即是余数出现的位置
        list.add(remainder);
        while (remainder != 0) {
            integer = remainder * 10 / second; //小数部分的结果
            remainder = remainder * 10 % second; //余数
            if (list.contains(remainder)) { //余数存在则说明出现了循环小数
                result += String.valueOf(integer);
                int position = list.size() - list.indexOf(remainder); //"("需要添加的位置,从后向前数
                int length = result.length(); //字符串长度
                String repeatNum = "(" + result.substring(length - position, length) + ")";
                String notRepeatNum = result.substring(0,length - position);
                result = notRepeatNum.concat(repeatNum);
                return result;
            }
    
            result += String.valueOf(integer); //正常计算
            list.add(remainder); //余数存入map
        }
        return result;
    }

