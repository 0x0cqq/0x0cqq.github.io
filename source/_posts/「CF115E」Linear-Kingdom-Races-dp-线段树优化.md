---
title: 「CF115E」Linear Kingdom Races-dp+线段树优化
urlname: CF115E
date: 2018-12-23 22:26:23
tags:
- 动态规划
- 数据结构
- 线段树
categories: 
- OI
- 题解
visible:
---

你是一个赛车比赛的组织者，想在线性王国中安排一些比赛。

线性王国有 $n$ 条连续的从左到右的道路。道路从左到右依次编号为从 $1$ 到 $n$ ，因此道路按照升序排列。在这些道路上可能会有几场比赛，每一场比赛都将使用这些道路的某个连续的子序列。而且，如果某场比赛举行了，你将获得一定数额的金钱。没有比赛在时间上重叠，所以每一段道路可以在多个比赛中使用。

不幸的是，**所有道路**的状况都不佳，需要修理。每条路都有与之相关的维修费用，你需要支付这笔费用来修理道路。只有在某场比赛中需要使用的所有道路**都进行了修复**，才能进行比赛。你的任务是修复道路并使你的利润最大化。你的利润被定义为你从比赛中获得的总金额减去你花在修理道路上的钱。**请注意，您可以决定不修任何道路，并获得利润 $0$ 。**

输出你能获得的最大利润。

<!-- more -->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/115/E)

## 题解

考虑动态规划。我们令 $dp[i][j]$ 为只考虑前 $i$ 个路，上一个没修的路在 $j$ 位置处的答案。

我们显然有以下状态转移：

$$
dp[i][j] = \left \{
\begin{aligned}{}
dp[i-1][j] - c[i] + p[i][j]&,j < i\\
max(dp[i-1][k])&,j = i\\
\end{aligned}
\right.
$$

其中 $p[i][j]$ 由所有左端点在 $j$ 右侧，右端点在 $i$ 的赛道构成，事实上我们可以每个赛道的贡献出现在其左端点左侧，所以是一个区间加。

我们考虑如何快速转移，针对第一个操作，只要支持区间加减即可。
对于第二个只要支持区间最值查询，那么我们一个线段树就可以解决了。

有趣的优化...

时间复杂度：$O(n \log n)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f3f3f3f3f
#define ll long long
using namespace std;

const int MAXN = 210000;

int n,m;
ll num[MAXN];

namespace SegTree{
  #define lson (nown<<1)
  #define rson (nown<<1|1)
  #define mid ((l+r)>>1)
  ll maxn[MAXN<<2],addn[MAXN<<2];
  void add(int nown,ll v){
    maxn[nown] += v,addn[nown] += v;
  }
  void push_down(int nown){
    if(addn[nown] != 0){
      add(lson,addn[nown]),add(rson,addn[nown]);
      addn[nown] = 0;
    }
  }
  void update(int nown,int l,int r,int ql,int qr,ll v){
    if(ql <= l && r <= qr){
      add(nown,v);
    }
    else{
      push_down(nown);
      if(ql <= mid) update(lson,l,mid,ql,qr,v);
      if(qr >= mid+1) update(rson,mid+1,r,ql,qr,v);
      maxn[nown] = max(maxn[lson],maxn[rson]);
    }
  }
  ll query(int nown,int l,int r,int ql,int qr){
    if(ql <= l && r <= qr){
      return maxn[nown];
    }
    else{
      push_down(nown);
      ll ans = -inf;
      if(ql <= mid) ans = max(ans,query(lson,l,mid,ql,qr));
      if(qr >= mid+1) ans = max(ans,query(rson,mid+1,r,ql,qr));
      return ans;
    }
  }
  void _set(int nown,int l,int r,int pos,ll v){
    if(l == r){
      maxn[nown] = v;
    }
    else{
      push_down(nown);
      if(pos <= mid) _set(lson,l,mid,pos,v);
      if(pos >= mid+1) _set(rson,mid+1,r,pos,v);
      maxn[nown] = max(maxn[lson],maxn[rson]);
    }
  }
}


typedef pair<ll,ll> pll;

vector<pll> V[MAXN];//first->pos,second->val

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    scanf("%lld",&num[i]);
  }
  for(int i = 1;i<=m;i++){
    ll a,b,c;
    scanf("%lld %lld %lld",&a,&b,&c);
    V[b].push_back(make_pair(a,c));
  }
}


void solve(){
  // 线段树范围 [0,n]
  SegTree::update(1,0,n,0,n,-inf);
  SegTree::_set(1,0,n,0,0);
  for(int i = 1;i<=n;i++){
    ll tmp = SegTree::query(1,0,n,0,i-1);
    // printf("%d:%d\n",i,tmp);
    SegTree::_set(1,0,n,i,tmp);
    SegTree::update(1,0,n,0,i-1,-num[i]);
    for(int j = 0;j<int(V[i].size());j++){
      ll L = V[i][j].first, val = V[i][j].second;
      SegTree::update(1,0,n,0,L-1,val);
    }
  }
  printf("%lld\n",SegTree::query(1,0,n,0,n));
}


int main(){
  init();
  solve();
  return 0;
}
```

