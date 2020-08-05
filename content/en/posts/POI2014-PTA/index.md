---
title: 「POI2014」PTA-单调队列
urlname: POI2014-PTA
date: 2018-06-27 16:51:31
tags:
- 动态规划
- 单调队列
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

给定 $n$ 个点的高度，规定从 $1$ 点出发，跳到比高度小于当前点的点不消耗体力，否则消耗一点体力，最后到达 $n$ 点。

$q$ 次询问，每次询问有一个步伐限制 $k$ ，求最少耗费的体力。

<!--more-->

## 链接

[Luogu P3752](https://www.luogu.org/problemnew/show/P3572)

## 题解

很明显的一个dp。

状态转移方程：

$$
\begin{equation}
dp[i] = \min_{j \geq i-k}
\begin{cases}
	dp[j] + 1 & ht[i] \geq ht[j]\\
	dp[j],    & ht[i] < ht[j]
\end{cases}
\end{equation}
$$

注意到$j$随$i$的变化而单调递增，所以这个东西可以用单调队列来完成$O(n)$的复杂度。

不过有一点小问题，在于这个加一的问题。我们注意到，如果我们把dp的值当作第一关键字，高度当作第二关键字，如果最优解的高度较矮，加一之后也不会比次优解要差（单调队列里的最优和次优至少差$1$），所以我们可以如此优化。

时间复杂度$O(nq)$。


## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 1100000;
int n,m;
int num[MAXN], dp[MAXN];
deque<int> q;// 其中的int为pos

void init(){
    scanf("%d",&n);
    num[0] = 0x3f3f3f3f;
    for(int i = 1;i<=n;i++)
        scanf("%d",&num[i]);
}
bool cmp(int x,int y){
	// 1 -> x 的优先级大于y;0 -> y的优先级大于x
    if(dp[x]!=dp[y])
        return dp[x] < dp[y];
    return num[x] > num[y];
}
int getans(int k){
    dp[1] = 0;
    while(!q.empty()) q.pop_back();
    q.push_back(1);
    for(int i = 2;i<=n;i++){
        while(!q.empty() && q.front() < i-k)
            q.pop_front();
        dp[i] = dp[q.front()] + ((num[q.front()] > num[i])? 0: 1);
        while(!q.empty() && cmp(i,q.back()))
            q.pop_back();
        q.push_back(i);
    }
    return dp[n];
}

void solve(){
    scanf("%d",&m);
    int t;
    for(int i = 1;i<=m;i++){
        scanf("%d",&t);
        printf("%d\n",getans(t));
    }
}

int main(){
    init();
    solve();
    return 0;
}
```

