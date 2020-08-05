---
title: 「HEOI2016/TJOI2016」树-线段树
urlname: HEOI2016-TJOI2016-tree
date: 2018-10-26 23:30:51
tags:
- 线段树
- 树形结构
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

在2016年，佳媛姐姐刚刚学习了树，非常开心。现在他想解决这样一个问题：给定一颗有根树（根为 $1$），有以下两种操作：

1. 标记操作：对某个结点打上标记（在最开始，只有结点1有标记，其他结点均无标记，而且对于某个结点，可以打多次标记。）

2. 询问操作：询问某个结点最近的一个打了标记的祖先（这个结点本身也算自己的祖先）

你能帮帮她吗?

<!--more-->

## 链接

[Luogu P4092](https://www.luogu.org/problemnew/show/P4092)

## 题解

我们按照 dfs 序维护一棵标记永久化的线段树。

每次查询直接查询该位置上所有标记的最大值即可，修改直接在线段树上打上 $\log n$ 个标记，更新标记取 $\max$ 即可。

时间复杂度 $O(n \log n)$ 。

这个题也可以考虑离线逆序处理即为删除标记，用并查集维护能到达的最上方（没有标记）的节点，然后删除标记是 $\text{union}$ 标记两侧集合即可，维护一个当前集合的最小值。

时间复杂度 $O(n \alpha(n))$ 。

## 代码



```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 110000;

struct Edge{
    int to,nex;
}edge[MAXN*2];int ecnt = 2;
int fir[MAXN];
void addedge(int a,int b){
    edge[ecnt] = (Edge){b,fir[a]};
    fir[a] = ecnt++;
}

int n,q,id[MAXN],siz[MAXN],cnt;
int back[MAXN];


namespace SegTree{
    #define lson (nown<<1)
    #define rson (nown<<1|1)
    #define mid ((l+r)>>1)
    int maxn[MAXN<<2];
    void build(int nown,int l,int r){
        maxn[nown] = 1;
        if(l == r) return;
        build(lson,l,mid);
        build(rson,mid+1,r);
    }
    void modify(int nown,int l,int r,int ql,int qr,int v){
        if(ql <= l && r <= qr){
            maxn[nown] = max(maxn[nown],v);
        }
        else{
            if(ql <= mid)
                modify(lson,l,mid,ql,qr,v);
            if(qr >= mid+1)
                modify(rson,mid+1,r,ql,qr,v);
        }
    }
    int query(int nown,int l,int r,int pos){
        if(l == r){
            return maxn[nown];
        }
        else{
            if(pos <= mid)
                return max(maxn[nown],query(lson,l,mid,pos));
            if(pos >= mid+1)
                return max(maxn[nown],query(rson,mid+1,r,pos));
        }
        return 1;
    }
}

void dfs(int nown,int fa){
    id[nown] = ++cnt;
    back[cnt] = nown;
    siz[nown] = 1;
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(v == fa) continue;
        dfs(v,nown);
        siz[nown] += siz[v];
    }
}

void init(){
    scanf("%d %d",&n,&q);
    for(int i = 2;i<=n;i++){
        int a,b;
        scanf("%d %d",&a,&b);
        addedge(a,b),addedge(b,a);
    }
}

void solve(){
    dfs(1,0);
    SegTree::build(1,1,n);
    for(int i = 1;i<=q;i++){
        char s[5];int x;
        scanf("%s %d",s,&x);
        if(s[0] == 'C'){
            SegTree::modify(1,1,n,id[x],id[x]+siz[x]-1,id[x]);
        }
        if(s[0] == 'Q'){
            int t = SegTree::query(1,1,n,id[x]);
            printf("%d\n",back[t]);
        }
    }
}

int main(){
    init();
    solve();
    return 0;
}
```


