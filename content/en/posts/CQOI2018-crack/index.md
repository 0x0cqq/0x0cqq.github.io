---
title: 「CQOI2018」破解D-H协议-BSGS算法
urlname: CQOI2018-crack
date: 2018-09-14 22:43:37
tags:
- 数学
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

简单题意：
 
给定一个质数 $P$ 和其原根 $g$，给定 $X$ 求 $g^x \equiv X \pmod p$ 的非负整数解 $x$。

<!--more-->

假定通讯双方名为 $\text{Alice}$ 和 $\text{Bob}$ ，协议的工作过程描述如下(其中 $\bmod$ 表示取模运算) :

1.  协议规定一个固定的质数 $P$ ，以及模 $P$ 的一个原根 $g$ 。 $P$ 和 $g$ 的数值都是公开的，无需保密。
    
2.   $\text{Alice}$ 生成一个随机数 $a$ ，并计算 $A=g^a \bmod P$, 将 $A$ 通过不安全信道发送给Bob。
    
3.  $\text{Bob}$ 生成一个随机数 $b$ ，并计算 $B=g^b \bmod P$ ，将 $B$ 通过不安全信道发送给 $\text{Alice}$ 。
    
4.  $\text{Bob}$ 根据收到的 $A$ 计算出 $K=A^b\bmod P$ ，而 Alice 根据收到的 $B$ 计算出$K=B^a\bmod P$。
    
5.  双方得到了相同的 $K$ 即  $g^{ab} \bmod P$。 $K$ 可以用于之后通讯的加密密钥。

可见，这个过程中可能被窃听的只有 $A,B$ ，而 $a,b,K$ 是保密的。并且根据 $A,B,P,g$ 这 $4$ 个数，不能轻易计算出 $K$ ，因此 $K$ 可以作为一个安全的密钥。

当然安全是相对的，该协议的安全性取决于数值的大小，通常 $a,b,P$ 都选取数百位以上的大整数以避免被破解。然而如果 $\text{Alice}$ 和 $\text{Bob}$ 编程时偷懒，为了避免实现大数运算，选择的数值都小于 $2^{31}$ ，那么破解他们的密钥就比较容易了。

## 链接

[Luogu P4454](https://www.luogu.org/problemnew/show/P4454)

## 题解

$\text{BSGS}$ 模版题，甚至连分类讨论都没有...

## 代码


```cpp
#include <cstdio>
#include <cmath>
#include <map>
#define ll long long
using namespace std;

ll gcd(ll a,ll b){
  return b==0?a:gcd(b,a%b);
}

ll pow(ll x,ll k,ll p){
  x %= p;
  ll ans = 1;
  for(ll i = k;i;i>>=1,x=x*x%p) if(i & 1) ans = ans * x % p;
  return ans;
}

ll bsgs(ll a,ll b,ll p){
  //printf("a:%lld b:%lld P:%lld\n",a,b,p);
  a %= p,b %= p;
  if(b == 1) return 0;
  ll cnt = 0,t = 1;
  for(ll g = gcd(a,p);g!=1;g = gcd(a,p)){
    if(b % g) return -1;
    a /= g,p /= g, t =  t * a/g % p;
    cnt++;
    if(t == b) return cnt; 
  }
  
  map<ll,ll> S;
  ll m = (ll)(sqrt(p)) + 1;
  ll base = b;
  for(ll i = 0;i<m;i++){
    S[base] = i;
    base = base * a % p;
  }
  ll now = t;
  base = pow(a,m,p);
  for(ll i = 1;i<=m+1;i++){
    now = now * base % p;
    if(S.count(now)){
      return i*m-S[now]+cnt;
    }
  }
  return -1;
}

ll n;
ll p,G;

ll cal(ll A,ll B){
  ll a = bsgs(G,A,p),b = bsgs(G,B,p);
  //printf("a:%lld b:%lld\n",a,b);
  return pow(G,a*b,p); 
}

void init(){
  scanf("%lld %lld",&G,&p);
}

void solve(){
  scanf("%lld",&n);
  for(int i = 1;i<=n;i++){
    ll a,b;
    scanf("%lld %lld",&a,&b);
    printf("%lld\n",cal(a,b));
  }
}

int main(){
  init();
  solve();
  return 0;
}
```


