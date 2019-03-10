---
title: 「CF804D」Expected diameter of a tree-树的直径+乱搞
urlname: CF804D
date: 2019-02-15 22:20:30
tags:
- 题解
- 乱搞
- 树的直径
categories: OI
visible:
---

给定一个含有 $n$ 个点， $m$ 条边的森林。有 $q$ 个询问，每次给出两个点 $u_i,v_i$ ，如果 $u_i$ 在联通块 $A$ 内，$v_i$ 在联通块 $B$ 内，我们随机选择两个点 $a \in A,b \in B$ ，我们在 $(a,b)$ 之间连一条边，如果这个连接成后新联通块不构成一个树，输出 $-1$ ，否则输出新联通块树的直径的期望。所有边权均为 $1$ 。

<!-- more -->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/804/D)

## 题解

如果 $u,v$ 在同一个联通块里面，输出 $-1$ 。

我们有一个结论：我们连接 $a,b$ 两点时，我们的直径只可能有两种可能：

1. $\max($ $A$ 联通块的直径，$B$ 联通块的直径 $)$
2. $a$ 点出发的最长路径 + $b$ 点出发的最长路径 + 1 （各联通块内）

我们考虑第一个很好求，设其为 $D$。那么我们的答案就是：

$$
ans_i = \frac{1}{siz[A] \times siz[B]}\sum_{a \in A,b \in B} max(D,d(a) + d(b) + 1)
$$

我们令 $d(a) + d(b) + 1 >= D$ 的数对 $(a,b)$ 的数目为 $cnt_i$ ，其（$d(a) + d(b) + 1$）和为 $sum_i$ ，那么化简之后：

$$
ans_i = \frac{D \times (siz[A] \times siz[B]-cnt_i) + sum_i}{siz[A] \times siz[B]}
$$

我们现在只需要求出 $cnt_i$ 和 $sum_i$ 。

- - -

接下来就是玄幻的过程了。

我们令两个联通块中比较小的联通块为 $A$ ，另一个为 $B$，我们计算 $d$ 数组前缀和之后用二分的办法计算答案，复杂度应当是 $O(siz[A] * log(siz[B]))$（并且用 map 进行记忆化）。

如果 $siz[A] < \sqrt n$ ，那么我们单次询问的复杂度不会超过 $O(\sqrt n \log n)$ ，总体复杂度是 $O(q \sqrt n \log n)$ 。

否则 $siz[A] > \sqrt n$，那么我们记忆化之后，我们注意到满足 $siz[A] > \sqrt n$ 的树只会有少于 $\sqrt n$ 个，所以我们每个$siz[A]$ 最多被计算 $O(\sqrt n)$ 次，所以就可以做到 $O(\sum siz[A] * \sqrt n\log n)$ ，也就是 $O(n \sqrt n \log n)$。

所以最后的时间复杂度就是 $O((n+q) \sqrt n \log n)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
#define ll long long
#define db double
using namespace std;

const int MAXN = 110000;

struct Edge{
  int to,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]};
  fir[a] = ecnt++;
}

int n,m,q;
int R[MAXN];
vector<int> d[MAXN];
vector<ll> s[MAXN];
int tmp[MAXN];
int dis[MAXN],vis[MAXN],col[MAXN],cnt;
int maxid;

void dfs(int nown,bool is_it_rated = 0,int f = 0){
  if(dis[nown] > dis[maxid]) maxid = nown;
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;
    if(v == f) continue;
    dis[v] = dis[nown] + 1;
    dfs(v,is_it_rated,nown);
  }
  if(is_it_rated){
    vis[nown] = 1,col[nown] = cnt;
    tmp[nown] = max(tmp[nown],dis[nown]);
  }
}

void getv(int nown,int f = 0){
  d[cnt].push_back(tmp[nown]);
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;
    if(v == f) continue;
    getv(v,nown);
  }
}

void init(){
  scanf("%d %d %d",&n,&m,&q);
  for(int i = 1;i<=m;i++){
    int u,v;
    scanf("%d %d",&u,&v);
    addedge(u,v),addedge(v,u);
  }
}

void cal(int x){
  ++cnt;
  d[cnt].push_back(-1e9);
  int u,v;
  maxid = 0,dis[x] = 0,dfs(x);u = maxid;
  dis[u] = 0,dfs(u);v = maxid;
  R[cnt] = dis[v];
  dis[u] = 0,dfs(u,1);dis[v] = 0,dfs(v,1);

  getv(x);
  sort(d[cnt].begin(),d[cnt].end());

  s[cnt].resize(d[cnt].size());
  s[cnt][0] = 0;
  for(unsigned i = 1;i<s[cnt].size();i++) 
    s[cnt][i] = s[cnt][i-1] + d[cnt][i];
}

void build(){
  dis[0] = -1;
  for(int i = 1;i<=n;i++){
    if(vis[i] == 0) cal(i);
  }
}

map<pair<int,int>,double> S;

double query(int u,int v){
  u = col[u],v = col[v];
  if(d[u].size() > d[v].size()) swap(u,v);
  if(S.count(make_pair(u,v))) return S[make_pair(u,v)];
  int D = max(R[u],R[v]);
  ll us = (int)(d[u].size())-1,vs = (int)(d[v].size())-1;
  double cnt = 0,sum = 0;
  for(int i = 1;i <= us;i++){
    int T = D - d[u][i] - 1;// 只要大于等于 T 就可以算 cnt
    int t = lower_bound(d[v].begin(),d[v].end(),T) - d[v].begin();
    cnt += db(vs-t+1),sum += db(s[v][vs] - s[v][t-1]) + db(vs-t+1) * (d[u][i]+1);
  }
  return S[make_pair(u,v)] = (db(D)*(us*vs-cnt)+sum) / (us*vs);
}

void solve(){
  for(int i = 1;i<=q;i++){
    int u,v;
    scanf("%d %d",&u,&v);
    if(col[u] == col[v]) printf("-1\n");
    else printf("%.10lf\n",query(u,v));
  }
}


signed main(){
  init();
  build();
  solve();
  return 0;
}
```

