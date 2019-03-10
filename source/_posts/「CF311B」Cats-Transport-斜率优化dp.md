---
title: 「CF311B」Cats Transport-斜率优化dp
urlname: CF311B
date: 2018-12-27 20:55:16
tags:
- 题解
- 动态规划
- 斜率优化
categories: OI 
visible:
---

Zxr960115 是一个大农场主。他养了 $m$ 只可爱的猫子,雇佣了 $p$ 个铲屎官。这里有一条又直又长的道路穿过了农场，有 $n$ 个山丘坐落在道路周围，编号自左往右从1到n。山丘 $i$ 与山丘 $i-1$ 的距离是 $d_i$ 米。铲屎官们住在 $1$ 号山丘。

一天，猫子们外出玩耍。猫子 $i$ 去山丘 $h_i$ 游玩，在 $t_i$ 时间结束他的游玩，然后在山丘 $h_i$ 傻等铲屎官。铲屎官们必须把所有的猫子带上。每个铲屎官都会从 $1$ 走到 $n$ 号山丘，可以不花费时间的把所有路途上游玩结束的猫子带上。每个铲屎官的速度为一米每单位时间，并且足够强壮来带上任意数量的猫子。

你的任务是安排每个铲屎官出发的时间，最小化猫子们等待的时间之和。

<!-- more -->

## 链接

[Codeforces](https://codeforc.es/problemset/problem/311/B)

## 题解

我们令 
$$
D[i] = \sum_{j=2}^i d[j] 
$$

那我们可以吧所有的 $t[i]$ 减去 $D[h[i]]$ ，得到一个新的 $t[i]$ ，那么如果一个饲养员在 $t \le t[i]$ 之前出发，就能够收集到这个猫，猫的等待时间为 $t[i] - t$。

我们再令 
$$
T[i] = \sum_{j = 1}^{i-1} t[j] 
$$

我们把猫按照新获得 $t[i]$ 排序之后，我们如果令 $dp[i][j]$ 为恰好取到前 $i$ 只猫，用去 $j$ 个饲养员时候的最小代价。

很明显有如下转移：

$$
dp[i][w] = \max_{0 \le j \le i-1}(dp[j][w-1] + t[i]\times (i-j) - (T[i] - T[j]))
$$ 

我们当 $j \le k$时，$k$ 比 $j$ 优等价于：

$$
dp[j][w-1] + t[i]\times (i-j) - T[i] + T[j] \ge dp[k][w-1] + t[i]\times (i-k) - T[i] + T[k]\\
dp[j][w-1] - t[i]\times j  + T[j] \ge dp[k][w-1] - t[i]\times k + T[k]\\
dp[j][w-1] + T[j] -dp[k][w-1] - T[k]  \ge t[i]\times j - t[i]\times k \\
dp[j][w-1] + T[j] -dp[k][w-1] - T[k]  \ge t[i]\times (j - k) \\
\frac{dp[j][w-1] + T[j] -dp[k][w-1] - T[k]}{(j - k)}  \le t[i] \\
\frac{Y(j) - Y(k)}{X(j)-X(k)} \le t[i]
$$

$t[i]$ 单调递增，那么我们一旦 $k$ 比 $j$ 优，那么 $k$ 就在之后会一直比 $j$ 优，我们就可以用单调队列（维护一个单调递增的队列？）优化这个问题，事实上是维护一个凸包..？

时间复杂度 $O(n + mp)$。

## 代码


```cpp
#include <bits/stdc++.h>
#define ll long long
#define inf 1e18
using namespace std;


const int MAXN = 110000;

int n,m,p;
int d[MAXN],h[MAXN],t[MAXN];
ll T[MAXN];

void init(){
  scanf("%d %d %d",&n,&m,&p);
  for(int i = 2;i<=n;i++){
    scanf("%d",&d[i]);
    d[i] += d[i-1];
  }
  for(int i = 1;i<=m;i++){
    scanf("%d %d",&h[i],&t[i]);
    t[i] -= d[h[i]];
  }
  sort(t+1,t+m+1);
  for(int i = 1;i<=m;i++){
    T[i] = T[i-1] + t[i];
  }
}

ll a[MAXN],b[MAXN];
ll *dp,*last;

int q[MAXN],fi,la;

double caly(int x){return last[x] + T[x];}
double calc(int j,int k){return (caly(j) - caly(k))/(j-k);}


ll caldp(int i,int j){
  return last[j] + 1LL * t[i] * (i-j) - (T[i] - T[j]);
}

void solve(){
  dp = a,last = b;
  for(int i = 0;i<=m;i++) dp[i] = inf;
  dp[0] = 0;
  for(int w = 1;w<=p;w++){
    fi = la = 0;
    q[0] = 0;
    swap(dp,last);
    for(int i = 1;i<=m;i++){
      while(fi < la && calc(q[fi],q[fi+1]) <= t[i]) fi++;
      dp[i] = caldp(i,q[fi]);
      while(fi < la && calc(q[la-1],q[la]) >= calc(q[la],i)) la--;
      q[++la] = i;
    }
  }
  printf("%lld\n",dp[m]);
}

int main(){
  init();
  solve();
  return 0;
}
```

