---
title: 「HNOI2010」弹飞绵羊-动态树
urlname: HNOI2010-bounce
date: 2018-05-18 18:52:39
tags:
- LCT
- 数据结构
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

游戏一开始，`Lostmonkey` 在地上沿着一条直线摆上 $n$ 个装置，每个装置设定初始弹力系数 $K_i$ ，当绵羊达到第 $i$ 个装置时，它会往后弹 $K_i$ 步，达到第 $i+K_i$ 个装置，若不存在第 $i+K_i$ 个装置，则绵羊被弹飞。

存在两种操作：

+ 查询在第 $i$ 个装置起步时，再经多少次会被弹飞。

+ 修改第 $i$ 个装置的弹力系数为 $K'$ 。

保证任何时候，任何装置弹力系数均为正整数。

<!--more-->

## 链接

[Luogu P3203](https://www.luogu.org/problemnew/show/P3203)

[BZOJ 2002](https://www.lydsy.com/JudgeOnline/problem.php?id=2002)

## 题解

`Link_Cut_Tree`比较好想的一道题。

我们注意到，这 $n$ 个装置的弹力系数可以抽象成一颗树，即连接第$i$和第 $i+K_i$ 个节点的边，并且弹力系数的正整数的性质使其不存在环。

对于弹出去的装置，我们都用一个 $n+1$ 号点来代替。每次在`Link_Cut_Tree`上查询 $i$ 到 $i+K_i$ 的距离，即为答案。修改的时候，我们先断掉与原来的 $i+K_i$ 的边，再连上到 $i+K'$ 的边，更新弹力系数数组即可。

注意这里的装置编号是 $0\to n-1$ 的，所以可以统一进行 $+1$ 处理。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <cctype>
using namespace std;

const int MAXN = 510000;
namespace fast_io {
    //...
}using namespace fast_io;

struct Link_Cat_Tree{
    int sum[MAXN];
    int f[MAXN],c[MAXN][2];
    bool rev[MAXN];
    void push_up(int x){
        sum[x] = sum[c[x][0]] + sum[c[x][1]] + 1;
    }
    void reverse(int x){
        if(!x) return;
        swap(c[x][0],c[x][1]);
        rev[x] ^= 1;
    }
    void push_down(int x){
        if(!x) return;
        if(rev[x]){
            reverse(c[x][0]);
            reverse(c[x][1]);
            rev[x] = 0;
        }
    }
    bool noroot(int x){
        return (c[f[x]][0] == x) || (c[f[x]][1] == x);
    }
    void push_all(int x){
        if(!x) return;
        if(noroot(x)) push_all(f[x]);
        push_down(x);
    }
    void rotate(int x){
        int y = f[x],z = f[y],t = (c[y][1] == x),w = c[x][1-t];
        if(noroot(y)) c[z][c[z][1]==y] = x;
        c[x][1-t] = y,c[y][t] = w; 
        if(w) f[w] = y;
        f[y] = x;f[x] = z;
        push_up(y),push_up(x); 
    }
    void splay(int x){
        push_all(x);
        while(noroot(x)){
            int y = f[x],z = f[y];
            if(noroot(y)){
                if((c[y][1]==x)^(c[z][1]==y)) rotate(x);
                else rotate(y);
            }rotate(x);
        }
    }
    void access(int x){
        for(int y = 0;x;x = f[y=x]){
            splay(x);c[x][1] = y;
            push_up(x);
        }
    }
    void makeroot(int x){
        access(x),splay(x),reverse(x);
    }
    int find(int x){
        access(x),splay(x);
        push_down(x);
        while(c[x][0])
            x = c[x][0],push_down(x);
        return x;
    }
    void link(int x,int y){
        makeroot(x);
        if(find(y)!=x)
            f[x] = y;
    }
    void cat(int x,int y){
        makeroot(x);//find == splay
        if(find(y) == x && f[x] == y && !c[x][1])
            f[x] = c[y][0] = 0,push_up(y);
    }
    int query(int u,int v){
        makeroot(v);
        //if(find(v)!=find(u)) return -1;
        access(u);splay(u);
        return sum[u];
    }
    void print(int n){
        for(int i = 1;i<=n;i++){
            printf("%d: sum:%d f:%d c:%d %d r:%d\n",i,sum[i],f[i],c[i][0],c[i][1],int(rev[i]));
        }
    }
};


int n,m,num[MAXN];
Link_Cat_Tree T;
void init(){
    read(n);
    for(int i = 1;i<=n;i++)
        read(num[i]);
    for(int i = 1;i<=n;i++)
        T.link(i,min(i+num[i],n+1));
}
void solve(){
    read(m);
    int op,a,b;
    for(int i = 1;i<=m;i++){
        read(op);read(a);++a;
        if(op == 1)
            print(T.query(a,n+1)-1),print('\n');
        else if(op == 2){
            read(b);
            T.cat(a,min(a+num[a],n+1));
            T.link(a,min(a+b,n+1));
            num[a] = b;
        }
    }
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

