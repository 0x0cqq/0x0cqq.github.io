---
title: 「网络流 24 题」搭配飞行员-二分图最大匹配
urlname: loj6000
date: 2019-03-19 19:43:03
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

飞行大队有若干个来自各地的驾驶员，专门驾驶一种型号的飞机，这种飞机每架有两个驾驶员，需一个正驾驶员和一个副驾驶员。由于种种原因，例如相互配合的问题，有些驾驶员不能在同一架飞机上飞行，问如何搭配驾驶员才能使出航的飞机最多。

因为驾驶工作分工严格，两个正驾驶员或两个副驾驶员都不能同机飞行。

<!--more-->

## 链接

[LOJ6000](https://loj.ac/problem/6000)

## 题解

注意到这就是一个二分图匹配问题。

我们把左侧放置正飞行员（ $1$ - $m$ ），右侧放置副飞行员（ $m+1$ - $n$ ），然后在可以配对的正副飞行员之间连边，二分图最大匹配即为答案。

可以用网络最大流解决这个问题。

## 代码

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 110,MAXM = 110*110;

struct Edge{
  int from,to;
  int cap,flow;
  int nex;
}edge[MAXM];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b,int c){
  edge[ecnt] = (Edge){a,b,c,0,fir[a]};fir[a] = ecnt++;
  edge[ecnt] = (Edge){b,a,0,0,fir[b]};fir[b] = ecnt++;
}

int n,m,dis[MAXN];

bool bfs(int s,int t){
  static queue<int> q;
  memset(dis,0,sizeof(dis));while(!q.empty()) q.pop();
  dis[s] = 1;q.push(s);
  while(!q.empty()){
    int x = q.front();q.pop();
    for(int e = fir[x];e;e = edge[e].nex){
      int v = edge[e].to;
      if(!dis[v] && edge[e].cap > edge[e].flow){
        dis[v] = dis[x]+1;q.push(v);
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
    if(dis[v] == dis[x] + 1 && edge[e].cap > edge[e].flow){
      int f = dfs(v,t,min(edge[e].cap - edge[e].flow,limit));
      if(f){
        sumf += f,limit -= f;
        edge[e].flow += f,edge[e^1].flow -= f;
      }
      if(limit == 0) break;
    }
  }
  return sumf;
}

int dinic(int s,int t){
  int ans = 0;
  while(bfs(s,t)) ans += dfs(s,t);
  return ans;
}

int w[MAXN][MAXN];

void init(){
  scanf("%d %d",&n,&m);int a,b;
  while(scanf("%d %d",&a,&b) == 2) w[a][b] = 1;
}

void solve(){
  // 建图：每个飞行员一个点，正 1-> m ，副 m+1 -> n
  int S = n+1,T = n+2;
  for(int i = 1;i<=m;i++) addedge(S,i,1);
  for(int i = 1;i<=m;i++) 
    for(int j = m+1;j<=n;j++) if(w[i][j] == 1) 
      addedge(i,j,1);
  for(int j = m+1;j<=n;j++) addedge(j,T,1);
  printf("%d\n",dinic(S,T));
}

int main(){
  init();
  solve();
  return 0;
}
```