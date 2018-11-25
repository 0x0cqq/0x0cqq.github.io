---
title: 「SCOI2014」方伯伯的OJ-动态开点线段树
urlname: SCOI2014-onlinejudge
date: 2018-10-03 23:35:33
tags:
- 题解
- 数据结构
- 线段树
categories: OI
visible:
---
方伯伯正在做他的 OJ 。现在他在处理 OJ 上的用户排名问题。 OJ 上注册了 $n$ 个用户，编号为 $1$ ～ $n$ ，一开始他们按照编号排名。

方伯伯会按照心情对这些用户做以下四种操作，修改用户的排名和编号 ，共有 $m$ 次操作：

1. 操作格式为 `1 x y` ，意味着将编号为 $x$ 的用户编号改为 $y$ ，而排名不变，执行完该操作后需要输出该用户在队列中的位置，数据保证 $x$ 必然出现在队列中，同时， $y$ 是一个当前不在排名中的编号。

2. 操作格式为 `2 x` ，意味着将编号为 $x$ 的用户的排名提升到第一位，执行完该操作后需要输出执行该操作前编号为 $x$ 用户的排名。

3. 操作格式为 `3 x` ，意味着将编号为 $x$ 的用户的排名降到最后一位，执行完该操作后需要输出执行该操作前编号为 $x$ 用户的排名。

4. 操作格式为 `4 k`，意味着查询当前排名为 $k$ 的用户编号，执行完该操作后需要输出当前操作用户的编号。

对于 $100\%$ 的数据， $1 \leq n \leq 10^8,1 \leq m \leq  10^5$。

强制在线。

<!-- more -->

## 链接

[Luogu P3285](https://www.luogu.org/problemnew/show/P3285)

## 题解

一道有(du)趣(liu)的数据结构题。

注意到 $n$ 的范围比较大， $m$ 的范围比较小，所以不能直接把平衡树建出来，要不然空间/时间咕咕咕...

所以我们需要想办法优化一下。注意到 $m$ 的范围是 $10^5$ ，而且只有在两端添加的操作，所以我们可以用动态开点线段树代替平衡树。

 > NOIP 2017 D2T3 告诉我们，如果一个平衡树只有在末尾/开头添加和删除操作，那么我们完全可以用动态开点线段树取代它。实现复杂度和时间复杂度都会大幅优化。

我们用一个很大很大的动态开点线段树取代平衡树，具体来说就是我们假装我们线段树的 $[1,10^8]$ 之间都塞满了数，但是事实上一个都没有，只有我们要对它进行修改的时候才去把某个位置到根的路径变成真实存在的即可。

把一个数放到头部就相当于在原位置标记我们已经删除了这个数，然后在 $(- \infty,0]$ 这个区间里顺次往外插入即可；放到尾部同理，就相当于从内向外在 $[n+1,+\infty)$ 往里插入数即可。

然后我们还要记录一个数在线段树重的位置，这里使用一个 `map` ，在线段树中 $x$ 数出现的位置，没有该 `key` 则为没有动过，仍在 $x$ 位置。

由于 $m$ 较 $n$ 比较小，所以时间复杂度 $O(m \log n)$ ，空间复杂度 $O(m \log n)$。

## 代码

{% fold %}
```cpp
#include <cstdio>
#include <map>
#include <algorithm>
using namespace std;

const int MAXN = 100000,logn = 35;

const int L = -1e7,R=1e8+1e7;

struct SegTree{
  int siz[MAXN*logn],val[MAXN*logn],ls[MAXN*logn],rs[MAXN*logn];
  int root,cnt;
  #define mid ((l+r)>>1)
  void update(int &nown,int l,int r,int pos,int v){
    if(!nown) nown = ++cnt;
    if(l == r)
      val[nown] = v,siz[nown] = 0;
    else{
      if(pos <= mid)
        update(ls[nown],l,mid,pos,v);
      if(pos >= mid+1)
        update(rs[nown],mid+1,r,pos,v);
      siz[nown] = siz[ls[nown]] + siz[rs[nown]];
    }
  }
  void remove(int &nown,int l,int r,int pos){
    if(!nown) nown = ++cnt;
    if(l == r)
      siz[nown] = -1;
    else{
      if(pos <= mid)
        remove(ls[nown],l,mid,pos);
      if(pos >= mid+1)
        remove(rs[nown],mid+1,r,pos);
      siz[nown] = siz[ls[nown]] + siz[rs[nown]];
    }
  }
  int kth(int nown,int l,int r,int k,int &v){
    if(k > (r-l+1) + siz[nown]) return -1;
    if(l == r){
      v = val[nown];
      return l;
    }
    else{
      int sz = (mid-l+1) + siz[ls[nown]];
      if(k <= sz)
        return kth(ls[nown],l,mid,k,v);
      if(k > sz)
        return kth(rs[nown],mid+1,r,k-sz,v);
      return -1;
    }
  }
  int getsum(int nown,int l,int r,int ql,int qr){
    if(!nown) return 0;
    if(ql <= l && r <= qr){
      return siz[nown];
    }
    else{
      int ans = 0;
      if(ql <= mid)
        ans += getsum(ls[nown],l,mid,ql,qr);
      if(qr >= mid+1)
        ans += getsum(rs[nown],mid+1,r,ql,qr);
      return ans;
    }
  }
  void update(int pos,int v){update(root,L,R,pos,v);}
  void remove(int pos){remove(root,L,R,pos);}
  int kth(int k){int v=0,t = kth(root,L,R,k,v);return v!=0?v:t;}
  int getsum(int l,int r){return getsum(root,L,R,l,r);}
}T;

int n,m,nowl,nowr;

map<int,int> M;//在线段树中 x 出现的位置，没有则为没有动过

int getpos(int x){
  return M.count(x)?M[x]:x;
}

int push_top(int x){
  int pos = getpos(x),ans = (pos-nowl+1) + T.getsum(nowl,pos);
  T.remove(pos),T.update(--nowl,x);
  M[x] = nowl;
  return ans;
}

int push_bottom(int x){
  int pos = getpos(x),ans = (pos-nowl+1) + T.getsum(nowl,pos);
  T.remove(pos),T.update(++nowr,x);
  M[x] = nowr;
  return ans;
}

int change_id(int x,int y){
  int pos = getpos(x),ans = (pos-nowl+1) + T.getsum(nowl,pos);
  T.update(pos,y);
  M[y] = pos;
  return ans;
}

int query_id(int k){
  return T.kth((nowl-L)+k);
}

void init(){
  scanf("%d %d",&n,&m);
  nowl = 1,nowr = n;
}

void solve(){
  int lastans = 0;
  for(int i = 1;i<=m;i++){
    int op,x,y,k;
    scanf("%d",&op);
    if(op == 1){
      scanf("%d %d",&x,&y);
      x -= lastans,y -= lastans;
      lastans = change_id(x,y);
    }
    else if(op == 2){
      scanf("%d",&x);x -= lastans;
      lastans = push_top(x);
    }
    else if(op == 3){
      scanf("%d",&x);x -= lastans;
      lastans = push_bottom(x);
    }
    else if(op == 4){
      scanf("%d",&k);k -= lastans;
      lastans = query_id(k);
    }
    printf("%d\n",lastans);
  }
}

int main(){
  init();
  solve();
  return 0;
}
```
{% endfold %}

