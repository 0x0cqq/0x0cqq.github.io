---
title: 「CF91E」Igloo Skyscraper-分块
urlname: CF91E
date: 2018-12-23 22:25:44
tags:
- 数据结构
- 分块
categories: 
- OI
- 题解
visible:
---

有 $n$ 个海象（编号为 $1$ 到 $n$ ）参加比赛建造自己的摩天大楼 。在 $t=0$ 时，第 $i$ 个海象的摩天大楼的高度为 $a_i$ 。每一时刻，编号为 $i$ 的海象会完成 $b_i$ 层楼的建造。

在奥运会现场报道的记者向活动组织者提出了 $q$ 次询问。每次询问给出三个数字 $l_i$ ，$r_i$ ，$t_i$。活动组织者用数字 $x$ 回答每个查询，$x$ 满足：

1. 数字 $x$ 位于从 $l_i$ 到 $r_i$ 的区间，即 $l_i \leq x \leq r_i$ 。

2. 编号为 $x$ 的海象的摩天大楼在 $t_i$ 时刻拥有编号在 $[l_i,r_i]$ 中所有海象的摩天大楼中的最大高度。

对于每位记者的查询，输出符合上述标准的海象的编号 $x$ 。**如果有多个可能的答案，请输出其中任何一个。**

<!-- more -->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/91/E)

## 题解

可以采用分块+离线的方法过掉这道题。

每个海象的楼的高度都可以视作一条直线 $y = bx + a$ ，那么我们的问题就变成了找这段区间内的直线在 $x = t$ 处的最大值。

我们注意到，如果我们将所有直线排在一起，那么我们在每一时刻最大值一定来自于一堆斜率递增的直线（就是一个下凸包）。

我们要在块内处理出按照时间顺序可能取到的直线。我们先在块内按斜率 $b$ 从小到大排序，然后去掉 $b$ 相同的直线后。我们可以再用 $O(\sqrt{n} \times \sqrt{n})$ 的时间枚举该条直线下一条应该是哪条后面的直线（判断谁的交点最靠左），然后我们就可以得到这 $O(\sqrt{n})$ 条直线的下凸包。

得到这个凸包之后，我们可以计算答案。

我们把询问对时间排序，整块判断能不能更新该点的凸包是不是需要下一条直线，零散直接暴力即可。

时间复杂度： $O((m+n) \sqrt{n})$。

## 代码


```cpp
#include <bits/stdc++.h>
#define inf 1e18
#define pii pair<int,int>
using namespace std;

const int MAXN = 110000;
const int MAXQ = 500;

struct Query{
  int l,r,t,id;
  bool operator < (const Query &a)const{
    return t < a.t;
  }
}q[MAXN];

int n,m,Q;
int lb[MAXN],rb[MAXN],bl[MAXN];

struct P{
  int a,b,id;
  bool operator < (const P &x) const{
    if(b != x.b) return b < x.b;
    if(a != x.a) return a > x.a;
    return 0;
  }
}p[MAXN];


double calv(P x,int t){
  return double(x.a) + double(x.b)*t;
}

bool cmp(P x,P y,int t){// 前面优，返回1，后面优秀，返回 0
  if(calv(x,t) != calv(y,t))
    return calv(x,t) > calv(y,t);
  else
    return x.b > y.b;
}

double calj(P x,P y){
  if(x.b == y.b) return inf;
  return double(x.a-y.a)/(y.b-x.b);
}

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    scanf("%d %d",&p[i].a,&p[i].b);
    p[i].id = i;
  }
  for(int i = 1;i<=m;i++){
    scanf("%d %d %d",&q[i].l,&q[i].r,&q[i].t);
    q[i].id = i;
  }
  sort(q+1,q+m+1);
}

vector<P> V[MAXQ];
vector<P> tmp;

void build(){
  Q = sqrt(n);
  for(int i = 1;i<=n;i++){
    bl[i] = (i-1)/Q + 1;
    if(bl[i] != bl[i-1]) lb[bl[i]] = i,rb[bl[i-1]] = i-1;
  }
  rb[bl[n]] = n;
  
  for(int x = 1;x<=bl[n];x++){
    int L = lb[x],R = rb[x];
    for(int i = L;i<=R;i++) V[x].push_back(p[i]);
    sort(V[x].begin(),V[x].end());
    tmp.clear();
    tmp.push_back(V[x][0]);
    for(int i = 1;i < int(V[x].size());i++){
      if(V[x][i].b != V[x][i-1].b) tmp.push_back(V[x][i]);
    }
    V[x].clear();
    V[x].push_back(tmp[0]);
    for(int i = 0;i < int(tmp.size())-1;){
      int t = i;
      for(int j = i+1;j<int(tmp.size());j++)
        if(calj(tmp[i],tmp[j]) < calj(tmp[i],tmp[t]))
          t = j;
      V[x].push_back(tmp[i = t]);
    }
    V[x].push_back(tmp.back());
  }
}

int now[MAXQ];
int ans[MAXN];


void solve(){
  for(int i = 1;i<=m;i++){
    int L = q[i].l,R = q[i].r,t = q[i].t;
    int BL = bl[L],BR = bl[R],tmp = 0;
    if(BL == BR){
      for(int i = L;i<=R;i++) if(cmp(p[i],p[tmp],t)) tmp = i;  
      ans[q[i].id] = tmp;
      continue;
    }
    for(int i = BL+1;i<=BR-1;i++){
      while(now[i]+1 < int(V[i].size()) && calv(V[i][now[i]],t) <= calv(V[i][now[i]+1],t))
        now[i]++;
      if(cmp(V[i][now[i]],p[tmp],t)) tmp = V[i][now[i]].id;
    }
    for(int i = L;i<=rb[BL];i++) if(cmp(p[i],p[tmp],t)) tmp = i;  
    for(int i = lb[BR];i<=R;i++) if(cmp(p[i],p[tmp],t)) tmp = i;   
    ans[q[i].id] = tmp;
  }
  for(int i = 1;i<=m;i++){
    printf("%d\n",ans[i]);
  }
}

int main(){
  init();
  build();
  solve();
  return 0;
}
```

