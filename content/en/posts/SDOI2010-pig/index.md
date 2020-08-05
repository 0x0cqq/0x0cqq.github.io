---
title: 「SDOI2010」古代猪文-Lucas+CRT
urlname: SDOI2010-pig
date: 2018-10-23 22:58:36
tags:
- 中国剩余定理
- Lucas定理
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

猪王国的文明源远流长，博大精深。

<!--more-->

iPig 在大肥猪学校图书馆中查阅资料，得知远古时期猪文文字总个数为 $N$ 。当然，一种语言如果字数很多，字典也相应会很大。当时的猪王国国王考虑到如果修一本字典，规模有可能远远超过康熙字典，花费的猪力、物力将难以估量。故考虑再三没有进行这一项劳猪伤财之举。当然，猪王国的文字后来随着历史变迁逐渐进行了简化，去掉了一些不常用的字。

iPig 打算研究古时某个朝代的猪文文字。根据相关文献记载，那个朝代流传的猪文文字恰好为远古时期的 $k$ 分之一，其中 $k$ 是 $N$ 的一个正约数（可以是 $1$ 和 $N$ ）。不过具体是哪 $k$ 分之一，以及 $k$ 是多少，由于历史过于久远，已经无从考证了。

iPig觉得只要符合文献，每一种能整除 $N$ 的 $k$ 都是有可能的。他打算考虑到所有可能的 $k$ 。显然当 $k$ 等于某个定值时，该朝的猪文文字个数为 $\frac{N}{k}$。然而从 $N$ 个文字中保留下 $\frac{N}{k}$ 个的情况也是相当多的。iPig预计，如果所有可能的 $k$ 的所有情况数加起来为 $P$ 的话，那么他研究古代文字的代价将会是 $G$ 的 $P$ 次方。
 
现在他想知道猪王国研究古代文字的代价是多少。由于iPig觉得这个数字可能是天文数字，所以你只需要告诉他答案除以999911659的余数就可以了。

## 链接

## 题解

依据题意推出式子

$$
t = \sum_{k|N} C^{k}_{N}\\
ans = G^t
$$

我们有指数的一个性质

$$
a ^ b \equiv a ^ {b\ \bmod\ p-1} \pmod p
$$

也就是指数的循环节是 $p-1$ 。


所以我们只需要

$$
ans = G^t = G^{t\ \bmod\ (p-1)} \pmod p
$$

所以我们只需要算出 $t \bmod p-1$ 即可。

我们注意到 $p-1 = 999911659-1 = 2 \times 3 \times 4679 \times 35617$ ，分别 $Lucas$ 再 $CRT$ 合并即可。

事实上我们可以只做一次 $CRT$ ，即我们每次都算出在模某数意义下的 $t$ ，最后合并一次即可。 

还要特判 $G = P$ 的情况。

时间复杂度大约是 $O(\sqrt n \times \log n )$ 。

## 代码


```cpp
#include <cstdio>
#include <cmath>
#include <cstdlib>
#define ll long long
using namespace std;

const ll P = 999911659;

const int MAXN = 100000;

ll pow(ll x,ll k,ll p){
    ll ans = 1;
    for(ll i = k;i;i>>=1,x = x*x%p) if(i & 1) ans = (ans * x) % p;
    return ans;
}
ll inv(ll x,ll p){return pow(x,p-2,p);}
ll mod[5] = {2,3,4679,35617},pw[MAXN];

void init(ll p){
    pw[0] = 1;
    for(int i = 1;i<p;i++)
        pw[i]= pw[i-1] * i % p;
}


ll c(ll n,ll m,ll p){//C_n^m mod mod[num]
    if(m > n) return 0;
    return (pw[n] * inv(pw[m],p) % p) * inv(pw[n-m],p) % p;
}
ll lucas(ll n,ll m,ll p){
    if(!m) return 1;
    return c(n%p,m%p,p) * lucas(n/p,m/p,p) % p;
}

ll N,G,ans[5];

ll CRT(){
    ll sum = 0;
    for(int i = 0;i<4;i++){
        ll now = (P-1)/mod[i];
        sum = sum + ans[i] * now * inv(now,mod[i]);
        sum %= (P-1);
    }
    return sum;
}

ll solve(){
    for(int num = 0;num<4;num++){
        ll p = mod[num],q = sqrt(N);
        init(p);
        ans[num] = 0;
        for(int i = 1;i<=q;i++){
            if(N % i != 0) continue;
            ans[num] = ans[num] + lucas(N,i,p);
            if(i * i == N) continue;
            ans[num] = ans[num] + lucas(N,N/i,p);
            ans[num] %= p;
        }
    }
    return CRT();
}

int main(){
    scanf("%lld %lld",&N,&G);
    if(G == P)
        printf("%d\n",0);
    else
        printf("%lld\n",pow(G,solve(),P));
    return 0;
}
```

