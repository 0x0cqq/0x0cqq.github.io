---
title: 「NOI2012」魔幻棋盘-差分+树套树
urlname: NOI2012-board
date: 2018-08-24 13:15:53
tags:
- 线段树
- 树套树
- 数据结构
- 差分
categories: 
- OI
- 题解
series:
- NOI
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---


将要读二年级的小 Q 买了一款新型益智玩具——魔幻棋盘，它是一个 $N$ 行 $M$ 列的网格棋盘，每个格子中均有一个正整数。棋盘守护者在棋盘的第 $X$ 行第 $Y$ 列（行与列均从 $1$ 开始编号）并且始终不会移动。棋盘守护者会进行两种操作：

1. 询问：他会以自己所在位置为基础，向四周随机扩展出一块大小不定的矩形区域，向你询问这一区域内所有数的最大公约数是多少。

2. 修改：他会随意挑选棋盘上的一块矩形区域，将这一区域内的所有数同时加上一个给定的整数。

游戏说明书上附有这样一句话“聪明的小朋友，当你连续答对 $19930324$ 次询问后会得到一个惊喜噢！”。小 Q 十分想得到这个惊喜，于是每天都在玩这个玩具。但由于他粗心大意，经常算错数，难以达到这个目标。于是他来向你寻求帮助，希望你帮他写一个程序来回答棋盘守护者的询问，并保证 $100\%$ 的正确率。

为了简化问题，你的程序只需要完成棋盘守护者的 $T$ 次操作，并且问题保证任何时刻棋盘上的数字均为不超过 $2^{62} - 1$ 的正整数。

<!--more-->

## 链接

