---
title: 「SDOI2011」消防-树的直径+单调队列
urlname: SDOI2011-fireman
date: 2018-05-21 20:11:00
tags:
- 单调队列
- 树的直径
- 树形结构
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

某个国家有 $n$ 个城市，这 $n$ 个点之间的边构成一棵树。

现求一条边长度和不超过 $S$ 的路径（两端都是城市，可以只为一个城市），使得所有城市到这条路径的距离的最大值最小，并输出这个最小值。

<!--more-->

## 链接

[Luogu P2491](https://www.luogu.org/problemnew/show/P2491)

## 题解

很有趣的题。

很明显，这条路径必须全部位于直径上。具体证明不会，大概可以感性理解一下。

那么我们就要考虑，在直径上选出一段长度不大于 $S$ 的路径，如何维护这颗树上的所有点到这条路径的长度的最大值。

考虑到只有两种情况：

+ 在树的直径上叉出来的一支
+ 路径上的两个端点到同侧直径端点的距离

第一个先 $O(n)$ 预处理出来，第二个记录直径的一个端点到直径上所有点的距离，然后可以 $O(1)$ 的计算。

我们枚举路径的右端点 $r$ ，然后把左端点 $l$ 推到最左侧可以满足  $d \leq S$  的点，这个过程是 $O(n)$ 的，注意到 $l,r$ 都是单调递增的，我们可以用一个单调队列维护 $[l,r]$ 的最大值，然后再与第二个情况取一个 $max$ 。然后最小值就是我们的 $ans$ 。

总时间复杂度 $O(n)$ 。

## 代码


```cpp
#include <cstdio>
#include <vector>
#include <algorithm>
#include <queue>
#include <cctype>
#define pp pair<int,int>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 310000;

struct Edge{
    int from,to;
    int len;
};

int n,k;
vector<Edge> edge[MAXN];

void init(){
    read(n),read(k);
    int a,b,c;
    for(int i = 1;i<=n-1;i++){
        read(a),read(b),read(c);
        edge[a].push_back((Edge){a,b,c});
        edge[b].push_back((Edge){b,a,c});
    }
}

int dis[MAXN],f[MAXN];

void dfs(int nown,int fa){
    f[nown] = fa;
    for(int i = 0;i<edge[nown].size();i++){
        int v = edge[nown][i].to,l = edge[nown][i].len;
        if(v == f[nown]) continue;
        dis[v] = dis[nown] + l;
        dfs(v,nown);
    }
}

int getmax(int nown){
    int ans = dis[nown];
    for(int i = 0;i<edge[nown].size();i++){
        int v = edge[nown][i].to;
        if(v == f[nown]) continue; 
        ans = max(ans,getmax(v));
    }
    return ans;
}

int num[MAXN],d[MAXN],maxn[MAXN],tot = 0;

void build(){
    int u = 0,v = 0;
    dis[1] = 0;
    dfs(1,0);
    for(int i = 1;i<=n;i++)
        if(dis[u] < dis[i]) u = i;
    dis[u] = 0;
    dfs(u,0);
    for(int i = 1;i<=n;i++)
        if(dis[v] < dis[i]) v = i;
    for(int i = v;i;i = f[i])
        num[++tot] = i;
    reverse(num+1,num+tot+1);
    for(int i = 1;i<=tot;i++)
        d[i] = dis[num[i]];
    for(int i = 1;i<=tot;i++){
        int nown = num[i];
        for(int j = 0;j<edge[nown].size();j++){
            int v = edge[nown][j].to;
            if(v == num[i+1] || v == num[i-1]) continue;
            maxn[i] = max(maxn[i],getmax(v));
        }
        if(maxn[i]) maxn[i] -= d[i];
    }
}

void solve(){
    deque<pp> q;
    int l = 1,ans = 0x3f3f3f3f;
    
    for(int i = 1;i<=tot;i++){
        while(!q.empty() && q.back().second < maxn[i])
            q.pop_back();
        q.push_back(make_pair(i,maxn[i]));
        while(d[i] - d[l] > k)
            l++;
        while(!q.empty() && q.front().first < l)
            q.pop_front();
        ans = min(ans,max(max(d[l],d[tot] - d[i]),q.front().second));
    }
    printf("%d\n",ans);
}

int main(){
    init();
    build();
    solve();
    flush();
    return 0;
}
```

