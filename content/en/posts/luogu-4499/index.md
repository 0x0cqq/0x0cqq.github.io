---
title: 「Luogu4449」于神之怒加强版-数学
urlname: luogu-4499
date: 2019-03-30 12:05:02
tags:
- 数学
- 数论
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

给定 $n,m,k$ ，计算
$$
\sum_{i=1}^n\sum_{j=1}^m {\gcd(i,j)}^k
$$
对 $1000000007$ 取模的结果

<!--more-->

## 链接

[Luogu P4449](https://www.luogu.org/problemnew/show/P4449)

## 题解

我们来来来推推推式子吧qwq
$$
\sum_{i=1}^n\sum_{j=1}^m {\gcd(i,j)}^k
$$
不妨令 $n<m$ ，枚举 $\gcd(i,j) = d$ ：
$$
S = \sum_{d=1}^{n} d^k \sum_{i=1}^{\lfloor\frac{n}{d}\rfloor}\sum_{i=1}^{\lfloor\frac{m}{d}\rfloor} [(i,j)=1]\\
= \sum_{d=1}^{n} d^k \sum_{i=1}^{\lfloor\frac{n}{d}\rfloor}\sum_{i=1}^{\lfloor\frac{m}{d}\rfloor} \sum_{t | \gcd(i,j)} \mu(t)\\
= \sum_{d=1}^{n} d^k \sum_{t = 1}^{\lfloor\frac{n}{d}\rfloor} \mu(t)\sum_{i=1}^{\lfloor\frac{n}{dt}\rfloor}\sum_{i=1}^{\lfloor\frac{m}{dt}\rfloor} 1\\
= \sum_{d=1}^{n} d^k \sum_{t = 1}^{\lfloor\frac{n}{d}\rfloor} \mu(t) \lfloor\frac{n}{dt}\rfloor \lfloor\frac{m}{dt}\rfloor\\
$$
令 $dt = T$ ，我们有：
$$
S = \sum_{T=1}^{n} \lfloor\frac{n}{T}\rfloor \lfloor\frac{m}{T}\rfloor\sum_{d|T}d^k\mu(\frac{T}{d})
$$
我们令 $g(T) = \sum_{d|T}d^k\mu(\frac{T}{d})$，原式变为：
$$
S = \sum_{T=1}^{n} \lfloor\frac{n}{T}\rfloor \lfloor\frac{m}{T}\rfloor g(T)
$$
很明显这个可以整除分块，很明显 $g$ 是一个积性函数，所以我们考虑如何算出 $g$ 的前缀和。

发现 $n,m$ 的范围比较小，可以考虑用线性筛解决这个问题。

线性筛的本质是不断加入最小质因子，我们考虑一个质数的
$$
g(P^t) = \sum_{i=0}^t f(P^i) \mu (P^{t-i})
$$
凡是有平方因子的数都是的莫比乌斯函数值都是 $0$ ，所以这个式子化成：
$$
g(P^t) = \mu(1) f(P^t) + \mu(P)f(P^{t-1})\\
= f(P^t) - f(P^{t-1})
= P^{kt} - P^{k(t-1)}
= P^{k(t-1)}(P^{k}-1)
$$
可以注意到如果没有 $P$ 这个质因子，答案就是直接乘上 $P^k-1$ ，如果有就乘上 $P^k$ 即可。

这大概也是线性筛筛未知积性函数的套路：算出来 $g(P^t)$  并观察这个东西的性质，当然也可以记录最小质因子的大小。

时间复杂度： $O(n + T \sqrt n)$ 。

## 代码

```cpp
#include <bits/stdc++.h>
#define ll long long
using namespace std;

const int MAXN = 5100000,mod = 1e9+7;

ll pow(ll x,ll k, ll p){
  ll ans = 1;
  for(ll i = k;i;i>>=1,x = (x*x)%p) if(i&1) ans = ans * x % p;
  return ans;
}

int g[MAXN],s[MAXN];
int noprime[MAXN],prime[MAXN];

void sieve(int n,int k){
  g[1] = 1;
  for(int i = 2;i<=n;i++){
    if(!noprime[i]){
      prime[++prime[0]] = i,g[i] = pow(i,k,mod)-1;
      if(g[i] < 0) g[i] += mod;//容易出锅...
    }
    for(int j = 1;j <= prime[0] && i*prime[j] <= n;j++){
      noprime[i*prime[j]] = 1;
      if(i % prime[j] == 0){
        g[i*prime[j]] = 1LL * g[i] * (g[prime[j]]+1) % mod;
        break;
      }
      g[i*prime[j]] = 1LL * g[i] * g[prime[j]] % mod;
    }
  }
  for(int i = 1;i<=n;i++) {
    s[i] = s[i-1] + g[i];
    if(s[i] >= mod) s[i] -= mod;
  }
}

int calc(int n,int m){
  if(n > m) swap(n,m);
  int ans = 0;
  for(int l = 1,r;l <= n;l = r + 1){
    r = min(n/(n/l),m/(m/l));
    int tmp = (1LL * (n/l) * (m/l)) % mod; // 多加括号...
    int sum = s[r] - s[l-1];
    if(sum < 0) sum += mod;
    ans = (ans + 1LL * tmp * sum) % mod;
  }
  return ans;
}

int main(){
  int T,k;
  scanf("%d %d",&T,&k);
  sieve(5000000,k);
  for(int i = 1;i<=T;i++){
    int n,m;
    scanf("%d %d",&n,&m);
    printf("%d\n",calc(n,m));
  }
  return 0;
}
```

