---
title: 「CF83D」Numbers-容斥原理
urlname: CF83D
date: 2019-01-09 19:17:41
tags:
- 题解
- 数论
- 容斥原理
categories: OI
visible:
---

给出三个整数 $l,r,k$( $1 \le  l ≤  r \le 2\cdot10^9, 2 \le k \le 2 \cdot 10^9)$。

求在区间 $[l,r]$ 内满足 $k \mid i$ ， 且对于任意 $j \in [2,k-1]$ 都**不满足** $k \mid  i$ 的数 $i$ 的个数。

<!-- more -->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/83/D)

## 题解

可以发现，问题可以转化为在 $[l,r]$ 中最小质因数是 $k$ 的数的个数。

现将问题差分，变成在 $[1,n]$ 以内最小质因数是 $k$ 的数的个数。

我们考虑转化问题，如果我们令 $f[i]$ 为 $i$ 的最小质因数，那么显然这个可以在线性的时间内筛出来（我们预处理一些，假设到 $\text{MAX}$ ）。

我们的问题就可以变成：

求出在 $[1,n]$ 中，$f[i] = k$ 的数的个数，明显发现，这个可以转化为在 $[1,\lfloor\frac{n}{k}\rfloor]$ 内， $f[i] \ge k$  的数的个数。
我们可以对数据进行分治，如果我们发现：


我们可以对数据进行分治，如果我们发现：
1. $\lfloor\frac{n}{k}\rfloor < \text{MAX}$，直接线性解决这个问题
2. $\lfloor\frac{n}{k}\rfloor \ge \text{MAX}$，这个时候如果我们线性筛筛的比较大，剩下的 $k$ 应该会比较小。这个时候事实上我们要求的是所有 $[1,n]$ 当中有多少个数存在一个小于 $k$ 的质因数，这个东西可以容斥解决。容斥的复杂度是 $2^k$，那么我们应该让线性筛筛出来的东西尽量大即可。而且事实上我们可以加入一个剪枝，也就是一旦你现在要容斥的数已经超过了 $n$ ，就直接 break 掉。

这样的话，复杂度大约是可以过掉的。

实际上可能要调一调线性筛的 $\text{MAX}$ ，但这个题目时限比较宽松，也是可以过掉的。


## 代码

{% fold %}
```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 10000000;

int prime[MAXN],cnt;
bool vis[MAXN];
int f[MAXN];// 最小质因数

void sieve(){
  memset(vis,0,sizeof(vis));
  f[1] = 1;
  for(int i = 2;i<MAXN;i++){
    if(vis[i] == 0){
      f[i] = i;
      prime[++cnt] = i;
    }
    for(int j = 1;i*prime[j]< MAXN && j<=cnt;j++){
      vis[i*prime[j]] = 1;
      f[i*prime[j]] = prime[j];
      if(i%prime[j] == 0)
        break;
    }
  }
}

bool is_prime(int k){
  int t = sqrt(k);
  for(int i = 2;i<=t;i++){
    if(k % i == 0)return 0;
  }
  return 1;
}


int cal1(int n,int k){
  int ans = 0;
  for(int i = 1;i<=n;i++){
    if(i == 1 || f[i] >= k) ans++;
  }
  return ans;
}


int LIM = 0,lim = 0;// LIM 质数个数，lim 为 n/k
#define ll long long
ll ans = 0;

void dfs(int p,ll now,ll f){
  if(now > lim) return;
  if(p > LIM) {
    ans += f * (lim/now);return;
  }
  dfs(p+1,now,f);
  dfs(p+1,now*prime[p],-f);
}

int cal2(int n,int k){
  LIM = 0,lim = n,ans = 0;
  for(int i = 1;prime[i] < k;i++)LIM++;
  dfs(1,1,1);
  return int(ans);
}

int calc(int n,int k){
  if(!n || !is_prime(k)) return 0;
  if(n/k < MAXN) return cal1(n/k,k);
  else return cal2(n/k,k);
}

int l,r,k;

int main(){
  scanf("%d %d %d",&l,&r,&k);
  sieve();
  printf("%d\n",calc(r,k) - calc(l-1,k));  
  return 0;
}
```
{% endfold %}