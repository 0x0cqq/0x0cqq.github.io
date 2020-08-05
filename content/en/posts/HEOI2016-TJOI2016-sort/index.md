---
title: 「HEOI2016/TJOI2016」排序-线段树
urlname: HEOI2016-TJOI2016-sort
date: 2018-08-29 10:38:45
tags:
- 线段树
- 排序
- 二分答案
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

在 $2016$ 年，佳媛姐姐喜欢上了数字序列。因而他经常研究关于序列的一些奇奇怪怪的问题，现在他在研究一个难题，需要你来帮助他。这个难题是这样子的：给出一个 $1$ 到 $n$ 的全排列，现在对这个全排列序列进行 $m$ 次局部排序，排序分为两种：
+ $(0,l,r)$表示将区间 $[l,r]$ 的数字升序排序
+ $(1,l,r)$表示将区间 $[l,r]$ 的数字降序排序
  最后询问第 $q$ 位置上的数字。

<!--more-->

## 链接

[Luogu P2824](https://www.luogu.org/problemnew/show/P2824)

## 题解

好题啊。

因为这个问题只有一个询问，所以我们考虑二分答案。

假设当前的考虑要判定的答案是 $mid$ 与 $p$ 位置上数的大小关系，通过 $O(\log n)$ 次二分，就可以求出最后这个位置上的数字。

所以问题转化为：求出 $p$ 位置上的数与 $k$ 的大小关系。我们关注到，如果我们只关心其位置上的数相对于某一个数的大小关系，那我们就可以将小于等于 $k$ 的数设置成 $0$ ，大于 $k$ 的数设置成 $1$，那么排序就比较容易了，只需要一个 $0/1$ 线段树，维护区间和，支持区间覆盖即可。每次我们查询到 $sum(l,r)$，然后根据这个 $sum$ 的值和排序的种类对区间进行覆盖，升序即为 $0...01...1$，降序则为 $1...10...0$。

最后查询 $q$ 这个位置上的值，如果是 $0$ ，就说明这个位置上的数小于等于 $k$ ，否则就是大于 $k$ 。

二分答案即可。

时间复杂度： $O(n \log^2 n)$

- - -

这题也有用可合并、分裂的线段树的做法，可以处理多组询问。

## 代码


```cpp
#include <cstdio>
using namespace std;

const int MAXN = 31000; 

namespace SegTree{
  #define lson (nown<<1)
  #define rson (nown<<1|1)
  #define mid ((l+r)>>1)
  int sumn[MAXN<<2],lazy[MAXN<<2];// -1 -> no label
  void add_label(int nown,int l,int r,int op){
    lazy[nown] = op,sumn[nown] = (r-l+1)*op;
  }
  void push_down(int nown,int l,int r){
    if(lazy[nown] != -1){
      add_label(lson,l,mid,lazy[nown]);
      add_label(rson,mid+1,r,lazy[nown]);
      lazy[nown] = -1;
    }
  }
  void push_up(int nown){
    sumn[nown] = sumn[lson] + sumn[rson];
  }
  void build(int nown,int l,int r,int k,int *a){
    lazy[nown] = -1;
    if(l == r){
      sumn[nown] = k < a[l];// 满足条件（<=）的 sumn 为 0 
    }
    else{
      build(lson,l,mid,k,a),build(rson,mid+1,r,k,a);
      push_up(nown);      
    }
  } 
  int query(int nown,int l,int r,int ql,int qr){
    if(ql <= l && r <= qr){
      return sumn[nown];
    }
    else{
      push_down(nown,l,r);
      int ans = 0;
      if(ql <= mid)
        ans += query(lson,l,mid,ql,qr);
      if(qr >= mid+1)
        ans += query(rson,mid+1,r,ql,qr);
      return ans;
    }
  }
  void update(int nown,int l,int r,int ql,int qr,int op){
    if(ql <= l && r <= qr){
      add_label(nown,l,r,op);
    }
    else{
      push_down(nown,l,r);
      if(ql <= mid)
        update(lson,l,mid,ql,qr,op);
      if(qr >= mid+1)
        update(rson,mid+1,r,ql,qr,op);
      push_up(nown);
    }
  }
  void print(int nown,int l,int r){
    printf("nown:%d l,r:%d %d sumn:%d lazy:%d\n",nown,l,r,sumn[nown],lazy[nown]);
    if(l == r) return;
    print(lson,l,mid);
    print(rson,mid+1,r);
  }
  void sort(int n,int l,int r,int op){// op 为 0 正序 ， op 为 1 逆序
    int b = query(1,1,n,l,r),a = (r-l+1) - b;
    //printf("a:%d b:%d\n",a,b);
    if(op == 0){
      if(a) update(1,1,n,l,l+a-1,0);
      if(b) update(1,1,n,r-b+1,r,1);
    } 
    else{
      if(b) update(1,1,n,l,l+b-1,1);
      if(a) update(1,1,n,r-a+1,r,0);      
    }
  }
  #undef lson
  #undef rson
  #undef mid
}

int n,m,q;
int a[MAXN];
int o[MAXN],l[MAXN],r[MAXN];
void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++)
    scanf("%d",&a[i]);
  for(int i = 1;i<=m;i++)
    scanf("%d %d %d",&o[i],&l[i],&r[i]);
  scanf("%d",&q);
}

bool check(int k){//检查 q 位置上的数是不是小于等于 k  
  SegTree::build(1,1,n,k,a);
  for(int i = 1;i<=m;i++)
    SegTree::sort(n,l[i],r[i],o[i]);
  return SegTree::query(1,1,n,q,q) == 0;
}

void solve(){
  int b = 1,e = n;
  while(b!=e){
    int mid = (b+e)>>1;
    //printf("%d %d:%d\n",b,e,mid);
    if(check(mid))
      e = mid;
    else
      b = mid+1;
  }
  printf("%d\n",b);
}

int main(){
  init();
  solve();
  return 0;
}
```

