---
title: 「SCOI2010」股票交易-dp+单调队列
urlname: SCOI2010-stock
date: 2018-07-08 10:56:37
tags:
- 题解
- 动态规划
- 单调队列
categories: OI
visible:
---

`lxhgww`预测到了未来$T$天内某只股票的走势，第$i$天的股票买入价为每股$AP_i$，第$i$天的股票卖出价为每股$BP_i$（数据保证对于每个$i$，都有$AP_i$>=$BP_i$），第$i$天的一次买入至多只能购买$AS_i$股，一次卖出至多只能卖出$BS_i$股。两次交易（某一天的买入或者卖出均算是一次交易）之间，至少要间隔$W$天；在任何时间一个人的手里的股票数不能超过$MaxP$。

在第1天之前，`lxhgww`手里有数目无限的钱，但是没有任何股票，在$T$天以后，`lxhgww`能赚到的钱最多是多少？

<!-- more -->

## 链接

[Luogu P2569](https://www.luogu.org/problemnew/show/P2569)

## 题解

显然要`dp`嘛，要不然它放在`dp`模块里搞笑么。

如果用$dp[i][j]$表示在第$i$天的时候拥有$j$股股票的时候的最大收益。

那么状态转移：

$$
dp[i][j] = max
\begin{cases}{}
dp[i-1][j]\\
-ap[i]\times j,\; &j\leq as[i]\\
dp[i-w][j+t] + t \times bp[i],\;&0 < t < bs[i],j+t \leq maxp\\
dp[i-w][j-t] - t \times ap[i],\;&0 < t < as[i],j-t > 0
\end{cases}
$$

注意到前两个转移是$O(1)$的 ，后两个是如果直接做是$O(n)$的，然而这个东西就是在一个区间里面找最大值，后面加减的$t$ 随位置同步改变，不会改变状态的相对大小，所以用单调队列优化后面两个转移即可。

最后扫一下所有的$dp[n][i]$最大值即为答案。

## 代码



```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 2100;

int n,m,w;
int ap[MAXN],bp[MAXN],as[MAXN],bs[MAXN];
int dp[MAXN][MAXN];

void init(){
    scanf("%d %d %d",&n,&m,&w);
    w++;
    for(int i = 1;i<=n;i++)
        scanf("%d %d %d %d",&ap[i],&bp[i],&as[i],&bs[i]);
}

deque<int> q;

void solve(){
    for(int i = 0;i<=n;i++)
        for(int j = 0;j<=m;j++)
            dp[i][j] = -0x3f3f3f3f;
    dp[0][0] = 0;
    for(int i = 1;i<=n;i++){
        for(int j = 0;j<=as[i];j++)
            dp[i][j]=-ap[i]*j;        
        for(int j = 0;j<=m;j++)
            dp[i][j] = max(dp[i][j],dp[i-1][j]);
        if(i-w < 0) continue;//!!!
        while(!q.empty()) q.pop_back();
        for(int j = 0;j<=m;j++){
            while(!q.empty() && q.front() < j-as[i])
                q.pop_front();
            while(!q.empty() && dp[i-w][q.back()]-(j-q.back())*ap[i] <= dp[i-w][j])
                q.pop_back();
            q.push_back(j);
            dp[i][j] = max(dp[i][j],dp[i-w][q.front()]-(j-q.front())*ap[i]);
        }

        while(!q.empty()) q.pop_back();
        for(int j = m;j>=0;--j){
            while(!q.empty() && q.front() > j+bs[i])
                q.pop_front();
            while(!q.empty() && dp[i-w][q.back()]+(q.back()-j)*bp[i] <= dp[i-w][j])
                q.pop_back();
            q.push_back(j);
            dp[i][j] = max(dp[i][j],dp[i-w][q.front()] + (q.front() - j)*bp[i]);
        }
    }
    int ans = 0;
    for(int i = 0;i<=m;i++)
        ans = max(ans,dp[n][i]);
    printf("%d\n",ans);
}

int main(){
    init();
    solve();
    return 0;
}
```


在写下这个题解的时候，这的确是第100篇博文了。祝贺一下自己。
