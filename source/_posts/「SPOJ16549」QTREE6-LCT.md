---
title: 「SPOJ16549」QTREE6-LCT
urlname: SPOJ16549-QTREE6
date: 2019-03-17 12:58:44
tags:
- 数据结构
- LCT
categories:
- OI
- 题解
visible:
---

给你一棵 $n$ 个点的树，编号 $1$~$n$ 。每个点可以是黑色，可以是白色。初始时所有点都是黑色。有两种操作：

+ `0 u` ：询问有多少个节点 $v$ 满足路径 $u$ 到 $v$ 上所有节点（包括端点）都拥有相同的颜色
+ `1 u` ：翻转 $u$ 的颜色

<!-- more -->

## 链接

[Luogu](https://www.luogu.org/problemnew/show/SP16549)

## 题解

我就不想用两个 LCT 做！

然后在 BZOJ 上就被卡常了...无所谓了！

我们考虑类似 QTREE457 ，维护一下虚子的联通块情况即可。需要注意的是，代表一个 $splay$ 的颜色应该是最左侧的颜色，也就是代码中的 `lc[x]` 。

套路也是相同的，`push_up` 会写的稍微麻烦点，`access` 要考虑虚子的变化对维护的虚子信息的影响。

时间复杂度: $O(n\log n)$

## 代码

```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 110000;

struct LCT{
  int c[MAXN][2],f[MAXN];
  int w[MAXN];// 代表颜色 0白 1黑
  int lc[MAXN],rc[MAXN];// 代表当前splay子树的最左侧和最右侧的颜色
  int lsum[MAXN],rsum[MAXN];// 代表左侧的连痛块和右侧的联通块的大小，
  int vsum[MAXN][2],siz[MAXN][2];// 根节点的虚子树，根节点颜色为 0/1 的大小
  void init(int n){
    for(int i = 1;i<=n;i++) w[i] = 1;
  }
  bool noroot(int x){return c[f[x]][0]==x||c[f[x]][1]==x;}
  void push_up(int x){
    #define ls (c[x][0])
    #define rs (c[x][1])
    siz[x][0] = siz[ls][0] + siz[rs][0] + (w[x]==0);
    siz[x][1] = siz[ls][1] + siz[rs][1] + (w[x]==1);
    lc[x] = ls?lc[ls]:w[x],rc[x] = rs?rc[rs]:w[x];
    int xl = 1 + vsum[x][w[x]] + (rc[ls]==w[x]?rsum[ls]:0);
    int xr = 1 + vsum[x][w[x]] + (lc[rs]==w[x]?lsum[rs]:0);
    lsum[x] = lsum[ls],rsum[x] = rsum[rs];
    if(!ls || (!siz[ls][1-lc[ls]] && lc[ls] == w[x])) lsum[x] += xr;
    if(!rs || (!siz[rs][1-rc[rs]] && rc[rs] == w[x])) rsum[x] += xl;
    #undef ls
    #undef rs
  }
  void rotate(int x){
    int y = f[x],z = f[y],t = (c[y][1]==x),w = (c[x][1-t]);
    if(noroot(y)) c[z][c[z][1]==y] = x;
    c[x][1-t] = y,c[y][t] = w;
    if(w) f[w] = y;
    f[x] = z,f[y] = x;
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
      vsum[x][lc[c[x][1]]] += lsum[c[x][1]];
      vsum[x][lc[y]] -= lsum[y]; 
      c[x][1] = y,push_up(x);
    }
  }
  void modify(int x){access(x),splay(x),w[x] ^= 1,push_up(x);}
  int query(int x){access(x),splay(x);return rsum[x];}
}T;

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
    dfs(v,x);
    T.f[v] = x,T.vsum[x][T.w[v]] += T.lsum[v];
  }
  T.push_up(x);
}

int n,m;

void init(){
  scanf("%d",&n);T.init(n);
  for(int i = 1;i<=n-1;i++){
    int a,b;
    scanf("%d %d",&a,&b);
    addedge(a,b),addedge(b,a);
  }
  dfs(1,0);
}

void solve(){
  scanf("%d",&m);
  for(int i = 1;i<=m;i++){
    int op,x;
    scanf("%d %d",&op,&x);
    if(op == 0) printf("%d\n",T.query(x));
    else if(op == 1) T.modify(x);
  }
}

int main(){
  init(),solve();
  return 0;
}
```