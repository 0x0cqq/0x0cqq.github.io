---
title: 「SDOI2014」数表-数论
urlname: SDOI2014-table
date: 2019-04-06 20:06:54
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

有一张 $n \times m$ 的数表，其第 $i$ 行第 $j$ 列（ $1 \le i \le n$， $1 \le j \le m$ ）的数值为能同时整除 $i$ 和 $j$ 的所有自然数之和。给定 $a$ ，计算数表中不大于 $a$ 的数之和。

<!--more-->

$1 \le n,m \le 10^5$ ， $1 \le Q \le 2 \times 10^4$ 


## 链接

[Luogu P3312](https://www.luogu.org/problemnew/show/P3312)

## 题解

我们把这个东西写成公式：
$$
\sum _ {i=1}^n \sum _ {j = 1}^m (\sum _ {d|\gcd(i,j)} d)[\sum _ {d|\gcd(i,j)} d \le a]
$$
不妨令 $n < m$ ，推推式子...
$$
\sum _ {d=1}^{n} (\sum _ {k|d} k)[\sum _ {k|d} k \le a] \sum _ {i=1}^{\lfloor \frac{n}{d} \rfloor} \sum _ {j=1}^{\lfloor \frac{m}{d} \rfloor} [\gcd(i,j) = 1]
$$
我们令 
$$
\sigma_1(n) = \sum _ {d|n} d
$$
这是一个积性函数。

------

那么就是 
$$
\sum _ {d=1}^{n} \sigma_1(d)[\sigma_1(d) \le a] \sum _ {i=1}^{\lfloor \frac{n}{d} \rfloor} \sum _ {j=1}^{\lfloor \frac{m}{d} \rfloor} [\gcd(i,j) = 1]
$$
我们知道：
$$
\sum _ {i=1}^{n} \sum _ {j=1}^{m} [\gcd(i,j) = 1]\\
= \sum _ {i=1}^{n} \sum _ {j=1}^{m} \sum _ {k | \gcd(i,j)} \mu(k)\\
= \sum _ {k = 1}^n \mu(k) \lfloor \frac{n}{k}\rfloor \lfloor \frac{m}{k}\rfloor
$$
那么代入就是：
$$
\sum _ {d=1}^{n} \sigma_1(d)[\sigma_1(d) \le a] \sum _ {k = 1}^{\lfloor \frac{n}{d} \rfloor} \mu(k) \lfloor \frac{n}{dk}\rfloor \lfloor \frac{m}{dk}\rfloor
$$
我们设 $T = dk$ ，就有：
$$
\sum _ {T = 1}^n \lfloor \frac{n}{T}\rfloor \lfloor \frac{m}{T}\rfloor \sum _ {d | T} [\sigma_1(d) \le a]\sigma_1(d)  \mu(\frac{T}{d})
$$
令 
$$
f(T) = \sum _ {d|T} \sigma_1(d)[\sigma_1(d) \le a]\mu(\frac{T}{d})
$$
式子就变成：
$$
\sum _ {T = 1}^n \lfloor \frac{n}{T}\rfloor \lfloor \frac{m}{T}\rfloor f(T)
$$
我们只要能获得 $f(T)$ 的前缀和，我们就能 $O(\sqrt n)$ 出解了。

那么我们怎么对不同的 $a$ 维护这个玩意呢？

我们考虑把 $a$ 从小到大排序，然后我们只需要处理出改变的 $f$，用一个东西维护前缀和即可。

我们考虑到加入一个 $\sigma_0(x) = a+1$ 的 $a$ 会对 $f$  产生什么影响。有且仅有 $x$ 的倍数会有更改，所以我们直接暴力枚举所有倍数，然后加入到f的前缀和的贡献当中就可以了。因为 $\frac{n}{1} + \frac{n}{2} + \cdots + \frac{n}{n} = O(n \log n) $ ，所以最后的复杂度就是 $O(n \log n + n \log^2 n + q \sqrt n \log n)$   

## 代码

```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 110000;

int N = 110000,T;
int sig[MAXN],prime[MAXN],mu[MAXN],vis[MAXN],ans[MAXN];

void sieve(int n){
  mu[1] = 1;
  for(int i = 2;i<=n;i++){
    if(!vis[i]){
      prime[++prime[0]] = i;
      mu[i] = -1;
    }
    for(int j = 1;j <= prime[0] && i * prime[j] <= n;j++){
      vis[i*prime[j]] = 1;
      if(i % prime[j] == 0){
        mu[i*prime[j]] = 0;
        break;
      }
      else mu[i*prime[j]] = -mu[i];
    }
  }
  for(int i = 1;i<=n;i++) for(int j = i;j<=n;j+=i) 
    sig[j] += i;
}

struct Node{
  int id,n,m,a;
}q[MAXN];

bool cmp1(const Node &x,const Node &y){return x.a < y.a;}
bool cmp2(const int &a,const int &b){return sig[a] < sig[b];}

namespace BIT{// 维护 f 的前缀和 
  int sumn[MAXN],n;
  void init(int _n){n = _n;}
  int lowbit(int x){return x & (-x);}
  int query(int x){
    int ans = 0;
    while(x >= 1) ans += sumn[x],x -= lowbit(x);
    return ans;
  }
  void modify(int x,int v){
    while(x <= n) sumn[x] += v,x += lowbit(x);
  }
}

void update(int x){
  for(int i = 1;i * x <= N;i++) BIT::modify(i*x,sig[x] * mu[i]);
}

int calc(int n,int m){
  int ans = 0;
  if(n > m) swap(n,m);
  for(int l = 1,r;l<=n;l = r+1){
    r = min(n/(n/l),m/(m/l));
    ans = ans + (n/l) * (m/l) * (BIT::query(r) - BIT::query(l-1));
  }
  return ans;
}


int main(){
  sieve(N),BIT::init(N);

  scanf("%d",&T);
  for(int i = 1;i<=T;i++){
    int a,b,c;
    scanf("%d %d %d",&a,&b,&c);
    q[i] = (Node){i,a,b,c};
  }
  sort(q+1,q+T+1,cmp1);

  static int t[MAXN];
  for(int i = 1;i<=N;i++) t[i] = i;
  sort(t+1,t+N+1,cmp2);
  
  int now = 1;
  for(int i = 1;i<=T;i++){
    while(t[now] <= N && sig[t[now]] <= q[i].a) update(t[now]),now++;
    ans[q[i].id] = calc(q[i].n,q[i].m);
  }
  for(int i = 1;i<=T;i++) printf("%d\n",ans[i] & 2147483647);
  return 0;
}
```

