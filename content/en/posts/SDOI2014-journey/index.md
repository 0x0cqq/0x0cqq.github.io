---
title: 「SDOI2014」旅行-树链剖分+动态开点线段树
urlname: SDOI2014-journey
date: 2018-05-24 20:38:27
tags:
- 数据结构
- 线段树
- 树链剖分
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

给定一棵 $n$ 个节点的树，对于每个点都有两个权值 $w_i,c_i$ 。

存在 $m$ 个操作，分为4类。

+ “`CC x c`”：将 $c_x$ 更改为 $c$ ；

+ “`CW x w`”：将 $w_x$ 更改为 $w$ ；

+ “`QS x y`”：对所有满足在 $x$ 到 $y$ 路径上且 $c_i = c_x = c_y$ 的节点 $i$，求 $\sum w_i$ ；

+ “`QM x y`”：对所有满足在 $x$ 到 $y$ 路径上且 $c_i = c_x = c_y$ 的节点 $i$ ，求 $\max(w_i)$ ；

对于后两个操作，保证 $c_x = c_y$ 。

<!--more-->

对于所有数据， $n,m \leq 10^5$ ，在任意时刻均满足 $w_i \leq 10^4,c_i \leq 10^5,\; w_i,c_i \in \mathbb{N}^+$ 。

## 链接

[Luogu P3313](https://www.luogu.org/problemnew/show/P3313)

## 题解

没什么太多好说的。几乎是裸题了。

对于每一种 $c$ ，建立一颗动态开点的线段树，每个节点维护当前区间的最大值和区间和。

对于树进行树链剖分，查询的时候直接按照树链剖分查询就好了。

时间复杂度 $O(m \log^{2}{n})$ ，空间复杂度 $O(m \log n)$ 。

## 代码


```cpp
#include <cstdio>
#include <vector>
#include <algorithm>
#include <cctype>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 110000,logn = 30;

int n,m,cnt;
int son[MAXN],dep[MAXN],fa[MAXN],siz[MAXN],top[MAXN],id[MAXN];

vector<int> edge[MAXN];

void dfs1(int nown,int f,int depth){
    siz[nown] = 1,fa[nown] = f;
    dep[nown] = depth,son[nown] = 0;
    for(int i = 0;i<edge[nown].size();i++){
        int v = edge[nown][i];
        if(v == f) continue;
        dfs1(v,nown,depth+1);
        siz[nown] += siz[v];
        if(siz[v] > siz[son[nown]]) son[nown] = v;
    }
}

void dfs2(int nown,int topf){
    top[nown] = topf;id[nown] = ++cnt;
    if(!son[nown]) return;
    dfs2(son[nown],topf);
    for(int i = 0;i < edge[nown].size();i++){
        int v = edge[nown][i];
        if(v == fa[nown] || v == son[nown]) continue;
        dfs2(v,v);
    }
}

namespace SegTree{
    int sumn[MAXN*logn],maxn[MAXN*logn],ls[MAXN*logn],rs[MAXN*logn],cnt = 0;
    #define mid ((l+r)>>1)
    void maintain(int nown){
        maxn[nown] = max(maxn[ls[nown]],maxn[rs[nown]]);
        sumn[nown] = sumn[ls[nown]] + sumn[rs[nown]];
    }
    int query_sum(int nown,int l,int r,int ql,int qr){
        if(nown == 0 || (ql <= l && r <= qr) )
            return sumn[nown];
        else{
            int ans = 0;
            if(ql <= mid) ans += query_sum(ls[nown],l,mid,ql,qr);
            if(mid+1 <= qr) ans += query_sum(rs[nown],mid+1,r,ql,qr);
            return ans;
        }
    }
    int query_max(int nown,int l,int r,int ql,int qr){
        if(nown == 0 || (ql <= l && r <= qr))
            return maxn[nown];
        else{
            int ans = 0;
            if(ql <= mid) ans = max(ans,query_max(ls[nown],l,mid,ql,qr));
            if(mid+1 <= qr) ans = max(ans,query_max(rs[nown],mid+1,r,ql,qr));
            return ans;
        }
    }
    void update(int &nown,int l,int r,int pos,int d){
        if(!nown) nown = ++cnt,ls[nown] = 0,rs[nown] = 0;
        if(l == r)
            sumn[nown] = maxn[nown] = d;
        else{
            if(pos <= mid) update(ls[nown],l,mid,pos,d);
            if(mid+1 <= pos) update(rs[nown],mid+1,r,pos,d);
            maintain(nown);
        }
    }
}

int rt[MAXN],r[MAXN],b[MAXN];


int query_max(int u,int v,int k){
    int ans = 0;
    while(top[u]!=top[v]){
        if(dep[top[u]] < dep[top[v]]) swap(u,v);
        ans = max(ans,SegTree::query_max(rt[k],1,n,id[top[u]],id[u]));
        u = fa[top[u]];
    }
    if(dep[u] > dep[v]) swap(u,v);
    ans = max(ans,SegTree::query_max(rt[k],1,n,id[u],id[v]));
    return ans;
}

int query_sum(int u,int v,int k){
    int ans = 0;
    while(top[u]!=top[v]){
        if(dep[top[u]] < dep[top[v]]) swap(u,v);
        ans += SegTree::query_sum(rt[k],1,n,id[top[u]],id[u]);
        u = fa[top[u]];
    }
    if(dep[u] > dep[v]) swap(u,v);
    ans += SegTree::query_sum(rt[k],1,n,id[u],id[v]);
    return ans;
}

void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++)
        read(r[i]),read(b[i]);
    int a,b;
    for(int i = 1;i<=n-1;i++){
        read(a),read(b);
        edge[a].push_back(b);
        edge[b].push_back(a);
    }
}

void build(){
    dfs1(1,0,1),dfs2(1,1);
    for(int i = 1;i<=n;i++)
        SegTree::update(rt[b[i]],1,n,id[i],r[i]);
}

void solve(){
    char op[10];int x,y;
    for(int i = 1;i<=m;i++){
        read(op),read(x),read(y);
        if(op[0] == 'C'){
            if(op[1] == 'W'){
                SegTree::update(rt[b[x]],1,n,id[x],y);
                r[x] = y;
            }
            else if(op[1] == 'C'){
                SegTree::update(rt[b[x]],1,n,id[x],0);
                SegTree::update(rt[y],1,n,id[x],r[x]);
                b[x] = y;
            }
        }
        else if(op[0] == 'Q'){
            if(op[1] == 'S')
                print(query_sum(x,y,b[x])),print('\n');
            else if(op[1] == 'M')
                print(query_max(x,y,b[x])),print('\n');
        }
    }
}

int main(){
    init();
    build();
    solve();
    flush();
    return 0;
}
```

