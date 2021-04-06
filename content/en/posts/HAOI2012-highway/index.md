---
title: 「HAOI2012」高速公路-期望+线段树
urlname: HAOI2012-highway
date: 2018-07-19 20:06:36
tags:
- 线段树
- 数学
- 期望
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

`Y901` 高速公路是一条由 $N-1$ 段路以及 $N$ 个收费站组成的东西向的链，我们按照由西向东的顺序将收费站依次编号为 $1 \sim N$ ，从收费站 $i$ 行驶到 $i+1$ (或从 $i+1$ 行驶到 $i$ )需要收取 $V_i$ 的费用。高速路刚建成时所有的路段都是免费的。

政府部门根据实际情况，会不定期地对连续路段的收费标准进行调整，根据政策涨价或降价。

求对于给定的 $l,r(l < r)$ ，在第 $l$ 个到第 $r$ 个收费站里等概率随机取出两个不同的收费站 $a$ 和 $b$ ，那么从 $a$ 行驶到 $b$ 将期望花费多少费用呢?

<!--more-->

## 链接

[Luogu P2221](https://www.luogu.org/problemnew/show/P2221)

## 题解

位于某个位置的边只会被两个端点分居两边的路径经过，所以我们就可以暴力推式子qwq：

$$
\begin{aligned}{}
E(l,r) &= \frac{1}{(r-l-1)(r-l)}\sum _ {i = l}^{r-1}(i-l+1)(r-i)V_i\\
&= \frac{1}{(r-l-1)(r-l)}\sum _ {i = l}^{r-1}[-i^2 V_i-(l+r-1)i V_i - r(l-1)V_i]
\end{aligned}
$$

所以需要记录的只有三个东西：$\sum V_i , \sum i V_i , \sum i^2 V_i$。

这三个东西都是可以用线段树维护的（就是 O(1) 完成打标记和标记下放）。

具体方法看代码吧。

> 披着期望外衣的线段树题。

## 代码


```cpp
#include <bits/stdc++.h>
#define gcd __gcd
#define ll long long
using namespace std;

const int MAXN = 110000;

namespace SegTree{
    //0->sigma(V_i),1->sigma(i*V_i),2->sigma(i^2*V_i)
    struct node{
        ll sum[3];
        node(ll _a = 0,ll _b = 0,ll _c = 0){
            sum[0] = _a,sum[1] = _b,sum[2] = _c;
        }
        node operator + (const node &a)const{
            node newnode;
            newnode.sum[0] = sum[0] + a.sum[0];
            newnode.sum[1] = sum[1] + a.sum[1];
            newnode.sum[2] = sum[2] + a.sum[2];
            return newnode;
        }
    }sumn[MAXN<<2];
    ll tag[MAXN<<2];
    #define lson (nown<<1)
    #define rson (nown<<1|1)
    #define mid ((l+r)>>1)
    inline ll cal(int n){
        return 1LL*n*(n+1)*(2*n+1)/6;
    }
    inline void addtag(int nown,int l,int r,ll v){
        tag[nown] += v;
        static node tmp;
        tmp = node(v*(r-l+1),v*(l+r)*(r-l+1)/2,v*(cal(r)-cal(l-1)));
        sumn[nown] = sumn[nown] + tmp;
    }
    inline void push_down(int nown,int l,int r){
        if(tag[nown]){
            addtag(lson,l,mid,tag[nown]),addtag(rson,mid+1,r,tag[nown]);
            tag[nown] = 0;
        }
    }
    inline void push_up(int nown){
        sumn[nown] = sumn[lson] + sumn[rson];
    }
    inline void update(int nown,int l,int r,int ql,int qr,int v){
        if(ql <= l && r <= qr)
            addtag(nown,l,r,v);
        else{
            push_down(nown,l,r);
            if(ql <= mid) update(lson,l,mid,ql,qr,v);
            if(qr >= mid+1) update(rson,mid+1,r,ql,qr,v);
            push_up(nown);
        }
    }
    inline node query(int nown,int l,int r,int ql,int qr){
        if(ql <= l && r <= qr)
            return sumn[nown];
        else{
            push_down(nown,l,r);
            node ans;
            if(ql <= mid) ans = ans + query(lson,l,mid,ql,qr);
            if(qr >= mid+1) ans = ans + query(rson,mid+1,r,ql,qr);
            return ans;
        }
    }
}

int n,m;

void update(int l,int r,int v){
    SegTree::update(1,1,n,l,r-1,v);
}

void query(int l,int r,ll &x,ll &y){
    SegTree::node tmp = SegTree::query(1,1,n,l,r-1);
    x = -1LL*r*(l-1)*tmp.sum[0] + 1LL * (r+l-1)*(tmp.sum[1]) - tmp.sum[2];
    y = 1LL*(r-l+1)*(r-l)/2;
    ll d = gcd(x,y);
    x/=d,y/=d;
} 

void init(){
    scanf("%d %d",&n,&m);
}

void solve(){
    ll x, y;
    for(int i = 1;i<=m;i++){
        char op[10];int l,r,c;
        scanf("%s %d %d",op,&l,&r);
        if(op[0] == 'C')
            scanf("%d",&c),update(l,r,c);
        else
            query(l,r,x,y),printf("%lld/%lld\n",x,y);
    }
}

int main(){
    init();
    solve();
    return 0;
}
```



