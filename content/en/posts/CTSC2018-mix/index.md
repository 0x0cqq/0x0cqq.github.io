---
title: 「CTSC2018」混合果汁-整体二分
urlname: CTSC2018-mix
date: 2018-10-17 22:54:44
tags:
- 整体二分
- set
categories: 
- OI
- 题解
series:
- WC/CTSC/APIO
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

小 R 热衷于做黑暗料理，尤其是混合果汁。

商店里有 $n$ 种果汁，编号为 $0,1,\cdots,n-1$ 。$i$  号果汁的美味度是 $d_i$ ，每升价格为 $p_i$​ 。小 R 在制作混合果汁时，还有一些特殊的规定，即在一瓶混合果汁中，$i$  号果汁最多只能添加 $l_i$ 升。

现在有 $m$ 个小朋友过来找小 R 要混合果汁喝，他们都希望小 R 用商店里的果汁制作成一瓶混合果汁。其中，第 $j$ 个小朋友希望他得到的混合果汁总价格不大于 $g_j$ ，体积不小于 $L_j$​ 。在上述这些限制条件下，小朋友们还希望混合果汁的美味度尽可能地高，一瓶混合果汁的美味度等于所有参与混合的果汁的美味度的最小值。请你计算每个小朋友能喝到的最美味的混合果汁的美味度。

<!--more-->

## 链接

[Luogu P4602](https://www.luogu.org/problemnew/show/P4602)

## 题解

这个题可以整体二分。

对 $d$ 进行 $\text{sort}$ 后，我们可以用 $\text{multiset}$ 维护前缀的果汁按照 $p$ 排序之后的顺序，然后把当前询问按照 $g$ 排序，逐步加入每种果汁，判断是否可以达成  $l$ 的体积作为二分依据。

假装复杂度大约是 $O(n \log^2 n)$。

反正可过。

## 代码


```cpp
// Code By Chen Qiqian on 2018.10.16
#include <bits/stdc++.h>
#define ll long long
using namespace std;

const int MAXN = 210000;

int n,m;

struct Node{
  ll d,p,l;
  bool operator < (const Node &a)const{
    if(d != a.d)
      return d > a.d;
    else
      return p < a.p;
  }
}t[MAXN];


bool cmp(const int &a,const int &b){
  if(t[a].p != t[b].p)
    return t[a].p < t[b].p;
  else
    return t[a].l < t[b].l;
}

struct Query{
  ll g,l,id;
}q[MAXN];


int ans[MAXN];

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    ll a,b,c;
    scanf("%lld %lld %lld",&a,&b,&c);
    t[i] = (Node){a,b,c};
  }
  sort(t+1,t+n+1);
  for(int i = 1;i<=m;i++){
    scanf("%lld %lld",&q[i].g,&q[i].l);
    q[i].id = i;
  }
}

int a1[MAXN],a2[MAXN];

struct T{
  ll p,l;
  bool operator < (const T &w)const{
    if(p != w.p)
      return p < w.p;
    else
      return l < w.l;
  }
};


multiset<T> K;
int pos = 0;//[1,pos]

bool cmp2(const int a,const int b){
  return q[a].g < q[b].g;
}



void solve(int *a,int n1,int l,int r){// *a 存储询问编号 在 [l,r] 果汁内二分
  if(n1 == 0) return;
  if(l == r){
    for(int i = 0;i<n1;i++)
      ans[q[a[i]].id] = t[l].d;
    return;
  }
  // 寻找到最小的需要的 n
  // d 按从大到小排序
  int mid = (l+r)>>1;
  //判断 1 -> mid 区间是否可以满足限制 (g_i,l_i)
  //维护multiset使其可以包括 [1,mid] 所有果汁
  while(pos < mid){
    pos++;
    K.insert((T){t[pos].p,t[pos].l});
  }
  while(pos > mid){
    K.erase(K.lower_bound((T){t[pos].p,t[pos].l}));
    pos--;
  }
  ll G = 0,L = 0,acnt = 0,bcnt = 0;
  sort(a,a+n1,cmp2);
  multiset<T>::iterator it = K.begin();
  #define xp it->p
  #define xl it->l
  for(int i = 0;i<n1;i++){
    while(it != K.end() && G + xp * xl <= q[a[i]].g){
      G += xp * xl,L += xl;
      it++;
    }
    if(L >= q[a[i]].l ||
      (it != K.end() && (q[a[i]].l-L) * xp + G <= q[a[i]].g))
      a1[acnt++] = a[i];
    else
      a2[bcnt++] = a[i];
  }
  memcpy(a,a1,sizeof(int)*acnt),memcpy(a+acnt,a2,sizeof(int)*bcnt);
  solve(a,acnt,l,mid),solve(a+acnt,bcnt,mid+1,r);
  #undef xp
  #undef xl
}

void solve(){
  static int qq[MAXN];
  for(int i = 1;i<=m;i++)
    qq[i] = i;
  t[n+1].d=-1;t[n+1].p=0;t[n+1].l=1e18;++n;
  solve(qq+1,m,1,n);
  for(int i = 1;i<=m;i++)
    printf("%d\n",ans[i]);
}

signed main(){
  init();
  solve();
  return 0;
}
```

