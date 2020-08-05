---
title: 「POI2012」Cloakroom-类背包dp
urlname: POI2012-Cloakroom
date: 2018-08-16 21:26:17
tags:
- 动态规划
- 背包
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

有 $n$ 件物品，每件物品有三个属性 $a[i], b[i], c[i]$ , $(a[i] < b[i])$ 。

再给出 $q$ 个询问，每个询问由非负整数 $m$ , $k$ , $s$ 组成，问是否能够选出某些物品使得：

+ 对于每个选的物品 $i$ ，满足 $a[i] \leq m$ 且 $b[i]>m+s$ 。

+ 所有选出物品的 $c[i]$ 的和正好是 $k$ 。

<!--more-->

## 链接

[Luogu P3537](https://www.luogu.org/problemnew/show/P3537)

## 题解

好题好题。

首先我们发现，如果把 $a[i]$ 这一维 $sort$ 掉，使 $a[i]$ 单增的话，这个问题就变成了给定若干个物品，问能不能取若干个物体满足 $\sum c[i] = k$ ，且 $\min(b[i]) > m + s$。

然后这个时候，我们想要每加入一个物品都能够更新答案，可以用 $dp$ 的方法来更新，状态的第一维也就很好设置，肯定是前 $i$ 个物品如何如何。然后看到数据范围，我们需要思考如何在 $O(\log n)$ 或者 $O(1)$ 的时间内出解。

根据时间的限制，下面我们只能设置一维了，不可能同时表示 $\sum c[i]$ 和 $\min(b[i])$ 。考虑到这只是一个可行性判定，所以我们不用都存两个，只要存的这一维和$ dp$ 数组的信息能够让我们推断出来可行不可行就可以。

所以我们令 $dp[i][j]$ 表示前i个物品，$\sum c[i]$ 为 $j$ 的情况下，所有方案中 $\min(b[i])$ 最大的是多少。

这个时候，我们查 $dp[i][k]$ ，若其大于等于 $k$ ，则无解；否则有解。

## 代码


```cpp
#include <cstdio>
#include <cstring>
#include <set>
#include <algorithm>
using namespace std;

const int MAXN = 1100,MAXM = 1100000;

struct Query{
    int id;
    int x,y,c;
    bool operator <(const Query &_q)const{
        return x < _q.x;
    }
}p[MAXN],q[MAXM];

int n,m;

void init(){
    scanf("%d",&n);
    for(int i = 1;i<=n;i++){
        scanf("%d %d %d",&p[i].c,&p[i].x,&p[i].y);
    }
    scanf("%d",&m);
    for(int i = 1;i<=m;i++){
        scanf("%d %d %d",&q[i].x,&q[i].c,&q[i].y);
        q[i].y += q[i].x;
        q[i].id = i;
    }
}

void solve(){
    sort(p+1,p+n+1),sort(q+1,q+m+1);
    static int dp[MAXM],ans[MAXM];
    memset(dp,0,sizeof(dp));
    dp[0] = 0x3f3f3f3f;
    int j = 1;
    p[n+1].x = 0x3f3f3f3f;
    for(int x = 1;x<=n+1;x++){
        while(j <= m && q[j].x < p[x].x){
            ans[q[j].id] = dp[q[j].c] <= q[j].y ? 0: 1;
            j++;
        }
        if(x == n+1) break;
        for(int i = 100000;i>=p[x].c;i--)
            dp[i] = max(dp[i],min(dp[i-p[x].c],p[x].y));
    }
    for(int i = 1;i<=m;i++){
        printf("%s\n",ans[i]?"TAK":"NIE");
    }
}


int main(){
    init();
    solve();
    return 0;
}
```

