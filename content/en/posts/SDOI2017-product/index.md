---
title: 「SDOI2017」数字表格-数论
urlname: SDOI2017-product
date: 2019-03-31 21:49:37
tags:
- 数论
- 数学
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
Doris 刚刚学习了 fibnacci 数列，用 $f[i]$ 表示数列的第 $i$ 项，那么： $f[0] = 0,f[1] = 1,f[n] = f[n - 1] + f[n - 2](n \geq 2)$ 。

Doris 用老师的超级计算机生成了一个 $n \times m$ 的表格，第 $i$ 行第 $j$ 列的格子中的数是 $f[\gcd(i, j)]$，其中 $\gcd(i, j)$ 表示 $i$ 与 $j$ 的最大公约数。

Doris 的表格中共有 $n \times m$ 个数，她想知道这些数的乘积是多少。

这些数的乘积实在是太大了，所以 Doris 只想知道乘积对 $1000000007$ 取模后的结果。

<!--more-->

## 链接

[Luogu P3704](https://www.luogu.org/problemnew/show/P3704)

## 题解

令 $fib(i)$ 为斐波那契数列的第 $i$ 项，我们要求的是：
$$
\prod_{i=1}^n \prod_{j=1}^m fib(\gcd(i,j))
$$
推推式子（不妨设 $n \le m$）：
$$
\prod_{i=1}^n \prod_{j=1}^m fib(\gcd(i,j))\\
= \prod_{d=1}^n fib(d)^{g(d)}
$$
其中 ：
$$
g(d) = \sum_{i=1}^{\lfloor\frac{n}{d}\rfloor} \sum_{j=1}^{\lfloor\frac{m}{d}\rfloor} [\gcd(i,j) = 1]\\
= \sum_{i=1}^{\lfloor\frac{n}{d}\rfloor} \sum_{j=1}^{\lfloor\frac{m}{d}\rfloor} \sum_{k | \gcd(i,j)} \mu(k)\\
= \sum_{k=1}^{\lfloor\frac{n}{d}\rfloor} \mu(k) \lfloor \frac{\lfloor\frac{n}{d}\rfloor} {k}\rfloor \lfloor \frac{\lfloor\frac{m}{d}\rfloor} {k}\rfloor\\
= \sum_{k=1}^{\lfloor\frac{n}{d}\rfloor} \mu(k)\lfloor\frac{n}{dk}\rfloor\lfloor\frac{m}{dk}\rfloor\\
$$
以上是我会的全部...

我们令 $T = kd$ ，然后直接代到最外面：
$$
sum = \prod_{d=1}^{n} fib(d)^{\sum_{k=1}^{\lfloor\frac{n}{d}\rfloor} \mu(k)\lfloor\frac{n}{dk}\rfloor\lfloor\frac{m}{dk}\rfloor}\\
= \prod_{k=1}^{n} \prod_{d = 1}^{\lfloor\frac{n}{k}\rfloor}fib(d)^{\mu(k)\lfloor\frac{n}{dk}\rfloor\lfloor\frac{m}{dk}\rfloor}\\
=\prod_{T=1}^n \prod_{k | T} fib(\frac{T}{k})^{\mu(k)\lfloor\frac{n}{T}\rfloor\lfloor\frac{m}{T}\rfloor}
$$
然后我们如果令：  
$$
f(T) = \prod_{k|T} fib(\frac{T}{k})^{\mu(k)}
$$
原来的式子就表示为：
$$
sum = \prod_{T=1}^n {f(T)}^{\lfloor\frac{n}{T}\rfloor\lfloor\frac{m}{T}\rfloor}
$$
$O(n\log n)$ 搞出来 $f$ 的取值，然后胡逼分块即可。

时间复杂度：$O(n \log n + T \sqrt n)$

## 代码

```cpp
#include <bits/stdc++.h>
#define ll long long
using namespace std;

const int MAXN = 1010000,mod = 1e9+7;

ll qpow(ll x,ll k){
  ll ans = 1;
  for(lli= k;i;i>>=1,x = (x*x)%mod) if(i & 1) ans = ans * x % mod;
  return ans;
}
int mu[MAXN],f[MAXN],fib[MAXN],inv[MAXN];
int sum[MAXN],sinv[MAXN];

void sieve(int n){
  // \sum_{d | n} \mu(d) = [n=1]
  // mu(n) = [n=1] - \sum_{d < n,d | n} mu(d)
  mu[1] = 1;
  for(inti= 1;i<=n;i++){
    for(intj= i+i;j<=n;j+=i) mu[j] -= mu[i];
  }
  for(inti= 0;i<=n;i++){f[i] = 1;}
  for(inti= 1;i<=n;i++){
    fib[i] = i==1? 1 : fib[i-1] + fib[i-2];
    if(fib[i] >= mod) fib[i] -= mod; 
    inv[i] = qpow(fib[i],mod-2);
    for(intj= i,k = 1;j<=n;j+=i,k++){
      f[j] = 1LL * f[j] * (mu[k] == 1?fib[i]:(mu[k]==0?1:inv[i])) % mod;
    }
  }
  sum[0] = sinv[0] = 1;
  for(inti= 1;i<=n;i++){
    sum[i] = 1LL * sum[i-1] * f[i] % mod;
    sinv[i] = 1LL * sinv[i-1] * qpow(f[i],mod-2) % mod;
  }
}


int calc(int n,int m){
  if(n > m) swap(n,m);
  int ans = 1;
  for(int l = 1,r;l<=n;l = r+1){
    r = min(n/(n/l),m/(m/l));
    int A = 1LL * sum[r] * sinv[l-1] % mod;
    int B = 1LL * (n/l) * (m/l) % (mod-1);
    // printf("l:%d A:%d B:%d\n",l,A,B);
    ans = 1LL * ans * qpow(A,B) % mod;
  }
  return ans;
}

signed main(){
  sieve(1000000);
  int T;
  scanf("%d",&T);
  for(inti= 1;i<=T;i++){
    int n,m;
    scanf("%d %d",&n,&m);
    printf("%d\n",calc(n,m));
  }
  return 0;
}
```

