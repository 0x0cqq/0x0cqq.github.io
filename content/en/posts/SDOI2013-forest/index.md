---
title: 「SDOI2013」森林-主席树+LCA+启发式合并
urlname: SDOI2013-forest
date: 2018-05-21 20:10:00
tags:
- 可持久化线段树
- 最近公共祖先
- 启发式合并
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

小Z有一片森林，含有 $N$ 个节点，每个节点上都有一个非负整数作为权值。初始的时候，森林中有 $M$ 条边。

小Z希望执行 $T$ 个操作，操作有两类：

+ `Q x y k` 查询点 $x$ 到点 $y$ 路径上所有的权值中，第 $k$ 小的权值是多少。此操作保证点 $x$ 和点 $y$ 连通，同时这两个节点的路径上至少有 $k$ 个点。

+ `L x y` 在点 $x$ 和点 $y$ 之间连接一条边。保证完成此操作后，仍然是一片森林。

强制在线。

对于所有的数据 $n,m,T \leq 8 \times 10^4$ 。

<!--more-->

## 链接

[Luogu P3302](https://www.luogu.org/problemnew/show/P3302)

## 题解

恶心的大数据结构。

对于合并操作，我们会想到 `LCT` ，而对于查询路径上的第 $k$ 大，又让我们想到主席树。

只能牺牲一种操作。注意到这里没有 `cut` ，所以我们可以通过启发式合并的方式，减少一个 $\log$ 。

用并查集维护森林的大小，每次合并的时候强势暴力dfs修改树上路径主席树，以及求 `lca`的倍增数组即可。

然后就是常规操作了。

需要用离散化，这里用了 `map`。

## 代码


```cpp
#include <cstdio>
#include <map>
#include <cctype>
#include <algorithm>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 81000,maxb = 20,logn = 500;

namespace prSegTree{
    int sumn[MAXN*logn],ls[MAXN*logn],rs[MAXN*logn],cnt = 1;
    #define mid ((l+r)>>1)
    void insert(int &nown,int pre,int l,int r,int pos,int d){
        nown = ++cnt;ls[nown] = ls[pre],rs[nown] = rs[pre];
        sumn[nown] = sumn[pre] + d;
        if(l == r) return;
        else{
            if(pos <= mid) insert(ls[nown],ls[pre],l,mid,pos,d);
            if(mid+1 <= pos) insert(rs[nown],rs[pre],mid+1,r,pos,d);
        }
    }
    int query(int x1,int x2,int y1,int y2,int l,int r,int k){
        if(l == r) return l;
        else{
            int sum = sumn[ls[x1]] + sumn[ls[x2]] - sumn[ls[y1]] - sumn[ls[y2]];
            if(k <= sum) return query(ls[x1],ls[x2],ls[y1],ls[y2],l,mid,k);
            if(sum+1 <= k) return query(rs[x1],rs[x2],rs[y1],rs[y2],mid+1,r,k-sum);
        }
    }
    void build(int &nown,int l,int r){
        nown = ++cnt;
        if(l == r) return;
        else{
            build(ls[nown],l,mid);
            build(rs[nown],mid+1,r);
        }
    }
}

int fir[MAXN];
int to[MAXN*2],nex[MAXN*2],ecnt = 1;

int n,m,q,num[MAXN],last[MAXN],tot = 0;
int rt[MAXN];
int f[MAXN][maxb],dep[MAXN];
map<int,int> S;

void addedge(int u,int v){
    to[ecnt] = v,nex[ecnt] = fir[u],fir[u] = ecnt++;
    to[ecnt] = u,nex[ecnt] = fir[v],fir[v] = ecnt++;
}

namespace BCJ{
    int f[MAXN],siz[MAXN];
    int find(int x){
        return f[x]==x?x:find(f[x]);
    }
    int query(int x){
        return siz[find(x)];
    }
    void un(int x,int y){
        //y->x
        int xx = find(x),yy = find(y);
        f[yy] = xx;siz[xx] += siz[yy];
    }
    void init(){
        for(int i = 1;i<=n;i++)
            f[i] = i,siz[i] = 1;
    }
}

void pre_dfs(int nown,int fa,int depth){
    prSegTree::insert(rt[nown],rt[fa],1,tot,S[num[nown]],1);
    dep[nown] = depth;
    f[nown][0] = fa;
    for(int j = 1;j<maxb;j++)
        f[nown][j] = f[ f[nown][j-1] ][j-1];
    for(int i = fir[nown];i;i=nex[i]){
        int v = to[i];
        if(v == fa) continue;
        pre_dfs(v,nown,depth+1);
    }
}

int lca(int u,int v){
    if(dep[u] < dep[v]) swap(u,v);
    for(int j = maxb-1;j>=0;j--)
        if(dep[f[u][j]] >= dep[v])
            u = f[u][j];
    if(u == v) return u;
    for(int j = maxb-1;j>=0;j--)
        if(f[u][j] != f[v][j])
            u = f[u][j],v = f[v][j];
    return f[u][0]; 
}

void init(){
    int T;
    read(T);
    read(n),read(m),read(q);
    BCJ::init();
    for(int i = 1;i<=n;i++){
        read(num[i]);
        S[num[i]] = 0;
    }
    for(map<int,int>::iterator it = S.begin();it!=S.end();it++){
        it->second = ++tot;last[tot] = it->first;
    }
    int a,b;
    for(int i = 1;i<=m;i++){
        read(a),read(b);
        addedge(a,b);
        BCJ::un(a,b);
    }
}

void build(){
    for(int i = 1;i<=n;i++){
        if(BCJ::find(i)==i)
            pre_dfs(i,0,1);
    }
}

void link(int u,int v){
    addedge(u,v);
    if(BCJ::query(u) < BCJ::query(v)) swap(u,v);
    pre_dfs(v,u,dep[u]+1);
    BCJ::un(u,v);
}

int query(int u,int v,int k){
    int l = lca(u,v),fl = f[l][0];
    int ans = prSegTree::query(rt[u],rt[v],rt[l],rt[fl],1,tot,k);
    //printf("query: u:%d v:%d l:%d fl:%d k:%d ANS:%d\n",u,v,l,fl,k,ans);
    return last[ans];
}

void solve(){
    char op[10];int a,b,k,last = 0;
    for(int i = 1;i<=q;i++){
        read(op);read(a),read(b);
        a^=last,b^=last;
        if(op[0] == 'L')
            link(a,b);
        else if(op[0] == 'Q')
            read(k),k^=last,print(last = query(a,b,k)),print('\n');
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

