---
title: 「CF875E」Delivery Club-二分+贪心
urlname: CF875E
date: 2019-03-03 23:07:28
tags:
- 贪心
categories: 
- OI
- 题解
series:
- Codeforces
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

有两个快递员，分别在 $s_1, s_2(0\le s_1,s_2\le 10^9)$ 位置。现在有 $n(1\le n\le 100000)$ 个任务，需要依次完成，每个任务用一个整数 $x_i$ 表示要将货物送到 $x_i$ 位置，让任何一个快递员到 $x_i$ 都可以。

由于快递员之间需要有对讲机联系，请你设计一种方案使得两个快递员之间的最长距离最短。

<!--more-->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/875/E)

## 题解

我们考虑二分，然后问题就变成了你能不能在二分的限制条件 $M$ 的间距内完成这个问题。

我们考虑贪心的解决这个问题。如果我们令 $[l_i,r_i]$ 是在走到第 $i$ 个之前的时候，存在合法方案当且仅当存在快递员位于 $[l_i,r_i]$ 而且两个快递员之间距离不超过 $M$ （这样两个快递员都可以移动）。

我们发现 $[l_n,r_n]$ 应该是 $[x_n-M,x_n+M]$ （比较显然）。

那么，这个时候我们已经有了 $[l_{i+1},r_{i+1}]$ ，我们如何推出 $[l_{i},r_i]$ 呢？
我们考虑到进行完第 $i$ 个任务之后，必然会有一位老哥位于 $x_i$ ，那么这个时候如果 $x_i$ 在 $[l_{i+1},r_{i+1}]$ 之间，我们只需要满足保证在某老哥走的时候第二个条件时刻满足即可：也就是 $l_i = x_i - M,r_i = x_i+M$ 。 为什么这个是对的呢？我们可以发现，如果一位老哥在这个区间里面，然后剩下一位老哥无论在哪一定可以在满足 $M$ 的限制之下到达 $x_i$ ，然后我们下一轮也就是win的了。

那如果 $x_i$ 不在 $[l_{i+1},r_{i+1}]$ 中呢？那我们考虑有一位老哥就必须在 $[l_{i+1},r_{i+1}]$ 中（因为他必然不动），但是他所在的位置还得满足能够让另一位老哥走到 $x_i$ 也能和他保持联系，所以他必须在 $[x_i-M,x_i+M]$。这两个区间求交之后就是答案。

最后判一下 $[l_1,r_1]$ 就可以了。

时间复杂度： $O(n \log C)$

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 110000;

int n,s1,s2,x[MAXN];

bool check(int M){
  int L = x[n]-M,R = x[n]+M;
  for(int i = n-1;i>=1;--i){
    if(L <= x[i] && x[i] <= R) L = x[i] - M,R = x[i] + M;
    else                       L = max(L,x[i]-M),R = min(R,x[i]+M);   
  }
  return (L <= s1 && s1 <= R) || (L <= s2 && s2 <= R);
}

int main(){
  scanf("%d %d %d",&n,&s1,&s2);
  for(int i = 1;i<=n;i++) scanf("%d",&x[i]);
  int L = abs(s1-s2),R = 1e9;
  while(L!=R){int mid = (L+R)/2;
    if(check(mid)) R = mid;
    else           L = mid+1; 
  }
  printf("%d\n",L);
}
```

