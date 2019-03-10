---
title: 「CF256E」Lucky Arrays-简单线段树
urlname: CF256E
date: 2018-12-27 20:51:00
tags:
- 题解
- 数据结构
- 线段树
categories: OI
visible:
---

给定一个长度为 $n(1 \le n \le 77777)$ 的数列 $a$ ，初始的时候全为 0。

给出一个 $3 \times 3$ 的矩阵 $w_{i,j}$ ，$w_{i,j} = 1$ 时代表 $(i,j)$ 这个**有序**数对为和谐的数对，否则 $(i,j)$ 不为一个和谐数对。

一个数列 $a$ 是和谐的当且仅当对于所有的 $1\le i \le n-1$ ， $(a_i,a_{i+1})$ 均为和谐数对。

有 $m(1\le m \le 77777)$ 次修改和询问，每次给出两个整数 $v_i,t_i$，将 $a_{v_i} (1 \le v_i \le n)$ 修改为 $t_i(0\le t_i \le 3)$。

每次修改后都询问，如果将数列里所有的 $0$ 都替换为任意 $1$ 到 $3$ 之间的整数（不同位置的 $0$ 可以替换为不同的数），那么最后产生的和谐的数列有多少种。每次修改后的查询并不会使数列发生任何改变。

答案对 $777777777$ 取模。

<!-- more -->

## 链接

[Codeforces](https://codeforc.es/contest/256/problem/E)

## 题解

我们维护一个线段树，每个区间上都维护一个 $f[i][j]$ 代表这个区间左端点数字为 $i$ 的时候，右端点为 $j$ 的时候，满足以上条件的方案数。

合并直接枚举两边各九种组合合并即可。

时间复杂度 $O(n \log n \times 81)$ ，貌似可以过。

我想了一个麻烦死的线性动态 $dp$，好像也可以做，时间复杂度应该是 一样的，但不想写了...

## 代码

{% fold %}
```cpp
#include <bits/stdc++.h>
#define ll long long 
#define mod 777777777LL
using namespace std;

const int MAXN = 80000;

int w[3][3];

namespace SegTree{
  struct Node{
    ll f[3][3];
    Node(){
      f[0][0] = f[0][1] = f[0][2] = 0;
      f[1][0] = f[1][1] = f[1][2] = 0;
      f[2][0] = f[2][1] = f[2][2] = 0;
    }
    void clear(){
      f[0][0] = f[0][1] = f[0][2] = 0;
      f[1][0] = f[1][1] = f[1][2] = 0;
      f[2][0] = f[2][1] = f[2][2] = 0;      
    }
    ll *operator [](const int x){return f[x];}
  }tree[MAXN*4];
  #define lson (nown<<1)
  #define rson (nown<<1|1)
  #define mid ((l+r)>>1)
  Node merge(Node &l,Node &r){
    Node ans;
    for(int i = 0;i<3;i++){
      for(int j = 0;j<3;j++){
        for(int x = 0;x<3;x++){
          for(int y = 0;y<3;y++){
            ans[i][j] += w[x][y] * l[i][x] * r[y][j];
          }
        }
        ans[i][j] %= mod;
      }
    }
    return ans;
  }
  void build(int nown,int l,int r){
    if(l == r){
      tree[nown].clear();
      tree[nown][0][0] = tree[nown][1][1] = tree[nown][2][2] = 1;
    }
    else{
      build(lson,l,mid),build(rson,mid+1,r);
      tree[nown] = merge(tree[lson],tree[rson]);
    }
  }
  void update(int nown,int l,int r,int pos,int v){
    // printf("%d %d %d\n",l,r,pos);
    if(l == r){
      tree[nown].clear();
      if(v == 0){tree[nown][0][0] = tree[nown][1][1] = tree[nown][2][2] = 1;}
      else {tree[nown][v-1][v-1] = 1;}
      // printf("!!\n");
    }
    else{
      if(pos <= mid) update(lson,l,mid,pos,v);
      if(pos >= mid+1) update(rson,mid+1,r,pos,v);
      tree[nown] = merge(tree[lson],tree[rson]);
      // printf("a:%d %d %d\n",l,r,pos);
    }
  }
  ll query(){
    ll ans = 0;
    for(int i = 0;i<3;i++){
      for(int j = 0;j<3;j++){
        ans += tree[1][i][j];
      }
    }
    return ans % mod;
  }
}

int n,m;

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 0;i<3;i++){
    for(int j = 0;j<3;j++){
      scanf("%d",&w[i][j]);
    }
  }
  SegTree::build(1,1,n);
}

void solve(){
  for(int i = 1;i<=m;i++){
    int p,v;
    scanf("%d %d",&p,&v);
    SegTree::update(1,1,n,p,v);
    printf("%lld\n",SegTree::query());
  }
}

int main(){
  init();
  solve();
  return 0;
}
```
{% endfold %}

