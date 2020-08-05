---
title: 「LNOI2014」LCA-树链剖分-差分
urlname: LNOI2014-lca
date: 2018-06-02 21:23:25
tags:
- 数据结构
- 树链剖分
- 差分
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

给出一个 $n$ 个节点的有根树。有 $q$ 次询问，每次询问给出 $l,r,z$ ，求 $\sum_{l \leq i \leq r}dep[LCA(i,z)]$ 。

<!--more-->

## 链接

[Luogu P4211](https://www.luogu.org/problemnew/show/P4211)

## 题解

神仙题...真是不知道考场上有没有人能够想到。

给出这样一个结论：

> 节点 $x$ 和 $y$ 的 $lca$ 到根节点的距离等于在 $x$ 到根节点的路径上且 $y$ 到根节点的路径上的节点个数。

所以如果我们将 $[l,r]$ 中的点到根节点的路径上所有的节点的值分别加 $1$ ，这个时候 $z$ 到根节点的路径上的权值和就是查询 $(l,r,z)$ 的答案。

- - -

而且我们注意到这个问题满足区间可减性：

即设 $sum(l,r) = \sum_{l\leq i\leq r}{dep[LCA(i,z)]}$ ，有 $sum(l,r) = sum(1,r)-sum(1,l-1)$ 。

因此，我们将询问 $(l,r,z)$ 分离成 $(l-1,z)$ 和 $(r,z)$ 。

我们用 $(t_i,pos_i)$ 代表询问。按照 $t_i$ 为第一关键字进行排序离线之后查询。每次查询的时候，使得 $1~t_i$ 的所有节点都已经把往根节点的路径上都做了修改，那么我们只需要查询一个 $(1,pos_i)$ 的路径上的节点的权值和即可。

这个东西如果用树链剖分+线段树，复杂度是 $O(n \log^{2}{n})$ ，如果用 LCT，复杂度是 $O(n\log n)$ 。

其实我感觉这道题完全可以出到 $200000$ ，然后给 $O(n \log^{2}{n})$ 五六十分部分分。

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

const int MAXN = 210000,mod = 201314;

int n,m;

vector<int> edge[MAXN];
int dep[MAXN],son[MAXN],top[MAXN],siz[MAXN],fa[MAXN],id[MAXN],cnt = 0;

void dfs1(int nown,int f,int depth){
    siz[nown] = 1;dep[nown] = depth;
    fa[nown] = f;
    for(int i = 0;i<edge[nown].size();i++){
        int v = edge[nown][i];
        if(v == f) continue;
        dfs1(v,nown,depth+1);
        siz[nown] += siz[v];
        if(siz[v] > siz[son[nown]]) son[nown] = v;
    }
}

void dfs2(int nown,int topf){
    top[nown] = topf;
    id[nown] = ++cnt;
    if(!son[nown]) return;
    dfs2(son[nown],topf);
    for(int i = 0;i<edge[nown].size();i++){
        int v = edge[nown][i];
        if(v == fa[nown] || v == son[nown])
            continue;
        dfs2(v,v);
    }
}

namespace SegTree{
    int sumn[MAXN],addn[MAXN];
    #define lson (nown<<1)
    #define rson ((nown<<1)|1)
    #define mid ((l+r)>>1)
    void push_up(int nown){
        sumn[nown] = sumn[lson] + sumn[rson];
        sumn[nown] %= mod;
    }
    void add(int nown,int l,int r,int d){
        sumn[nown] += d*(r-l+1);
        addn[nown] += d;
        sumn[nown] %= mod,addn[nown] %= mod;
    }
    void push_down(int nown,int l,int r){
        if(addn[nown]){
            add(lson,l,mid,addn[nown]);
            add(rson,mid+1,r,addn[nown]);
            addn[nown] = 0;
        }
    }
    void add(int nown,int l,int r,int ql,int qr,int d){
        if(ql <= l && r <= qr){
            add(nown,l,r,d);
        }
        else{
            push_down(nown,l,r);
            if(ql <= mid) add(lson,l,mid,ql,qr,d);
            if(mid+1 <= qr) add(rson,mid+1,r,ql,qr,d);
            push_up(nown);
        }
    }
    int query(int nown,int l,int r,int ql,int qr){
        if(ql <= l && r <= qr) 
            return sumn[nown];
        else{
            push_down(nown,l,r);
            int ans = 0;
            if(ql <= mid) ans += query(lson,l,mid,ql,qr);
            if(mid + 1 <= qr) ans += query(rson,mid+1,r,ql,qr);
            ans %= mod;
            return ans;
        }
    }
    void build(int nown,int l,int r){
        ;
    }
}

struct Q{
    int ti,pos,id;
    Q(int t,int p,int i):ti(t),pos(p),id(i){;}
    bool operator<(Q a) const{
        return ti < a.ti;
    }
};

vector<Q> q;

int ans[MAXN<<2],qa[MAXN][2];

void init(){
    read(n),read(m);
    int a,b,c;
    for(int i = 2;i<=n;i++){
        read(a);
        edge[i].push_back(a+1);
        edge[a+1].push_back(i);
    }
    int tot;
    for(int i = 1;i<=m;i++){
        read(a),read(b),read(c);
        q.push_back(Q(a,c+1,++tot));
        qa[i][0] = tot;
        q.push_back(Q(b+1,c+1,++tot));
        qa[i][1] = tot;
    }
}

void w_add(int u,int v,int d = 1){
    while(top[u]!=top[v]){
        if(dep[top[u]] < dep[top[v]]) swap(u,v);
        SegTree::add(1,1,n,id[top[u]],id[u],d);
        u = fa[top[u]];
    }
    if(dep[u] > dep[v]) swap(u,v);
    SegTree::add(1,1,n,id[u],id[v],d);
}

int w_query(int u,int v){
    int ans = 0;
    while(top[u] != top[v]){
        if(dep[top[u]] < dep[top[v]]) swap(u,v);
        ans += SegTree::query(1,1,n,id[top[u]],id[u]);
        u = fa[top[u]]; ans %= mod;
    }
    if(dep[u] > dep[v]) swap(u,v);
    ans += SegTree::query(1,1,n,id[u],id[v]);
    ans %= mod;
    return ans;
}

void solve(){
    sort(q.begin(),q.end());
    dfs1(1,0,1);
    dfs2(1,1);
    int nowt = 0;
    for(int i = 0;i < q.size();i++){
        while(q[i].ti > nowt) w_add(1,++nowt);
        ans[q[i].id] = w_query(1,q[i].pos);
    }
    for(int i = 1;i<=m;i++)
        print((ans[qa[i][1]]-ans[qa[i][0]]+mod+mod+mod)%mod),print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

