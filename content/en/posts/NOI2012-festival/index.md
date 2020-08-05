---
title: 「NOI2012」美食节-费用流
urlname: NOI2012-festival
date: 2018-05-03 22:16:33
tags:
- 费用流
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


美食节共有 $n$ 种不同的菜品，每个同学都点了一份在这 $n$ 个菜品中的菜。总共有 $m$ 个厨师来制作这些菜品。厨师们会按照要求的顺序进行制作，并且每次只能制作一人份。第 $j$ 个厨师制作第 $i$ 种菜品的时间记为 $t_{i,j}$ 。每个同学的等待时间为所有厨师开始做菜起，到自己那份菜品完成为止的时间总长度。总等待时间为所有同学的等待时间之和。

已知共有 $n$ 种菜品，第 $i$ 种菜品需要做 $p_i$ 份，共有 $m$ 个厨师。请计算出最小的总等待时间是多少。

<!--more-->

## 链接

[Luogu P2050](https://www.luogu.org/problemnew/show/P2050)


## 题解

很有趣的题。

看起来跟「SCOI2007」修车 很像，然而这道题的数据大大加强了。

这道题主要的方法如下：

对于每一个厨师，构建 $\sum p$ 个点，分别代表其倒数第一个，...，倒数第 $p$ 个制作的菜品。对于第 $i$ 个菜品，由菜品节点向第 $j$ 个厨师倒数第 $k$ 个做的菜，连一条容量为 $1$ ，费用为 $t_{i,j} \times k$ 的边。可以发现，这条边就代表了所有在倒数第 $k$ 个后面以及倒数第 $k$ 个制作菜品中由倒数第k个菜品的制作而产生的等待时间。

其他还有从各个节点连向汇点，以及源点连向各菜品节点，容量为 $p_i$ 的边。


但是，这个过不了。经过计算，我们发现最多的时候会有近 $6000000$ 条边，显然很惨。干写这个算法大概是50-60分的样子吧。

所以我们需要作出一些改进，来让这个算法变成 `O(能过)` 。考虑到最主要的问题是边数太多，所以我们应该想办法减少边的数目。

这个时候就可以玄学操作了。

考虑到以下的一件事：如果一个厨师倒数第 $k$ 个需要做的菜还没有做，那么不可能先做倒数第 $k+1$ 个菜，因为无论做什么菜，倒数第 $k$ 个做的菜价格总是更低。

所以我们先把每个厨师最后一个制作的菜品加入图中，然后进行一次 spfa 的增广。然后每次增广出来的菜和厨师，我们就加一条同一个厨师后面一个需要做的菜，这样既能保证复杂度比较低，也可以正确增广。


## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <cstring>
#include <queue>
#include <cctype>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 100000,MAXM = 2000000;

struct Edge{
    int from,to;
    int cap,flow;
    int cost,nex;
}edge[MAXM];

int n,m,s,t,sum = 0;
int ff = 0,cc = 0,p[MAXN],ti[1000][1000];
int fir[MAXN],ecnt = 2;

void addedge(int a,int b,int c,int d){
    edge[ecnt] = (Edge){a,b,c,0,d,fir[a]};
    fir[a] = ecnt++;
    edge[ecnt] = (Edge){b,a,0,0,-d,fir[b]};
    fir[b] = ecnt++;
}

int dis[MAXN],instack[MAXN],pree[MAXN];
queue<int> q;

bool spfa(){
    while(!q.empty()) q.pop();
    memset(dis,0x3f,sizeof(dis));
    memset(instack,0,sizeof(instack));
    q.push(s);dis[s] = 0;
    while(!q.empty()){
        int nown = q.front();q.pop();
        instack[nown] = 0;
        for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
            Edge e = edge[nowe];
            if(dis[e.to] > dis[nown] + e.cost && e.cap > e.flow){
                dis[e.to] = dis[nown] + e.cost;
                pree[e.to] = nowe;
                if(instack[e.to] == 0){
                    q.push(e.to);
                    instack[e.to] = 1;
                }
            }
        }
    }
    return dis[t] < 0x3f3f3f3f;
}

void argument(){
    int nown = t,nowe = 0,limit = 0x3f3f3f3f;
    while(nown != s){
        nowe = pree[nown];
        limit = min(limit,edge[nowe].cap - edge[nowe].flow);
        nown = edge[nowe].from;
    }
    nown = t;
    while(nown != s){
        nowe = pree[nown];
        edge[nowe].flow += limit;
        edge[nowe^1].flow -= limit;
        nown = edge[nowe].from;
    }
    ff += limit,cc += limit * dis[t];
}


void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++){
    	read(p[i]);
    	sum += p[i];
    }
    for(int i = 1;i<=n;i++){
        for(int j = 1;j<=m;j++){
            read(ti[i][j]);
        }
    }
}

void solve(){
    s = m*sum + n + 1,t = m*sum + n + 2;
    for(int i = 1;i<=n;i++)
        addedge(s,m*sum + i,p[i],0);
    for(int j = 1;j<=m;j++){
        addedge(j,t,1,0);
        for(int i = 1;i<=n;i++){	
            addedge(m*sum + i,j,1,ti[i][j]);
        }
    }
    while(spfa()){
        argument();
        int x = edge[pree[t]].from;
        addedge(x+m,t,1,0);
        for(int i = 1;i<=n;i++){
            addedge(m*sum + i,x+m,1,ti[i][(x-1)%m+1]*((x+m-1)/m+1));
        }
    }
    print(cc),print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

