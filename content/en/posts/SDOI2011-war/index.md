---
title: 「SDOI2011」消耗战-虚树+树形dp
urlname: SDOI2011-war
date: 2018-10-15 21:52:56
tags:
- 树形结构
- 虚树
- 树形dp
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

给定一个 $n$ 个点，以 $1$ 为根的有根树，砍断第 $i$ 条边的代价为 $c_i$。有 $m$ 次询问，每次给出 $k_i$ 个关键点（保证关键点不含 $1$ 号节点），询问能够使 $1$ 号节点不能到达任何关键点，所要砍断边的代价和最小是多少。

数据范围：$n,m \leq 250000,\sum {k_i} \leq 5 \times 10^5$

<!--more-->

## 链接

[Luogu P2495](https://www.luogu.org/problemnew/show/P2495)

## 题解

可以先思考只有一个询问的情况。

如果设 $i$ 到 $1$ 的路径上所有边代价最小的边的代价为 $w[i]$，使 $i$ 的子树里面的所有点都不能到达 $1$ 节点的最小代价为 $f[i]$ ，那么有如下的转移（ $v$ 是 $i$ 的子节点）：

$$
f[i] = \min(w[i],\sum {f[v]})
$$

这个 $\text{dp}$ 的正确性好像并不是那么显然...简单证明可以这样：$\min$ 中的第一个是非常显然的一个可行解，第二个有这么几种情况：如果存在某个 $f[v]$ 由 $w[v]$ 转移而来，那么如果存在 $w[v] = w[i]$，那么必然就是第一种情况再加上若干条边，取 $\min$ 之后显然不影响答案。

我们注意到以上 $\text{dp}$ 的复杂度为 $O(\text{树的节点数})$，而我们的 $\sum{k_i}$ 是 $500000$ 。如果 $O(n)$ 的 $\text{dfs}$ 预处理出树链剖分和 $w[i]$ ，对于每次询问用 $O(k_i \log n)$ 的时间建出虚树（虚树上只需要维护 $w[i]$ ），再 $O(k_i)$ 的做一次树形 $\text{dp}$，最后时间复杂度就是 $O( n + \sum k_i \log n)$ 。

## 代码


```cpp
// Code By Chen Qiqian on 2018.10.13
#include <cstdio>
#include <algorithm>
#include <vector>
#include <unistd.h>
#define ll long long
#define inf 0x3f3f3f3f3f3f
using namespace std;

const int MAXN = 610000;


struct Edge{
  int to,len,nex;
}edge[MAXN];int ecnt = 2,fir[MAXN];
void addedge(int a,int b,int c){
  edge[ecnt] = (Edge){b,c,fir[a]};
  fir[a] = ecnt++;
}


int n,m;
ll w[MAXN];
int dep[MAXN],siz[MAXN],son[MAXN],fa[MAXN],top[MAXN],dfn[MAXN],tot;

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n-1;i++){
    int u,v,c;
    scanf("%d %d %d",&u,&v,&c);
    addedge(u,v,c),addedge(v,u,c);
  }
}

void dfs1(int nown,int f,int depth){
  dep[nown] = depth,fa[nown] = f;
  siz[nown] = 1,son[nown] = 0;
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to,l = edge[nowe].len;
    if(v == fa[nown]) continue;
    w[v] = min(w[nown],(ll)l);
    dfs1(v,nown,depth+1);
    siz[nown] += siz[v];
    if(siz[v] > siz[son[nown]]) son[nown] = v;
  }
}

void dfs2(int nown,int topf){
  dfn[nown] = ++tot;top[nown] = topf;
  if(!son[nown]) return;
  dfs2(son[nown],topf);
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;//l = edge[nowe].len;
    if(v == fa[nown] || v == son[nown]) continue;
    dfs2(v,v);
  }
}

int lca(int x,int y){
  if(x == 0 || y == 0) return 0;
  while(top[x] != top[y]){
    if(dep[top[x]] < dep[top[y]]) swap(x,y);
    x = fa[top[x]];
  }
  if(dep[x] > dep[y]) swap(x,y);
  return x;
}

void build(){
  w[1] = inf;
  dfs1(1,0,1);
  dfs2(1,1);
}

int k,kp[MAXN],type[MAXN];

bool cmp(int a,int b){
  return dfn[a] < dfn[b];
}

Edge _edge[MAXN];int _ecnt = 2,_fir[MAXN];
void _addedge(int a,int b,int c = 0){
  _edge[_ecnt] = (Edge){b,c,_fir[a]};
  _fir[a] = _ecnt++;
}

ll _dfs(int nown){
  ll tmp = 0;
  if(type[nown])
    return (ll)w[nown];
  for(int nowe = _fir[nown];nowe;nowe = _edge[nowe].nex){
    int v = _edge[nowe].to;
    tmp += _dfs(v);
  }
  return min(tmp,(ll)w[nown]);
}


void solve_tree(){
  sort(kp+1,kp+k+1,cmp);
  _ecnt = 2;
  static int stk[MAXN];int top = 0,cnt = k;//[0,top]
  for(int i = 1;i<=k;i++){
    type[kp[i]] = 1;
    int L = lca(kp[i],stk[top]);
    if(L == stk[top])
      stk[++top] = kp[i];
    else{
      while(top >= 1 && dep[stk[top-1]] >= dep[L]){
        int nown = stk[top-1],v = stk[top];
        _addedge(nown,v);
        top--;
      }
      if(stk[top] != L){
        _addedge(L,stk[top]);
        stk[top] = L;
        kp[++cnt] = L;
      }
      stk[++top] = kp[i];
    }
  }
  while(top >= 1)
    _addedge(stk[top-1],stk[top]),top--;
  
  type[1] = 0;
  printf("%lld\n",_dfs(1));
  for(int i = 1;i<=k;i++)
    type[kp[i]] = 0;
  for(int i = 1;i<=cnt;i++)
    _fir[kp[i]] = 0;
}



void solve(){
  scanf("%d",&m);
  for(int i = 1;i<=m;i++){
    scanf("%d",&k);
    for(int j = 1;j<=k;j++)
      scanf("%d",&kp[j]);
    kp[++k] = 1;
    solve_tree();
  }
}


signed main(){
  init();
  build();
  solve();
  return 0;
}
```

