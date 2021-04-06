---
title: 「CQOI2018」异或序列-莫队
urlname: CQOI2018-xor-sequence
date: 2018-09-14 22:11:20
tags: 
- 莫队
- 分块
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

已知一个长度为 $n$ 的整数数列 $a_1,a_2,...,a_n$ ，给定查询参数 $l$ 、 $r$ ，问在 $a_l,a _ {l+1},...,a_r$ ​区间内，有多少子序列满足异或和等于 $k$ 。也就是说，对于所有的 $x,y$ $(l \leq x \leq y \leq r)$ ，能够满足 $a_x \bigoplus a _ {x+1} \bigoplus ... \bigoplus a_y = k$ 的 $x,y$ 有多少组。

<!--more-->

## 链接

[Luogu P4462](https://www.luogu.org/problemnew/show/P4462)

## 题解

考虑到这题没有修改，而且是区间查询问题，所以我们可以考虑一下莫队算法。

如果我们用莫队的话，那么应该让这个数对 $(x,y)$ 的数目能够在 $O(1)$ 的时间维护。

因为异或有结合律，以及 $a\bigoplus a = 0$ ，所以如果我们令 $S_i = a_1 \bigoplus a_2 \bigoplus ... \bigoplus a_i$ ，那么 $a_x \bigoplus a _ {x+1} \bigoplus ... \bigoplus a_y$ 就等于 $S_y \bigoplus S _ {x-1}$。

这个时候如果我们令 $T_i = S _ {i-1} \bigoplus k(S_0 = 0)$ ， 那么 $(x,y)$ 是合法数对的条件就化作 $S_y = T_x$ 。

那么问题转化为在 $l \leq x\leq y \leq r$ 的区间内，有多少对 $(x,y)$ 满足 $T_x = S_y$ ，其中的 $\{T_n\}$ 和 $\{S_n\}$ 都可以 $O(n)$ 的计算。

莫队套套套，记录一下在当前区间每个数在 $\{T_n\}$ 和 $\{S_n\}$ 中出现次数，转移的时候注意分左右讨论一下就好了。

## 代码


```cpp
// luogu-judger-enable-o2
#include <cstdio>
#include <cmath>
#include <algorithm>
#define ll long long
using namespace std;

const int MAXN = 110000;

int n,m,k,Q;
int num[MAXN];
int xor1[MAXN],xor2[MAXN];
ll ans[MAXN];

struct Query{
  int l,r,id;
  bool operator <(const Query _q)const{
    if(l/Q != _q.l/Q){
      return l/Q < _q.l/Q;
    }
    else{
      return r < _q.r;
    }
  }
}q[MAXN];

void init(){
  scanf("%d %d %d",&n,&m,&k);
  Q = sqrt(n);
  for(int i = 1;i<=n;i++){
    scanf("%d",&num[i]);
  }
  for(int i = 1;i<=m;i++){
    scanf("%d %d",&q[i].l,&q[i].r);
    q[i].id = i;
  }
  sort(q+1,q+m+1);
}

void build(){
  for(int i = 1;i<=n;i++){
    xor1[i] = xor1[i-1] ^ num[i];
    xor2[i] = xor2[i-1] ^ num[i];
  }
  for(int i = 0;i<=n;i++) xor2[i] ^= k;
  for(int i = n;i>=0;i--) xor2[i+1] = xor2[i];
}

ll ANS = 0;
ll num1[MAXN],num2[MAXN];

void addl(int pos){
  num1[xor1[pos]]++;
  num2[xor2[pos]]++;
  ANS += num1[xor2[pos]];
}

void addr(int pos){
  num1[xor1[pos]]++; 
  num2[xor2[pos]]++; 
  ANS += num2[xor1[pos]];
}

void dell(int pos){
  ANS -= num1[xor2[pos]];
  num1[xor1[pos]]--;
  num2[xor2[pos]]--;
}

void delr(int pos){
  ANS -= num2[xor1[pos]];
  num1[xor1[pos]]--;
  num2[xor2[pos]]--;  
}

void solve(){
  int L = 1,R = 0;
  for(int i = 1;i<=m;i++){
    while(q[i].l < L) addl(--L);
    while(R < q[i].r) addr(++R);
    while(L < q[i].l) dell(L++);
    while(q[i].r < R) delr(R--); 
    ans[q[i].id] = ANS;
  }
  for(int i = 1;i<=m;i++){
    printf("%lld\n",ans[i]);
  } 
}

int main(){
  init();
  build();
  solve();
  return 0;
}
```

