---
title: 「CQOI2016」手机号码-数位dp
urlname: CQOI2016-phone
date: 2018-06-19 21:59:36
tags:
- 题解
- 数位dp
- 动态规划
categories: OI
visible:
---

手机号码是一个有 $11$ 位且不含前导 $0$ 的数。满足条件手机号码的必须**同时**满足：号码中出现至少 $3$ 个相邻的相同数字；号码中不能同时出现 $8$ 和 $4$ 。

给定两个数 $L$ 和 $R$ ，统计出 $[L,R]$区间内所有满足条件的手机号码的个数。 $L$ 和 $R$ 都是符合定义的手机号码。

<!-- more -->

## 链接

[Luogu P4124](https://www.luogu.org/problemnew/show/P4124)

## 题解

这个题用数位dp其实也可以递推。

定义一个状态$dp[i][j][num][is8][is4]$，其中$i$代表需要考虑的是后$i$位；$j$表示倒数第$i+1$位是数码$j$；$num$表示目前的连号是几个（$num = 1,2$），若这个为$3$则代表已经出现了连着三位相同的数字；最后两维分别表示有没有出现$8$和有没有出现$4$。状态储存的值就是符合条件的数的个数。

边界情况就是在 $i == 0$ 的时候。只有 `num == 3` 且 `is8 && is4 == 0` 时，边界才能得 $1$ ；否则就得 $0$ 。

其次转移就好了。枚举下一个数位从 $0$ 到 $9$ ，然后根据新的数位计算出 $num$ ， $is8$ ， $is4$ 等信息，转移就可以了。这里的 $num$ 如果已经为 $3$ ，就算与上一位相同，我们也不再往上加了；如果不是3的话才往上加。

注意在计算状态的时候，要把所有 `is8 && is4 == 1` 的情况全都置作$0$。

- - -

计算答案的话，就按照普通数位dp的统计方式去统计就可以了：把每一位都拆下来，在每一位都取到所有比这一位小的数，最后再加上最后一个数的情况。


## 代码

{% fold %}
```cpp
#include <cstdio>
using namespace std;
#define ll long long 

const int MAXN = 12;

ll x,y;
ll dp[MAXN][MAXN][4][2][2];
//dp[i][j][num][is8][is4];
//后i位，上一个数字是j，连续出现了num个数，有没有出现8，有没有出现4

void init(){
    scanf("%lld %lld",&x,&y);
}

void solve(){
    for(int i = 0;i<=11;i++)
    for(int j = 0;j<=9;j++)
    for(int num = 1;num<=3;num++)
    for(int is8 = 0;is8<=1;is8++)
        for(int is4 = 0;is4<=1;is4++){
            ll &t = dp[i][j][num][is8][is4];
            if(i == 0)
                t = (num==3?1:0);// 边界的判定
            else for(int w = 0;w<=9;w++){
                t += dp[i-1][w][num==3?3:w==j?num+1:1][is8||(w==8)][is4||(w==4)];
            if(is8 && is4)
                t = 0;
        }
    }
}

ll cal(ll x){
    if (x < 1e10) return 0;
    int d[20],cnt = 0;
    while(t) d[++cnt] = x%10,x/=10;
    d[cnt+1] = 0;
    ll ans = 0;int num = 0,is8 = 0,is4 = 0;
    for(int i = cnt;i>=1;--i){
        for(int j = 0;j<d[i];j++)
            ans += dp[i-1][j][num==3?3:d[i+1]==j?num+1:1][(j==8)||is8][(j==4)||is4];
        // 该位小于限定数
		num = (num == 3?3:d[i]==d[i+1]?num+1:1);
        is8 |= d[i] == 8;
        is4 |= d[i] == 4;
    }
    ans -= dp[10][0][1][0][0];//减去存在前缀0的情况
    ans += dp[0][d[1]][num][is8][is4];
    return ans;
}

void getans(){
    ll ans = cal(y)-cal(x-1);
    printf("%lld\n",ans);
}

int main(){
    init();
    solve();
    getans();
    return 0;
}
```
{% endfold %}