---
title: 「Luogu3768」简单的数学题-杜教筛
urlname: Luogu3768-simplemath
date: 2018-12-20 21:15:12
tags:
- 数论
- 数论函数
- 杜教筛
categories: 
- OI
- 题解
series:
- Luogu
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

求
$$
\sum_{i=1}^n\sum_{j=1}^n ij\gcd(i,j))~mod~p
$$
其中 $n < 10^{10}$。

<!--more-->


## 题解

$$
ans =\sum_{i=1}^n\sum_{j=1}^n ij\gcd(i,j))~mod~p\\
=\sum_{d=1}^n d\sum_{i=1}^{\lfloor\frac{n}{d}\rfloor}\sum_{j=1}^{\lfloor\frac{n}{d}\rfloor}ijd^2[\gcd(i,j) == 1]\\
=\sum_{d=1}^n d^3 \sum_{i=1}^{\lfloor\frac{n}{d}\rfloor}\sum_{j=1}^{\lfloor\frac{n}{d}\rfloor}ij[\gcd(i,j) == 1]\\
$$

如果我们令

$$
f(d) = \sum_{i=1}^{n}\sum_{j=1}^{n}ij[\gcd(i,j) == d]\\
g(d) = \sum_{d|k} f(k) = d^2\sum_{i=1}^{\lfloor\frac{n}{d}\rfloor}\sum_{j=1}^{\lfloor\frac{n}{d}\rfloor} ij\\
g(d) = d^2{\left[\frac{\lfloor\frac{n}{d}\rfloor(\lfloor\frac{n}{d}\rfloor + 1)}{2}\right]}^2
$$

令 $sum(x) = \frac{x(x+1)}{2}$，原式化为：

$$
g(d) = d^2 \cdot sum(\lfloor\frac{n}{d}\rfloor)^2
$$

就有：

$$
f(d) = \sum_{d|k} \mu(k) g(\frac{k}{d})\\
f(1) = \sum_{i=1}^n \mu (i) g(i)\\
f(1) = \sum_{i=1}^n \mu (i) i^2 sum(\lfloor\frac{n}{i}\rfloor)^2
$$

那么：

$$
ans = \sum_{d=1}^n d^3 \sum_{i=1}^{\lfloor\frac{n}{d}\rfloor} \mu (i) i^2 sum(\lfloor\frac{n}{di}\rfloor)^2
$$

枚举 $id = T$，则有

$$
ans = \sum_{T = 1}^n sum(\lfloor\frac{n}{T}\rfloor)^2 \sum_{d|T} d^3 \mu(\frac{T}{d}) \times {(\frac{T}{d})}^2\\
= \sum_{T=1}^n T^2 sum(\lfloor\frac{n}{T}\rfloor)^2 \sum_{d|T} d \mu(\frac{T}{d}) \\
$$

有 $id*\mu = \varphi$ ， 所以

$$
ans = \sum_{T=1}^n sum(\lfloor\frac{n}{T}\rfloor)^2 T^2 \varphi(T) \\
$$

令 $f(x) = x^2 \varphi(x)$，我们就有
$$
ans = \sum_{T=1}^n sum(\lfloor\frac{n}{T}\rfloor)^2 f(T)
$$

注意到 $\lfloor\frac{n}{T}\rfloor$  只有根号个取值，所以我们想要处理出 $f(T)$ 的前缀和。


杜教筛：

$$
S(n) = \sum_{i=1}^{n} h(i) - \sum_{d = 2}^{n} g(d)S(\lfloor \frac{n}{d} \rfloor)
$$

如果我们令 $g(n) = n^2$ ，那么 

$$
h(i) = (g*f)(i)=\sum_{d|i}f(d)g(\frac{i}{d})=\sum_{d|i}d^2\varphi(d){(\frac{i}{d})}^2\\
= \sum_{d|i}\varphi(d)i^2 = i^3\\
$$

又因为 
$$
\sum_{i=1}^n i^3 = \left[\frac{n(n+1)}{2}\right]^2
$$

所以我们就有

$$
S(n) = \sum_{i=1}^{n} h(i) - \sum_{d = 2}^{n} g(d)S(\lfloor \frac{n}{d} \rfloor)\\
= \left[\frac{n(n+1)}{2}\right]^2 - \sum_{d = 2}^{n} d^2S(\lfloor \frac{n}{d} \rfloor)\\
$$


综上：

$$
ans = \sum_{T=1}^n sum(\lfloor\frac{n}{T}\rfloor)^2 f(T)\\
S(n) = \left[\frac{n(n+1)}{2}\right]^2 - \sum_{d = 2}^{n} d^2S(\lfloor \frac{n}{d} \rfloor)\\
$$


代码实现一定要多取模...

## 代码


```cpp
#include <bits/stdc++.h>
#define ll long long
using namespace std;

const int MAXN = 8500000;

ll pow(ll x,ll k,ll p){
  ll ans = 1;
  for(ll i = k;i;i>>=1,x = (x*x)%p) if(i & 1) ans = (ans*x)%p;
  return ans;
}

ll inv(ll x,ll p){return pow(x,p-2,p);}

ll p,n,rev_6,rev_2;
map<ll,ll> s;
ll pre_s[MAXN];

void sieve(){
  static ll prime[MAXN],phi[MAXN],cnt = 0;
  static int vis[MAXN];
  phi[1] = 1;
  for(int i = 2;i<=MAXN-1;i++){
    if(vis[i] == 0){
      prime[++cnt] = i;
      phi[i] = i-1;
    }
    for(int j = 1;i * prime[j] <= MAXN-1 && j<=cnt;j++){
      vis[i*prime[j]] = 1;
      if(i % prime[j] == 0){
        phi[i*prime[j]] = phi[i] * (prime[j]);
        break;
      }
      else{
        phi[i*prime[j]] = phi[i] * (prime[j]-1);
      }
    }
  }
  for(int i = 1;i<=MAXN-1;i++){
    pre_s[i] = phi[i]%p * i % p * i % p;
    pre_s[i] += pre_s[i-1];
    pre_s[i] %= p;
  }
}

ll sum(ll x){x%=p;return x%p *(x+1)%p *rev_2%p;}
ll sums(ll x){x%=p;return x%p *(x+1)%p *(x+x+1)%p *rev_6%p;}

ll S(ll n){
  if(n < MAXN) return pre_s[n];
  if(s.count(n))return s[n];
  ll ans = sum(n)%p;
  ans = ans*ans%p;
  for(ll l = 2,r;l <= n;l = r+1){
    r = (n/(n/l));
    ans -= S(n/l)%p * (sums(r) - sums(l-1)+p)%p;
    ans = ans % p;
  }
  return s[n] = ans % p;
}

void init(){
  scanf("%lld %lld",&p,&n);
  rev_6 = inv(6,p),rev_2 = inv(2,p);
}

ll calc(ll n){
  ll ans = 0;
  for(ll l = 1,r;l <= n;l = r+1){
    r = (n/(n/l));
    ll tmp = (S(r) - S(l-1) + p) % p;
    ll summ = sum(n/l) %p;
    ans += summ%p * summ%p * tmp%p;
    ans %= p;
  }
  return ans;
}

int main(){
  init();
  sieve();
  printf("%lld\n",calc(n));
  return 0;
}
```

