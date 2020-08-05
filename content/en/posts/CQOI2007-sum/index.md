---
title: 「CQOI2007」余数求和-数论+分块
urlname: CQOI2007-sum
date: 2018-09-15 22:24:04
tags:
- 数学
- 分块
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


给出正整数 $n$ 和 $k$ ，计算
$$
\sum_{i=1}^{n} k \bmod i
$$

<!--more-->
## 链接

[Luogu P2261](https://www.luogu.org/problemnew/show/P2261)

## 题解

推一发式子：

$$
\sum_{i=1}^{n} k \bmod i\\
= \sum_{i=1}^{n} k - \lfloor \frac{k}{i} \rfloor \cdot i\\
= n k - \sum_{i=1}^{n} \lfloor \frac{k}{i} \rfloor \cdot i\\
$$

那么，问题就变成我们要求出下式的值：

$$
\sum_{i=1}^{n} \lfloor \frac{k}{i} \rfloor \cdot i
$$

我们发现，这个式子当 $i > k$ 时没啥意义，所以化成：

$$
\sum_{i=1}^{\min(n,k)} \lfloor \frac{k}{i} \rfloor \cdot i
$$

我们注意到 $\lfloor \frac{k}{i} \rfloor$ 最多只有 $2\sqrt{n}$ 种取值，所以可以进行数论分块，对于相同的一段取值，我们计算出这段里面的 $\sum i$ ，就可以在 $O(\sqrt{\min(n,k)})$ 的时间内计算出结果了。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#define ll long long
using namespace std;

ll n,k;

void init(){
  scanf("%lld %lld",&n,&k);
}

void solve(){
  ll ans = n*k;
  for(ll l = 1,r;l <= n && l <= k;l = r+1){
    r = min((k/(k/l)),n);
    ans -= (k/l) * (r+l)*(r-l+1)/2;
  }
  printf("%lld\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```

