---
title: 「SDOI2008」洞穴勘测-LCT
urlname: SDOI2008-cave
date: 2018-05-12 18:06:09
tags:
- 题解
- 数据结构
- 动态树
- Link Cut Tree(LCT)
categories: OI
visible:
---

辉辉热衷于洞穴勘测。

辉辉有一台监测仪器可以实时将通道的每一次改变状况，并在辉辉手边的终端机上显示：

`Connect u v`代表监测到洞穴u和洞穴v之间出现了一条通道，`Destroy u v`代表监测到洞穴u和洞穴v之间的通道被毁。`Query u v`，代表向监测仪询问此时洞穴u和洞穴v是否连通。

保证无论通道怎么改变，任意时刻任意两个洞穴之间至多只有一条路径。

已知在第一条指令显示之前，洞穴群中没有任何通道存在。

<!-- more -->

## 链接

[Luogu P2147](https://www.luogu.org/problemnew/show/P2147)

[BZOJ2049](https://www.lydsy.com/JudgeOnline/problem.php?id=2049)

## 题解

利用动态树维护森林的连通性。

每次寻找在对应原树中的根，一样就联通，否则不连通。不加更多解释。

注意判断一下加边和切边的合法性判断。

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

const int MAXN = 20000;

struct Link_Cat_Tree{
    int f[MAXN],c[MAXN][2];
    bool rev[MAXN];
    inline bool noroot(int x){
        return (c[f[x]][0] == x) || (c[f[x]][1] == x);
    }
    inline void reverse(int x){
        if(!x)  return;
        swap(c[x][0],c[x][1]);
        rev[x] ^= 1;
    }
    inline void push_down(int x){
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
    inline void rotate(int x){
        int y = f[x],z = f[y],t = (c[y][1] == x),w = c[x][1-t];
        if(noroot(y)) c[z][c[z][1] == y] = x;
        c[y][t] = w,c[x][1-t] = y;  
        if(w) f[w] = y;
        f[y] = x,f[x] = z;
    }
    inline void splay(int x){
        push_all(x);
        while(noroot(x)){
            int y = f[x],z = f[y];
            if(noroot(y)){
                if((c[z][1] == y) ^ (c[y][1] == x))
                    rotate(x);
                else rotate(y);
            }rotate(x);
        }
    }
    inline void access(int x){
        for(int y = 0;x;x = f[y=x])
            splay(x),c[x][1] = y;
    }
    inline void makeroot(int x){
        access(x);splay(x);reverse(x);
    }
    inline int find(int x){
        access(x),splay(x);
        push_down(x);
        while(c[x][0])
            x = c[x][0],push_down(x);
        return x;
    }
    inline void link(int x,int y){
        makeroot(x);
        if(find(y)!=x)
            f[x] = y;
    }
    inline void cat(int x,int y){
        makeroot(x);
        if(find(y) == x && f[x] == y && !c[x][1])
            f[x] = c[y][0] = 0;
    }
    inline int query(int x,int y){
        return int(find(x) == find(y));
    }
};

Link_Cat_Tree S;

int n,m;

char yes[6] = "Yes\n",no[5] = "No\n";

void solve(){
    read(n),read(m);
    char op[20];int a,b;
    for(int i = 1;i<=m;i++){
        read(op);read(a),read(b);
        if(op[0] == 'C')
            S.link(a,b);
        if(op[0] == 'D')
            S.cat(a,b);
        else if(op[0] == 'Q')
            print(S.query(a,b) ? yes:no);
    }
}

int main(){
    solve();
    flush();
    return 0;
}
```
{% endfold %}