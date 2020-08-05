---
title: 「SCOI2007」排列-状压dp
urlname: SCOI2007-permutation
date: 2018-10-02 09:35:55
tags:
- 状压dp
- 动态规划
categories: 
- OI
- 题解
series:
- 各省省选
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

给一个数字串 $s$ 和正整数 $d$ , 统计 $s$ 有多少种不同的排列能被 $d$ 整除（可以有前导 $0$ ）。

<!--more-->

## 链接
[Luogu P4163](https://www.luogu.org/problemnew/show/P4163)

## 题解

简单状压dp。

我们先考虑每个数字都不同的情况，然后在除掉每个数字出现次数的阶乘即可。

我们令 $s$ 的长度为 $n$，设状态 $dp[S][r]$ 为目前选了集合 $S$ ，模 $d$ 余数为 $r$ 的情况数，有如下转移方程：

$$
dp[S][r] = \sum dp[S | 2^i][r*10 + s[i]],\text{if } S \& 2^i = 0 
$$

边界情况就是 $dp[2^{n+1}-1][0] = 1$ 其余均为 $0$。

$\text{dfs}$ 即可，时间复杂度为 $O(n2^n \times d)$，事实上跑不满...

## 代码

```cpp
#include <cstdio>
#include <cstring>
using namespace std;

const int MAXN = 11;

char str[MAXN];int n,d;
int dp[1<<MAXN][1001];

void init(){
  scanf("%s",str);
  n = strlen(str);
  scanf("%d",&d);
  memset(dp,-1,sizeof(dp));
  // printf("str:%s d:%d\n",str,d);
}


int dfs(int now,int r){
  if(now == (1<<n)-1) return r == 0;
  if(dp[now][r] != -1) return dp[now][r];
  int ans = 0;
  for(int i = 0;i<n;i++){
    if((now & (1<<i)) == 0){
      ans += dfs(now|(1<<i),(r*10+(str[i]-48))%d);
    }
  }
  return dp[now][r] = ans;
}

void solve(){
  dfs(0,0);
  int t[MAXN],power[MAXN];
  for(int i = 0;i<=9;i++) t[i] = 0;
  for(int i = 0;i<n;i++)  t[int(str[i]-48)]++;
  power[0] = 1;
  for(int i = 1;i<=n;i++) power[i] = power[i-1] * i;
  int ans = dp[0][0];
  for(int i = 0;i<=9;i++) ans /= power[t[i]];
  printf("%d\n",ans);
}


int main(){
  int T;
  scanf("%d",&T);
  for(int i = 1;i<=T;i++){
    init();
    solve();
  }
  return 0;
}
```

