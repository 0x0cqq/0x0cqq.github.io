---
title: 「CF813D」Two Melodies-简单dp
urlname: CF813D
date: 2019-01-29 07:10:48
tags:
- 动态规划
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

给定一个长度为 $n$ 的数组，我们要从中找出两个不相交（不含邮相同元素的）的子序列，要求每个子序列的任意两个相邻元素的差的绝对值为 $1$ 或 在模 $7$ 意义下相同。请你求出这两个子序列长度和的最大值。

<!--more-->

## 题解

令 $dp[x][y]$ 表示第一个子序列最后一个元素取到 $x$ ，第二个子序列的最后一个元素取到 $y$ 的最大的和。

1. $x < y$ 
令 $dp[x][y] = dp[y][x]$
2. $x = y$
显然 $dp[x][y] = 0$
3. $x > y$
$$
dp[x][y] = \max _ {0 \le i < x,i \neq y}(dp[i][y]+1)
$$
其中 $i$ 到 $x$ 满足如上条件。

前两个的正确性很好理解，第三个的正确性如何保证呢？我们考虑到虽然我们只更新了第一个，但是我们第一种情况也就交换了两个子序列，所以事实上我们也可以算更新了两个子序列的。

我们这样转移是 $O(n^3)$ 的，不能通过本题。

我们可以优化这个 dp 。我们按照第一维 $y$ 从小到大，第二维 $x$ 从小到大更新。

对于每个 y ，我们可以维护两个数组 $\text{maxmod[j]},\text{maxnum[j]}$，分别代表在当前 $y$ 中，（当前计算到 $dp[x][y]$），满足 $0 \le i < x$ 且 $i \neq y$ 的最大的 dp 值，而且这些 $a[i]$ 在模 7 的余数（或本身数值）为 $j$ 。

我们发现这样的转移就变成了 $O(1)$ 的。

所以，最后的时间复杂度就变成了 $O(n^2)$ 。 

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 5100,MAXC = 110000;

int n,a[MAXN];
int dp[MAXN][MAXN];// dp[x][y]
int maxnum[MAXC],maxmod[7];

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n;i++) scanf("%d",&a[i]);
}

void solve(){
  int ans = -1e9;
  for(int i = 0;i<MAXC;i++) maxnum[i] = -1e9;
  for(int y = 0;y<=n;y++){
    for(int x = 1;x<=n;x++) maxnum[a[x]] = -1e9;
    for(int i = 0;i<7;i++) maxmod[i] = -1e9;
    dp[0][y] = dp[y][0];
    for(int x = 1;x <= y-1;x++){
      dp[x][y] = dp[y][x];
      maxnum[a[x]] = max(maxnum[a[x]],dp[x][y]);
      maxmod[a[x] % 7] = max(maxmod[a[x] % 7],dp[x][y]);
    }
    for(int x = y+1;x<=n;x++){
      dp[x][y] = -1e9;
      dp[x][y] = max(dp[x][y],maxnum[a[x]-1] + 1);
      dp[x][y] = max(dp[x][y],maxnum[a[x]+1] + 1);
      dp[x][y] = max(dp[x][y],maxmod[a[x]%7] + 1);
      dp[x][y] = max(dp[x][y],dp[0][y] + 1);
      maxnum[a[x]] = max(maxnum[a[x]],dp[x][y]);
      maxmod[a[x] % 7] = max(maxmod[a[x] % 7],dp[x][y]);   
    }
    for(int x = 1;x<=n;x++){
      ans = max(ans,dp[x][y]);
    }
  }
  printf("%d\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```

