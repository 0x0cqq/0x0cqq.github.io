---
title: 「CF232D」Fence-后缀数组+主席树
urlname: CF232D
date: 2019-02-04 17:48:34
tags:
- 后缀数组
- 主席树
- 字符串
- 数据结构
categories: 
- OI
- 题解
visible:
---

给定长度为 $n$ 的整数序列 $h[n]$ ，有 $Q$ 个询问，每次给出 $l_1,r_1$  ，​询问有多少对 $l_2,r_2$ ，满足以下条件:

1. $r_2 – l_2 = r_1 – l_1$
2. 区间 $[l_1, r_1]$ 与区间 $[l_2, r_2]$ 没有交集
3. 对于任意 $i \in [0,r_1 – l_1]$ ，满足 $h[l_1 + i] + h[l_2 + i] = h[l_1] + h[l_2]$

<!-- more -->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/232/D)

## 题解

注意到第三个条件可以转化成 
$$
h[l_1 + i + 1] + h[l_2 + i + 1] = h[l_1 + i] + h[l_2 + i],
\\ i \in [0,r_i-l_i-1]
$$

也就是
$$
h[l_1 + i + 1] - h[l_1 + i] = - (h[l_2 + i + 1]  - h[l_2 + i])
\\ i \in [0,r_i-l_i-1]
$$

我们令 $g[i] = h[i+1] - h[i]$，那么第三个条件的表述就变为：

$$
g[l_1+i] =  -g[l_2+i]
\\ i \in [0,r_i-l_i-1]
$$

如果我们令 $len = r_i-l_i-1$ ，那么条件变成：

$$
g[l_1...l_1+len] = - g[l_2...l_2+len]
$$

后缀数组处理之后，就变成了一个二维数点的问题，随便怎么搞一搞就可以了。

这里用了主席树实现。要特判 $l = r$ 的情况，答案是 $n-1$ 。注意要排除掉相交的情况，需要加一减一，这个地方比较容易错...

## 代码


