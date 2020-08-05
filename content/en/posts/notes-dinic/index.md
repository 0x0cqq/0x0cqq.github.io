---
title: Dinic学习笔记
urlname: dinic-notes
date: 2018-02-08 14:31:15
tags:
- 图论
- Dinic
- 模板
categories: 
- OI
- 学习笔记
series:
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

Dinic算法是一种用于网络流中最大流的增广路算法，其时间复杂度为$O(n^2 \times m)$，但大多数情况下会远远优于此时间复杂度。

<!--more-->

## 基本概念

从Menci神犇的[博客](https://oi.men.ci/dinic-notes/)复制而来。我觉得这写的是很好的一篇介绍，除了代码风格不太喜欢。

- 容量： ${capacity}(e)$ 表示一条有向边 $e(u,v)$ 的最大允许的流量。

- 流量： ${flow}(e)$ 表示一条有向边 $e(u,v)$ 总容量中已被占用的流量。

- 剩余容量（残量）：即 $capacity(e)−flow(e)$，表示当前时刻某条有向边 $e(u,v)$ 总流量中未被占用的部分。

- 反向边：原图中每一条有向边在残量网络中都有对应的反向边，反向边的容量为$0$，容量的变化与原边相反；『反向边』的概念是相对的，即一条边的反向边的反向边是它本身。

- 残量网络：在原图的基础之上，添加每条边对应的反向边，并储存每条边的当前流量。残量网络会在算法进行的过程中被修改。

- 增广路（augmenting path）：残量网络中从源点到汇点的一条路径，增广路上所有边中最小的剩余容量为增广流量。

- 增广（augmenting）：在残量网络中寻找一条增广路，并将增广路上所有边的流量加上增广流量的过程。

- 层次： $level(u)$ 表示节点 $u$ 在层次图中与源点的距离。

- 层次图：在原残量网络中按照每个节点的层次来分层，只保留相邻两层的节点的图，满载（即流量等于容量）的边不存在于层次图中。

## 思路

用文字叙述大概如下：

```
1. 建立以出发点为源点的层次图（即源点到各店的距离）
2. 在层次图&残量网络中寻找增广路，并增广流量
3. 重复2直到找不到增广路
4. 重复123直到不存在层次图
```

## 实现

建立层次图使用bfs，而寻找增广路则是使用dfs递归增广。
具体实现的时候也有一定的技巧，在代码里面有注释。

反向边存在的意义是什么呢？形象来说其实就是给你一个后悔的机会，往一边流去之后还能再回来。注意反向边的容量在我这里初始为0。

有一个优化就是当前弧优化。这个优化是很显而易见的。如果这条边在当前层次图下找不到路，那么这条边在当前层次图内就再也不会用到。所以我们单开一个cur数组，记录目前遍历到的边，这样就可以进行优化。

## 代码

以[Luogu P3376](https://www.luogu.org/problemnew/show/P3376)为例



```cpp
#include <cstdio>
#include <queue>
#include <cstring>
#include <algorithm>
using namespace std;

struct Edge{
    int from,to,flow,cap;
    int next;
}edge[201000];
int fir[10100],dis[10100],cur[10100];

int n,m,s,t,tot = 2;//tot从2开始是最舒服的，既可以直接异或，后面的终止条件也不用想来想去。

bool bfs(){
    queue<int> q;
    memset(dis,0,sizeof(dis));
    memcpy(cur,fir,sizeof(fir));//清空当前边
    q.push(s);dis[s] = 1;
    while(!q.empty()){
        int nown = q.front();q.pop();
        for(int nowe = fir[nown];nowe!=0;nowe = edge[nowe].next){
            int v = edge[nowe].to;
            if(dis[v] == 0 && edge[nowe].cap > edge[nowe].flow){
                //两个条件：未遍历而且边可以增广
                dis[v] = dis[nown]+1;
                q.push(v);
                //由于我们只沿最短路增广，所以这里就可以直接break掉了。
                if(v == t)
                    return dis[t];
            }
        }
    }
    return dis[t];
}

int dfs(int nown,int limit = 0x3f3f3f3f){
    //找到终点或没得可找 这个优化很重要
    if(nown == t || limit == 0)
        return limit;
    for(int &nowe = cur[nown];nowe!=0;nowe = edge[nowe].next){
        //这里有当前弧优化
        int v = edge[nowe].to;
        if(dis[v] == dis[nown]+1 && edge[nowe].flow < edge[nowe].cap){
            //满足层次图条件(沿着最短路)
            int f = dfs(v,min(edge[nowe].cap-edge[nowe].flow,limit));
            if(f>0){
                //更改当前边
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
    while(bfs()){//bfs是步骤1
        while( (f = dfs(s)) > 0)//dfs是步骤2
            ans+=f;
    }
    return ans;
}

void addedge(int a,int b,int c){
    edge[tot].from = a;edge[tot].to = b;
    edge[tot].cap = c;edge[tot].flow = 0;
    edge[tot].next = fir[a];fir[a] = tot;
    tot++;
}

int main(){
    scanf("%d %d %d %d",&n,&m,&s,&t);
    for(int i = 0;i<m;i++){
        int a,b,c;
        scanf("%d %d %d",&a,&b,&c);
        addedge(a,b,c);
        addedge(b,a,0);//需要加反向边
    }
    printf("%d\n",dinic());
    return 0;
}
```


