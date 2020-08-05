---
title: 「ZJOI2010」网络扩容-网络流-费用流
urlname: ZJOI2010-network
date: 2018-04-05 16:55:11
tags:
- 图论
- 费用流
- 网络流
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

给定一张有向图，每条边都有一个容量 $C$ 和一个扩容费用 $W$ 。这里扩容费用是指将容量扩大 $1$ 所需的费用。

现在请你编写一个程序求出：
1. 在不扩容的情况下， $1$ 到 $N$ 的最大流； 
2. 将 $1$ 到 $N$ 的最大流增加 $K$ 所需的最小扩容费用。

<!--more-->

## 链接

[Luogu P2604](https://www.luogu.org/problemnew/show/P2604)

[BZOJ 1834](https://www.lydsy.com/JudgeOnline/problem.php?id=1834)

## 题解

一道最大流和费用流的题。

第一问不说了。第二问事实上我们注意到我们可以把每条边想像成， $C$ 的免费流量和费用为 $W$ 的流量。因为答案问我们在最大流为 $ans+k$ 的时候，最小费用是多少，所以我们需要引入一条边来控制流量，再跑得到的费用流就是最小费用了。

怎么来达成边的约束呢？事实上拆边为两条就好，一条免费边，一条收费边。

- - -

具体建图方法如下。

先按照费用流的样子建图，所有边的费用为 $0$ ，源点为 $1$ ，终点为 $n$ ，然后跑`Dinic`得到 $ans1$ 。

关于 $ans2$ ，稍微复杂一些。

保留原图。对于图中的每条边，再建一条容量为 $ans1+k$ ，费用为 $w\_i$ 的边。由 $n$ 号节点向 $n+1$ 号节点建一条容量为 $ans1+K$ ，费用为 $0$ 的边，并把汇点设置为 $n+1$ ，注意把流量初始需要设置成 $ans1$ 。直接在残量网络上跑费用流，得到费用即为 $ans2$ 。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

namespace fast_io {
    ...
}using namespace fast_io;

const int MAXN = 6000,MAXM = 110000;

int fx[MAXM],tx[MAXM],cx[MAXM],wx[MAXM];

struct Edge{
    int from,to;
    int flow,cap;
    int cost,nex;
}edge[MAXM];

int n,m,s,t,k;
int fir[MAXN],cur[MAXN],pree[MAXN],ecnt = 2;

void addedge(int a,int b,int ca,int co = 0,int f = 0){
    edge[ecnt].from = a,edge[ecnt].to = b;
    edge[ecnt].cost = co,edge[ecnt].cap = ca;
    edge[ecnt].flow = f;
    edge[ecnt].nex = fir[a],fir[a] = ecnt;
    ecnt++;
    edge[ecnt].from = b,edge[ecnt].to = a;
    edge[ecnt].cost = -co,edge[ecnt].cap = 0;
    edge[ecnt].flow = -f;
    edge[ecnt].nex = fir[b],fir[b] = ecnt;
    ecnt++;
}

int dis[MAXN],instack[MAXN];

queue<int> q;

//Dinic
bool bfs(){
    memset(dis,0,sizeof(dis));
    memcpy(cur,fir,sizeof(fir));
    while(!q.empty()) q.pop();
    q.push(s);dis[s] = 1;
    while(!q.empty()){
        int nown = q.front();q.pop();
        for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
            int v = edge[nowe].to;
            if(dis[v] == 0 && edge[nowe].cap > edge[nowe].flow){
                dis[v] = dis[nown]+1;
                q.push(v);
                if(v == t)
                    return true;
            }
        }
    }
    return false;
}

int dfs(int nown,int limit = 0x3f3f3f3f){
    if(nown == t||limit == 0)
        return limit;
    for(int &nowe = cur[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(dis[v] == dis[nown]+1 && edge[nowe].cap > edge[nowe].flow){
            int f = dfs(v,min(limit,edge[nowe].cap - edge[nowe].flow));
            if(f>0){
                edge[nowe].flow+=f;
                edge[nowe^1].flow-=f;
                return f;
            }
        }
    }
    return 0;
}

int dinic(){
    int ans = 0,f;
    while(bfs())
        while((f=dfs(s))>0)
            ans+=f;
    return ans;
}

//费用流
bool spfa(){
    while(!q.empty()) q.pop();
    memset(dis,0x3f,sizeof(dis));
    memset(instack,0,sizeof(instack));
    dis[s] = 0;q.push(s);
    while(!q.empty()){
        int nown = q.front();q.pop();
        instack[nown] = 0;
        for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
            Edge e = edge[nowe];
            if(dis[e.to]>dis[nown]+e.cost&&e.cap>e.flow){
                dis[e.to] = dis[nown]+e.cost;
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

void argument(int &sumc,int &sumf){
    int nown = t,delta = 0x3f3f3f3f;
    while(nown!=s){
        delta = min(delta,edge[pree[nown]].cap - edge[pree[nown]].flow);
        nown = edge[pree[nown]].from;
    }
    nown = t;
    while(nown!=s){
        edge[pree[nown]].flow += delta;
        edge[pree[nown]^1].flow -= delta;
        nown = edge[pree[nown]].from;
    }
    sumf+=delta,sumc+=delta*dis[t];
}

int min_cost_flow(int ans){
    int c = 0,f = ans;
    while(spfa())
        argument(c,f);
    return c;
}

//主程序
void init(){
    read(n),read(m),read(k);s = 1,t = n;
    for(int i = 1;i<=m;i++){
        read(fx[i]),read(tx[i]),read(cx[i]),read(wx[i]);
        addedge(fx[i],tx[i],cx[i]);
    }
}

void solve(){
    int ans1 = dinic(),ans2;
    for(int i = 1;i<=m;i++)
        addedge(fx[i],tx[i],ans1+k,wx[i]);
    addedge(n,n+1,ans1+k,0,ans1);t = n+1;
    //注意这个地方需要改变汇点，加边的时候需要给定初始流量
    ans2 = min_cost_flow(ans1);
    print(ans1),print(' '),print(ans2),print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