[Luogu P2086](https://www.luogu.org/problemnew/show/P2086)

## 题解

我们发现，如果只有单点修改，这个东西是很好解决的，区间修改（加）就不太好做。

---

我们有如下结论：
$$
\gcd(a,b) = \gcd(a,b-a)
$$
然后我们发现我们所有的查询都是包含同一个点的，这也可以给我们提供一点思路。

我们如果对于所有点，我们对某点做一个二维的差分（也就是矩形的前缀和等于这个位置原来的值），所以这个时候我们可以直接对这个差分进行 $\gcd$ 的查询。

我们建立一个二维线段树，维护差分后的数组，我们需要建立两个一维线段树来辅助差分。修改矩形的时候，我们因为是以左上角差分的，所以我们需要修改四个点，就是矩形的四个角，注意 $+1$ 和 $-1$ 的问题。

在这里，我们不必以中心点为基准差分，事实上可以以任意点差分。

参考：[SengXian's Blog](https://blog.sengxian.com/solutions/bzoj-2877)

## 代码



```cpp
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cctype>
using namespace std;
#define ll long long

namespace fast_io{
	//...
}using namespace fast_io;

const int MAXN = 510000;

ll gcd(ll a,ll b){
  return b==0?abs(a):gcd(b,a%b);
}

#define lson (nown<<1)
#define rson (nown<<1|1)
#define mid ((l+r)>>1)
struct SegTree1D{
  ll *gg;
  SegTree1D(int m){gg = new ll[m<<2];}
  void build(int nown,int l,int r,const ll *lt,const ll *rt){
    if(r < l) return gg[nown] = 0,void();
    if(l == r) gg[nown] = rt == NULL?lt[l]: gcd(lt[nown],rt[nown]);
    else{
      build(lson,l,mid,lt,rt),build(rson,mid+1,r,lt,rt);
      gg[nown] = gcd(gg[lson],gg[rson]);
    }
  }
  ll query(int nown,int l,int r,int ql,int qr){
    if(qr < l || r < ql) return 0;
    if(ql <= l && r <= qr) return gg[nown];
    else{
      ll ans = 0;
      if(ql <= mid) ans = gcd(ans,query(lson,l,mid,ql,qr));
      //if(ans == 1) return ans;
      if(qr >= mid+1) ans = gcd(ans,query(rson,mid+1,r,ql,qr));
      return ans;
    }
  }
  void modify(int nown,int l,int r,int pos,ll v){
    if(pos < l || pos > r) return;
    if(l == r) gg[nown] += v;
    else{
      if(pos <= mid) modify(lson,l,mid,pos,v);
      else modify(rson,mid+1,r,pos,v);
      gg[nown] = gcd(gg[lson],gg[rson]);
    }
  }
  void modify(int nown,int l,int r,int pos,const ll *ltree,const ll *rtree){
    if(pos < l || pos > r) return;
    if(l == r) gg[nown] = gcd(ltree[nown],rtree[nown]);
    else{
      if(pos <= mid) modify(lson,l,mid,pos,ltree,rtree);
      else modify(rson,mid+1,r,pos,ltree,rtree);
      gg[nown] = gcd(ltree[nown],rtree[nown]);
    }
  }
}*C,*D;

int n,m,xx,yy,t;
ll *a[MAXN],*b[MAXN];
ll c[MAXN],d[MAXN],val;//c横d纵

struct SegTree2D{
  // 每一行建1棵1D线段树
  // 一共n棵，每棵大小均为m
  SegTree1D *t[MAXN<<2];
  int a,b,c,d;//行从 a->b, 列从 c->d or (a,b)
  ll v;
  void build(int nown,int l,int r,int m,ll **num){
    t[nown] = new SegTree1D(m);
    if(l == r) t[nown]->build(1,1,m,num[l],NULL);
    else{
      build(lson,l,mid,m,num),build(rson,mid+1,r,m,num);
      t[nown]->build(1,1,m,t[lson]->gg,t[rson]->gg);
    }
  }
  void modify(int nown,int l,int r){//(a,b) += v
    if(r < a || l > a) return;
    if(l == r) t[nown]->modify(1,1,m,b,v);
    else{
      if(a <= mid) modify(lson,l,mid);
      else modify(rson,mid+1,r);
      t[nown]->modify(1,1,m,b,t[lson]->gg,t[rson]->gg);
    }
  }
  ll query(int nown,int l,int r){
    if(b < l || r < a) return 0;
    if(a <= l && r <= b) return t[nown]->query(1,1,m,c,d);
    else{
      ll ans = 0;
      if(a <= mid) ans = gcd(ans,query(lson,l,mid));
      //if(ans == 1) return ans;
      if(b >= mid+1) ans = gcd(ans,query(rson,mid+1,r));
      return ans;
    }
  }
}T;

void modify(int x,int y,ll v){
  T.a = x,T.b = y,T.v = v;
  if(1 <= x && x <= n && 1 <= y && y <= m) T.modify(1,1,n);
}

ll query(int x1,int x2,int y1,int y2){
  ll ans = val;
  x1 = xx - x1,x2 = xx + x2,y1 = yy - y1,y2 = yy + y2;
  ans = gcd(ans,gcd(D->query(1,1,n,x1+1,x2),C->query(1,1,m,y1+1,y2)));
  T.a = x1+1,T.b = x2,T.c = y1+1,T.d = y2;
  ans = gcd(ans,T.query(1,1,n));
  return abs(ans);
}

void modify(int x1,int x2,int y1,int y2,ll v){
  if(x1 <= xx && xx <= x2 && y1 <= yy && yy <= y2) val += v;
  if(x1 <= xx && xx <= x2) C->modify(1,1,m,y1,v),C->modify(1,1,m,y2+1,-v);
  if(y1 <= yy && yy <= y2) D->modify(1,1,n,x1,v),D->modify(1,1,n,x2+1,-v);
  modify(x1,y1,v),modify(x1,y2+1,-v),modify(x2+1,y1,-v),modify(x2+1,y2+1,v);
}

void init(){
  read(n),read(m),read(xx),read(yy),read(t);
  for(int i = 0;i<=n+10;i++){
    ll t = m+10;
    a[i] = new ll[t],b[i] = new ll[t];
    memset(a[i],0,sizeof(ll) * t),memset(b[i],0,sizeof(ll) * t);
  }
  for(int i = 1;i<=n;i++)
    for(int j = 1;j<=m;j++)
      read(a[i][j]);
}

void build(){
  for(int i = 1;i<=n;i++)
    for(int j = 1;j<=m;j++)
      b[i][j] = a[i][j] - a[i-1][j] - a[i][j-1] + a[i-1][j-1];
  for(int i = 1;i<=m;i++) c[i] = a[xx][i] - a[xx][i-1];
  for(int i = 1;i<=n;i++) d[i] = a[i][yy] - a[i-1][yy];
  val = a[xx][yy];
  C = new SegTree1D(m),D = new SegTree1D(n);
  C->build(1,1,m,c,NULL),D->build(1,1,n,d,NULL);
  T.build(1,1,n,m,b);
}

void solve(){
  static int op,x1,x2,y1,y2;
  static ll v;
  for(int i = 1;i<=t;i++){
    read(op),read(x1),read(y1),read(x2),read(y2);
    if(op == 0){
      print(query(x1,x2,y1,y2)),print('\n');
    }
    else{
      read(v);
      modify(x1,x2,y1,y2,v);
    }
  }
}

signed main(){
  init();
  build();
  solve();
  flush();
  return 0;
}
```




