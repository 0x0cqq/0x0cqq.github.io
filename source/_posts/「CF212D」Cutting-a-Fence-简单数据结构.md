---
title: 「CF212D」Cutting a Fence-简单数据结构
urlname: CF212D
date: 2018-12-26 19:36:56
tags:
- 数据结构
categories: 
- OI
- 题解
visible:
---

给定一个长度为 $n$ 的数列 $a_1,a_2,...,a_n$，定义 $f(x,k) = \min_{i=0}^{k-1} (a_{x+i})$ ，请对于每一个 $k = 1$ 到 $n$ ，求出 $\sum_{i=1}^{n-k+1} f(i,k)$ 的值。

<!-- more -->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/212/D)

## 题解

我拥有一个非常丑陋的做法（

我们维护一个并查集，然后我们从大往小加入每个数 $a[i]$，每次插入 $a[i]$ 都尝试与 $i$ 左边/右边的集合合并。

我们发现，合并的区间中间有一个区间最小的数 $a[i]$ ，那么我们发现会新出现一些区间，它们的最小值均为 $a[i]$ 。假设左边的集合大小为 $L$，右边的集合大小为 $R$，那么我们新增的区间就是：

+ 加上长度为 $L+R+1$ 的区间的所有子区间，最小值为 $a[i]$
+ 减去长度分别为 $L$ 和 $R$ 的区间的所有子区间，最小值为 $a[i]$

我们发现长度为 $x$ 的区间的子区间事实上是：

+ 长度为 $1$ 的子区间： $x$ 个
+ 长度为 $2$ 的子区间： $x-1$ 个
+ $\cdots$
+ 长度为 $x-1$ 的子区间：$2$ 个
+ 长度为 $x$ 的子区间： $1$ 个


事实上是一个等差数列...所以如果我们维护差分值的话，就相当于一个某位置单点加 $x$，其余位置区间减 $1$ 的操作 ..？（事实上还要乘上一个 $a[i]$）

第一个操作我们维护一个差分数组，第二个操作我们维护一个二阶差分数组，这个题大概就可以做了？

最后线性递推出所有的答案即可。

常数巨大无比警告...大约是 $O(n \alpha(n))$ ..？

## 代码



```cpp
#include <bits/stdc++.h>
#define int long long
using namespace std;

const int MAXN = 1100000;

namespace BCJ{
  int f[MAXN],siz[MAXN];
  void init(int n){
    for(int i = 1;i<=n;i++)
      f[i] = i,siz[i] = 1;
  }
  int find(int x){
    return f[x] == x?x:f[x] = find(f[x]);
  }
  void merge(int x,int y){
    int fx = find(x),fy = find(y);
    if(fx == fy) return;
    f[fx] = fy;
    siz[fy] += siz[fx];
  }
  int getsize(int x){return siz[find(x)];}
}

int n,m;
int num[MAXN],s[MAXN],vis[MAXN];
int c1[MAXN],c2[MAXN],ans[MAXN];
bool cmp(int a,int b){return num[a] > num[b];}

void init(){
  scanf("%lld",&n);
  for(int i = 1;i<=n;i++){
    scanf("%lld",&num[i]);
  }
  BCJ::init(n);
}

void addc(int x,int v,int val){
  if(x == 0) return;
  // printf("add: x:%lld val:%lld v:%lld\n",x,val,v);
  c1[1] += v*x*val;
  c2[1] -= v*1*val,c2[x+1] += v*1*val;
}

void calc(){
  for(int i = 1;i<=n;i++)
    s[i] = i;
  sort(s+1,s+n+1,cmp);
  for(int i = 1;i<=n;i++){
    int t = s[i];
    vis[t] = 1;
    int L = 0,R = 0;
    if(vis[t-1]) L = BCJ::getsize(t-1),BCJ::merge(t,t-1);
    if(vis[t+1]) R = BCJ::getsize(t+1),BCJ::merge(t,t+1);
    addc(L+R+1,1,num[t]),addc(L,-1,num[t]),addc(R,-1,num[t]);
  }
}


void solve(){
  for(int i = 1;i<=n;i++) c2[i] = c2[i-1] + c2[i];
  for(int i = 1;i<=n;i++) c2[i] = c2[i-1] + c2[i];
  for(int i = 1;i<=n;i++) c1[i] = c1[i-1] + c1[i];
  ans[1] = c1[1];
  for(int i = 1;i<=n;i++) ans[i+1] = c1[i] + c2[i];
  scanf("%lld",&m);
  for(int i = 1;i<=m;i++){
    int t;
    scanf("%lld",&t);
    printf("%.10lf\n",double(ans[t])/(n-t+1));
  }
}

signed main(){
  init();
  calc();
  solve();
  return 0;
}
```


