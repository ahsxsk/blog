title: LeetCode:Increasing_Triplet_Subsequence
date: 2017-11-11 13:09:04
categories: [LeetCode]
------------------

Given an unsorted array return whether an increasing subsequence of length 3
exists or not in the array.

Formally the function should:

Return true if there exists i, j, k  
such that arr[i] < arr[j] < arr[k] given 0 ≤ i < j < k ≤ n-1 else return
false.

Your algorithm should run in O(n) time complexity and O(1) space complexity.

Examples:  
Given [1, 2, 3, 4, 5],  
return true.

Given [5, 4, 3, 2, 1],  
return false.

题干的意思是给定未排序数组，从中找到三个满足arr[i] < arr[j] < arr[k] given 0 ≤ i < j < k ≤
n-1递增数字时返回true，找不到返回false。

##  解题思路：

设定两个数字min和middle，min保存已发现的最小值，middle保存仅比min大的第二小值。

    
    
    if num <= min 则 min = num
    else if num <= middle 则 middle = num
    else 则return true；原因是 此时的num 肯定比min,middle都大，有min < middle < num

源码如下：

    
    
    /**
     * Increasing Triplet Subsequence
     * @param nums
     * @return
     */
    public boolean increasingTriplet(int[] nums) {
        int min = Integer.MAX_VALUE;
        int middle = Integer.MAX_VALUE;
        for (int num : nums) {
            if (num <= min) {
                min = num;
            } else if (num <= middle) {
                middle = num;
            } else {
                return true;
            }
        }
        return false;
    }

