---
title: 「NOI2005」聪聪与可可-期望dp
urlname: NOI2005-clever-and-cute
date: 2018-10-02 09:37:40
tags:
- 题解
- 动态规划
- 期望dp
categories: OI
visible:
---

给定一个 $n$ 个点， $m$ 条边的无向图。聪聪开始的时候在 `S`，可可在节点 `T` 处。以后的每个时间单位，可可都会选择去相邻的景点(可能有多个)中的一个或停留在原景点不动。而去这些地方所发生的概率是相等的。假设有 $P$ 个景点与景点 `M` 相邻，它们分别是景点 `R`、 景点 `S`，……，景点 `Q`，在时刻 $i$ 可可处在景点 `M`，则在 $i+1$ 时刻，可可有 $\frac{1}{1+P}$ 的可能在景点 `R`，有 $\frac{1}{1+P}$ 的可能在景点 `S`，……，有 $\frac{1}{1+P}$ 的可能在景点 `Q`，还有 $\frac{1}{1+P}$ 的可能停在景点 `M`。

当聪聪在景点 `C` 时，她会选一个更靠近可可的景点，如果这样的景点有多个，她会选一个标号最小的景点。如果走完第一次移动以后仍然没吃到可可，她还可以在本段时间内再向可可进行一次移动。

在每个时间单位，假设聪聪先走，可可后走。在某一时刻，若聪聪和可可位于同一个景点，则可怜的可可就被吃掉了。

请求出平均情况下，聪聪用几个时间单位就可能吃到可可。

<!-- more -->

## 链接

[Luogu P4206](https://www.luogu.org/problemnew/show/P4206)

## 题解

有趣的期望dp。

我们注意到，如果我们知道可可和聪聪的位置，那么聪聪的两次移动我们都是唯一的。

所以我们用 $n$ 次 $\text{bfs}$ 处理出所有点对间的最短路，然后针对 $n$ 个可可可能在的点，对每个节点进行一次遍历（边），找到最近的出度。以上两个过程都是 $O(n^2)$ 的。

现在我们就可以进行转移了。

设 $dp[u][v]$ 为聪聪在 $u$ ，可可在 $v$ 时的期望步数，然后转移即可。注意到我们需要遍历 $v$ 这个点对应的所有的边，但是无向图的话，所有的边会被遍历两遍，所以对于每个 $v$ ，转移是 $O(n)$ 的，然后转移的复杂度也是 $O(n^2)$ 。


## 代码


```cpp
#include <cstdio>
#include <vector>
#include <queue>
#include <unistd.h>
using namespace std;

const int MAXN = 1100;

int n,m,s,t;

vector<int> edge[MAXN];
int dis[MAXN][MAXN],near[MAXN][MAXN];
double dp[MAXN][MAXN];
queue<int> q;

void init(){
  scanf("%d %d %d %d",&n,&m,&s,&t);
  for(int i = 1;i<=m;i++){
    int u,v;
    scanf("%d %d",&u,&v);
    edge[u].push_back(v);
    edge[v].push_back(u);
  }
}

void bfs(int st){
  while(!q.empty()) q.pop();
  q.push(st);dis[st][st] = 0;

  while(!q.empty()){
    int nown = q.front();q.pop();
    // printf("%d\n",nown);
    for(unsigned i = 0;i<edge[nown].size();i++){
      int v = edge[nown][i];
      // printf("  v:%d\n",v);
      if(dis[st][v] == 0 && v != st){
        dis[st][v] = dis[st][nown] + 1;
        q.push(v);
      }
    }
  }
}

void get_near(int to){
  for(int nown = 1;nown<=n;nown++){
    if(nown == to) continue;//cautious
    near[nown][to] = 0x3f3f3f3f;
    for(unsigned i = 0;i<edge[nown].size();i++){
      int v = edge[nown][i];
      if(dis[v][to] < dis[nown][to] && near[nown][to] > v){
        near[nown][to] = v;
      }
    }
  }
}

double dfs(int u,int v){
  int uu = u,vv = v;
  if(dp[uu][vv] != 0) return dp[u][v];
  if(u == v) return 0;
  if(near[u][v] == v || near[near[u][v]][v] == v){
    return dp[u][v] = 1;
  }
  u = near[near[u][v]][v];
  double ans = 0;
  for(unsigned i = 0;i<edge[v].size();i++){
    int to = edge[v][i];
    ans += (dfs(u,to)+1);
  }
  ans += dfs(u,v)+1;
  return dp[uu][vv] = ans/(edge[v].size()+1);
}

void solve(){
  for(int i = 1;i<=n;i++) bfs(i);
  for(int i = 1;i<=n;i++) get_near(i);
  double ans = dfs(s,t);
  printf("%.3lf\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```

