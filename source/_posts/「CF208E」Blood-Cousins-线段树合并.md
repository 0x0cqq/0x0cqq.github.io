---
title: 「CF208E」Blood Cousins-线段树合并
urlname: CF208E
date: 2018-12-25 21:08:48
tags:
- 数据结构
- 树形结构
- 线段树合并
categories: 
- OI
- 题解
visible:
---

给你一片森林，每次询问一个点与多少个点拥有共同的 $K$ 级祖先

<!-- more -->

## 题解

用倍增处理出 $k$ 级祖先，然后离线所有询问到一个数对： $(x,d)$ 表示需要查询在 $x$ 为根的子树中深度为 $d$ 的节点个数，每个询问的答案就是这个节点个数减 $1$ 。

我们可以用线段树合并解决这个问题。

时间复杂度 $O((n+m) \log n)$ ，空间复杂度 $O(n \log n)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 110000,logn = 20;

struct Edge{
  int v,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]};
  fir[a] = ecnt++;
}

namespace SegTree{
  int sumn[MAXN*logn*5],ls[MAXN*logn*5],rs[MAXN*logn*5],cnt = 0;
  #define mid ((l+r)>>1)
  void update(int &nown,int l,int r,int pos,int v){
    if(!nown) nown = ++cnt;
    if(l == r)
      sumn[nown] += v;
    else{
      if(pos <= mid) update(ls[nown],l,mid,pos,v);
      if(pos >= mid+1) update(rs[nown],mid+1,r,pos,v);
      sumn[nown] = sumn[ls[nown]] + sumn[rs[nown]];
    }
  }
  int query(int nown,int l,int r,int pos){
    if(!nown) return 0;
    if(l == r) return sumn[nown];
    else{
      if(pos <= mid) return query(ls[nown],l,mid,pos);
      else return query(rs[nown],mid+1,r,pos);
    }
  }
  void merge(int &lt,int rt,int l,int r){
    if(lt == 0 || rt == 0){lt = lt + rt;return;}
    if(l == r)
      sumn[lt] += sumn[rt];
    else{
      merge(ls[lt],ls[rt],l,mid);
      merge(rs[lt],rs[rt],mid+1,r);
      sumn[lt] = sumn[ls[lt]] + sumn[rs[lt]];
    }
  }
}

int n,m;
int fa[MAXN][logn],dep[MAXN];

struct Q{int d,id;};
vector<Q> q[MAXN];

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n;i++){
    scanf("%d",&fa[i][0]);
    if(fa[i][0] != 0)
      addedge(fa[i][0],i);
  }
}

void dfs0(int nown,int depth){
  dep[nown] = depth;
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].v;
    dfs0(v,depth+1);
  } 
}

int find_kth(int x,int k){
  int t = dep[x] - k;
  for(int i = logn-1;i>=0;i--){
    if(dep[fa[x][i]] >= t)
      x = fa[x][i];
  }
  return x;
}

void build(){
  for(int j = 1;j<logn;j++)
    for(int i = 1;i<=n;i++)
      fa[i][j] = fa[fa[i][j-1]][j-1];
  for(int i = 1;i<=n;i++)
    if(fa[i][0] == 0) dfs0(i,1);
}

int ans[MAXN];

void pre_calc(){
  scanf("%d",&m);
  for(int i = 1;i<=m;i++){
    int v,p;
    scanf("%d %d",&v,&p);
    int x = find_kth(v,p);
    if(x == 0) continue;
    q[x].push_back((Q){dep[x]+p,i});
  }
}

int rt[MAXN];

void dfs1(int nown){
  SegTree::update(rt[nown],1,n,dep[nown],1);
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].v;
    dfs1(v);
    SegTree::merge(rt[nown],rt[v],1,n);
  }
  for(unsigned i = 0;i<q[nown].size();i++){
    int id = q[nown][i].id,dd = q[nown][i].d;
    if(dd > n) continue;
    ans[id] = SegTree::query(rt[nown],1,n,dd) - 1;
  }
}

void solve(){
  for(int i = 1;i<=n;i++)
    if(fa[i][0] == 0) dfs1(i);
  for(int i = 1;i<=m;i++)
    printf("%d ",ans[i]);
  printf("\n");
}

int main(){
  init();
  build();
  pre_calc();
  solve();
  return 0;
}
```

