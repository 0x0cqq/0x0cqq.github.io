---
title: 「ZJOI2010」数字计数-数位dp
urlname: ZJOI2010-count
date: 2018-06-18 09:35:53
tags:
- 数位dp
- 动态规划
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

给定两个正整数 $a$ 和 $b$ ，求在 $[a,b]$ 中的所有整数中，每个数码(`digit`)各出现了多少次。

<!--more-->

## 链接

[Luogu P2602](https://www.luogu.org/problemnew/show/P2602)

## 题解

比较入门的数位dp...很适合我这种蒟蒻。

令 $dp[i][j]$ 为当倒数第 $i$ 位为 $j$ 时，后 $i$ 位的数码总计（一个储存着十个整数的结构体，加减即为对位加减）。若 $j=10$ ，则代表这位是前导 $0$ 。(感觉这个搞法有点笨拙...巨佬能不能教教我...)

令 $sum(i,j)$ 为有 $i$ 数码有 $j$ 个，其他均为 $0$ 的状态。

则状态转移方程为：

$$dp[1][j] = sum(j,1)$$

$$dp[i][j] = sum(j,10^{i-1}) + \sum_{w = 0}^{9} dp[i-1][w]\; ,0\leq j \leq 9$$

$$dp[i][10] = \sum_{w = 1}^{10} dp[i-1][w]$$

计算答案时，这个实在不太好说...看代码的注释会更好理解...

## 代码


```cpp
#include <cstdio>
using namespace std;
#define ll long long 

ll a,b;

const int MAXN = 20;

struct sum{
    ll num[10];
    sum(int pos = -1,ll d = 1){
        for(int i = 0;i<10;i++) num[i] = 0;
        if(~pos)
            num[pos] = d;
    }
    sum operator +(const sum a)const{
        sum ans = sum();
        for(int i = 0;i<=9;i++)
            ans.num[i] = this->num[i] + a.num[i];
        return ans;
    }
    sum operator *(const int a)const{
        sum ans = sum();
        for(int i = 0;i<=9;i++)
            ans.num[i] = this->num[i] * a;
        return ans;
    }
    sum operator -(const sum a)const{
        sum ans = sum();
        for(int i = 0;i<=9;i++)
            ans.num[i] = this->num[i] - a.num[i];
        return ans;
    }
};

sum dp[MAXN][MAXN];
ll t[MAXN];
//dp[i][j] -> 后i位，倒数第i位为j,j == 10 代表为先导0

void init(){
    scanf("%lld %lld",&a,&b);
    t[0] = 1;
    for(int i = 1;i<=15;i++)
        t[i] = 10*t[i-1];
}

void build(){
    for(int j = 0;j<=9;j++)
        dp[1][j] = sum(j,1); 
    for(int i = 2;i<=15;i++){
        for(int j = 0;j<=9;j++){
            dp[i][j] = sum(j,t[i-1]);
            for(int w = 0;w<=9;w++)
                dp[i][j] = dp[i][j] + dp[i-1][w];
        }
        dp[i][10] = sum();
        for(int w = 1;w<=10;w++)
            dp[i][10] = dp[i][10] + dp[i-1][w]; 
    }
}

sum getnum(ll a){
    ll tmp = a;
    sum ans = sum(0,1);
    if(a == 0) return sum(0,1);
    int num[15],cnt = 0;
    while(a){
        num[++cnt] = a % 10;
        a/=10;
    }
    ans = ans + dp[cnt][10] - dp[cnt][0];
    //加上在这一位有前导0，再除去在这一位是0的
    for(int i = cnt;i>=1;--i){
        for(int j = 0;j<num[i];++j)
            ans = ans + dp[i][j];
        //加上所有比当前位置小的数的数码
        ans = ans + sum(num[i],tmp%t[i-1]+1);
        //补上后面的数中不再计算的这一位的数码
    }
    return ans;
}

void solve(){
    sum ans = getnum(b)-getnum(a-1);
    for(int i = 0;i<=9;i++){
        printf("%lld ",ans.num[i]);
    }
    printf("\n");
}

int main(){
    init();
    build();
    solve();
    return 0;
}
```


