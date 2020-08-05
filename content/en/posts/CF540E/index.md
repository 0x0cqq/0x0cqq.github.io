---
title: 「CF540E」Infinite Inversions-动态开点线段树
urlname: CF540E
date: 2019-01-01 14:11:22
tags:
- 数据结构
- 线段树
categories: 
- OI
- 题解 
series:
- Codeforces
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

现在有一个由所有正整数组成的无限递增序列： $p = {1,2,3,...}$ 。

对这个序列执行 $n$ 次交换操作。每次一个操作，给出两个整数 $a,b$，交换位置 $a$ 和 $b$ 处的元素。 

你的任务是在所有操作结束后，输出最终序列的逆序对个数，即满足 $i < j$ 且 $p_i > p_j$ 的有序数对 $(i,j)$ 的数量。

<!--more-->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/540/E)

## 题解

我们发现，两个没有经过任何交换的位置之间是不可能产生逆序对的，可能产生逆序对的只有：
+ 换的与没换的
+ 换的与换的

所以我们只需要考虑被换的能产生的逆序对即可，可以发现这样统计是完全的。

我们考虑先用 $map$ 记录交换最后的结果和哪些位置有交换，这块非常简单，时间复杂度是 $O(n\log n)$ 的。

我们接下来考虑最后数列的逆序对个数。

先考虑第一种情况：换的与没换的产生了逆序对。

对于每一个交换的数，我们考虑两种情况：在其前面，比其大，在其后面，比其大。

我们考虑到换的在 1e9 范围内比较小，可以开一个动态开点线段树维护哪些位置被x掉了，然后查询区间和就可以知道第一个问题的答案了。

我们考虑第二种情况：两个换了的产生了逆序对。

这种情况下，我们只需要考虑在前面的，比他大的个数即可，本质上是个二维数点问题。

维护扫描线，和动态开点线段树，可以在 $O(n \log V)$ 时间内解决。

最后时间复杂度： $O(n (\log V + \log n))$，空间 $O(n \log V)$

## 代码


```cpp
#include <bits/stdc++.h>
#define ll long long
using namespace std;

const int MAXN = 101000,logn = 35;

struct SegTree{
  int sumn[MAXN*logn],ls[MAXN*logn],rs[MAXN*logn],cnt = 0;
  #define mid ((l+r)/2)
  void update(int &nown,int l,int r,int pos,int v){
    if(!nown) nown = ++cnt;
    if(l == r)
      sumn[nown] += v;
    else{
      sumn[nown] += v;
      if(pos <= mid) update(ls[nown],l,mid,pos,v);
      if(pos >= mid+1) update(rs[nown],mid+1,r,pos,v);
    }
  }
  int query(int nown,int l,int r,int ql,int qr){
    if(ql > qr) return qr - ql + 1;//以便后面和负数区间对掉，其余部分最多只会差1，返回0没有锅
    if(!nown) return 0;
    if(ql <= l && r <= qr)
      return sumn[nown];
    else{
      int ans = 0;
      if(ql <= mid) ans += query(ls[nown],l,mid,ql,qr);
      if(qr >= mid+1) ans += query(rs[nown],mid+1,r,ql,qr);
      return ans;
    }
  }
}T1,T2;

int n,MAX = 1e9;

map<int,int> S; // pos->val
int getval(int x){return S.count(x)?S[x]:x;}

void _swap(int a,int b){
  int va = getval(a),vb = getval(b);
  S[a] = vb,S[b] = va;
}

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n;i++){
    int a,b;
    scanf("%d %d",&a,&b);
    _swap(a,b);
  }
}

ll ans = 0;
int rt1,rt2;

void solve(){
  for(auto it = S.begin();it!=S.end();it++){
    T1.update(rt1,1,MAX,it->first,1);
  }
  for(auto it = S.begin();it!=S.end();it++){
    int p = it->first,v = it->second;
    ans += ((p-1)-(v+1)+1) - T1.query(rt1,1,MAX,v+1,p-1);//前面比他大的
    ans += ((v-1)-(p+1)+1) - T1.query(rt1,1,MAX,p+1,v-1);//后面比他小的
  }
  for(auto it = S.begin();it!=S.end();it++){
    int v = it->second;
    ans += T2.query(rt2,1,MAX,v+1,MAX);
    T2.update(rt2,1,MAX,v,1);
  }
  printf("%lld\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```

