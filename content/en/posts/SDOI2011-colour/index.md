---
title: 「SDOI2011」染色-树链剖分+线段树
urlname: SDOI2011-colour
date: 2018-03-14 21:20:54
tags:
- 数据结构
- 树链剖分
- 线段树
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

给定一棵有 $n$ 个节点的无根树和 $m$ 个操作，操作有两类：
+ 将节点 $a$ 到节点 $b$ 路径上所有点都染成颜色 $c$ ；
+ 询问节点 $a$ 到节点 $b$ 路径上的颜色段数量（连续相同颜色被认为是同一段），

如“112221”由3段组成：“11”、“222”和“1”。

请你写一个程序依次完成这 $m$ 个操作。

<!--more-->

## 链接

[Luogu P2486](https://www.luogu.org/problemnew/show/P2486)

## 题解

这道题是一道不是很难的树链剖分+线段树的题目。

很明显是一道树链剖分的题目，我们只需要搞明白：如何维护区间的颜色块的数目。

很容易想到用线段树来维护这个东西。所以我们只要维护三个东西：**左端点的颜色，右端点的颜色，总共的颜色块数目。**

在合并的时候，如果左边块的右端点的颜色等于右边块的左端点颜色，就给总颜色块数目减1，就可以达成合并区间的目的。合并后的块的左颜色等于左孩子的左颜色，右颜色等于右孩子的右颜色。总共的颜色块数目是两块颜色块的数目加起来，再判一下前文提到的相同的颜色就行了

由于我太菜了，所以有的地方懒得去想，就多加了几个 `if else...` 了事，代码也就长些。

## 代码



```cpp

#include <cstdio>
#include <vector>
#include <cctype>
#define lson (nown<<1)
#define rson (nown<<1|1)
#define mid ((l+r)>>1)
using namespace std;

//快读模版
namespace fast_io {
    inline char read() {...}
    inline void read(int &x) {...}
    inline void read(char *a){...}
    const int OUT_LEN = 1000000;
    char obuf[OUT_LEN], *ooh = obuf;
    inline void print(char c) {...}
    inline void print(int x) {...}
    inline void print(char *a){...}
    inline void flush() {...}
}using namespace fast_io;

const int MAXN = 110000;

int n,m;
int son[MAXN],top[MAXN],fa[MAXN],siz[MAXN],dep[MAXN];
int id[MAXN],id_to[MAXN],num[MAXN],cnt = 1;

vector<int> edge[MAXN];

//线段树节点定义
struct node{
    int num,lcol,rcol;
    bool lazy;
    node(int n = 0,int l = 0,int r = 0):num(n),lcol(l),rcol(r){};
    bool empty(){
        return num == 0;
    }
}pool[MAXN<<2];

//线段树节点的合并
inline node merge(node l,node r){
    //特判！！！
    if(l.empty()) return r;
    if(r.empty()) return l;
    node ans;
    ans.num = l.num+r.num;
    if(l.rcol == r.lcol) ans.num-=1;
    ans.lcol = l.lcol,ans.rcol = r.rcol;
    return ans;
}

//线段树的标记下传
inline void push_down(int nown,int l,int r){
    if(pool[nown].lazy){
        int c = pool[nown].lcol;
        pool[lson] = node(1,c,c),pool[lson].lazy = 1;
        pool[rson] = node(1,c,c),pool[rson].lazy = 1;
        pool[nown].lazy = 0;
    }
}

//反转区间
inline node reverse(node nown){
    swap(nown.lcol,nown.rcol);
    return nown;
}

//建树
inline void build(int nown,int l,int r){
    pool[nown].lazy = 0;
    if(l == r)
        pool[nown] = node(1,num[id_to[l]],num[id_to[l]]);
    else{
        build(lson,l,mid);
        build(rson,mid+1,r);
        pool[nown] = merge(pool[lson],pool[rson]);
    }
}

//线段树区间更新
inline void update(int nown,int l,int r,int ql,int qr,int c){
    if(ql<=l&&r<=qr){
        pool[nown] = node(1,c,c);
        pool[nown].lazy = 1;
    }
    else{
        push_down(nown,l,r);
        if(ql<=mid) update(lson,l,mid,ql,qr,c);
        if(qr>=mid+1) update(rson,mid+1,r,ql,qr,c);
        pool[nown] = merge(pool[lson],pool[rson]);
    }
}

//线段树区间查询颜色块树
inline node query(int nown,int l,int r,int ql,int qr){
    if(ql<=l&&r<=qr)
        return pool[nown];//这里的返回值是整个结构体
    else{
        push_down(nown,l,r);
        if(ql<=mid && mid+1<=qr){
            node ls,rs;
            ls = query(lson,l,mid,ql,qr);
            rs = query(rson,mid+1,r,ql,qr);
            return merge(ls,rs);
        }
        else if(qr<=mid)
            return query(lson,l,mid,ql,qr);
        else if(ql>=mid+1)
            return query(rson,mid+1,r,ql,qr);
    }
}

/*--- 以下为树链剖分模版 ---*/
inline void dfs1(int nown,int f,int depth){
    dep[nown] = depth,fa[nown] = f,siz[nown] = 1;
    son[nown] = 0;int maxsum = -1;
    for(int i = 0;i<edge[nown].size();i++){
        int to = edge[nown][i];
        if(to == f) continue;
        dfs1(to,nown,depth+1);
        siz[nown]+=siz[to];
        if(siz[to]>maxsum) maxsum = siz[to],son[nown] = to;
    }
}

inline void dfs2(int nown,int topf){
    top[nown] = topf,id[nown] = cnt,id_to[cnt] = nown;cnt++;
    if(!son[nown]) return;
    dfs2(son[nown],topf);
    for(int i = 0;i<edge[nown].size();i++){
        int to = edge[nown][i];
        if(to == fa[nown]||to == son[nown]) continue;
        dfs2(to,to);
    }
}

void update_range(int x,int y,int c){
    while(top[x]!=top[y]){
        if(dep[top[x]]<dep[top[y]]) swap(x,y);
        update(1,1,n,id[top[x]],id[x],c);
        x = fa[top[x]];
    }
    if(dep[x]>dep[y]) swap(x,y);
    update(1,1,n,id[x],id[y],c);
}

//这里多用了几个if else 和reverse来让颜色块接对方向
//可以同时交换lans和rans等来完成这一项(未经验证)
int query_range(int x,int y){
    node lans = node(0,0,0),rans = node(0,0,0);
    while(top[x]!=top[y]){
        if(dep[top[x]] > dep[top[y]]){
            lans = merge(lans,reverse(query(1,1,n,id[top[x]],id[x])));
            x = fa[top[x]];
        }
        else{
            rans = merge(query(1,1,n,id[top[y]],id[y]),rans);
            y = fa[top[y]];
        }
    }
    if(dep[x]<dep[y])
        lans = merge(lans,query(1,1,n,id[x],id[y]));
    else
        rans = merge(reverse(query(1,1,n,id[y],id[x])),rans);
    return merge(lans,rans).num;
}
/*--- 以上为树链剖分模版 ---*/

//程序的初始化
inline void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++)
        read(num[i]);
    int a,b;
    for(int i = 1;i<=n-1;i++){
        read(a),read(b);
        edge[a].push_back(b);
        edge[b].push_back(a);
    }
    dfs1(1,0,1);
    dfs2(1,1);
    build(1,1,n);
}

//回应询问
void solve(){
    char op[20];int a,b,c;
    for(int i = 1;i<=m;i++){
        read(op),read(a),read(b);
        if(op[0] == 'C')
            read(c),update_range(a,b,c);
        else if(op[0] == 'Q')
            print(query_range(a,b)),print('\n');
    }
}


int main(){
    init();
    solve();
    flush();
    return 0;
}
```



