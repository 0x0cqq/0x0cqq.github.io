---
title: 「CF321E」Ciel and Gondolas-wqs二分+决策单调性
urlname: CF321E
date: 2019-02-12 22:07:23
tags:
- 题解
- 动态规划
- wqs二分
- 决策单调性
categories: OI
visible:
---

Ciel 狐狸在游乐园里排队等待上摩天轮。现在有 $n$ 个人按编号顺次在队列里，有 $m$ 条船，第 $i$ 条船到时，前 $q_{i}$ 个人可以上船。保证 $\sum q_i = n$。 人总是不愿意和陌生人上同一条船的，当第 $i$ 个人与第 $j$ 个人处于同一条船上时，会产生 $u_{i,j}$ 的沮丧值。请你求出最小的沮丧值和。一条船上的人两两都会产生沮丧值，不会计算这个沮丧值两次。

<!-- more -->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/321/E)

## 题解

我们注意到我们有一个简单的转移方程：

$$
dp[i][j] = \min_{1 \le p < i}(dp[p][j-1] + g(p+1,j))
$$

其中 $g(i,j)$ 表示从 $i$ 到 $j$ 中选中所有人需要耗费的代价。

这个东西的复杂度是 $O(n^2m)$ ， 我们可以用决策单调性优化到 $O(nm \log n)$ ，但是这个不足以过掉该题，我们可以使用 wqs 二分 + 决策单调性优化到 $O(n \log n \log m)$ 。

需要注意的是这里的代价应当是负的，也就是我们需要加上代价。（差不多啦

需要读入优化。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;
 
 
namespace fast_io {
  inline char read(){static const int IN_LEN=1000000;static char buf[IN_LEN],*s,*t;return s==t?(((t=(s=buf)+fread(buf,1,IN_LEN,stdin))==s)?-1:*s++) : *s++;}
  inline void read(int &x){static bool iosig;static char c;for (iosig=false,c=read();!isdigit(c);c=read()){if(c=='-')iosig=true;if(c==-1)return;}for(x=0;isdigit(c);c=read())x=((x+(x<<2))<<1)+(c^'0');if(iosig)x=-x;}
}using namespace fast_io;
 
const int MAXN = 4100;
 
int n,m;
char tmp[MAXN*2];
int a[MAXN][MAXN],s[MAXN][MAXN];// 前 i 个与前 j 个的答案
 
int G(int x,int y){// 第 x 个到第 y 个的答案，x <= y
  return (s[y][y] - 2 * s[x-1][y] + s[x-1][x-1])/2;
}
 
int dp[MAXN],siz[MAXN],fi,la;
struct Node{
  int p,l,r;
  Node(int _p = 0,int _l = 0,int _r = 0){p = _p,l = _l,r = _r;}
};
 
Node q[MAXN];//[fi,la]
 
void reset(){dp[0] = siz[0] = la = 0;fi = 1;}
 
int cal(int now,int last,int k){return dp[last] + G(last+1,now) + k;}
 
int check(int k){// k 为代价，每个都加上一个 k ，因为斜率是负数
  // 不限分段个数，考虑 dp[i] 为前 i 个分若干段的最小值，每分一段要加一个 k x
  reset();
  q[++la] = Node(0,1,n);
  for(int i = 1;i<=n;i++){
    while(fi < la && q[fi].r < i) fi++;
    dp[i] = cal(i,q[fi].p,k),siz[i] = siz[q[fi].p] + 1;
    // 为什么对新来的这么不友好？？？
    if(cal(n,q[la].p,k) <= cal(n,i,k)) continue;
    while(fi < la && cal(q[la].l,q[la].p,k) > cal(q[la].l,i,k)) la--;
 
    int L = q[la].l,R = q[la].r + 1;// 二分决策点
    while(L!=R){
      int mid = (L+R)/2;
      if(cal(mid,q[la].p,k) > cal(mid,i,k))
        R = mid;
      else
        L = mid+1;
    }
    q[la].r = L-1;
    q[++la] = Node(i,L,n);
  }
  // 最优分几段？
  return siz[n];
}
 
void init(){
  read(n),read(m);
  for(int i = 1;i<=n;i++)
    for(int j = 1;j<=n;j++){
      read(a[i][j]);
      s[i][j] = s[i-1][j] + s[i][j-1] - s[i-1][j-1] + a[i][j];
    }
}
 
void solve(){
  int L = 0,R = s[n][n];
  while(L != R){
    int mid = (L+R)/2;
    if(check(mid) <= m) R = mid;
    else                L = mid+1;
  }
  check(L);
  printf("%d\n",dp[n] - L*m);
}
 
 
int main(){
  init();
  solve();
  return 0;
}
```