```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 210000,LOGN = 20;

namespace SA{
  int s[MAXN],sa[MAXN],ht[MAXN],x[MAXN],y[MAXN],rk[MAXN],cnt[MAXN];
  void get_sa(int n,int m){
    for(int i = 0;i<m;i++) cnt[i] = 0;
    for(int i = 0;i<n;i++) cnt[s[i]]++;
    for(int i = 1;i<m;i++) cnt[i] += cnt[i-1];
    for(int i = n-1;~i;--i) sa[--cnt[s[i]]] = i;
    m = rk[sa[0]] = 0;
    for(int i = 1;i<n;i++) rk[sa[i]] = s[sa[i]] == s[sa[i-1]]?m:++m;
    for(int j = 1;;j<<=1){
      if(++m == n) break;
      for(int i = 0;i<j;i++) y[i] = n-j+i;
      for(int i = 0,k = j;i<n;i++) if(sa[i] >= j) y[k++] = sa[i] - j;
      for(int i = 0;i<n;i++) x[i] = rk[y[i]];
      for(int i = 0;i<m;i++) cnt[i] = 0;
      for(int i = 0;i<n;i++) cnt[x[i]]++;
      for(int i = 1;i<m;i++) cnt[i] += cnt[i-1];
      for(int i = n-1;~i;--i) sa[--cnt[x[i]]] = y[i],y[i] = rk[i];
      m = rk[sa[0]] = 0;
      for(int i = 1;i<n;i++) rk[sa[i]] = (y[sa[i]] == y[sa[i-1]] && y[sa[i]+j] == y[sa[i-1]+j]?m:++m);
    }
  }
  void get_height(int n){
    for(int i = 0,h = ht[0] = 0;i<n;i++){
      int j = sa[rk[i]-1];
      while(i+h<n && j+h<n && s[i+h] == s[j+h]) h++;
      ht[rk[i]] = h;
      if(h) --h;
    }
  }
  void solve(int n,int m,int *a){
    for(int i = 0;i<n;i++) s[i] = a[i];
    s[n++] = 0;
    get_sa(n,m),get_height(n);
  }
}

namespace ST{
  int minn[MAXN][LOGN];
  void init(int n,int *a){
    for(int i = 1;i<=n;i++) minn[i][0] = a[i];
    for(int j = 1;j<LOGN;j++)
      for(int i = 1;i + (1<<(j-1)) <= n;i++)
        minn[i][j] = min(minn[i][j-1],minn[i+(1<<(j-1))][j-1]);
  }
  int query(int l,int r){
    int t = log2(r-l+1);
    return min(minn[l][t],minn[r-(1<<t)+1][t]);
  }
}

int _q(int l,int r){
  return l == r ? inf : ST::query(l+1,r);
}

int rt[MAXN];

namespace CMT{
  int ls[MAXN*LOGN],rs[MAXN*LOGN],sumn[MAXN*LOGN],cnt;
  #define mid ((l+r)/2)
  void insert(int &nown,int pre,int l,int r,int pos,int v){
    nown = ++cnt;ls[nown] = ls[pre],rs[nown] = rs[pre],sumn[nown] = sumn[pre];
    if(l == r) sumn[nown] += v;
    else{
      if(pos <= mid) insert(ls[nown],ls[pre],l,mid,pos,v);
      if(pos >= mid+1) insert(rs[nown],rs[pre],mid+1,r,pos,v);
      sumn[nown] = sumn[ls[nown]] + sumn[rs[nown]];
    }
  }
  int query(int nown,int l,int r,int ql,int qr){
    if(!nown) return 0;
    if(ql <= l && r <= qr) return sumn[nown];
    else{
      int ans = 0;
      if(ql <= mid) ans += query(ls[nown],l,mid,ql,qr);
      if(qr >= mid+1) ans += query(rs[nown],mid+1,r,ql,qr);
      return ans;
    }
  }
  #undef mid
}

map<int,int> S;
int n,len,m,q,h[MAXN],g[MAXN];

void init(){
  scanf("%d",&n);
  for(int i = 0;i<n;i++){
    scanf("%d",&h[i]);
    if(i) g[i-1] = h[i] - h[i-1];
  }
  g[n-1] = h[n]-h[n-1],g[n] = 2e9+1;
  len = 2*n+1;
  for(int i = 1;i<=n;i++) g[n+i] = -g[i-1];

  for(int i = 0;i<len;i++) S[g[i]] = 0;
  for(auto it = S.begin();it != S.end();it++) it->second = ++m; 
  m++;
  for(int i = 0;i<len;i++) g[i] = S[g[i]];
}

int query_cmt(int lb,int rb,int l,int r){
  return CMT::query(rt[rb],0,len,l,r) - CMT::query(rt[lb-1],0,len,l,r);
}

int query(int L,int R){
  if(L == R) return n-1;
  int pos = SA::rk[L],l = R-L,lb,rb;
  int LL = 0,RR = pos;
  while(LL != RR){
    int mid = (LL+RR)/2;
    if(_q(mid,pos) >= l) RR = mid;
    else                 LL = mid+1;
  }
  lb = LL;
  LL = pos,RR = len;
  while(LL != RR){
    int mid = (LL+RR+1)/2;
    if(_q(pos,mid) >= l) LL = mid;
    else                 RR = mid-1;
  }
  rb = LL;
  return query_cmt(lb,rb,n+1,len) - query_cmt(lb,rb,max(n+1,n+L-l+1),n+R+1);
  return 0;
}

void solve(){
  SA::solve(len,m,g),ST::init(len,SA::ht);
  for(int i = 1;i<len;i++) CMT::insert(rt[i],rt[i-1],0,len,SA::sa[i],1);
  scanf("%d",&q);
  for(int i = 1;i<=q;i++){
    int l,r;
    scanf("%d %d",&l,&r);
    printf("%d\n",query(l-1,r-1));
  }
}

int main(){
  init();
  solve();
  return 0;
}
```
	


