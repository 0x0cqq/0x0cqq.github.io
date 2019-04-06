---
title: 「CF486E」LIS of Sequence-简单数据结构
urlname: CF486E
date: 2019-01-01 13:13:38
tags:
- 动态规划
- 数据结构
categories: 
- OI
- 题解
visible:
---

给你一个长度为 $n$ 的序列 $a_1,a_2,...,a_n$ ，你需要把这 $n$ 个元素分成三类：$1,2,3$，每类的条件如下：

1. **所有**的最长上升子序列**都不包含**这个元素

2. **有但非所有**的最长上升子序列**包含**这个元素

3. **所有**的最长上升子序列**都包含**这个元素

<!-- more -->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/486/E)

## 题解

由普通 $\text{LIS}$ 的 $O(n \log n)$ 算法扩展得到这个问题的 $O(n \log n)$ 的解法。

在原来的 LIS 过程中，我们只维护 $f[i]$ 为某值时， $a_i$ 的值最小为多少。现在我们将这些 $a_i$ 通通扔到 $n$ 个 `vector` 里面（而不是取 $\max$ ），可以发现，在每个 `vector` 里面，我们的 $a[i]$ 应当是单调递减的（我们将每个 `vector` 里面最后一个数当作普通 LIS 里面的数组的数）。

然后我们考虑如何计算方案数。

我们二分得到应当考虑的 $f[i]$ 的值，然后在这个 `vector` 里面二分得到一个位置，然后用另一个 `vector` 里面维护的前缀和计算得到这个能从多少种 $f[i]-1$ 的方案转移过来。最后我们要扫一遍全数组，得到全部的 LIS 条数。

为什么我们要计算方案数呢？因为这样可以计算出 $F1_i,F2_i$ （恰好以 $i$ 结尾、开始的最长 LIS 长度）， $G1_i,G2_i$ （上述 LIS 的个数）。这个时候我们就可以分类了。

我们把这个数列的最长长度称为 $\mathrm{MAXLEN}$ ，总共的 LIS 条数记作 $\mathrm{tot\_cnt}$

+ 如果 $F1[i] + F2[i] - 1 < \mathrm{MAXLEN}$，则该类型是 $1$ ；
+ 如果 $G1[i] * G2[i]  = \mathrm{tot\_cnt}$，则该类型是 $3$ ；
+ 否则，该类型是 $2$ 。

这里的 $G$ 会很大，如何判断相等？本来想用自然溢出，后来考虑到因为都是乘法，很有可能在 $\bmod 2^{64}$ 意义下同余，所以对一个大质数 $10^9+9$ 取模。（事实上这里两个取模甚至更多会更好，但数据并不是很强） 

时间复杂度是 $O(n \log n)$ 。

## 代码

中间有一段复制的，所以事实上要写的也没多少呢...


```cpp
#include <bits/stdc++.h>
#define ll long long
using namespace std;
const ll mod =  1e9+9;

const int MAXN = 210000;
int n;
int a[MAXN];

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n;i++)
    scanf("%d",&a[i]);
}

namespace Solve1{
int f[MAXN],t[MAXN],now,MAXANS;
vector<int> v[MAXN];
vector<ll> sum[MAXN];ll g[MAXN],tot[MAXN];
void output(int n,int *ff,ll *gg){
  for(int i = 1;i<=n;i++)ff[i] = f[i],gg[i] = g[i];
}
void solve(){
  a[0] = 0,f[0] = 0,g[0] = 1,t[0] = 0;
  v[0].push_back(0),sum[0].push_back(1),tot[0] = 1;
  now = 0;
  for(int i = 1;i<=n;i++){
    int tmp = lower_bound(t,t+now+1,a[i]) - t;
    if(tmp == now+1) ++now;
    f[i] = tmp,t[tmp] = a[i];
    int w = upper_bound(v[f[i]-1].begin(),v[f[i]-1].end(),a[i],greater<int>()) - v[f[i]-1].begin();
    ll ans = w == 0?0:sum[f[i]-1][w-1];
    ans = (tot[f[i]-1] - ans)%mod;
    g[i] = ans < 0?ans+mod:ans;
    v[f[i]].push_back(a[i]);
    tot[f[i]] = (tot[f[i]] + g[i])%mod;
    sum[f[i]].push_back(tot[f[i]]);
    MAXANS = max(MAXANS,f[i]);
  }
}
}

namespace Solve2{
int f[MAXN],t[MAXN],now,MAXANS;
vector<int> v[MAXN];
vector<ll> sum[MAXN];ll g[MAXN],tot[MAXN];
void output(int n,int *ff,ll *gg){
  for(int i = 1;i<=n;i++)ff[i] = f[i],gg[i] = g[i];
}
void solve(){
  a[n+1] = 1e9,f[n+1] = 0,g[n+1] = 1,t[0] = 1e9;
  v[0].push_back(1e9),sum[0].push_back(1),tot[0] = 1;
  now = 0;
  for(int i = n;i>=1;i--){// 这里相对上面有更改
    int tmp = lower_bound(t,t+now+1,a[i],greater<int>()) - t;//这里相对上面有更改
    if(tmp == now+1) ++now;
    f[i] = tmp,t[tmp] = a[i];
    int w = upper_bound(v[f[i]-1].begin(),v[f[i]-1].end(),a[i]) - v[f[i]-1].begin();//这里相对上面有更改
    ll ans = w == 0?0:sum[f[i]-1][w-1];
    ans = (tot[f[i]-1] - ans)%mod;
    g[i] = ans < 0?ans+mod:ans;
    v[f[i]].push_back(a[i]);
    tot[f[i]] = (tot[f[i]] + g[i])%mod;
    sum[f[i]].push_back(tot[f[i]]);
    MAXANS = max(MAXANS,f[i]);
  }
}
}

int F1[MAXN],F2[MAXN];ll G1[MAXN],G2[MAXN];
void solve(){
  Solve1::solve(),Solve1::output(n,F1,G1);
  Solve2::solve(),Solve2::output(n,F2,G2);
  int maxans = Solve1::MAXANS;ll totans = 0;
  for(int i = 1;i<=n;i++){
    if(F1[i] == maxans) totans+=G1[i];
    totans %= mod;
  }
  for(int i = 1;i<=n;i++){
    if(F1[i] + F2[i] - 1 < maxans)         printf("1");
    else if(G1[i] * G2[i] % mod == totans) printf("3");
    else                                   printf("2");
  }
  printf("\n");
}


int main(){
  init();
  solve();
  return 0;
}
```

