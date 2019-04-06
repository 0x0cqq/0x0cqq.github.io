---
title: 「ZJOI2007」最大半连通子图-强连通分量-dp
urlname: ZJOI2007-semi-connected
date: 2018-04-05 16:54:05
tags:
- 图论
- 强连通分量
- 动态规划
categories: 
- OI
- 题解
visible:
---

给定一个有向图 $G$ ，请求出 $G$ 的最大半连通子图拥有的节点数 $K$ ，以及不同的最大半连通子图的数目 $C$ 。

<!-- more -->
由于 $C$ 可能比较大，仅要求输出 $C$ 对 $X$ 的余数。

具体定义：

一个有向图 $G=(V,E)$ 称为半连通的 $(Semi-Connected)$ ，如果满足：$\forall u,v∈V$ ，存在 $u \rightarrow v$ 或 $v \rightarrow u$ 。即对于图中任意两点 $u,v$ ，存在一条 $u$ 到 $v$ 的有向路径或者从 $v$ 到 $u$ 的有向路径。

若 $G'=(V',E')$ 满足 $V'\subset V$ ， $E'$ 是 $E$ 中所有跟 $V'$ 有关的边，则称 $G'$ 是 $G$ 的一个导出子图。

若 $G'$ 是 $G$ 的导出子图，且 $G'$ 半连通，则称 $G'$ 为 $G$ 的半连通子图。

若 $G'$ 是 $G$ 所有半连通子图中包含节点数最多的，则称 $G'$ 是 $G$ 的最大半连通子图。

## 链接

[Luogu P2272](https://www.luogu.org/problemnew/show/P2272)

[BZOJ 1093](https://www.lydsy.com/JudgeOnline/problem.php?id=1093)

## 题解

经过观察和分析发现，一个有向图是一个半连通子图当且仅当其缩点后成为一条链。

这个很显然，画画图就发现了。那么现在问题就变成了寻找一张有向无环图里面最长链的长度及个数。

可以用dp的方法来求。

状态转移方程：

$$
len[u] = max(len[v])+1 ,\quad \{u,v\} \in E 
$$
$$
num[u] = sum(num[v]) ,\quad \{u,v\} \in E , \;len[u] = len[v] + 1 
$$

有一点很坑的就是，不能有重边，要不然就会死的很惨，重复计算导致答案偏大。

所以重建图要去重！！！

## 代码


```cpp
#include <cstdio>
#include <cctype>
#include <cstring>
#include <algorithm>
using namespace std;

namespace fast_io {
    ...
}using namespace fast_io;

const int MAXN = 110000,MAXM = 2100000;

struct stack{
    int num[MAXN],topnum;
    stack(){topnum = 0;}
    void pop(){topnum--;}
    int top(){return num[topnum-1];}
    void push(int val){num[topnum++] = val;}
    bool empty(){return topnum != 0;}
}a;

int n,m,ecnt = 1,X;

int fir[MAXN];
int cnt = 1,cnum = 0;
int low[MAXN],dfn[MAXN],siz[MAXN];
int col[MAXN];
int instack[MAXN];

struct Edge{
    int from,to,nex;
    bool operator < (Edge a)const{
        if(from == a.from)
            return to < a.to;
        return from < a.from;
    }
}edge[MAXM];

void addedge(int a,int b){
    edge[ecnt].from = a,edge[ecnt].to = b;
    edge[ecnt].nex = fir[a];fir[a] = ecnt++;
}

void dfs(int nown){
    low[nown] = dfn[nown] = cnt++;
    instack[nown] = 1;a.push(nown);
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(dfn[v] == 0)
            dfs(v),low[nown] = min(low[v],low[nown]);
        else if(instack[v] == 1)
            low[nown] = min(dfn[v],low[nown]);
    }
    if(low[nown] == dfn[nown]){
        cnum++;int j = -1;
        do{
            j = a.top();a.pop();
            instack[j] = 0;
            col[j] = cnum;
            siz[cnum]++;
        }while(j!=nown);
    }
}

void tarjan(){
    for(int i = 1;i<=n;i++)
        if(dfn[i] == 0)
            dfs(i);
    for(int i = 1;i<=m;i++){
        edge[i].from = col[edge[i].from];
        edge[i].to = col[edge[i].to];
    }
    memset(fir,0,sizeof(fir));
    //去重！！！
    sort(edge+1,edge+m+1);
    int lastu = 0,lastv = 0;
    for(int i = 1;i<=m;i++){
        int u = edge[i].from,v = edge[i].to;
        if(u!=v&&(!(u==lastu&&v==lastv)))
            addedge(u,v);
        lastu = u,lastv = v;
    }
}

int dp[MAXN],num[MAXN];

void dfs2(int nown){
    dp[nown] = siz[nown],num[nown] = 1;
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(dp[v] == 0) dfs2(v);
        if(dp[nown] < dp[v] + siz[nown])
            dp[nown] = dp[v] + siz[nown],num[nown] = num[v];
        else if(dp[nown] == dp[v] + siz[nown])
            num[nown] += num[v], num[nown] %= X;
    }
}

void solve(){
    for(int i = 1;i<=cnum;i++)
        if(num[i] == 0)
            dfs2(i);
    int ans1 = 0,ans2 = 0;
    for(int i = 1;i<=cnum;i++){
        if(dp[i] > ans1) ans1 = dp[i],ans2 = num[i];
        else if(dp[i] == ans1) ans2 += num[i],ans2 %=X;
    }
    print(ans1),print('\n'),print(ans2),print('\n');
}

void init(){
    read(n),read(m),read(X);
    int a,b;
    for(int i = 1;i<=m;i++){
        read(a),read(b);
        addedge(a,b);
    }
}

int main(){
    init();
    tarjan();
    solve();
    flush();
    return 0;
}
```


