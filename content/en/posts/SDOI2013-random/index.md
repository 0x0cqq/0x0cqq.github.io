---
title: 「SDOI2013」随机数生成器-BSGS算法
urlname: SDOI2013-random
date: 2018-09-11 20:54:20
tags:
- 数论
- BSGS算法
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

小 $W$ 喜欢读书，尤其喜欢读《约翰克里斯朵夫》。最近小W准备读一本新书，这本书一共有 $P$ 页，页码范围为 $0 ... P-1$。

小 $W$ 很忙，所以每天只能读一页书。为了使事情有趣一些，他打算使用 $\text{NOI2012}$ 上学习的线性同余法生成一个序列，来决定每天具体读哪一页。

我们用 $X_i$ 来表示通过这种方法生成出来的第 $i$ 个数，也即小 $W$ 第 $i$ 天会读哪一页。这个方法需要设置 $3$ 个参数 $a,b,X_1$ ，满足 $0 \leq a,b,X_1 \leq p-1$ ，且 $a,b,X_1$ 都是整数。按照下面的公式生成出来一系列的整数：$X_{i+1} =(aX_i+b)\bmod p$ 其中 $\bmod$ 表示取余操作。

但是这种方法可能导致某两天读的页码一样。

小 $W$ 要读这本书的第 $t$ 页，所以他想知道最早在哪一天能读到第 $t$ 页，或者指出他永远不会读到第 $t$ 页。

<!--more-->

## 链接

[Luogu P3306](https://www.luogu.org/problemnew/show/P3306)

## 题解

先忽略模数，求 $X_n$ 的通项公式。

刚学的高中数学必修五，我们可以知道，这个函数可以变形成类等比数列。

因为 $a,b$ 都是常数，所以我们可以设：

$$
X_{i+1} + \lambda= a(X_i + \lambda)\\
X_{i+1} = aX_i + \lambda(a-1)\\
$$
所以：

$$
\lambda(a-1) = b\\
\lambda = \frac{b}{a-1}
$$

设 $Y_i = X_i+\lambda$ ，则有：
$$
Y_{i+1} = a Y_i
$$

又 $Y_1 = X_1 + \lambda$，所以得到 $Y_i$ 的通项公式：

$$
Y_i = (X_1+\lambda) \times a^{i-1}
$$

则：

$$
X_i = Y_i - \lambda  = (X_1+\lambda) \times a^{i-1} - \lambda
$$

那么问题就转换成求：

$$
(X_1+\lambda) \times a^{i-1} - \lambda \equiv t \pmod p
$$

的最小正整数解 $i$。
- - -
如果我们用 $x$ 代表 $i-1$，那么就变成求：

$$
 a^{x} \equiv (t + \lambda) \times (X_1+\lambda)^{-1} \pmod p
$$
然后这里的 $\lambda = b \times a^{-1}$ 。

如果令 $A = a, B =  (t + \lambda) \times (X_1+\lambda)^{-1}$ ，那么这个式子就变成了 $\text{BSGS}$ 的标准式：

$$
A^x \equiv B \pmod p
$$
套用 $\text{BSGS}$ 算法解出 $x$，$x+1$ 即是答案。

注意处理无解和特殊情况。

当 $a = 1$ 时，这个东西不再能化成类等比数列，就是一个类等差数列，用逆元求解即可。

## 代码


```cpp
#include <cstdio>
#include <cmath>
#include <algorithm>
#include <map>
#define ll long long
using namespace std;

ll pow(ll x,ll k,ll p){
  x %= p;
  ll ans = 1;
  for(ll i = k;i;i>>=1,x=x*x%p) if(i&1) ans = ans*x%p;
  return ans;
}

ll inv(ll x,ll p){
  return pow(x%p,p-2,p);
}

ll gcd(ll a,ll b){
  return b == 0?a:gcd(b,a%b);
}

ll bsgs(ll a,ll b,ll p){
  //printf("bsgs a:%lld b:%lld p:%lld\n",a,b,p);
  a %= p,b %= p;
  ll t = 1,cnt = 0;
  if(b == 1) return 0;
  for(ll g = gcd(a,p);g != 1;g = gcd(a,p)){
    if(b % g) return -2;
    a /= g,p /= g,t = t * a/g % p;
    ++cnt;
    if(b == t) return cnt; 
  }
  map<ll,ll> S;
  ll m = (ll)(sqrt(p)) + 1;
  ll base = b;
  for(int i = 0;i<m;i++){
    S[base] = i;
    base = base * a % p;
  }
  base = pow(a,m,p);
  ll now = t;
  for(int i = 1;i<=m+1;i++){
    now = now * base % p; 
    if(S.count(now))
      return i * m - S[now] + cnt;
  }
  return -2;
}

ll cal(ll p,ll a,ll b,ll x_1,ll t){
  if(x_1 == t) return 1;
  if(a == 0){
    if(x_1==t) return 1;
    else if(b==t) return 2;
    else return -1;
  }
  if(a == 1){
    //X_i = X_1 + (n-1) * b
    if(b == 0){
      if(x_1 == t) return 1;
      else return -1;
    }
    else{
      return (((t-x_1+p)%p) * inv(b,p) % p)%p + 1;
    }
  }
  else{
    ll lam = b * inv(a-1,p);
    ll A = a, B = ((t + lam)%p) * inv(x_1+lam,p) % p;
    return bsgs(A,B,p)+1;
  }
}

void solve(){
  ll p,a,b,x_1,t;
  scanf("%lld %lld %lld %lld %lld",&p,&a,&b,&x_1,&t);
  printf("%lld\n",cal(p,a,b,x_1,t));
}


int main(){
  int T;
  scanf("%d",&T);
  for(int i = 1;i<=T;i++){
    solve();
  }
  return 0;
}
```



