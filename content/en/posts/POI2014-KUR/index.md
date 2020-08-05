---
title: 「POI2014」KUR-Couriers-主席树
urlname: POI2014-KUR
date: 2018-05-06 19:38:00
tags:
- 数据结构
- 主席树
- 线段树
- 可持久化线段树
categories: 
- OI
- 题解
series:
- 各国OI
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

给一个数列 $\{a_n\}$ ，每次询问区间 $[l,r]$ 内有没有一个数出现次数超过一半。如果有，输出这个数，如果没有，输出 $0$ 。

<!--more-->

## 链接

[Luogu P3567](https://www.luogu.org/problemnew/show/P3567)

## 题解

主席树的模版...然而蒟蒻如我居然并看不出来怎么做...不过现在对权值线段树也更了解了呢。

普通的建立一颗主席树。每个节点维护该区间内权值总和。

在查询的时候，还是两个前缀相减，往大于 $\lceil \frac{r-l+1}{2} \rceil$ （原始的 $[l,r]$ ）的方向去走，如果没有，就返回0，边界就是 $l == r$ 的时候返回。

其实就是总统选举那道题的弱化版。

很简单。然而我更菜。

## 代码


```cpp
#include <cstdio>
#include <cctype>
#define mid ((l+r)>>1)
#define pp pair<int,int>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 600000;

namespace prSegTree{
    int val[MAXN*20];int ls[MAXN*20],rs[MAXN*20];
    int cnt = 1;
    void build(int &nown,int l,int r){
        nown = cnt++;
        if(l == r)
            val[nown] = 0;
        else{
            build(ls[nown],l,mid);
            build(rs[nown],mid+1,r);
        }
    }
    void update(int &nown,int pre,int l,int r,int pos,int d){
        nown = cnt++;val[nown] = val[pre]+d;
        ls[nown] = ls[pre];rs[nown] = rs[pre];
        if(l == r)
            return;
        else{
            if(pos <= mid)
                update(ls[nown],ls[pre],l,mid,pos,d);
            if(mid+1 <= pos)
                update(rs[nown],rs[pre],mid+1,r,pos,d);
        }
    }
    int query(int nowl,int nowr,int l,int r,int limit){
        if(l == r)
            return l;
        else{
            if(val[ls[nowr]] - val[ls[nowl]]>=limit)
                return query(ls[nowl],ls[nowr],l,mid,limit);
            if(val[rs[nowr]] - val[rs[nowl]]>=limit)
                return query(rs[nowl],rs[nowr],mid+1,r,limit);
            return 0;
        }
    }
}

int n,m;
int root[MAXN];

void init(){
    read(n),read(m);
    prSegTree::build(root[0],1,n);
    int tmp;
    for(int i = 1;i<=n;i++){
        read(tmp);
        root[i] = root[i-1];
        prSegTree::update(root[i],root[i-1],1,n,tmp,1);
    }
}

void solve(){
    int l,r;
    for(int i = 1;i<=m;i++){
        read(l),read(r);
        print(prSegTree::query(root[l-1],root[r],1,n,(r-l+1)/2+1)),print('\n');
    }
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

