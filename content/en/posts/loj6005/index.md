---
title: 「网络流 24 题」最长递增子序列-dp+网络最大流
urlname: loj6005
date: 2019-03-21 22:57:57
tags:
- 图论
- 网络流
- 动态规划
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

给定正整数序列 $x_1 \sim x_n$ ，以下递增子序列均为非严格递增。

1. 计算其最长递增子序列的长度 $s$ 。
   
2. 计算从给定的序列中最多可取出多少个长度为 $s$ 的递增子序列。

3. 如果允许在取出的序列中多次使用 $x_1$ 和 $x_n$ ，则从给定序列中最多可取出多少个长度为 $s$ 的递增子序列。

<!--more-->

## 链接

[LOJ6005](https://loj.ac/problem/6005)

## 题解

这个问题需要用dp和网络流搭配解决。

第一问：直接 $O(n^2)$ dp 即可。
 - - -
第二问：在第一问的基础上，我们考虑网络流。

我们把每个点拆成两个点： $(i,0)$ 和 $(i,1)$ 
+ $S$ 向所有 $dp[i] = 1$ 的 $(i,0)$ 连边
+ 所有 $dp[i] = s$ 的点向 T 连边
+ 对于每个 $j$，向所有满足： $j < i \le n,x[j] \le x[i],dp[j] + 1 = dp[i]$ ，连一条 $(i,1)$ 向 $(j,0)$ 的边
+ 最后每个 $(i,0)$ 向 $(i,1)$ 连边。

然后 dinic 大概就可以了。

- - - 
  
第三问：把四个边增加到正无穷：$(1,0) \rightarrow (1,1)$ , $(n,0) \rightarrow (n,1)$ , $S \rightarrow (1,0)$ , $(n,1) \rightarrow T$（如果有） 。

## 代码

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 1100,MAXM = MAXN*MAXN;

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

int dis[MAXN];
bool bfs(int s,int t){
  static queue<int> q;
  memset(dis,0,sizeof(dis));while(!q.empty()) q.pop();
  dis[s] = 1,q.push(s);
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
int dfs(int x,int t,int limit =inf){
  if(limit == 0 || x == t) return limit;
  int sumf = 0;
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to;
    if(dis[v] == dis[x]+1){
      int f = dfs(v,t,min(limit,edge[e].cap - edge[e].flow));
      if(f){
        sumf += f,limit -= f;
        edge[e].flow += f,edge[e^1].flow -= f;
        if(limit == 0) break;
      }
    }
  }
  return sumf;
}

int dinic(int s,int t){
  static int ans = 0;
  while(bfs(s,t)) ans += dfs(s,t);
  return ans;
}

int n;
int x[MAXN],dp[MAXN];

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n;i++) scanf("%d",&x[i]);
}

void solve(){
  int ans = 0,S = n+1,T = 2*n+3;// 0 -> n && n+1 -> 2*n+1
  for(int i = 1;i<=n;i++) addedge(i,i+n+1,1);
  for(int i = 1;i<=n;i++){
    for(int j = 0;j<i;j++)if(x[j] <= x[i]) dp[i] = max(dp[i],dp[j]+1);
    for(int j = 0;j<i;j++)if(x[j] <= x[i] && dp[j] + 1 == dp[i]) addedge(j+n+1,i,1);
    ans = max(ans,dp[i]);
  }
  for(int i = 1;i<=n;i++) if(dp[i] == ans) addedge(i+n+1,T,1);
  printf("%d\n",ans);
  printf("%d\n",dinic(S,T));
  addedge(1,1+n+1,n*n-1),addedge(n,n+n+1,n*n-1);
  addedge(S,1,n*n-1);
  if(dp[n] == ans) addedge(n+n+1,T,n*n-1);
  printf("%d\n",dinic(S,T));
}

int main(){
  init(),solve();
  return 0;
}
```