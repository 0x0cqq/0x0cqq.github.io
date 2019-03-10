---
title: 「CF369E」Valera and Queries-线段树
urlname: CF369E
date: 2018-12-29 23:41:25
tags:
- 题解
- 数据结构
- 线段树
- 树套树
categories: OI 
visible:
---

有 $n$ 条线段，分别为 $[l_i,r_i]$ 。

有 $m$ 个询问，分别为 $cnt_i,p_1,p_2,...,p_{cnt_i}$

对于每个询问，输出有多少线段至少覆盖这 $cnt_i$ ​个点中的一个。（$\sum cnt_i \le 3 \cdot 10^5$）

<!-- more -->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/369/E)

## 题解

我们可以考虑一个点的贡献会出现在哪些区间。

我们最大的问题是每个区间可能被多个点在内，我们如果按照每个点在内（左端点在左，右端点在右）的话，会重复统计一些区间。

我们考虑用唯一性确定这个贡献，用最左侧的点给区间计算贡献。所以我们每个点可能生发出贡献的区间是从左边的上一个点右边一直到这个点右边最右侧位置。

~~我们可以考虑用扫描线计算这个东西，我们考虑对每次给出的点排序，然后扫描线维护即可。
我们可以维护两个BIT/线段树，然后查询区间和即可。~~

~~需要 `KD Tree` 或者树套树或者 `CDQ` 分治来完成二维数点的任务。~~

可以线段树套vector解决这个问题。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 310000;

int n,m,cnt = 0;
struct Line{
  int l,r;
  bool operator < (const Line x)const{
    if(l != x.l) return l < x.l;
    else return r < x.r;
  }
}a[MAXN];

int t[MAXN],back[MAXN];
map<int,int> S;

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    scanf("%d %d",&a[i].l,&a[i].r);
    S[a[i].l] = 0;
  }
  sort(a+1,a+n+1);
  for(auto it = S.begin();it!=S.end();it++){
    it->second = ++cnt;
    back[cnt] = it->first;
  }
}

namespace SegTree{
  vector<int> v[MAXN<<2];
  #define lson (nown<<1)
  #define rson (nown<<1|1)
  #define mid ((l+r)>>1)
  void build(int nown,int l,int r,int *a){
    for(int i = l;i<=r;i++)
      v[nown].push_back(a[i]);
    sort(v[nown].begin(),v[nown].end());
    if(l == r) 
      return;
    else
      build(lson,l,mid,a),build(rson,mid+1,r,a);
  }
  int a,b;
  void query(int nown,int l,int r,int ql,int qr,int &ans){
    if(ql <= l && r <= qr){
      ans += upper_bound(v[nown].begin(),v[nown].end(),b) - lower_bound(v[nown].begin(),v[nown].end(),a);
    }
    else{
      if(ql <= mid)
        query(lson,l,mid,ql,qr,ans);
      if(qr >= mid+1)
        query(rson,mid+1,r,ql,qr,ans);
    }
  }
  int query(int n,int x1,int x2,int y1,int y2){
    if(x1 > x2) return 0;
    a = y1,b = y2;
    int ans = 0;
    query(1,1,n,x1,x2,ans);
    return ans;
  }
}

void build(){
  static int tmp[MAXN];
  for(int i = 1;i<=n;i++){
    tmp[i] = a[i].r;
  }
  for(int i = 1;i<=n;i++){
    t[i] = back[S[a[i].l]];
  }
  SegTree::build(1,1,n,tmp);
}

int s[MAXN];
int getval(int x){
  return upper_bound(t+1,t+n+1,x) - t;
}

void solve_case(){
  int p;
  scanf("%d",&p);
  for(int i = 1;i<=p;i++) scanf("%d",&s[i]);
  sort(s+1,s+p+1);
  s[0] = -1e9;
  int ans = 0;
  for(int i = 1;i<=p;i++){
    ans += SegTree::query(n,getval(s[i-1]),getval(s[i])-1,s[i],1e9);
  }
  printf("%d\n",ans);
}

void solve(){
  for(int i = 1;i<=m;i++){
    solve_case();
  }
}

int main(){
  init();
  build();
  solve();
  return 0;
}
```

