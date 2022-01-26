---
title: 「CQOI2015」任务查询系统-可持久化线段树
urlname: CQOI2015-mission
date: 2018-05-16 21:16:32
tags:
- 可持久化线段树
- 差分
- 数据结构
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

超级计算机中的任务用三元组 $(S_i,E_i,P_i)$ 描述， $(S_i,E_i,P_i)$ 表示任务运行区间为 $[S_i,E_i]$ ,其优先级为 $P_i$ 。

给出 $n$ 个任务。随后给出 $m$ 个询问，第 $X_i$ 秒正在运行的任务中，优先级最小的 $K_i$ 个任务的优先级之和是多少。特别的，如果 $K_i$ 大于第 $X_i$ 秒正在运行的任务总数，则直接回答第 $X_i$ 秒正在运行的任务优先级之和。

强制在线。

<!--more-->

## 链接

[Luogu P3128](https://www.luogu.org/problemnew/show/P3168)

## 题解

注意到这个问题主要就是区间的权值修改，以及单点的求和（求值），我们可以采用差分的办法。

首先对任务离线后分成 $(S_i,P_i,1)$ ， $(E_i+1,P_i,-1)$ 两个修改，排序后扫一遍进行修改。

查询第 $X_i$ 秒的时候，我们注意到我们每个时间所对应的线段树其实就是差分的前缀和，所以我们直接在第 $X_i$ 个线段树上求前 $K_i$ 个数的和就好了。注意在叶子结点需要分类讨论，看叶子结点有没有取全。

数据范围很大（？），需要离散化，这里用了map。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <map>
#include <cctype>
#include <vector>
#define ll long long
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 200000;

map<int,int> S;int last[MAXN];

namespace prSegTree{
    int val[MAXN*50],ls[MAXN*50],rs[MAXN*50];
    ll sum[MAXN*50];int cnt = 0;
    #define mid ((l+r)>>1)
    void maintain(int nown,int l,int r){
        val[nown] = val[ls[nown]] + val[rs[nown]];
        sum[nown] = sum[ls[nown]] + sum[rs[nown]];
    }
    void insert(int &nown,int pre,int l,int r,int pos,int d){
        nown = ++cnt;ls[nown] = ls[pre],rs[nown] = rs[pre];
        val[nown]=val[pre]+d,sum[nown]=sum[pre]+1ll * d * last[pos];
        if(l == r) return;
        else{
            if(pos <= mid) insert(ls[nown],ls[pre],l,mid,pos,d);
            if(mid+1 <= pos) insert(rs[nown],rs[pre],mid+1,r,pos,d);
        }
    }
    ll query(int nown,int l,int r,int k){
        if(l == r){
            if(k>=val[nown]) return sum[nown];
            else return k * last[l];
        }
        else{
            int sumn = val[ls[nown]];
            if(k <= sumn)
                return query(ls[nown],l,mid,k);   
            else if(sumn + 1 <= k)
                return sum[ls[nown]] + query(rs[nown],mid+1,r,k-sumn);
        }
    }
}


int n,m,totn,maxt,rt[MAXN];
vector<int> qq[MAXN];

void init(){
    read(n),read(m);
    int a,b,c;
    maxt = n;
    for(int i = 1;i<=n;i++){
        read(a),read(b),read(c);
        qq[a].push_back(c);
        qq[b+1].push_back(-c);
        maxt = max(maxt,b+1);
        S[c] = 0;
    }
    for(auto it = S.begin();it!=S.end();it++){
        it->second = ++totn;
        last[totn] = it->first;
    }
    for(int i = 1;i<=maxt;i++){
        rt[i] = rt[i-1];
        for(int j = 0;j<qq[i].size();j++){
            prSegTree::insert(rt[i],rt[i],1,totn,(S[abs(qq[i][j])]),qq[i][j] > 0? 1 : -1);
        }
    }
}

void solve(){
    ll last = 1,ans;
    int x,k,a,b,c;
    for(int i = 1;i<=m;i++){
        read(x),read(a),read(b),read(c);
        k = 1+(a*last+b)%c;
        ans = prSegTree::query(rt[x],1,totn,k);
        printf("%lld\n",ans);
        last = ans;
    }
}

int main(){
    init();
    solve();
    return 0;
}
```

