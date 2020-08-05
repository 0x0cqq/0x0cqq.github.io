---
title: 「网络流 24 题」方格取数-二分图最大独立集
urlname: loj6007
date: 2019-03-24 22:48:57
tags:
- 图论
- 网络流
- 二分图
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

在一个有 $m \times n$ 个方格的棋盘中，每个方格中有一个正整数。

现要从方格中取数，使任意 $2$ 个数所在方格没有公共边，且取出的数的总和最大。试设计一个满足要求的取数算法。

<!--more-->

## 链接

[LOJ 6007](https://loj.ac/problem/6007)

## 题解

可以发现，这是一个二分图的带权最大独立集的问题。

对于这个问题，我们可以这么解决：

我们对于二分图的 $S$ 集和 $T$ 集，原点向 $S$ 集合上连边， $T$ 集合的所有点向汇点连边，边流量为点权；所有有约束的边直接连边，权值 $\inf$ ；答案就是边权和减去最大流的流量。

怎么证明？可以感性证明。

求出来的最小割一定是一个合法方案。我们割掉了哪条边，意味着我们付出了一个代价，也就是我们不选了这个物品。如果我们同时选了在二分图两侧有连边的节点（没有割边），那么我们这个图就不可能被割开（中间是无穷大），这个图就不是一个合法的最小割了。反向应当也是可以证明的。

所以这个算法的正确性是可以保障的。

## 代码

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 10000,MAXM = 50000;

struct Edge{
  int from,to;
  int cap,flow;
  int nex;
}edge[MAXM];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b,int c){
  edge[ecnt] = (Edge){a,b,c,0,fir[a]},fir[a] = ecnt++;
  edge[ecnt] = (Edge){b,a,0,0,fir[b]},fir[b] = ecnt++;
}

int dis[MAXN];
bool bfs(int s,int t){
  static queue<int> q;
  memset(dis,0,sizeof(dis));while(!q.empty()) q.pop();
  dis[s] = 1;q.push(s);
  while(!q.empty()){
    int x = q.front();q.pop();
    for(int e = fir[x];e;e = edge[e].nex){
      int v = edge[e].to;
      if(!dis[v] && edge[e].cap > edge[e].flow){
        dis[v] = dis[x] + 1,q.push(v);
      }
    }
  }
  return dis[t];
}

int dfs(int x,int t,int limit = inf){
  if(limit == 0 || x == t) return limit;
  int sumf = 0;
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to;
    if(dis[v] == dis[x] + 1){
      int f = dfs(v,t,min(limit,edge[e].cap - edge[e].flow));
      if(f){
        sumf += f,limit -= f,edge[e].flow += f,edge[e^1].flow -= f;
        if(limit == 0) break;
      }
    }
  }
  return sumf;
}

int dinic(int s,int t){
  int ans = 0;
  while(bfs(s,t)) ans += dfs(s,t);
  return ans;
}

int m,n,val[110][110],sum;

int _hash(int x,int y){return (x-1)*n+y;}
bool judge(int x,int y){return (x+y)&1;}


int main(){
  scanf("%d %d",&m,&n);
  for(int i = 1;i<=m;i++) for(int j = 1;j<=n;j++)
    scanf("%d",&val[i][j]),sum += val[i][j];
  int S = n*m+1,T = S + 1;
  for(int i = 1;i<=m;i++){
    for(int j = 1;j<=n;j++){
      if(judge(i,j)) addedge(S,_hash(i,j),val[i][j]);
      else           addedge(_hash(i,j),T,val[i][j]);
      if(!judge(i,j)){
        if(i > 1) addedge(_hash(i-1,j),_hash(i,j),inf);
        if(i < m) addedge(_hash(i+1,j),_hash(i,j),inf);
        if(j > 1) addedge(_hash(i,j-1),_hash(i,j),inf);
        if(j < n) addedge(_hash(i,j+1),_hash(i,j),inf);
      }
    }
  }
  printf("%d\n",sum-dinic(S,T));
  return 0;
}
```