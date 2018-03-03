---
title: 「ZJOI2007」时态同步-树形dp
urlname: ZJOI2007-sync
date: 2018-03-03 18:30:16
tags:
- 题解
- 动态规划
- 树形dp
categories: OI
visible:
---

给定一棵由$n$个节点构成的树。

在树上存在一个“激发器”，标号为$s$。当激发器工作后，电流会延边传向每一个相邻节点。而中间节点接收到电流后，会将该电流传向与它连接并且尚未接收到电流的节点。对于每条边$e$，电流通过它需要的时间为$t\_e$，电流的转发可以认为是在瞬间完成的。最终，激电流将到达一些“终止节点”――接收电流之后不再转发的节点。

使用一次道具可以使得电流通过某条边的时间增加一个单位。请问最少使用多少次道具才可达到每一个“终止节点”同时收到电流？

<!-- more -->

## 链接

[Luogu P1131](https://www.luogu.org/problemnew/show/P1131)

## 题解

注意到子树无论怎么搞，对上面的选择有影响的只是一个最后电流到达终点同步的时间，所以我们把这个设计进状态里面。

注意到如果子树的同步的时间最少的话，那么它的消耗道具次数就应该是最少的，同时因为这棵子树的每一层之间，至少含有一条边，那么如果子树的同步时间变多$x$，那么在子树上的道具消耗次数就一定要变多大于等于$x$，而这个时候在子树与父节点的同步中，子树的根节点与父节点间的边的同步时间最多减少$x$，所以可以证明父节点的最优消耗道具次数一定是在子节点的最优同步时间下取得的，也就可以证明$dp$的正确性。

状态转移方程：

$$
time[u] = max(time[v]+len(u,v))
$$

$$
ans[u] = sum(ans[v]+time[u]-(time[v]+len(u,v))
$$

其中$u$，$v$有一条边，且$v$非$u$的父亲。

## 代码

{% fold %}

```cpp
#include <cstdio>
#include <vector>
#include <cctype>
#include <algorithm>
#define int long long
using namespace std;

namespace fast_io {
    ...//省略快读模版
}using namespace fast_io;

namespace normal_io{
    inline char read(){
        return getchar();
    }
    inline void read(int &x){
        scanf("%lld",&x);
    }
    inline void print(int x){
        printf("%lld",x);
    }
    inline void print(char x){
        putchar(x);
    }
    inline void flush(){
        return;
    }
}using namespace normal_io;

const int MAXN = 510000;

int n,s;

struct Edge{
    int t,l;
    Edge(int b = 0,int c = 0):t(b),l(c){};
};

vector<Edge> edge[MAXN];

int ans[MAXN],times[MAXN];

bool vis[MAXN];

void addedge(int a,int b,int c){
    edge[a].push_back(Edge(b,c));
    edge[b].push_back(Edge(a,c));
}

void init(){
    read(n),read(s);
    int a,b,c;
    for(int i = 1;i<=n-1;i++){
        read(a),read(b),read(c);
        addedge(a,b,c);
    }
}

void dp(int nown){
    vis[nown] = 1;
    int tmpsum = 0,mintime = 0,k = 0;
    for(int i = 0;i<edge[nown].size();i++){
        int to = edge[nown][i].t,len = edge[nown][i].l;
        if(vis[to] == 1)
            continue;
        dp(to);
        ans[nown] += ans[to];
        mintime = max(mintime,times[to]+len);
        tmpsum += (times[to]+len);
        k++;
    }
    ans[nown] += k * mintime - tmpsum,times[nown] = mintime;
}

void solve(){
    dp(s);
    print(ans[s]);
}

main(){
    init();
    solve();
    flush();
    return 0;
}
```

{% endfold %}