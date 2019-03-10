---
title: 「ZJOI2012」网络-LCT
urlname: ZJOI2012-network
date: 2018-08-03 19:41:40
tags:
- 题解
- 数据结构
- 树形结构
- Link Cut Tree(LCT)
- 动态树
categories: OI
visible:
---

有一个无向图$G$，每个点有个权值，每条边有一个颜色。这个无向图满足以下两个条件：

+ 对于任意节点连出去的边中，相同颜色的边不超过两条。
+ 图中不存在同色的环，同色的环指相同颜色的边构成的环。

在这个图上，你要支持以下三种操作：

+ 修改一个节点的权值。
+ 修改一条边的颜色。
+ 查询由颜色$c$的边构成的图中，$u$到节点$v$之间的简单路径上的节点的权值的最大值。

对于$100%$的数据，保证颜色不多于$10$种。

<!-- more -->

## 链接

[Luogu P2173](https://www.luogu.org/problemnew/show/P2173)

## 题解

对于每一种颜色维护一颗维护最大值的$LCT$，点权对于所有的树都要改，改边的颜色的话相当于删边再加边，最大值查询就好。

错误判断的话就是LCT的正常操作，再维护一个度数就可以了。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <cctype>
using namespace std;

inline char read(){
    const int SIZE = 1024*1024;
    static char *s,*t,ibuf[SIZE];
    if(s == t)
        t = (s = ibuf) + fread(ibuf,1,SIZE,stdin);
    return s == t ? -1: (*s++);
}

inline void read(int &x){
    static bool iosig = 0;char ch;
    for(ch = read(),iosig = 0;!isdigit(ch);ch= read()){
        if(ch == '-') iosig = 1;
        if(ch == -1) return;
    }
    for(x = 0;isdigit(ch);ch = read())
        x = (((x<<2)+x)<<1) + (ch^48);
    if(iosig) x = -x;
}

const int MAXN = 13000;

struct Link_Cat_Tree{
    int v[MAXN],maxn[MAXN];
    int f[MAXN],c[MAXN][2];
    bool rev[MAXN];
    void push_up(int x){
        maxn[x] = max(max(maxn[c[x][0]],maxn[c[x][1]]),v[x]);
    }
    void reverse(int x){
        swap(c[x][0],c[x][1]);
        rev[x] ^= 1;
    }
    void push_down(int x){
        if(rev[x]){
            reverse(c[x][0]),reverse(c[x][1]);
            rev[x] = 0;
        }
    }
    bool noroot(int x){
        return c[f[x]][0] == x || c[f[x]][1] == x;
    }
    void push_all(int x){
        if(noroot(x))
            push_all(f[x]);
        push_down(x);
    }
    void rotate(int x){
        int y = f[x],z = f[y],t = (c[y][1] == x),w = c[x][1-t];
        if(noroot(y)) c[z][c[z][1]==y] = x;
        c[y][t] = w,c[x][1-t] = y;
        if(w) f[w] = y;
        f[x] = z,f[y] = x;
        push_up(y),push_up(x);
    }
    void splay(int x){
        push_all(x);
        while(noroot(x)){
            int y = f[x],z = f[y];
            if(noroot(y)){
                if((c[y][1]==x)^(c[z][1]==y))
                    rotate(x);
                else rotate(y);
            }rotate(x);
        }
    }
    void access(int x){
        for(int y = 0;x;x = f[y = x]){
            splay(x);c[x][1] = y;
            push_up(x);
        }
    }
    void makeroot(int x){
        access(x),splay(x),reverse(x);
    }
    void split(int x,int y){//split后y位于树根（代表整条链
        makeroot(x),access(y),splay(y);
    }
    int find(int x){
        access(x),splay(x);
        push_down(x);
        while(c[x][0]){
            x = c[x][0],push_down(x);
        }
        return x;
    }
    bool link(int x,int y){
        makeroot(x);
        if(find(y) != x){
            f[x] = y;
            return 1;
        }else return 0;
    }
    bool judge(int x,int y){
        makeroot(x);
        return find(y) == x && f[x] == y && !c[x][1];
    }
    bool cat(int x,int y){
        makeroot(x);//find 之后 y 位于 树根
        if(find(y) == x && f[x] == y && !c[x][1]){
            f[x] = c[y][0] = 0;push_up(y);
            return 1;
        }else return 0;
    }
    void update(int x,int val){
        makeroot(x);
        v[x] = val,push_up(x);
    }
    int query(int x,int y){
        makeroot(x);
        if(find(y)!=x)
            return -1;
        else{
            access(y),splay(y);
            return maxn[y];
        }
    }
}T[10];// Tree 0 -> 9
int d[MAXN][10];// degree 

int n,m,c,k;

void update(int x,int v){
    for(int i = 0;i<c;i++)
        T[i].update(x,v);
}

int change(int u,int v,int w){
    if(T[w].judge(u,v)) return 0;
    for(int i = 0;i<c;i++){
        if(T[i].judge(u,v)){
            if(d[u][w] >= 2 || d[v][w] >= 2)
                return 1;
            else{
                if(!T[w].link(u,v))
                    return 2;
                else{
                    d[u][i]--,d[v][i]--;
                    T[i].cat(u,v);
                    d[u][w]++,d[v][w]++;
                    return 0;
                }
            }
        }
    }
    return -1;
}

void init(){
    read(n),read(m),read(c),read(k);
    int u,v,w;
    for(int i = 1;i<=n;i++){
        read(v);
        update(i,v);
    }
    for(int i = 1;i<=m;i++){
        read(u),read(v),read(w);
        T[w].link(u,v);
        d[u][w]++,d[v][w]++;
    }
}

int query(int u,int v,int w){
    return T[w].query(u,v);
}

void solve(){
    int op,u,v,w;
    for(int i = 1;i<=k;i++){
        read(op);
        if(op == 0){
            read(u),read(v);
            update(u,v);
        }
        else if(op == 1){
            read(u),read(v),read(w);
            int t = change(u,v,w);
            if(t>0) printf("Error %d.\n",t);
            else if(t==-1) printf("No such edge.\n");
            else printf("Success.\n");
        }
        else if(op == 2){
            read(w),read(u),read(v);
            printf("%d\n",query(u,v,w));
        }
    }
}

int main(){
    init();
    solve();
    return 0;
}
```

