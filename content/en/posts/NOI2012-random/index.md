---
title: 「NOI2012」随机数生成器-矩阵快速幂
urlname: NOI2012-random
date: 2018-08-21 21:56:54
tags:
- 数学
- 矩阵快速幂
- 递推
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

给定正整数 $n,m,a,c,X[0],g$ ，求按照 $X[n+1] = (a X[n] + c) \bmod m$ 生成出的第 $n$ 项 $X[n] \bmod g$ 的值。

数据范围： $n,m,a,c,X[0] \leq 10^{18}$

<!--more-->

## 链接

[Luogu P2044](https://www.luogu.org/problemnew/show/P2044)

## 题解

构造转移矩阵：

$$
\left[\begin{matrix}
a & c \\
0 & 1  
\end{matrix}\right]
\times
\left[\begin{matrix}
x _ {n}\\
1
\end{matrix} \right]
=
\left[\begin{matrix}
a x_n + c \\
0 + 1
\end{matrix} \right]
= 
\left[\begin{matrix}
x _ {n+1} \\
1
\end{matrix} \right]
$$

快速幂即可。

这里的乘法需要快速乘。

## 代码


```cpp
#include <cstdio>
#include <cstring>
using namespace std;
#define ld long double
#define ll long long

ll m,a,c,x0,n,g;

ll mul(ll a,ll b){
    a%=m,b%=m;
    return ((a*b - (ll)((ll)(((ld)a/m) * b + 1e-3) * m))%m+m)%m;
}

struct Matrix{
    ll a[3][3];
    Matrix(){
        memset(a,0,sizeof(a));
    }
};

Matrix mul(Matrix &_a,Matrix &_b){
    Matrix ans;
    for(int i = 1;i<=2;i++){
        for(int j = 1;j<=2;j++){
            for(int k = 1;k<=2;k++){
                (ans.a[i][j] += mul(_a.a[i][k],_b.a[k][j]))%=m;
            }
        }
    }
    return ans;
}

Matrix pow(Matrix x,ll p){
    Matrix ans;
    ans.a[1][1] = ans.a[2][2] = 1;
    for(ll i = p;i;x = mul(x,x),i>>=1) if(i & 1) ans = mul(ans,x);
    return ans;
}

int main(){
    scanf("%lld %lld %lld %lld %lld %lld",&m,&a,&c,&x0,&n,&g);x0 %= m;
    Matrix tmp;
    tmp.a[1][1] = a % m, tmp.a[1][2] = c % m,tmp.a[2][2] = 1;
    tmp = pow(tmp,n);
    ll ans = ((mul(tmp.a[1][1],x0) + tmp.a[1][2])%m)%g;
    printf("%lld\n",ans);
    return 0;
}

```

