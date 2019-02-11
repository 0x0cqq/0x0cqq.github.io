---
title: 「CF877F」Ann and Books-莫队
urlname: CF877F
date: 2019-02-11 23:39:31
tags:
- 题解
- 数据结构
- 莫队
categories:
visible:
---

有 $n$ 本书，第 $i$ 本书中有 $a_i$ 个问题，均属于第 $t_i$ 类问题。

有 $q$ 次询问，每次询问给出一个区间 $[l_i,r_i]$ ，询问有多少个原序列的连续子区间是给出区间的子区间，且该子区间中所有书中问题的和满足第 $1$ 类的问题恰好比第 $2$ 类的问题恰好多 $k$ 个。

<!-- more -->

数据范围： $1 \le n \le 10^5$ , $-10^9 \le k \le 10^9$,  $t_i \in \{1,2\}$ , $0 \le a_i \le 10^9$ , $1 \le q \le 10^5$ , $1 \le l_i \le r_i \le n$

## 链接

[Codeforces](https://codeforces.com/problemset/problem/877/F)

## 题解

看到离线的区间询问让我们想到莫队（其实是前几天THUWC没做出来签到题让我想到的），然后我们发现我们可以做到相邻的区间转移。这个问题事实上就是前缀和相差 $k$ ，我们用个什么东西（比如 map ）离散化一下所有的sum前缀和，预处理出来每个位置的前缀和减掉和加上 $k$ 之后的离散化后的数字。在莫队的过程中维护一个 $cnt$ 数组，就可以 $O(1)$ 转移了。

时间复杂度：$O(q \sqrt n + n \log n )$

## 代码

{% fold %}
```cpp
#include <bits/stdc++.h>
#define ll long long
using namespace std;
const int MAXN = 110000;

int n,q,Q;
int t[MAXN],a[MAXN];
ll k,sum[MAXN],A[MAXN],B[MAXN];// A -> -k / B -> +k
map<ll,int> S;int tmpcnt = 0;

struct Query{
  int l,r,id;
}qu[MAXN];

bool cmp(Query a,Query b){
  if(a.l/Q != b.l/Q)
    return a.l / Q < b.l / Q;
  else
    return ((a.l/Q)&1)?a.r < b.r:a.r > b.r;
}

void init(){
  scanf("%d %lld",&n,&k);
  for(int i = 1;i<=n;i++) scanf("%d",&t[i]);
  for(int i = 1;i<=n;i++) scanf("%d",&a[i]);
  for(int i = 1;i<=n;i++){
    sum[i] = t[i] == 1?a[i]:-a[i];
    sum[i] += sum[i-1];
    S[sum[i]] = 0;
  }
  S[0] = 0;
  for(auto it = S.begin();it != S.end();it++)
    it->second = ++tmpcnt;
  for(int i = 0;i<=n;i++){
    if(S.count(sum[i]-k)) A[i] = S[sum[i]-k];
    if(S.count(sum[i]+k)) B[i] = S[sum[i]+k];
    sum[i] = S[sum[i]];
  }
  Q = sqrt(n);
  scanf("%d",&q);
  for(int i = 1;i<=q;i++)
    scanf("%d %d",&qu[i].l,&qu[i].r),qu[i].id = i;
  sort(qu+1,qu+q+1,cmp);
}

static int cnt[MAXN],L = 1,R = 0;// 维护 [L-1,R] 的前缀和
ll ans = 0;
void addL(int pos){
  ans += cnt[B[pos-1]];cnt[sum[pos-1]]++;
}
void addR(int pos){
  ans += cnt[A[pos]];cnt[sum[pos]]++;
}
void delL(int pos){
  cnt[sum[pos-1]]--;ans -= cnt[B[pos-1]];
}
void delR(int pos){
  cnt[sum[pos]]--;ans -= cnt[A[pos]];
}

ll ANS[MAXN];

void solve(){
  cnt[S[0]] = 1;
  for(int i = 1;i<=q;i++){
    while(qu[i].l < L) addL(--L);
    while(qu[i].r > R) addR(++R);
    while(qu[i].l > L) delL(L++);
    while(qu[i].r < R) delR(R--);
    ANS[qu[i].id] = ans;
  }
  for(int i = 1;i<=q;i++){
    printf("%lld\n",ANS[i]);
  }
}

int main(){
  init();
  solve();
  return 0;
}
```
{% endfold %}


