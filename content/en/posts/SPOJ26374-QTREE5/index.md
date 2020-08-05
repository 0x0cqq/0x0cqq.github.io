---
title: 「SPOJ26374」QTREE5-LCT
urlname: SPOJ26374-QTREE5
date: 2019-03-18 22:36:52
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


你被给定一棵 $n$ 个点的树，点从 $1$ 到 $n$ 编号。每个点可能有两种颜色：黑或白。我们定义 $dist(a,b)$ 为点 $a$ 至点 $b$ 路径上的边个数。一开始所有的点都是黑色的。

要求作以下操作：
- `0 i` 将点 $i$ 的颜色反转（黑变白，白变黑）
- `1 v` 询问 $dist(u,v)$ 的最小值。$u$ 点必须为白色（ $u$ 与 $v$ 可以相同），显然如果 $v$ 是白点，查询得到的值一定是 $0$ 。

特别地，如果作 `1` 操作时树上没有白点，输出 $-1$ 。

<!--more-->

## 链接

[Luogu](https://www.luogu.org/problemnew/show/SP2939)

## 题解

我直接复制了 QTREE4 的代码...

主要改动如下：

1. 把所有的 $\max$ 改成了 $\min$
2. 把所有的边权改成 $1$ 
3. 去除所有跟路径有关的东西

然后就ok了...

时间复杂度： $O(n \log^2 n)$

## 代码

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 210000;

struct Edge{
  int to,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]};
  fir[a] = ecnt++;
}

inline int _f(multiset<int> &S){return S.size()?*S.begin():inf;}

struct LCT{
  int c[MAXN][2],w[MAXN],f[MAXN],sum[MAXN];
  int lmin[MAXN],rmin[MAXN];
  multiset<int> Ch[MAXN];
  void init(int n){for(int i = 0;i<=n;i++) w[i] = lmin[i] = rmin[i] = inf;}
  bool noroot(int x){return c[f[x]][0] == x || c[f[x]][1] == x;}
  void push_up(int x){assert(x);
    #define ls c[x][0]
    #define rs c[x][1]
    sum[x] = sum[ls] + sum[rs] + 1;
    int minc = min(w[x],_f(Ch[x]));
    int L = min(minc,rmin[ls] + 1),R=min(minc,lmin[rs]);
    lmin[x] = min(lmin[ls],R + sum[ls] + 1);
    rmin[x] = min(rmin[rs],L + sum[rs]);
    #undef ls
    #undef rs
  }
  void rotate(int x){
    int y = f[x],z = f[y],t = c[y][1] == x,w = c[x][1-t];
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
      if(c[x][1]) Ch[x].insert(lmin[c[x][1]]);
      if(y)       Ch[x].erase(Ch[x].find(lmin[y]));
      c[x][1] = y,push_up(x);
    }
  }
  void modify(int x){
    access(x),splay(x);
    w[x] = w[x]==0?inf:0;
    push_up(x);
  }
  int query(int x){
    access(x),splay(x);
    return rmin[x];
  }
  void add(int x,int v){Ch[x].insert(lmin[v]);}
}T;


void dfs1(int x,int fa){
  for(int nowe = fir[x];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;
    if(v == fa) continue;
    T.f[v] = x,dfs1(v,x);
    T.add(x,v);
  }
  T.push_up(x);
}

int n,q;

void init(){
  scanf("%d",&n);
  for(int i = 2;i<=n;i++){
    int a,b;
    scanf("%d %d",&a,&b);
    addedge(a,b),addedge(b,a);
  }
  T.init(n);dfs1(1,0);
}

void solve(){
  scanf("%d",&q);
  int op, x;
  for(int i = 1;i<=q;i++){
    scanf("%d %d",&op,&x);
    if(op == 1){
      int ans = T.query(x);
      if(ans < inf) printf("%d\n",ans);
      else        printf("-1\n");
    }else if(op == 0) T.modify(x);
  }
}

int main(){
  init();
  solve();
  return 0;
}
```

