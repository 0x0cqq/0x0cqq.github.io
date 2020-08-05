---
title: 点分治学习笔记
urlname: point-DC-notes
date: 2018-04-22 13:14:04
tags:
- 笔记
- 点分治
- 树形结构
- 模板
categories: 
- OI
- 学习笔记
series:
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: true
---


点分治是一种主要在树上的分治，可以在解决一些树上特定条件的路径的问题。其复杂度与大部分分治类似，大概是 $O(K \; \log{n})$（ $K$ 为除分治步骤之外的时间复杂度的多项式）。

<!--more-->

## 简介

点分治感性的来说，其实就需要考虑一件事情：如何把树上路径问题转换成过根结点的路径问题。

**定理:树上所有的路径可以分为过根结点的路径和不过根结点的路径。**

对于根结点来说，我们处理完过根结点的路径，剩下所有的路径都不会过根结点了。所以我们可以把根节点和与根结点相连的边均删掉，然后对于新产生的子树，剩下的路径应该都在其中，就可以对子树进行分治处理。

## 实现

主要是三个函数：`solve`，`work`，`getroot`。

### `solve`

solve函数，也就是主要函数，是一个递归解决问题的过程。

每一次都先把这个点标记成已经访问过，然后对于这个点去寻找

代码如下：

```cpp
void solve(int nown){
    work(nown);
    vis[nown] = 1;
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(vis[v]) continue;
        f[rt = 0] = sz = siz[v];//初始化rt
        getroot(v,rt);//找到该子树的重心
        solve(rt);//递归解决问题
    }
}
```

### `work`

`work`函数就是完成对于当前的子树中所有过根的节点的处理。这个函数没有具体的样子，因题而异。

照我目前的理解，主要的思路就是：dfs，想办法拼起来两条同时过根节点而且端点不在一个子树里面的节点。

### `getroot`

首先，为了保证我们分出去的子树的规模尽量的一致，我们每次都需要把当前的树的重心作为根节点，然后完成上段所述的事情。

在这里，寻找重心其实就是找哪个点作根的时候剩下的最大子树的大小最小...代码如下：

```cpp
//vis==1 代表已经处理过（不在当前子树中）
//f[nown] 储存这个点作根时剩下的最大子树的大小
void getroot(int nown,int fa){
    siz[nown] = 1,f[nown] = 0;
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(vis[v] || v == fa) continue;
        getroot(v,nown);
        siz[nown] += siz[v];
        f[nown] = max(f[nown],siz[v]);
    }
    f[nown] = max(f[nown],sz - siz[nown]);
    if(f[nown] < f[rt]) rt = nown;
}
```

不是很难。

## 代码

以[Luogu P3806](https://www.luogu.org/problemnew/show/P3806) 为例。
（其实这个题...比模版还是要多一些的...复杂度是 $O(n \log{n} \log{n})$



```cpp
#include <cstdio>
#include <algorithm>
#include <cctype>
using namespace std;

const int MAXN = 110000;

namespace fast_io {
    //...
}using namespace fast_io;

struct Edge{
    int from,to;
    int len,nex;
}edge[MAXN];
int ecnt = 1;int fir[MAXN];
void addedge(int a,int b,int l){
    edge[ecnt] = (Edge){a,b,l,fir[a]};
    fir[a] = ecnt++;
    edge[ecnt] = (Edge){b,a,l,fir[b]};
    fir[b] = ecnt++;
}
//-----
int n,m,q[MAXN],ans[MAXN];
//-----
int f[MAXN],vis[MAXN],siz[MAXN];
int rt,sz;

struct node{
    int d,f;
    bool operator < (node a)const{
        return d < a.d;
    }
}dep[MAXN];
int num;

int search(int d){
    int b = 1,e = num;
    while(e!=b){
        int mid = (b+e)>>1;
        if(dep[mid].d >= d) e = mid;
        else b = mid + 1;
    }
    return b;
}

//-----
void getroot(int nown,int fa){
    siz[nown] = 1,f[nown] = 0;
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(vis[v] || v == fa) continue;
        getroot(v,nown);
        siz[nown] += siz[v];
        f[nown] = max(f[nown],siz[v]);
    }
    f[nown] = max(f[nown],sz - siz[nown]);
    if(f[nown] < f[rt]) rt = nown;
}

void dfs(int nown,int fa,int wh,int d){
    dep[++num] = (node){d,wh};
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to,l = edge[nowe].len;
        if(vis[v] || v == fa) continue;
        dfs(v,nown,wh,d+l);
    }
}

void work(int nown){
    num = 0;
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to,l = edge[nowe].len;
        if(vis[v]) continue;
        dfs(v,nown,v,l);
    }
    dep[++num] = (node){0,0};
    sort(dep+1,dep+num+1);
    //二分查找 并判断对于每个ans是否有符合的答案
    for(int i = 1;i<=m;i++){
        if(ans[i]) continue;
        int l = 1;
        while(l < num && dep[l].d + dep[num].d < q[i])
            l++;
        while(l < num && 2*dep[l].d < q[i]){
            if(ans[i]) break;
            int t = q[i]-dep[l].d,r = search(t);
            while(r <= num && dep[r].d == t && dep[l].f == dep[r].f)
                r++;
            ans[i] |= (dep[r].d == t);
            l++;
        }
    }
}

void solve(int nown){
    vis[nown] = 1;
    work(nown);
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(vis[v]) continue;
        f[rt = 0] = sz = siz[v];
        getroot(v,rt);
        solve(rt);
    }
}

void init(){
    read(n),read(m);
    int a,b,c;
    for(int i = 1;i<=n-1;i++){
        read(a),read(b),read(c);
        addedge(a,b,c);
    }
    for(int i = 1;i<=m;i++)
        read(q[i]);
}

void solve(){
    f[rt = 0] = sz = n;
    getroot(1,rt);
    solve(rt);
    for(int i = 1;i<=m;i++){
        if(ans[i]) print('A'),print('Y'),print('E');
        else print('N'),print('A'),print('Y');
        print('\n');
    }
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```



## 例题

{% post_link 「国家集训队」聪聪可可-点分治 [国家集训队]聪聪可可 %}

[[Luogu P2664]树上游戏](https://www.luogu.org/problemnew/show/P2664)

