---
title: 「CF160E」Buses and People-线段树
urlname: CF160E
date: 2018-12-24 23:57:34
tags:
- 题解
- 数据结构
- 线段树
categories: OI
visible:
---

Bertown 大街可以抽象为一条数轴。在数轴上有 $10^9$ 个巴士站。站点按照它们在数轴上的顺序从 $1$ 到 $10^9$ 的整数编号。这个城市有 $n$ 辆公共汽车。每天第 $i$ 个公共汽车从 $s_i$ 位置出发，到 $f_i$ 位置停止（ $s_i < f_i$ ），它在所有位于 $s_i$ 与  $f_i$ 的中间站点停靠并且仅在晚上返回。公共汽车在时间 $t_i$ 开始行驶，并且它也在时间 $t_i$ 完成行驶（行驶、停靠都是瞬间的）。所有公共汽车的开始时间 $t_i$ 都不同。公交车有无限的容量。

Bertown 有很多居民。今天第 $i$ 个人要从 $l_i$ 位置出发到 $r_i$ 位置结束（ $l_i < r_i$ ）；第 $i$ 个人在时间 $b_i$ 进入他的出发位置（ $l_i$ ）。一方面，每个人都希望尽快到达目的地，另一方面，他不想换乘公交车。

也就是：为第 $i$ 个人挑选的公交汽车 $j$ ，满足 $s_j≤l_i$, $r_i≤f_j$ 和 $b_i≤t_j$ 的条件下，$t_j$ 最小。

你的任务是确定每个人今天是否可以到达目的地，如果可以，找到每个人将乘坐的公交车的号码，不可以则输出 $-1$ 。

<!-- more -->

## 题解

我只想到了一个sb的线段树套set的 $O(n \log^2 n)$ 的做法，但 tutorial 给出了一个 $O((n+m) \log (n+m))$ 的优秀做法。

我们在这里从 $t$ 从小往大处理，按时间顺序加入每个人；加入车的时候只需要判断哪些人可以被这个车带走，然后这个车就是这些人的答案。

我们考虑使用一个线段树维护这个所有人。我们根据 $l[i]$ 从小到大建立这个树，每个位置放置一个人，维护区间的 $r[i]$ 最小值及出现位置。

当我们加入一个 $s_i,f_i$ 的车的时候，我们只需要在所有 $l[i]$ 大于 $s[i]$ 的部分中，找到一个 $r[i]$ 最小的人，把它删掉，然后持续到找不到这个人即可。最后还在树里面的都是无法乘车的人。

这个方法很好啊，比我树套树不知道高到哪里去了...

## 代码

{% fold %}
```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;
typedef pair<int,int> pii;

const int MAXN = 210000;

struct B{
  int l,r,t,id;
  bool operator < (const B &x)const{return t < x.t;}
}bus[MAXN],p[MAXN];
bool cmp(B &x,B &y){return x.l < y.l;}
struct Node{
  int minn,pos,id;
  bool operator < (const Node &x)const{return minn < x.minn;}
};

int n,m;
pii LL[MAXN];

namespace SegTree{
  Node t[MAXN<<2];
  #define lson (nown<<1)
  #define rson (nown<<1|1)
  #define mid ((l+r)/2)
  void build(int nown,int l,int r,int *id){
    if(l == r){
      t[nown] = (Node){inf,l,id[l]};
    }
    else{
      build(lson,l,mid,id),build(rson,mid+1,r,id);
      t[nown] = min(t[lson],t[rson]);
    }
  }
  void update(int nown,int l,int r,int pos,int v){//change v
    if(l == r)
      t[nown].minn = v;
    else{
      if(pos <= mid) update(lson,l,mid,pos,v);
      if(pos >= mid+1) update(rson,mid+1,r,pos,v);
      t[nown] = min(t[lson],t[rson]);
    }
  }
  Node query(int nown,int l,int r,int ql,int qr){
    if(ql <= l && r <= qr)
      return t[nown];
    else{
      Node ans = (Node){inf,0,0};
      if(ql <= mid) ans = min(ans,query(lson,l,mid,ql,qr));
      if(qr >= mid+1) ans = min(ans,query(rson,mid+1,r,ql,qr));
      return ans;
    }
  }
  #undef lson
  #undef rson
  #undef mid
}

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    scanf("%d %d %d",&bus[i].l,&bus[i].r,&bus[i].t);
    bus[i].id = i;
  }
  for(int i = 1;i<=m;i++){
    scanf("%d %d %d",&p[i].l,&p[i].r,&p[i].t);
    LL[i] = make_pair(p[i].l,i);
    p[i].id = i;
  }
  sort(LL+1,LL+m+1);
  sort(p+1,p+m+1),sort(bus+1,bus+n+1);
}

int xx[MAXN];
int tmp[MAXN],pos[MAXN],ans[MAXN];

void build(){
  for(int i = 1;i<=m;i++) 
    tmp[i] = LL[i].second,xx[i] = LL[i].first,pos[LL[i].second] = i;
  SegTree::build(1,1,m,tmp);
}

void add_person(int now){
  SegTree::update(1,1,m,pos[p[now].id],p[now].r);
}
void add_bus(int now){
  int L = lower_bound(xx+1,xx+m+1,bus[now].l) - xx;
  if(L == m+1) return;
  while(true){
    Node t = SegTree::query(1,1,m,L,m);
    if(t.minn > bus[now].r) break;
    else{
      ans[t.id] = bus[now].id;
      SegTree::update(1,1,m,t.pos,inf);
    }
  }
}

void solve(){
  int nx = 1,ny = 1;
  while(true){
    if(nx == (n+1)) break;
    if((nx != n+1 && ny == m+1) || bus[nx].t < p[ny].t )
      add_bus(nx++);// 新加入人？新加入车？
    else
      add_person(ny++);
  }
  for(int i = 1;i<=m;i++) printf("%d ",ans[i] == 0?-1:ans[i]);
  printf("\n");
}

int main(){
  init();
  build();
  solve();
  return 0;
}

```
{% endfold %}