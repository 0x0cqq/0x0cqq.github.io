---
title: 「网络流 24 题」餐巾计划-费用流
urlname: loj6008
date: 2019-03-30 07:42:29
tags:
- 图论
- 网络流
- 费用流
categories:
- OI
- 题解
series:
- 网络流 24 题
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

一个餐厅在相继的 $n$ 天里，每天需用的餐巾数不尽相同。假设第 $i$ 天需要 $r_i$ 块餐巾。餐厅可以购买新的餐巾，每块餐巾的费用为 $P$ 分；或者把旧餐巾送到快洗部，洗一块需 $M$ 天，其费用为 $F$ 分；或者送到慢洗部，洗一块需 $n$ 天，其费用为 $S$ 分（$S < F$）。

每天结束时，餐厅必须决定将多少块脏的餐巾送到快洗部，多少块餐巾送到慢洗部，以及多少块保存起来延期送洗。但是每天洗好的餐巾和购买的新餐巾数之和，要满足当天的需求量。

试设计一个算法为餐厅合理地安排好 $n$ 天中餐巾使用计划,使总的花费最小。

<!--more-->

## 链接

[LOJ6008](https://loj.ac/problem/6008)

## 题解

这道题可以用费用流来解决。（下面用一个有序列数对 $(cap,cost)$ 描述一条边的流量和价格）

我们把每个点拆成两个点，$in(i)$ 和 $out(i)$，分别处理干净毛巾和脏的毛巾。

我们从原点向每一个 $in$ 点连接一条 $(inf,P)$ 的边，表示购买的干净毛巾。

从 $S$ 向每一个 $out(i)$ 连接一条 $(r_i,0)$ 的边，表示每天我可以收获这么多条脏毛巾；从每一个 $in(i)$ 向 $T$ 连接一条 $(r_i,0)$ 的边，表示我每天得用掉这么多条干净毛巾。上面的连边保证我们满足条件时的流是最大流。

从 $out(i)$ 向 $out(i+1)$ 连边 $(inf,0)$ ，表示可以把脏毛巾留着不洗；然后就是快洗店/慢洗店，从 $out(i)$ 向 $in(i+M)/in(i+N)$ 连一条 $(inf,F/S)$ 的边。

费用流的最小费用即为答案。

## 代码

```cpp
#include <bits/stdc++.h>
// #define int long long
#define inf 0x3f3f3f3fLL
using namespace std;

const int MAXN = 2100,MAXM = MAXN*8*2;

namespace MCMF{
  int S,T;
  struct Edge{
    int from,to;
    int cap,flow;
    int cost,nex;
  }edge[MAXM*2];
  int fir[MAXN],ecnt = 2; 
  void addedge(int a,int b,int c,int d){
    edge[ecnt] = (Edge){a,b,c,0, d,fir[a]},fir[a] = ecnt++;
    edge[ecnt] = (Edge){b,a,0,0,-d,fir[b]},fir[b] = ecnt++;
  }
  int dis[MAXN],inq[MAXN];
  bool spfa(){
    memset(dis,0x3f,sizeof(dis));
    static queue<int> q;
    dis[S] = 0;q.push(S);
    while(!q.empty()){
      int x = q.front();q.pop();inq[x] = 0;
      for(int e = fir[x];e;e = edge[e].nex){
        int v = edge[e].to;
        if(edge[e].cap > edge[e].flow && dis[v] > dis[x] + edge[e].cost){
          dis[v] = dis[x] + edge[e].cost;
          if(!inq[v]) q.push(v),inq[v] = 1;
        }
      }
    }
    return dis[T] < dis[0];
  }
  int dfs(int x,int limit = inf){
    if(x == T || limit == 0) return limit;
    int sumf = 0;inq[x] = 1;
    for(int e = fir[x];e;e = edge[e].nex){
      int v = edge[e].to;
      if(!inq[v] && dis[v] == dis[x] + edge[e].cost){
        int f = dfs(v,min(limit,edge[e].cap - edge[e].flow));
        sumf += f,limit -= f;
        edge[e].flow += f, edge[e^1].flow -= f;
        if(limit == 0) break;
      }
    }
    return sumf;
  }
  pair<int,int> solve(int s,int t){
    S = s,T = t;
    int ansf = 0,ansc = 0;
    while(spfa()){
      int f = dfs(s);
      memset(inq,0,sizeof(inq));
      ansf += f,ansc += f * dis[t];
    }
    return make_pair(ansf,ansc);
  }
}

int n,P,fd,fp,sd,sp;
int v[MAXN];

signed main(){
  scanf("%d %d %d %d %d %d",&n,&P,&fd,&fp,&sd,&sp);
  for(int i = 1;i<=n;i++) scanf("%d",&v[i]);
  int S = 2*n+1,T = 2*n+2;// 1-> n,n+1->n+n
  for(int i = 1;i<=n;i++){
    MCMF::addedge(S,i,inf/2,P);
    MCMF::addedge(S,i+n,v[i],0);
    MCMF::addedge(i,T,v[i],0);
    MCMF::addedge(i+n,i+n+1,inf/2,0);
    if(i+fd <= n) MCMF::addedge(i+n,i+fd,inf/2,fp);
    if(i+sd <= n) MCMF::addedge(i+n,i+sd,inf/2,sp);
  }
  pair<int,int> ans = MCMF::solve(S,T);
  printf("%d\n",ans.second);
  return 0;
}
```