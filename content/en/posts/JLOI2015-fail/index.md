---
title: 「JLOI2015」城池攻占-左偏树
urlname: JLOI2015-fail
date: 2018-07-21 20:45:52
tags:
- 左偏树
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

有 $m$ 个骑士攻占 $n$ 个城池。除 $1$ 号城池外，城池 $i$ 会受到另一座城池 $f_i$ 的管辖，其中 $f_i < i$。也就是说，所有城池构成了一棵有根树。第 $i$ 个骑士的初始战斗力为 $s_i$，第一个攻击的城池为 $c_i$。

每个城池有一个防御值 $h_i$，如果一个骑士的战斗力大于等于城池的生命值，那么骑士就可以占领这座城池；否则占领失败，骑士将在这座城池牺牲。占领一个城池以后，骑士的战斗力将发生变化，然后继续攻击管辖这座城池的城池，直到占领 $1$ 号城池，或牺牲为止。

除 $1$ 号城池外，每个城池 $i$ 会给出一个战斗力变化参数 $a_i$;$v_i$。若 $a_i = 0$，攻占城池 $i$ 以后骑士战斗力会增加 $v_i$；若 $a_i = 1$，攻占城池 $i$ 以后，战斗力会乘以 $v_i$。注意每个骑士是单独计算的。也就是说一个骑士攻击一座城池，不管结果如何，均不会影响其他骑士攻击这座城池的结果。

对于每个城池，输出有多少个骑士在这里牺牲；对于每个骑士，输出他攻占的城池数量。

<!--more-->

## 链接

[Luogu P3261](https://www.luogu.org/problemnew/show/P3261)

## 题解

这个问题是可以离线的，我们不需要在线的回答每一个骑士的问题。

所以我们思考如何对于这个问题进行处理。

考虑所有到达某个节点的人。在这些人中，都会有一些攻击力最小的人在这个节点死掉。这个时候剩下的人的攻击力的大小关系并不会改变。

所以我们有两个选择：平衡树、堆。

这个时候我们思考一下对于**所有下面活着的人如何再攻击上面的城池**。这个时候其实就是所有某个节点所有的子节点的活着的人合并到一起。用启发式合并的话，复杂度是$O(n \log^2 n)$，如果用左偏树的话，复杂度就是$O(n \log n)$。

在最上面添加一个虚拟的节点把所有人都牺牲了就好。

这里的加法和乘法类似线段树，维护`lazy`标记下传即可。

## 代码


```cpp
#include <cstdio>
#include <cctype>
#include <algorithm>
#include <cstring>
#include <vector>
typedef long long ll;
using namespace std;

namespace fast_io{
	//...
}using namespace fast_io;

const int MAXN = 310000;

namespace MH{
int l[MAXN],r[MAXN],d[MAXN];
ll v[MAXN],addn[MAXN],muln[MAXN];
inline void add(int x,ll val){
    if(!x) return;
    v[x]+=val,addn[x]+=val;
}
inline void mul(int x,ll val){
    if(!x) return;
    v[x]*=val,addn[x]*=val,muln[x] *= val;
}
inline void push_down(int x){
    if(!x) return;
    if(muln[x]!=1){
        mul(l[x],muln[x]),mul(r[x],muln[x]);
        muln[x] = 1;
    }
    if(addn[x]){
        add(l[x],addn[x]),add(r[x],addn[x]);
        addn[x] = 0;
    }
}
inline int merge(int x,int y){
    if(x == y) return x;
    if(!x || !y) return x+y;
    if(v[x] > v[y]) swap(x,y);
    push_down(x);
    r[x] = merge(r[x],y);
    if(d[l[x]] < d[r[x]]) swap(l[x],r[x]);
    d[x] = d[r[x]] + 1;
    return x;
}
inline ll top(int x){
    return v[x];
}
inline int del(int x){
    push_down(x);
    int t = merge(l[x],r[x]);
    l[x] = r[x] = d[x] = 0;
    return t;
}
inline void init(int n,ll *num){
    for(int i = 1;i<=n;i++)
        v[i] = num[i],l[i] = r[i] = d[i] = addn[i] = 0,muln[i] = 1;
}
}

int n,m,root;
ll h[MAXN];
int f[MAXN],a[MAXN];ll v[MAXN];
ll s[MAXN];int c[MAXN],dep[MAXN];
int ans1[MAXN],ans2[MAXN];
vector<int> edge[MAXN];
vector<int> st[MAXN];

void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++)
        read(h[i]);
    for(int i = 2;i<=n;i++){
        read(f[i]),read(a[i]),read(v[i]);
        edge[f[i]].push_back(i);
    }
    for(int i = 1;i<=m;i++){
        read(s[i]),read(c[i]);
        st[c[i]].push_back(i);
    }
    root = m+1;
    edge[root].push_back(1);
    h[root] = (long long)(1e18);
    MH::init(m,s);
}

int dfs(int nown){
    int ans = 0,tmp = 0;
    for(int i = 0;i < edge[nown].size();i++){
        int v = edge[nown][i];
        dep[v] = dep[nown] + 1;
        tmp = dfs(v);
        ans = MH::merge(ans,tmp);
    }
    for(int i = 0;i<st[nown].size();i++)
       ans = MH::merge(st[nown][i],ans);
    while(MH::top(ans) < h[nown] && ans!=0){
        ans1[nown]++;
        tmp = ans;
        ans2[tmp] = dep[c[tmp]] - dep[nown];
        ans = MH::del(ans);
    }
    if(a[nown] == 0)
        MH::add(ans,v[nown]);
    else if(a[nown] == 1)
        MH::mul(ans,v[nown]);
    return ans;
}

void output(){
    for(int i = 1;i<=n;i++)
        print(ans1[i]),print('\n');
    for(int i = 1;i<=m;i++)
        print(ans2[i]),print('\n');
}

signed main(){
    init();
    dfs(root);
    output();
    flush();
    return 0;
}
```

