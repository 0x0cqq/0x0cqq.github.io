---
title: 「SCOI2008」奖励关-期望dp
urlname: SCOI2008-award
date: 2018-08-03 19:39:32
tags:
- dp
- 期望dp
- 题解
categories: OI
visible:
---

系统将依次随机抛出$k$次宝物，每次你都可以选择吃或者不吃。宝物一共有$n$种，系统每次抛出这$n$种宝物的概率都相同且相互独立。

吃一次第 $i$ 种宝物将得到 $P_i$ 分，但并不是每种宝物都是可以随意获取的。第 $i$ 种宝物有一个前提宝物集合 $S_i$ 。只有当 $S_i$ 中所有宝物都至少吃过一次，才能吃第 $i$ 种宝物。注意，$P_i$ 可以是负数。

假设你采取最优策略，平均情况你一共能在奖励关得到多少分值？


<!-- more -->

## 链接

[Luogu P2473](https://www.luogu.org/problemnew/show/P2473)

## 题解

为了方便最后答案的计算，我们设$dp[i][S]$为当前已经吃了$i$次，并且已经吃到的宝物的集合为$S$，到最后（吃完$k$次）能够获得。

然后状态转移（$W_i$为单独取$i$的集合）：

$$
dp[i][S] = \frac{1}{n}\sum_{i = 1}^{n} 
\begin{cases}
min(dp[i+1][S],dp[i+1][S \cup W_i] + P_i),S_i \subset S\\
dp[i+1][S],S_i \not\subset S
\end{cases}
$$

状压，转移即可。


## 代码

{% fold %}
```cpp
#include <cstdio>
#include <algorithm>
using namespace std;

const int MAXN = 110;

int k,n;
int q[MAXN],p[MAXN],t;

double dp[MAXN][1<<16];//1<<type代表第i种

void init(){
    scanf("%d %d",&k,&n);
    for(int i = 1;i<=n;i++){
        scanf("%d %d",&p[i],&t);
        while(t!=0)
            q[i] |= (1<<(t-1)),scanf("%d",&t);
    }
}

void solve(){
    for(int i = k-1;i>=0;i--){
        for(int j = 0;j<=(1<<n)-1;j++){
            for(int w = 1;w<=n;w++)
                dp[i][j] += max(dp[i+1][j],(q[w]&j)==q[w]?dp[i+1][j|(1<<w-1)]+p[w]:-1e9);
            dp[i][j]/=n;
        }
    }
    printf("%.6lf\n",dp[0][0]);
}

int main(){
    init();
    solve();
    return 0;
}
```
{% endfold %}