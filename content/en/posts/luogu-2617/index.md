---
title: 「Luogu2617」Dynamic Rankings-树状数组-可持久化线段树
urlname: luogu-2617
date: 2018-05-12 18:05:36
tags:
- 数据结构
- 可持久化线段树
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

给定一个含有 $n$ 个数的序列 $\{a_n\}$ ，回答询问或执行操作：

+ `Q i j k` （$1\leq i\leq j\leq n, 1\leq k\leq j-i+1$）表示询问$a[i],a[i+1]......a[j]$中第 $k$ 小的数。

+ `C i t` ($1 \leq i \leq n,0\leq t \leq 10^{9}$)表示把 $a[i]$ 改变成为 $t$ 。

<!--more-->

## 链接

[Luogu P2617](https://www.luogu.org/problemnew/show/P2617)

先在这里粗略的讲一讲。

与普通主席树不同，令第 $i$ 个位置的线段树维护 $(i-lowbit(i),\; i\,]$ 这个区间的权值线段树，而不是 $[1,\;i\,]$ 。

这个时候，我们注意到，对于每一个修改，只会影响到 $O(\log{n})$ 个线段树。我们直接按树状数组的规则去修改，直接在原节点上建立一颗新树进行更改即可。

而每次查询，也只会需要到 $O(\log{n})$ 个线段树，也就是两个树状数组前缀和相减，就可以得到指定区间的权值线段树。我们可以按照树状数组的方式先将权值线段树中要加上的节点和要减去的节点全部存到一个数组里，然后就可以按照不带修改区间 $k$ 大差不多的样子去查询了。

这里时空复杂度应该都是 $O(n \log^{2}{n})$ 。

需要离散化。这里用了 `map` 。这里有一个地方易错。离散化出来的数可能比 $n$ 要大，所以需要另记一个 `totn` 在树状数组查询修改和各种地方作为值域使用。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <map>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 50000;

int n,m,totn = 0;
int rt[MAXN],num[MAXN];

int lowbit(int x){return x & (-x);}

namespace prSegTree{
    int val[MAXN*50],ls[MAXN*50],rs[MAXN*50];
    int cnt = 0;int ll[MAXN],rr[MAXN],totx,toty;
    #define mid ((l+r) >> 1)
    void insert(int &nown,int pre,int l,int r,int pos,int d){
        nown = ++cnt;val[nown] = val[pre] + d;
        ls[nown] = ls[pre],rs[nown] = rs[pre];
        if(l == r) return;
        else{
            if(pos <= mid)
                insert(ls[nown],ls[pre],l,mid,pos,d);
            else if(pos >= mid+1)
                insert(rs[nown],rs[pre],mid+1,r,pos,d);
        }
    }
    void update(int pos,int v,int d){
        for(int i = pos;i<=totn;i += lowbit(i))
            insert(rt[i],rt[i],1,totn,v,d);
    }
    void add(int l,int r){
        totx = toty = 0;
        for(int i = l-1;i;i-=lowbit(i))
            ll[++totx] = rt[i];
        for(int i = r;i;i-=lowbit(i))
            rr[++toty] = rt[i];
    }
    int find_kth(int l,int r,int k){
        int sum = 0;
        if(l == r){
            return l;
        }
        else{
            for(int i = 1;i<=totx;i++) sum -= val[ls[ll[i]]];
            for(int i = 1;i<=toty;i++) sum += val[ls[rr[i]]];   
            if(k <= sum){
                for(int i = 1;i<=totx;i++)  ll[i] = ls[ll[i]];
                for(int i = 1;i<=toty;i++)  rr[i] = ls[rr[i]];
                return find_kth(l,mid,k);
            }
            else{
                for(int i = 1;i<=totx;i++)  ll[i] = rs[ll[i]];
                for(int i = 1;i<=toty;i++)  rr[i] = rs[rr[i]];
                return find_kth(mid+1,r,k-sum);
            } 
        }  
    }
    int query(int l,int r,int k){
        add(l,r);
        return find_kth(1,totn,k);
    }
}
 
map<int,int> S;int last[MAXN];

int op[MAXN],ql[MAXN],qr[MAXN],v[MAXN];

void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++)
        read(num[i]),S[num[i]] = 0;
    char t[23];
    for(int i = 1;i<=m;i++){
        read(t);read(ql[i]),read(qr[i]);
        if(t[0] == 'Q') op[i] = 1,read(v[i]);
        else S[qr[i]] = 0;
    }
    for(auto it = S.begin();it != S.end();it++)
        it->second = ++totn,last[totn] = it->first;
    for(int i = 1;i<=n;i++)
        prSegTree::update(i,S[num[i]],1);
}

void solve(){
    for(int i = 1;i<=m;i++){
        if(op[i] == 0)
            prSegTree::update(ql[i],S[num[ql[i]]],-1),
            prSegTree::update(ql[i],S[qr[i]],1),num[ql[i]] = qr[i]; 
        else
            print(last[prSegTree::query(ql[i],qr[i],v[i])]),print('\n');
    }
}


int main(){
    init();
    solve();
    flush();
    return 0;
}
```

