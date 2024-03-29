---
title: 「NOI2010」能量采集-简单数学
urlname: NOI2010-energy
date: 2018-06-18 09:31:46
tags:
- 数学
- 最大公约数
categories: 
- OI
- 题解
series:
- NOI
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---


给定两个整数 $n,m$ ，对于平面上的整点 $\{(x,y)|x \in [1,n],y \in [1,m],x,y \in \mathbb Z\}$ 。若 $(x,y)$ 与 $(0,0)$ 的连线上有 $k$ 个整点（不包括 $(0,0),(n,m)$ ），则产生的贡献为 $2k+1$ 。求所有满足条件的点的贡献总和。

<!--more-->

## 链接

[Luogu P1447](https://www.luogu.org/problemnew/show/P1447)

## 题解

给出一个结论：**从 $(0,0)$ 到 $(n,m)$ 的线段上，有 $gcd(n,m)-1$ 个整点(不包括端点)**。想一想很好明白：令 $t$ 是 $n,m$ 的公因数， $(\frac {n}{t},\frac {m}{t})$ 就相当于步长， $m,n$ 一定时 $t$ 越大，步长越小，整点就越多。 $gcd(n,m)$ 是 $n,m$ 的最大公因数，所以就是最多整点的个数了。

所以问题转化为：
求

$$\sum _ {i = 1}^{n} \sum _ {j = 1}^{m}2\times gcd(n,m)-1$$

的值。

显然高端的数学方法我肯定是不会的。那怎么办呢。

数据范围不允许我们求出对于每一个 $n,m$ 的 $gcd$ ，但是我们可以想办法求出对于每一个 $w$ ， $gcd(i,j) = w$ 的 $(i,j)$ 对数，然后就可以 $O(n)$ 的加出结果了。

这个东西的话也不太好求...但是我们可以求出以 $w$ 为约数的树的个数！对于一个 $w$ ，均以 $w$ 为约数的 $(i,j)$ 的个数就是 $\lfloor \frac{n}{w} \rfloor \times \lfloor \frac{m}{w} \rfloor$ 。

还有一件事情，就是以 $w$ 为最大公因数的数的个数就是以 $w$ 为约数的数的个数减去以 $kw(k = 2,3,4...)$ 为最大公因数的个数。

然后我们就可以开始从上往下的递推了，计算的时候每次往上跳 $w$ ，直到超界，然后都减去就可以了。

根据一些调和级数的东西， $1+\frac{1}{2}+\frac{1}{3}...+\frac{1}{n} \approx \ln n$ ，所以最后的复杂度大约是 $O(n \ln n)$ 。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#define int long long
using namespace std;

const int MAXN = 110000;

int n,m,w,f[MAXN];

void init(){
    scanf("%lld %lld",&n,&m);
    w = min(n,m);
}

void solve(){
    int ans = 0;
    for(int i = w;i>=1;--i){
        f[i] = (n/i) * (m/i);
        for(int j = 2*i;j<=w;j+=i)
            f[i] -= f[j];
        ans += f[i]*(2*i-1);
    }
    printf("%lld\n",ans);
}

signed main(){
    init();
    solve();
    return 0;
}
```

