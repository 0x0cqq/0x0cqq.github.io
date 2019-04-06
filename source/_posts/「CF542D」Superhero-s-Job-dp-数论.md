---
title: 「CF542D」Superhero's Job - dp + 数论
urlname: CF542D
date: 2019-03-02 12:17:18
tags:
- 动态规划
- 数学
categories: 
- OI
- 题解
visible:
---

我们定义 
$$
J(x) = \sum_{d | x} [\gcd(x,\frac{x}{d}) = 1] d
$$

请你求出 $J(x) = A$ 有多少个 $x$ 满足条件。

<!-- more -->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/542/D)

## 题解

我们可以发现，这个 $J(x)$ 是一个积性函数。

所以如果 $x = {p_1}^{k_1}{p_2}^{k_2}\cdots{p_m}^{k_m}$ ，那么 $J(x) = J({p_1}^{k_1})J({p_2}^{k_2})\cdots J({p_m}^{k_m}) = ({p_1}^{k_1}+1)({p_2}^{k_2}+1)({p_m}^{k_m}+1)$

所以问题变成了我们有多少种对 $A$ 形如上面形式的不同分解。

我们考虑求出所有 $A$ 的约数，记为 $d_1,d_2,...,d_n$ 。我们考虑哪些 $p$ 可能用来组成 $A$ 。如果 $p$ 可以被用来组成 $A$ ，那么 $A$ 的约数里面肯定存在一个约数减去 $1$ 之后是 $p$ 的若干次方。

我们把所有的约数减去 $1$ 之后直接分解质因数，这个过程的复杂度大概是：

$$
\sqrt 1 + \sqrt 2 + ... + \sqrt{\sqrt{n}}  + \sqrt \frac{n}{1} + \sqrt{\frac{n}{2}} + ... + \sqrt{\frac{n}{n}}
$$

不会证明，但可以过吧（

然后我们就得到了所有可以组成 A 的质数 $p_1,...,p_k$，这样的质数不会很多，我们发现这样的质数不会超过 $\sigma_0(n) \approx \sqrt[3]{n}$ 。

我们考虑 $dp$ , 令 $dp[i][j]$ 表示使用前 $i$ 个质数拼出来第 $j$ 个约数的方案数。

转移的话，每次加入一个质数，对于所有的 $j$，我们都乘上这个质数若干次，然后更新答案。什么？你说复杂度？不会证不会证，反正能过就行（

最后 $dp[k][n]$ 就是答案。

## 代码


```cpp
#include <bits/stdc++.h>
#define ll long long
using namespace std;

const int MAXN = 10000;

ll A;
ll p[MAXN],k,d[MAXN],n;
map<ll,int> div_pos;set<ll> vis;
ll dp[MAXN];// 滚动数组

int main(){
  cin >> A;
  for(ll i = 1;i*i<=A;i++) if(A % i == 0){
    d[++n] = i;
    if(i * i != A) d[++n] = A/i;
  }
  sort(d + 1,d + n + 1);
  // for(int i = 1;i<=n;i++){
  //   printf("%d:%lld\n",i,d[i]);
  // }
  for(int t = 1;t<=n;t++){
    ll x = d[t]; div_pos[x] = t;x -= 1;
    bool flag = 0;
    for(ll i = 2;i * i <= x;i++){
      if(x % i == 0){
        flag = 1;
        while(x % i == 0) x /= i;
        if(x == 1 && !vis.count(i)) p[++k] = i,vis.insert(i);
        break;
      }
    }
    if(flag == 0 && x > 1 && !vis.count(x)) p[++k] = x,vis.insert(x);
  }
  sort(p+1,p+k+1);
  dp[1] = 1;
  for(int i = 1;i<=k;i++){
    for(int j = n;j>=1;j--){
      if(dp[j] == 0) continue;
      for(ll w = p[i];log2(d[j]) + log2(w+1) <= log2(1.5*A);w *= p[i]){
        if(div_pos.count(d[j]*(w+1))){
          dp[div_pos[d[j]*(w+1)]] += dp[j];
        }
      }
    }
  }
  printf("%lld\n",dp[n]);
  return 0;
}
```

