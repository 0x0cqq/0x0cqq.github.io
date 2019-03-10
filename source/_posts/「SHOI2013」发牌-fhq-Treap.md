---
title: 「SHOI2013」发牌-fhq Treap
urlname: SHOI2013-card
date: 2018-10-15 21:59:15
tags:
- 题解
- 数据结构
- 平衡树
- Treap
categories: OI
visible:
---

在一些扑克游戏里，如德州扑克，发牌是有讲究的。一般称呼专业的发牌手为荷官。荷官在发牌前，先要销牌。所谓销牌，就是把当前在牌库顶的那一张牌移动到牌库底，它用来防止玩家猜牌而影响游戏。

假设一开始，荷官拿出了一副新牌，这副牌有 $N$ 张不同的牌，编号依次为 $1$ 到 $N$ 。由于是新牌，所以牌是按照顺序排好的，从牌库顶开始，依次为 $1, 2, \dots$ 直到$N$ ，$N$ 号牌在牌库底。为了发完所有的牌，荷官会进行$N$ 次发牌操作，在第 $i$ 次发牌之前，他会连续进行 $R_i$ 次销牌操作， $R_i$ 由输入给定。请问最后玩家拿到这副牌的顺序是什么样的？

<!-- more -->

## 链接

[Luogu P3988](https://www.luogu.org/problemnew/show/P3988)

## 题解

$\text{fhq Treap}$  模拟即可。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 800000;

namespace treap{
    int val[MAXN],fhq[MAXN],siz[MAXN],c[MAXN][2];
    int cnt,root;
    void push_up(int x){
        if(!x) return;
        siz[x] = siz[c[x][0]] + siz[c[x][1]] + 1;
    }
    int newnode(int v){
        int x = ++cnt;
        val[x] = v;fhq[x] = rand();
        push_up(x);
        return x;
    }
    void split(int x,int k,int &l,int &r){
        if(!x){
            l = r = 0;
            return;
        }
        if(siz[c[x][0]] + 1 <= k)
            l = x,split(c[x][1],k-siz[c[x][0]]-1,c[l][1],r);
        else
            r = x,split(c[x][0],k,l,c[r][0]);
        push_up(l),push_up(r);
    }
    int merge(int l,int r){//小根堆 
        if(l == 0 || r == 0)
            return l+r;
        int x;
        if(fhq[l] <= fhq[r]){
            x = l,c[x][1] = merge(c[l][1],r);	 
        }
        else{
            x = r,c[x][0] = merge(l,c[r][0]);
        }
        push_up(x);
        return x;
    }
    void build(int n){
        for(int i = 1;i<=n;i++){
            root = merge(root,newnode(i));
        }
    }
    int del(int k){// 删除并返回 rnk = k 的数字的值 
        int a,b;
        int l,m,r;
        split(root,k,a,b);
        split(a,k-1,l,m),r = b;
        root = merge(r,l);
        return val[m];
    }
}

int n;

void solve(){
    scanf("%d",&n);
    treap::build(n);
    for(int i = 1;i<=n;i++){
        int r;
        scanf("%d",&r);
        r %= (n-i+1);
        printf("%d\n",treap::del(r+1));
    }
}

int main(){
    solve();
    return 0;
}
```


