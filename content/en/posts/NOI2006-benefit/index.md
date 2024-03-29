---
title: 「NOI2006」最大获利-网络流-最大权闭合子图
urlname: NOI2006-benefit
date: 2019-01-26 15:24:46
tags:
- 网络流
- 最大权闭合子图
- 图论
categories: 
- OI
- 题解
series:
- NOI
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---


新的技术正冲击着手机通讯市场，对于各大运营商来说，这既是机遇，更是挑战。THU 集团旗下的 CS&T 通讯公司在新一代通讯技术血战的前夜，需要做太多的准备工作，仅就站址选择一项，就需要完成前期市场研究、站址勘测、最优化等项目。

在前期市场调查和站址勘测之后，公司得到了一共 $N$ 个可以作为通讯信号中转站的地址，而由于这些地址的地理位置差异，在不同的地方建造通讯中转站需要投入的成本也是不一样的，所幸在前期调查之后这些都是已知数据：建立第 $i$ 个通讯中转站需要的成本为 $P_i$ 。

另外公司调查得出了所有期望中的用户群，一共 $M$ 个。关于第 i 个用户群的信息概括为 $A_i$ , $B_i$ 和 $C_i$ ：这些用户会使用中转站 $A_i$ 和中转站 $B_i$ 进行通讯，公司可以获益 $C_i$ 。

THU 集团的 CS&T 公司可以有选择的建立一些中转站（投入成本），为一些用户提供服务并获得收益（获益之和）。那么如何选择最终建立的中转站才能让公司的净获利最大呢？（净获利 = 获益之和 – 投入成本之和）

<!--more-->

## 题解

最大权闭合图问题。

我们转化模型，我们把边和点都看成一个物品，那么我们有一些依赖关系：如果我们指定要选的边的集合，这个时候我们肯定希望选的点的权值和越小越好，然而我们必须要选的最少的点就是所有上文边集里面的每条边的端点的并。

转化成这样的问题之后，我们就是一个最大权闭合图的问题了。所有原图中的点在新图中都是负权值，从该点在新图的点向汇点连一个该点代价为容量的边；所有原图中的边在新图中都是负权值，从源点向该边在新图的点连一个该边收益为容量的边；剩余原图的边向两个端点各连一条 inf 的边即可。

跑出最大流即为答案。

正确性？


\<copy part\>
如果割掉用户的边，那么就舍弃掉一部分收益，可以看做损失。
如果割掉中转站的边，那么就付出一定代价，可以看做损失。
又因为不会割掉INF的边，所以就巧妙的解决了选A必须选B的问题。
\<\copy part\>


## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int inf = 1e9+7;
const int MAXN = 55100,MAXM = 4*MAXN;

struct Edge{
  int to,nex;
  int cap,flow;
}edge[MAXM*2];
int fir[MAXN],cur[MAXN],ecnt = 2;
void addedge(int a,int b,int c){
  edge[ecnt] = (Edge){b,fir[a],c,0};
  fir[a] = ecnt++;
  edge[ecnt] = (Edge){a,fir[b],0,0};
  fir[b] = ecnt++;
}

int S,T;
int dis[MAXN];
queue<int> q;

bool bfs(){
  memset(dis,0,sizeof(dis));
  memcpy(cur,fir,sizeof(cur));
  while(!q.empty()) q.pop();
  dis[S] = 1;
  q.push(S);
  while(!q.empty()){
    int nown = q.front();q.pop();
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
      int v = edge[nowe].to;
      if(edge[nowe].cap > edge[nowe].flow && dis[v] == 0){
        dis[v] = dis[nown] + 1;
        q.push(v);
        if(v == T) return 1;
      }
    }
  }
  return 0;
}

int dfs(int nown,int limit = inf){
  if(limit == 0 || nown == T) return limit;
  for(int &nowe = cur[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;
    if(edge[nowe].cap > edge[nowe].flow && dis[v] == dis[nown] + 1){
      int f = dfs(v,min(limit,edge[nowe].cap - edge[nowe].flow));
      if(f){
        edge[nowe].flow+=f;
        edge[nowe^1].flow -= f;
        return f;
      }
    }
  }
  return 0;
}

int dinic(){
  int ans = 0,f = 0;
  while(bfs()){
    while(true){
      f = dfs(S);
      if(f == 0) break;
      else ans+=f;
    }
  }
  return ans;
}

int n,m,a[MAXN];
int u[MAXN],v[MAXN],w[MAXN];

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    scanf("%d",&a[i]);
  }
  for(int i = 1;i<=m;i++){
    scanf("%d %d %d",&u[i],&v[i],&w[i]);
  }
}

void solve(){//边在前[1,m]，点在后 [m+1,m+n]
  S = n+m+1,T = n+m+2;
  for(int i = 1;i<=n;i++)addedge(m+i,T,a[i]);
  for(int i = 1;i<=m;i++){
    addedge(S,i,w[i]);
    addedge(i,m+u[i],inf),addedge(i,m+v[i],inf);
  }
  int ans = -dinic();
  for(int i = 1;i<=m;i++){
    ans += w[i];
  }
  printf("%d\n",ans);
}

int main(){
  init();
  solve();
  return 0;
} 
```

