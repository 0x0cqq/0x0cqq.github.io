---
title: 「SDOI2017」树点涂色-LCT+树链剖分
urlname: SDOI2017-paint
date: 2019-03-30 13:00:28
tags:
- 树形结构
- dfs序
- LCT
- 线段树
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


Bob 有一棵 $n​$ 个点的有根树，其中 $1​$ 号点是根节点。Bob 在每个节点上涂了颜色，并且每个点上的颜色不同。

定义一条路径的权值是，这条路径上的点（包括起点和终点）共有多少种不同的颜色。

Bob 可能会进行这几种操作：

+ ``1 x``，把点 $x$ 到根节点的路径上的所有的点染上一种没有用过的新颜色；
+ ``2 x y``，求 $x$ 到 $y$ 的路径的权值；
+ ``3 x``，在以 $x$ 为根的子树中选择一个点，使得这个点到根节点的路径权值最大，求最大权值。

Bob 一共会进行 $m$ 次操作。

 <!--more-->

## 链接

[Luogu P3703](https://www.luogu.org/problemnew/show/P3703)

## 题解

我们注意到很重要的一点是：染上一种没有用过的新颜色。再加上每次染色都是从这个点到根节点，这意味着，有多少段颜色就有多少种颜色。

我们如果令 $f(x)$ 为 $x$ 到根节点颜色的段数，$g(x,y)$ 为第二个操作的答案，不难发现如下性质：
$$
g(x,y) = f(x) + f(y) - 2*\text{lca}(x,y) + 1
$$
这个其实可以通过考虑颜色段+1的本质是出现了一个分割点。

然后我们考虑如何维护 $f(x)$ 的值。

我们给一个点到根节点染上色，就是让这个点到根节点打通成为一条连通块。咦？似乎很像 `access` ？那我们岂不每次 `access` 一下就可以了，然后我们发现 `access` 的时候切换虚实边的次数就是这个点的答案。这样我们按照 `dfs` 序列构造一棵线段树，切换虚/实边的时候更新线段树+1/-1即可。

时间复杂度：$O(n \log n)$

## 代码

```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 110000;

namespace SegTree{
  #define ls (x<<1)
  #define rs (x<<1|1)
  #define mid ((l+r)>>1)
  int mx[MAXN<<2],lzy[MAXN<<2];
  void add(int x,int v){mx[x] += v,lzy[x] += v;}
  void push_down(int x){if(lzy[x]) add(ls,lzy[x]),add(rs,lzy[x]),lzy[x] = 0;}
  void push_up(int x){mx[x] = max(mx[ls],mx[rs]);}
  void build(int x,int l,int r,int *a){
    if(l == r) mx[x] = a[l];
    else{
      build(ls,l,mid,a),build(rs,mid+1,r,a);
      push_up(x);
    }
  }
  void update(int x,int l,int r,int ql,int qr,int v){
    if(ql <= l && r <= qr) add(x,v);
    else{
      push_down(x);
      if(ql <= mid) update(ls,l,mid,ql,qr,v);
      if(qr >= mid+1) update(rs,mid+1,r,ql,qr,v);
      push_up(x);
    }
  }
  int query(int x,int l,int r,int ql,int qr){
    if(ql <= l && r <= qr) return mx[x];
    else{
      push_down(x);
      int ans = -0x3f3f3f3f;
      if(ql <= mid) ans = max(ans,query(ls,l,mid,ql,qr));
      if(qr >= mid+1) ans = max(ans,query(rs,mid+1,r,ql,qr));
      return ans;
    }
  }
}

struct Edge{
  int to,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]},fir[a] = ecnt++;
}

int n,m;
int dfn[MAXN],f[MAXN],siz[MAXN],dep[MAXN],son[MAXN],top[MAXN];
void dfs0(int x,int fa,int depth){
  siz[x] = 1,f[x] = fa,dep[x] = depth;
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to;
    if(v == fa) continue;
    dfs0(v,x,depth+1);
    siz[x] += siz[v];
    if(siz[v] > siz[son[x]]) son[x] = v;
  }
}

void dfs1(int x,int topf){
  top[x] = topf;dfn[x] = ++dfn[0];
  if(!son[x]) return;
  dfs1(son[x],topf);
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to;
    if(v == son[x] || v == f[x]) continue;
    dfs1(v,v);
  }
}

int lca(int x,int y){
  while(top[x] != top[y]){
    if(dep[top[x]] < dep[top[y]]) swap(x,y);
    x = f[top[x]];
  }
  if(dep[x] > dep[y]) swap(x,y);
  return x;
}

void update_tree(int x,int v){
  if(!x) return;
  SegTree::update(1,1,n,dfn[x],dfn[x]+siz[x]-1,v);
}
int query_tree(int x){return SegTree::query(1,1,n,dfn[x],dfn[x]+siz[x]-1);}
int query(int x){return SegTree::query(1,1,n,dfn[x],dfn[x]);}
int query(int x,int y){return query(x)+query(y)-2*query(lca(x,y))+1;}

namespace LCT{
  int c[MAXN][2],f[MAXN],mn[MAXN];
  void init(int n,int *fa){for(int i = 1;i<=n;i++) f[i] = fa[i],mn[i] = i;}
  bool noroot(int x){return c[f[x]][0] == x || c[f[x]][1] == x;}
  void push_up(int x){mn[x] = c[x][0]?mn[c[x][0]]:x;}
  void rotate(int x){
    int y = f[x],z = f[y],t = (c[y][1] == x),w = c[x][1-t];
    if(noroot(y)) c[z][c[z][1]==y] = x;
    c[x][1-t] = y,c[y][t] = w;
    if(w) f[w] = y;
    f[y] = x,f[x] = z; 
    push_up(y);
  }
  void splay(int x){
    while(noroot(x)){
      int y = f[x],z = f[y];
      if(noroot(y)){
        (c[y][1]==x)^(c[z][1]==y)?rotate(x):rotate(y);
      }rotate(x);
      push_up(x);
    }
  }
  void access(int x){
    for(int y = 0;x;x = f[y=x]){
      splay(x);
      update_tree(mn[c[x][1]],1),update_tree(mn[y],-1);
      c[x][1] = y,push_up(x);
    }
  }
}
void modify(int x){LCT::access(x);}

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 2;i<=n;i++){
    int a,b;
    scanf("%d %d",&a,&b);
    addedge(a,b),addedge(b,a);
  }
  dfs0(1,0,1),dfs1(1,1);
  static int v[MAXN];
  for(int i = 1;i<=n;i++) v[dfn[i]] = dep[i];
  SegTree::build(1,1,n,v),LCT::init(n,f);
}

void solve(){
  int op,x,y;
  for(int i = 1;i<=m;i++){
    scanf("%d",&op);
    if(op == 1) scanf("%d",&x),modify(x);
    else if(op == 2) scanf("%d %d",&x,&y),printf("%d\n",query(x,y));
    else if(op == 3) scanf("%d",&x),printf("%d\n",query_tree(x));
  }
}

int main(){
  init(),solve();
  return 0;
}
```

