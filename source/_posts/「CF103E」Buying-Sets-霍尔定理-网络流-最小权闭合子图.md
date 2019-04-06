---
title: 「CF103E」Buying Sets-霍尔定理-网络流-最小权闭合子图
urlname: CF103E
date: 2019-02-02 21:59:59
tags:
- 网络流
- 图论
categories: 
- OI
- 题解
visible:
---

我们有 $n$ 个集合，第 $i$ 个集合有 $m_i$ 个数（$1$ 到 $n$ 中的整数），权值为 $w_i$ 。

现在请你从中选出 $k$ （$k$ 为任意 $0$ 到 $n$ 中的整数）个集合，满足这 $k$ 个集合的并集的大小为 $k$ ，询问这 $k$ 个集合的权值和最小值。

保证从这 $n$ 选出任意 $x$ 个集合，他们的并集大小不小于 $k$ 。

<!-- more -->  

## 链接

[Codeforces](https://codeforces.com/problemset/problem/103/E)

## 题解

熟悉二分图那套理论的同学很快就会发现，题目中给出的条件：任意 $k(1 \le k \le n)$ 个集合的并集的大小都不小于 $k$ ，可以转化成霍尔定理的一方面的表述。

我们建立一个二分图 $G_1$ ，左边放上所有的集合，右边放上所有的数，把左侧每个集合向其拥有的数连一条边，那么这个时候，根据霍尔定理，这个二分图存在一个左侧所有节点都在匹配中的匹配（这个图中右侧也只有 $n$ 个节点，所以事实上是一个完美匹配）。

所以每一个集合 $i$ 都可以对应到一个数 $c_i$ ， 且任意两个数的 $c_i$ 都不相同。

这个时候我们发现，任意选 $k$ 个集合，我们都可以得到这 $k$ 个集合并集的一个子集，就是由这 $k$ 个集合的 $c_i$ 构成的集合。这个时候我们已经不能有任何其他的数加入，如果我们选择了第 $i$ 个集合，那么我们对于第 $i$ 个集合，对于除了 $c_i$ 的元素 $t$ ，我们都必须选择 $c_j = t$ 的 $j$ 集合，才能保证不多出来元素。

这个时候，我们就有了一个新模型， 仔细观察的话，就会发现其实是一个最小权闭合子图的模型，可以用最小割模型来解决，网上也有许多资料，在这里就不重复了。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 610,inf = 0x3f3f3f3f;

int n,w[MAXN];
vector<int> G[MAXN];

struct Edge{
  int from,to;
  int cap,flow;
  int nex;
}edge[MAXN*MAXN*2];
int fir[MAXN],ecnt = 2;
int addedge(int a,int b,int c){
  edge[ecnt] = (Edge){a,b,c,0,fir[a]};
  fir[a] = ecnt++;
  edge[ecnt] = (Edge){b,a,0,0,fir[b]};
  fir[b] = ecnt++;
  return ecnt - 2;
}

int dis[MAXN];
queue<int> q;

bool bfs(int s,int t){
  memset(dis,0,sizeof(dis));
  while(!q.empty()) q.pop();
  dis[s] = 1;q.push(s);
  while(!q.empty()){
    int nown = q.front();q.pop();
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
      int v = edge[nowe].to;
      if(dis[v] == 0 && edge[nowe].cap > edge[nowe].flow){
        dis[v] = dis[nown] + 1;
        q.push(v);
      }
    }
  }
  return dis[t] != 0;
}

int dfs(int nown,int t,int limit = inf){
  if(nown == t || limit == 0) return limit;
  int sumf = 0;
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;
    if(dis[v] == dis[nown] + 1 && edge[nowe].cap > edge[nowe].flow){
      int f = dfs(v,t,min(limit,edge[nowe].cap - edge[nowe].flow));
      if(f){
        edge[nowe].flow += f,edge[nowe^1].flow -= f;
        sumf += f,limit -= f;
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

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n;i++){
    int m;
    scanf("%d",&m);
    while(m--){
      int x;scanf("%d",&x);
      G[i].push_back(x);
    }
  }
  for(int i = 1;i<=n;i++) scanf("%d",&w[i]);
}

vector<int> E[MAXN];int c[MAXN],back[MAXN];

void get_matching(){
  int S = 0,T = 2*n+1;
  for(int i = 1;i<=n;i++){
    addedge(S,i,1),addedge(i+n,T,1);
    for(auto j : G[i])
      E[i].push_back(addedge(i,j+n,1));
  }
  dinic(S,T);
  for(int i = 1;i<=n;i++){
    for(unsigned x = 0;x < G[i].size();x++){
      if(edge[E[i][x]].flow == 1){
        c[i] = G[i][x];
        back[G[i][x]] = i;
        break;
      }
    }
  }
}

void solve(){
  get_matching();
  ecnt = 2;memset(fir,0,sizeof(fir));
  int S = n+1,T = S+1;
  int ans = 0;
  for(int i = 1;i<=n;i++){
    w[i] = -w[i];
    if(w[i] > 0) addedge(S,i, w[i]),ans += w[i];
    else         addedge(i,T,-w[i]);
  }
  for(int i = 1;i<=n;i++){
    for(auto j : G[i])if(j != c[i])
      addedge(i,back[j],inf);
  }
  ans -= dinic(S,T);
  printf("%d\n",-ans);
}

int main(){
  init();
  solve();
  return 0;
}
```

