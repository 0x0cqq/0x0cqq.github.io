---
title: 「NOI2014」魔法森林-LCT
urlname: NOI2014-forest
date: 2018-06-16 11:36:51
tags:
- 题解
- 数据结构
- 动态树
- Link Cut Tree(LCT)
categories: OI
visible:
---

给定一个$n$个点$m$条边的无向图，每条边有两个权值$a_i,b_i$。请你找到一条从$1 \rightarrow n$ 的道路，令道路上所有边的集合为$S$，使$ans = \max(a_i)+\max(b_j),i,j \in S$最小，求出这个最小值$ans$。

<!-- more -->

## 链接

[Luogu P2387](https://www.luogu.org/problemnew/show/P2387)

[BZOJ 3669](https://www.lydsy.com/JudgeOnline/problem.php?id=3669)

## 题解

这题告诉我们了一个$LCT$(连猫树)的新用法：动态维护最小生成树。

思考一下：如果我们有一颗生成树，现在再添加进一条边，图里必然会出现一个环。而新的最小生成树就是在这个环里面砍掉最大的那一条边而得到的。

这是非常显然的。

可以发现一个结论，就是给定一个无向图，那么$1 \rightarrow n$路径上边权最大值最小的这些边一定在其最小生成树里面。这个只要考虑一下$Kruskal$算法的过程就很容易明白。

那么再回来看这个问题。如果这个地方只有一维的限制，那么我们就可以用并查集做。这是一个离线的做法，也就是我们把所有边一股脑的扔进去，拿到一个最小生成树，然后答案就是这两点之间的边权最大值。（其实是并查集直到两个东西联通为止）

但是现在有了$a$这一维的限制，该怎么办呢？考虑一下贪心的做法，我们可以利用$LCT$**动态**维护最小生成树的特点。

考虑对于$a$排序之后，就可以排除掉$a$对这个东西的干扰。然后我们按照$a$从小到大往树里面加边，每次维护最小生成树，答案就可以用$a_{now} + b_{max}$来求得，动态更新即可。

为什么这个东西是正确的呢？如果路径上的$a_{max} < a_{now}$，会不会对答案造成影响？

不会。因为如果$a_{max} < a_{now}$，那么在我们加到$a_{max}$这条边的时候，其所有路径上的边应该已经出现，就可以囊括$a_{max} + b_{max}$这种情况了。而如果后面换用了其他$b$更小的边，显然$a_{max}$会扩大为$a_{now}$，算法的正确性就可以保证了。

$LCT$只能维护点权，所以我们把边换成点，每次$link$或者$cat$的时候连或者猫两下就可以了。

## 代码

{% fold %}
```cpp
#include <cstdio>
#include <algorithm>
#include <cctype>
using namespace std;

namespace fast_io {
	//...
}using namespace fast_io;

const int MAXN = 151000;

struct Link_Cat_Tree{
    int val[MAXN],maxn[MAXN];
    int c[MAXN][2],f[MAXN];
    bool rev[MAXN];
    int getmax(int u,int x,int y){
        if(val[u] >= val[maxn[x]] && val[u] >= val[maxn[y]])
            return u;
        else if(val[maxn[x]] >= val[maxn[y]])
            return maxn[x];
        else 
            return maxn[y];
    }
    bool noroot(int x){
        return (c[f[x]][1] == x) || (c[f[x]][0] == x);
    }
    void push_up(int x){
        if(!x) return;
        maxn[x] = getmax(x,c[x][0],c[x][1]);
    }
    void reverse(int x){
        if(!x) return;
        swap(c[x][0],c[x][1]);
        rev[x]^=1;
    }
    void push_down(int x){
        if(!x) return;
        if(rev[x]){
            reverse(c[x][0]),reverse(c[x][1]);
            rev[x] = 0;
        }
    }
    void push_all(int x){
        if(!x) return;
        if(noroot(x)) push_all(f[x]);
        push_down(x);
    }
    void rotate(int x){
        int y = f[x],z = f[y],t = (c[y][1] == x),w = c[x][1-t];
        if(noroot(y)) c[z][c[z][1]==y] = x;
        c[x][1-t] = y;c[y][t] = w;
        if(w) f[w] = y;
        f[y] = x;f[x] = z;
        push_up(y),push_up(x);
    }
    void splay(int x){
        push_all(x);
        while(noroot(x)){
            int y = f[x],z = f[y];
            if(noroot(y))
                (c[z][1] == y) ^ (c[y][1] == x) ? rotate(x):rotate(y);
            rotate(x);
        }
    }
    void access(int x){
        for(int y = 0;x;x=f[y=x]){
            splay(x);
            c[x][1] = y,push_up(x);
        }
    }
    void makeroot(int x){
        access(x);splay(x);reverse(x);
    }
    int findroot(int x){
        access(x);splay(x);
        push_down(x);
        while(c[x][0])
            x = c[x][0],push_down(x);
        return x;
    }
    void link(int x,int y){
        makeroot(x);
        if(findroot(y) != x)
            f[x] = y;
    }
    void cat(int x,int y){
        makeroot(x);
        if(findroot(y) == x && f[x] == y && !c[x][1])
            f[x] = c[y][0] = 0,push_up(y);
    }
    void split(int x,int y){
        makeroot(x),access(y),splay(y);
    }
    int querymax(int x,int y){
        return split(x,y),maxn[y];
    }
}T;

//点1->n 边n+1->n+m
int n,m;

struct Edge{
    int from,to,a,b;
}edge[MAXN];

bool cmp(Edge x,Edge y){
    return x.a < y.a;
}

void init(){
    read(n),read(m);
    int a,b,f,t;
    for(int i = 1;i<=m;i++){
        read(f),read(t),read(a),read(b);
        edge[i] = (Edge){f,t,a,b};
    }
}

void solve(){
    int ans = 0x3f3f3f3f;
    sort(edge + 1,edge+m+1,cmp);
    for(int i = 1;i<=m;i++)
        T.val[n+i] = edge[i].b;
    for(int i = 1;i<=n+m;i++)
        T.maxn[i] = i;
    int x = 0,y = 0,a = 0,b = 0;
    for(int i = 1;i<=m;i++){
        x = edge[i].from,y = edge[i].to;
        a = edge[i].a,b = edge[i].b;
        if(x == y) continue;
        if(T.findroot(x)!=T.findroot(y))
            T.link(n+i,x),T.link(n+i,y);
        else{
            int t = T.querymax(x,y) - n;
            if(edge[t].b < b) continue;
            T.cat(n+t,edge[t].from),T.cat(n+t,edge[t].to);
            T.link(n+i,x),T.link(n+i,y);
        }
        if(T.findroot(1) == T.findroot(n))
            ans = min(ans,a+edge[T.querymax(1,n)-n].b);
    }
    if(ans > 1000000000)
        print(-1);
    else
        print(ans);
    print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```
{% endfold %}
