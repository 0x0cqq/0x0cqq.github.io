---
title: 「HAOI2009」毛毛虫-树形dp
urlname: HAOI2009-worm
date: 2018-06-06 19:08:55
tags:
- 题解
- 树形dp
- 动态规划
categories: OI
visible:
---

对于一棵树，我们可以将某条链和与该链相连的边抽出来，称其为一个“毛毛虫”。求在这个树中点数最多的毛毛虫的点数。

$n < 300000$

<!-- more -->

## 链接

[Luogu P3174](https://www.luogu.org/problemnew/show/P3174)


## 题解

很简单的一道$dp$题（感觉这个东西像一个$faKe$的$dp$）...

随便找一个根，记录$in[x]$为$x$节点的度，令$d[x]$为从$x$节点向下最长的毛毛虫的边数（含$x$连向其他儿子及其连向父节点的边）。

状态转移方程：

$d[x] = \max(d[v]) + in[x]$

统计答案的时候，在$dfs$过程中，我们记录其子树里面的最大的两个$d$，最后更新$ans = max(ans,d + d' + in[x])$。

最后给ans+1。

## 代码


```cpp
#include <cstdio>
#include <vector>
#include <cctype>
using namespace std;

namespace fast_io{
    //...
}using namespace fast_io;

const int MAXN = 310000;

vector<int> edge[MAXN];
int n,m,d[MAXN],in[MAXN],ans = 0;

void dfs(int nown,int fa){
    //d[nown] -> 从nown往下走的最大毛毛虫
    int maxa = 0,maxb = -0x3f3f3f3f;
    for(int i = 0;i<edge[nown].size();i++){
        int v = edge[nown][i];
        if(v == fa) continue;
        dfs(v,nown);
        d[nown] = max(d[nown],d[v]);
        if(d[v] >= maxa)
            maxb = maxa,maxa = d[v];
        else if(d[v] >= maxb)
            maxb = d[v];
    }
    ans = max(ans,maxa+maxb+in[nown]);
    d[nown] += in[nown]-1;
}

void init(){
    read(n),read(m);
    int a,b;
    for(int i = 1;i<=m;i++){
        read(a),read(b);
        edge[a].push_back(b);
        edge[b].push_back(a);
        in[a]++;in[b]++;
    }
}


void solve(){
    dfs(1,0);
    printf("%d\n",ans+1);
}

int main(){
    init();
    solve();
    return 0;
}
```

