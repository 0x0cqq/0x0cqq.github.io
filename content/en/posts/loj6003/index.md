---
title: 「网络流 24 题」魔术球-二分图最大匹配
urlname: loj6003
date: 2019-03-20 20:45:09
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

假设有 $n$ 根柱子，现要按下述规则在这 $n$ 根柱子中依次放入编号为 $1, 2, 3, 4, \cdots$ 的球。

1. 每次只能在某根柱子的最上面放球。
2. 在同一根柱子中，任何 $2$ 个相邻球的编号之和为完全平方数。

试设计一个算法，计算出在 $n$ 根柱子上最多能放多少个球。

<!--more-->

## 链接

[LOJ6003](https://loj.ac/problem/6003)

## 题解

其实这个本质上类似一个链覆盖的问题。

我们每次考虑加入一个球，然后在二分图上连上可行的边（ $i+j$ 是平方数而且 $i < j$），每次直接接着跑 dinic ，直到不满足即可。

输出方案就是枚举边，找链起点。同上一道题。

其实应该二分，复杂度更好保证，不过这个比较好写（

- - -

这题也可以贪心，懒得写了，题解粘贴过来：

> 贪心就是从小到大枚举编号，之后在已经有球的柱子里随便找一个能放的放。如果找不到，就新开一个柱子。
> 但它是正确的吗？为什么？

> 可以证明。用数学归纳法证明贪心法每次的选择是唯一的(即，只能把球放到0或1个已经放了球的柱子上)，且答案为(一个简单式子，暂不剧透)。用dilworth定理可以证明这个是最优的(hint:柱子的顶端构成一个反链)。
>  
> 这个算法work是因为“加起来是平方数”的性质很好。改成其他条件就做不了了。


链接 ： [UOJ BLOG](http://kczno1.blog.uoj.ac/blog/2724)

## 代码

```cpp
#include <bits/stdc++.h>
#include <unistd.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 3200,MAXM = MAXN*100,N = MAXN/2;

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
  dis[s] = 1;q.push(s);
  while(!q.empty()){
    int x = q.front();q.pop();
    for(int e = fir[x];e;e = edge[e].nex){
      int v = edge[e].to;
      if(!dis[v] && edge[e].cap > edge[e].flow){
        dis[v] = dis[x] + 1;q.push(v);
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
        sumf += f,limit -= f;
        edge[e].flow += f,edge[e^1].flow -= f;
      }
      if(limit == 0) break;
    }
  }
  return sumf;
}

int dinic(int s,int t){
  static int ans = 0;
  while(bfs(s,t)) ans += dfs(s,t);
  return ans;
}

int n,is_squ[MAXN];

void init(){
  scanf("%d",&n);for(int i = 1;i*i < MAXN;i++) is_squ[i*i] = 1;
}

int solve(){
  int S = MAXN-1,T = MAXN-2;
  for(int i = 1;i<=MAXN;i++){
    addedge(S,i,1),addedge(i+N,T,1);
    for(int j = 1;j<i;j++){
      if(is_squ[i+j]) addedge(j,i+N,1);
    }
    int ans = i - dinic(S,T);
    if(ans > n) return i-1;
  }
}

void output(int x){
  int S = MAXN-1,T = MAXN-2;
  memset(fir,0,sizeof(fir)),ecnt = 2;
  for(int i = 1;i<=x;i++){
    addedge(S,i,1),addedge(i+N,T,1);
    for(int j = i+1;j<=x;j++){
      if(is_squ[i+j]) addedge(i,j+N,1);
    }
  }
  dinic(S,T);
  static int pre[MAXN],nxt[MAXN];
  for(int e = 2;e<=ecnt;e+=2){
    int a = edge[e].from,b = edge[e].to,f = edge[e].flow;
    if(f == 1 && 1 <= a && a <= x && N+1 <= b && b <= MAXN+x){
      pre[b-N] = a,nxt[a] = b-N;
    }
  }
  printf("%d\n",x);
  for(int i = 1;i<=x;i++){
    if(pre[i] == 0){
      for(int t = i;t;t = nxt[t]) printf("%d ",t);
      printf("\n");
    }
  }
}

int main(){
  init(),output(solve());
  return 0;
}
```