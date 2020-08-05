---
title: 「SPOJ16580」QTREE7-LCT
urlname: SPOJ16580-QTREE7
date: 2019-03-18 20:54:33
tags:
- 数据结构
- LCT
categories: 
- OI
- 题解 
series:
- QTREE
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

一棵树,每个点初始有个点权和颜色(输入会给你) 
+ `0 u` : 询问所有 $u,v$ 路径上的最大点权,要满足 $u,v$ 路径上所有点的颜色都相同
+ `1 u` : 反转 $u$ 的颜色 
+ `2 u w` :把 $u$ 的点权改成 $w$

<!--more-->

$color_i \in [0,1],w_i \in [-10^9,10^9],n,m \le 10^5$

## 链接

[Luogu](https://www.luogu.org/problemnew/show/SP16580)

## 题解

我就是要用一个 LCT 做！

这次在 BZOJ 上也没有被卡常！

我们维护两个 `multiset` 维护每个点的虚子树（顶点不同颜色）的最大联通块（表现为 `lmx[x]`），每次 access 的时候更新一下就好了。

一定记住，access的时候该删的删，该加的加，是相对于子树来说的！别搞错了(大哭

时间复杂度：$O(n \log^2 n)$ 。

## 代码

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 110000;

int _f(multiset<int> &S){return S.empty()?-inf:*(S.rbegin());}

struct LCT{
  int c[MAXN][2],f[MAXN],v[MAXN],w[MAXN],sum[MAXN][2];
  int lc[MAXN],rc[MAXN],lmx[MAXN],rmx[MAXN];
  multiset<int> vmx[MAXN][2];
  void init(){lmx[0] = rmx[0] = -inf+1;}
  bool noroot(int x){return c[f[x]][0]==x||c[f[x]][1]==x;}
  void push_up(int x){
    #define ls c[x][0]
    #define rs c[x][1]
    sum[x][0] = sum[ls][0] + sum[rs][0] + (w[x]==0);
    sum[x][1] = sum[ls][1] + sum[rs][1] + (w[x]==1);
    lc[x] = ls?lc[ls]:w[x],rc[x] = rs?rc[rs]:w[x];
    int maxl = max(max(v[x],_f(vmx[x][w[x]])) , rc[ls] == w[x]?rmx[ls]:-inf);
    int maxr = max(max(v[x],_f(vmx[x][w[x]])) , lc[rs] == w[x]?lmx[rs]:-inf);
    lmx[x] = lmx[ls],rmx[x] = rmx[rs];
    if(!ls || (!sum[ls][1-lc[x]] && w[x] == lc[x])) lmx[x] = max(lmx[x],maxr);//!!!
    if(!rs || (!sum[rs][1-rc[x]] && w[x] == rc[x])) rmx[x] = max(rmx[x],maxl);//!!!
    #undef ls
    #undef rs
  }
  void rotate(int x){
    int y = f[x],z = f[y],t = (c[y][1]==x),w = c[x][1-t];//!!!
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
    }push_up(x);
  }
  void access(int x){
    for(int y = 0;x;x = f[y=x]){
      splay(x);
      vmx[x][ lc[c[x][1]] ].insert(lmx[ c[x][1] ]);//!!!
      vmx[x][ lc[y] ].erase(lmx[y]);//!!!
      c[x][1] = y,push_up(x);//!!!
    }
  }
  void m_node(int x,int c,int val){w[x] = c,v[x] = val;}
  void m_fa(int x,int fa){f[x] = fa,vmx[fa][lc[x]].insert(lmx[x]);}
  void m_color(int x){access(x),splay(x),w[x]^=1,push_up(x);}
  void m_value(int x,int val){access(x),splay(x),v[x] = val,push_up(x);}
  int q_max(int x){access(x),splay(x);return rmx[x];}
}T;

int n,q;
int col[MAXN],val[MAXN];

struct Edge{
  int to,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]};
  fir[a] = ecnt++;
}


void dfs(int x,int fa){
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to;
    if(v == fa) continue;
    T.m_node(v,col[v],val[v]);
    dfs(v,x);
    T.push_up(v),T.m_fa(v,x);
  }
}

void init(){
  scanf("%d",&n);T.init();
  for(int i = 1;i<=n-1;i++){
    int a,b;
    scanf("%d %d",&a,&b);
    addedge(a,b),addedge(b,a);
  }
  for(int i = 1;i<=n;i++) scanf("%d",&col[i]);
  for(int i = 1;i<=n;i++) scanf("%d",&val[i]);
  T.m_node(1,col[1],val[1]);dfs(1,0);
}

void solve(){
  scanf("%d",&q);
  for(int i = 1;i<=q;i++){
    int op,x,v;
    scanf("%d %d",&op,&x);
    if(op == 0) printf("%d\n",T.q_max(x));
    else if(op == 1) T.m_color(x);
    else if(op == 2) scanf("%d",&v),T.m_value(x,v);
  }
}

int main(){
  init();
  solve();
  return 0;
}
```