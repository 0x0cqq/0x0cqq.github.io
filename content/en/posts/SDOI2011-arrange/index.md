---
title: 「SDOI2011」工作安排-费用流
urlname: SDOI2011-arrange
date: 2018-04-06 20:00:38
tags:
- 图论
- 费用流
categories: 
- OI
- 题解
series:
- 各省省选
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

你的公司需要提供 $n$ 类产品，其中第 $i$ 类产品共需要 $C_{i}$ 件。公司共有 $m$ 名员工。员工能够制造的产品种类有所区别，我们用一个由 $0$ 和 $1$ 组成的 $m\times n$ 的矩阵 $\mathbb {A}$ 来描述每名员工能够制造哪些产品。

对于员工 $i$ ，给出 $S_i$ 。定义他的愤怒值与他制作的产品数量之间的函数是一个 $S_i+1$ 段的分段函数。设 $T_{i,0}=0$,$T_{i,S_{i+1}}=+\infty$ ，那么当他制造第 $[T_{i,j-1}+1,T_{i,j}]$ 件产品时，每件产品会使他的愤怒值增加 $W_{i,j}$ ， $1\leq j\leq S_{i+1}$ 。保证 $0<W_{i,j} < W_{i,j+1}, \; 0 < T_{i,j} < T_{i,j+1}$ 。

你的任务是制定出一个产品的分配方案，使得订单条件被满足，并且所有员工的愤怒值之和最小。

<!--more-->

## 链接

[Luogu P2488](https://www.luogu.org/problemnew/show/P2488)

[BZOJ 2245](https://www.lydsy.com/JudgeOnline/problem.php?id=2245)

## 题解

一道费用流的题目。

每个产品的数量可以用一条边来限制，主要需要满足的就是愤怒值分段函数式的结构。

注意到每个人的愤怒值的分段函数与做了具体哪类产品无关，所以我们可以在人这边的边上动点手脚。我们可以拆边，按段来拆边，每段给一条边，通过容量来满足分段的要求。

具体建图：

令 $1$ 至 $m$ 为 $m$ 个员工所代表的点， $m+1$ 至 $m+n$ 为 $n$ 类产品代表的点， $s$ 为源点， $t$ 为汇点。

对于 $A$ 矩阵，如果 $A_{i,j}$ 是 $1$ ，那么我们就连一条起点为 $i$ ，终点为 $m+j$ ，容量为 $+\infty$ ，费用为 $0$ 的边。

对于第 $i$ 个商品种类，我们连一条起点为 $m+i$ ，终点为 $t$ ，容量为 $C_{i}$ ，费用为 $0$ 的边。

对于第 $i$ 个人，我们连 $S_{i}+1$ 条边，起点均为 $s$ ，终点均为 $i$ ，令第 $j$ 条边的容量为 $S_{i,j}-S_{i,j-1}, j \in [1,S_{i}+1]$ ，费用为  $W_{i,j}$ 。

跑最小费用最大流，得到的费用即为结果。

注意需要开 `long long`...

值得一提的是，由于我有一个 $j$ 写成了 $i$ ，导致我绝望的找了15分钟的bug...令人窒息。

## 代码


```cpp
#include <cstdio>
#include <queue>
#include <cctype>
#include <cstring>
#include <algorithm>
#define ll long long
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAX = 1e9;

const int MAXN = 1000,MAXM = 200000;

struct Edge{
    int from,to;
    int flow,cap;
    int cost;
    int nex;
}edge[MAXM];

int n,m,s,t,ecnt = 2;
int fir[MAXN],pree[MAXN];
ll dis[MAXN];int instack[MAXN];
queue<int> q;

void addedge(int a,int b,int c,int d){
    //printf("%lld %lld %lld %lld\n",a,b,c,d);
    edge[ecnt].from = a,edge[ecnt].to = b;
    edge[ecnt].cap = c,edge[ecnt].flow = 0;
    edge[ecnt].cost = d,edge[ecnt].nex = fir[a];
    fir[a] = ecnt++;
    edge[ecnt].from = b,edge[ecnt].to = a;
    edge[ecnt].cap = 0,edge[ecnt].flow = 0;
    edge[ecnt].cost = -d,edge[ecnt].nex = fir[b];
    fir[b] = ecnt++;
}

bool spfa(){
    while(!q.empty()) q.pop();
    memset(dis,0x3f,sizeof(dis));
    dis[s] = 0;q.push(s);
    while(!q.empty()){
        int nown = q.front();q.pop();
        instack[nown] = 0;
        for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
            Edge e = edge[nowe];
            if(dis[e.to] > dis[nown] + e.cost && e.cap > e.flow){
                dis[e.to] = dis[nown] + e.cost;
                pree[e.to] = nowe;
                if(instack[e.to] == 0){
                    instack[e.to] = 1;
                    q.push(e.to);
                }
            }
        } 
    }
    return dis[t] < 0x3f3f3f3f3f3f3f3f;
}

void argument(ll &sumf,ll &sumc){
    int nown = t,nowe,delta = MAX;
    while(nown!=s){
        nowe = pree[nown];
        delta = min(delta,edge[nowe].cap - edge[nowe].flow);
        nown = edge[nowe].from;
    }
    nown = t;
    while(nown!=s){
        nowe = pree[nown];
        edge[nowe].flow+=delta,edge[nowe^1].flow-=delta;
        nown = edge[nowe].from;
    }
    sumf+=delta,sumc+=delta*dis[t];
}

void min_cost_flow(){
    ll f = 0,c = 0;
    while(spfa())
        argument(f,c);
    printf("%lld\n",c);
}

void init(){
    read(m),read(n);
    s = m+n+1,t = m+n+2;
    int tmp = 0;
    for(int i = 1;i<=n;i++){
        read(tmp);
        addedge(m+i,t,tmp,0);
    }
    for(int i = 1;i<=m;i++){
        for(int j = 1;j<=n;j++){
            read(tmp);
            if(tmp)
                addedge(i,m+j,MAX,0);
        }
    }
    int b[10];
    for(int i = 1;i<=m;i++){
        read(tmp);
        for(int j = 1;j<=tmp;j++)
            read(b[j]);
        b[0] = 0;b[tmp+1] = MAX;

        for(int j = 1;j<=tmp+1;j++){
            int w;read(w);
            addedge(s,i,b[j]-b[j-1],w);
        } 
    }
}

int main(){
    init();
    min_cost_flow();
    return 0;
}
```

