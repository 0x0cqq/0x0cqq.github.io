---
title: 「POI2013」Price List-图论
urlname: POI2013-Price-List
date: 2018-08-14 19:53:50
tags:
- 图论
- 最短路
categories: 
- OI
- 题解
series:
- 各国OI
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

给定一个 $n$ 个点，$m$ 条边的无向联通图，每条边的权值均为 $a$。

在**原图**所有满足 $u$ 节点和 $v$ 节点间最短路为 $2 \times a$ 的点对 $(u,v)$ 间建立一条无向边，边的权值均为 $b$。

给定一个起始节点$k$，求在上述操作后，$k$到所有节点的最短路径。

<!--more-->

## 链接

[Luogu P3547](https://www.luogu.org/problemnew/show/P3547)

## 题解

第一遍写觉得是sb题，第二遍觉得是神题oooorz

可以发现，一共有三种从k点到达其他点的方式：

+ 全走 $a$ 边
+ 走 $0/1$ 条边的 $a$ ，剩下沿最短路走 $b$ 
+ 全走 $b$ 边（可能绕远）

第一种和第二种情况可以一遍 $bfs$ 解决，这也就是我所想到的了。

然后交上去， $WA$ 。

- - -

第三种情况如果直接两次往外扩展建边，那么复杂度是 $O(m^2)$ 。

这个时候我们有一个微小的优化，就是建两份的图，分别用作从一个点第一次和第二次扩展的用的边。

每次我们两次扩展，都把所有合法的第二次扩展的边删掉，理由是非常显然的，因为我们已经访问到了这个节点，根据bfs的性质，所有这个节点在第二张图的入边都不需要了，所以就可以删掉。

然后复杂度是 $O(m \sqrt{m})$ 。

具体证明如下：


首先，时间复杂度约等于遍历的边的数量，所以我们只需要考虑那些遍历了却没被删掉的边的数量。

对于每一个节点 $x$ ，由他开始只会进行一次遍历再二次遍历中，没被删掉的边只有一种，就是在二次遍历中遍历到了一个仍然与 $x$ 距离为 $1$ 的点，也就是一个三元环。

所以对于这个节点 $x$ ，假设和他距离为 $1$ 的点有 $k$ 个（也就是这个节点的度数），那么对于每一次二次遍历，那么最多有 $k^2$ 条边遍历过但没有被删掉，只有这些边有可能在接下来的遍历中被再次遍历，又因为第一次遍历的边总共是 $m$ 条，所以总时间复杂度就是它们的相乘。
$$
\sum_{v \in V} \min(deg(v)^2,m) \leq \sum_{v \in V} \sqrt{deg(v)^2 \cdot m} = \sqrt {m} \sum_{v \in V} deg(v) = O(m \sqrt{m})
$$
- - -


参考：
[CSDN](https://blog.csdn.net/commonc/article/details/51643519)

这个题告诉我们：适当删边可能降低一些复杂度。

orz出题人...

## 代码


```cpp
#include <cstdio>
#include <queue>
#include <cstring>
#include <algorithm>
using namespace std;

const int MAXN = 210000,MAXM = 210000;

struct Graph{
    int to[MAXM],nex[MAXM],pre[MAXM];
    int fir[MAXN];int ecnt;
    Graph(){
        ecnt = 1;
    }
    void addedge(int u,int v){
        int e = ecnt;
        pre[fir[u]] = e;
        to[e] = v,nex[e] = fir[u],pre[e] = 0;
        fir[u] = e; 
        ecnt++;
    }
    void deledge(int x,int e){
        int n = nex[e],p = pre[e];
        if(!p) fir[x] = n;
        nex[p] = n,pre[n] = p;
    }
}A,B;

int n,m,k,a,b;
long long ans[MAXN];

long long dis[MAXN];
queue<int> q;


void init(){
    scanf("%d %d %d %d %d",&n,&m,&k,&a,&b);
    int u,v;
    for(int i = 1;i<=m;i++){
        scanf("%d %d",&u,&v);
        A.addedge(u,v),A.addedge(v,u);
        B.addedge(u,v),B.addedge(v,u);
    }
}

void bfs1(){
    while(!q.empty()) q.pop();
    for(int i = 1;i<=n;i++) dis[i] = 1000000;
    dis[k] = 0;q.push(k);
    while(!q.empty()){
        int nown = q.front();q.pop();
        for(int nowe = A.fir[nown];nowe;nowe = A.nex[nowe]){
            int v = A.to[nowe];
            if(dis[v] > dis[nown] + 1){
                dis[v] = dis[nown] + 1;
                q.push(v);
            }
        }
    }
    for(int i = 1;i<=n;i++)
        ans[i] = min(dis[i] * a,(dis[i]/2) * b + (dis[i]%2) * a);
}

void bfs2(){
    static bool vis[MAXN];
    while(!q.empty()) q.pop();
    for(int i = 1;i<=n;i++)
        dis[i] = 1000000;
    dis[k] = 0;q.push(k);
    while(!q.empty()){
        int nown = q.front();q.pop();
        vis[nown] = 1;
        for(int e1 = A.fir[nown];e1;e1 = A.nex[e1]){
            int v1 = A.to[e1];
            vis[v1] = 1;
        }
        for(int e1 = A.fir[nown];e1;e1 = A.nex[e1]){
            int v1 = A.to[e1];
            for(int e2 = B.fir[v1];e2;e2 = B.nex[e2]){
                int v2 = B.to[e2];
                if(!vis[v2]){
                    // printf("	v2:%d\n",v2);
                    if(dis[v2] > dis[nown] + 1){
                        dis[v2] = dis[nown] + 1;
                        q.push(v2);
                    }
                    B.deledge(v1,e2);
                }
            }
        }
        for(int e1 = A.fir[nown];e1;e1 = A.nex[e1]){
            int v1 = A.to[e1];
            vis[v1] = 0;
        }
        vis[nown] = 0;
    }
    for(int i = 1;i<=n;i++)
        ans[i] = min(ans[i],dis[i] * b);
}

void solve(){
    memset(ans,0x3f,sizeof(ans));
    bfs1();
    bfs2();
    for(int i = 1;i<=n;i++){
        printf("%lld\n",ans[i]);
    }
}

int main(){
    init();
    solve();
    return 0;
}
```

