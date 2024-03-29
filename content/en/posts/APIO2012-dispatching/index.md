---
title: 「APIO2012」派遣-左偏树
urlname: APIO2012-dispatching
date: 2018-07-21 20:45:20
tags:
- 左偏树
- 数据结构
categories: 
- OI
- 题解
series:
- WC/CTSC/APIO
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

给定一棵有根树，每个点有一个代价 $C_i$ ，权值 $L_i$ ，要求从这个树某个节点 $k$ 的子树（包含该节点）选取若干个节点，使得选取节点的个数乘上节点 $k$ 的权值最大，且这若干个节点的代价和不超过给定的限制 $M$ 。

<!--more-->

## 链接

[Luogu P1552](https://www.luogu.org/problemnew/show/P1552)

## 题解

可以用一定的贪心的思想。

如果确定了一个根结点 $k$ ，那么我们的问题就转化成在 $M$ 的限制内，取最多的节点。

对于每个节点，如果我们知道它的子节点的最优的满足 $M$ 的限制的若干节点，那么可以证明合并之后的所有最优节点肯定都只会来自于子节点的最优节点。这是非常显然的。

所以我们用左偏树（大根堆）合并，对于每个节点 `pop` 掉最大的若干个节点使其符合限制，然后尝试更新答案。

然后子树合并得到根结点的情况，`dfs`处理即可。

最后时间复杂度大概是 $O(n \log n)$ 。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <cstring>
#include <vector>
using namespace std;
typedef long long ll;
const int MAXN = 200000;

namespace MH{
ll v[MAXN],sum[MAXN],siz[MAXN];
int l[MAXN],r[MAXN],d[MAXN];
void push_up(int x){
    if(!x) return;
    sum[x] = sum[l[x]] + v[x] + sum[r[x]];
    siz[x] = siz[l[x]] + 1 + siz[r[x]]; 
}
int merge(int x,int y){
    if(x == y) return x;
    if(!x || !y) return x+y;
    if(v[x] < v[y]) swap(x,y);
    r[x] = merge(r[x],y);
    if(d[l[x]] < d[r[x]]) swap(l[x],r[x]);
    d[x] = d[r[x]] + 1;
    push_up(x);
    return x;
}
int del(int x){
    int t = merge(l[x],r[x]);
    sum[x] = v[x],l[x] = r[x] = d[x] = 0;
    return t;
}
ll top(int x){
    return v[x];
}
void init(int n,ll *num){
    for(int i = 1;i<=n;i++){
        v[i] = sum[i] = num[i],siz[i] = 1,l[i] = r[i] = d[i] = 0;
    }
}
void print(int n){
    printf("----------------------\n");
    for(int i = 1;i<=n;i++){
        printf("%d: v:%lld sum:%lld siz:%lld son:%d %d d:%d\n",i,v[i],sum[i],siz[i],l[i],r[i],d[i]);
    }
    printf("----------------------\n");
}
}

int n,m,root;
ll fans;
vector<int> edge[MAXN];
int f[MAXN];ll s[MAXN], l[MAXN];

void init(){
    scanf("%d %d",&n,&m);
    root = n + 1;
    for(int i = 1;i<=n;i++){
        scanf("%d %lld %lld",&f[i],&s[i],&l[i]);
        if(f[i] == 0) f[i] = root;
    }
    for(int i = 1;i<=n;i++)
        edge[f[i]].push_back(i);
    fans = -1;
    MH::init(n,s);
}

int dfs(int x){
    int ans = x,tmp;
    for(int i = 0;i<edge[x].size();i++){
        int v = edge[x][i];
        tmp = dfs(v);
        ans = MH::merge(ans,tmp);
    }
    while(MH::sum[ans] > m && ans!=0)
        ans = MH::del(ans);
    fans = max(fans,l[x] * MH::siz[ans]);
    return ans;
}

int main(){
    init();
    dfs(root);
    printf("%lld\n",fans);
    return 0;
}
```

