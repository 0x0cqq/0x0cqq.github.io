---
title: 「IOI2014」Wall-线段树
urlname: IOI2014-Wall
date: 2018-07-17 19:51:27
tags:
- 数据结构
- 线段树
categories: 
- OI
- 题解
visible:
---

给定一个长度为 $n$ 且初始值全为 $0$ 的序列。你需要支持以下两种操作：

+ $Add\, L, R, h$ ：将序列 $[L, R]$ 内所有值小于 $h$ 的元素都赋为 $h$，此时不改变高度大于 $h$ 的元素值
+ $Remove\, L, R, h$：将序列 $[L, R]$ 内所有值大于 $h$ 的元素都赋为 $h$ ，此时不改变高度小于 $h$ 的元素值

你需要输出进行 $k$ 次上述操作之后的序列。

<!-- more -->

## 链接

[Luogu P4560](https://www.luogu.org/problemnew/show/P4560)

## 题解

维护两个标记，近乎于线段树裸题。不过这种写法很有趣，可以积累一下。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <cctype>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;

const int MAXN = 2100000,INF = 0x3f3f3f3f;
namespace SegTree{
#define ls (o<<1)
#define rs (o<<1|1)
#define mid ((l+r)>>1)
int high[MAXN<<2],low[MAXN<<2];
// op == 1 修改向上 op == 2 修改向下
void turn(int o,int v,int op){
    if(op == 1){
        low[o] = max(low[o],v);
        high[o] = max(high[o],v);
    }
    if(op == 2){
        low[o] = min(low[o],v);
        high[o] = min(high[o],v);
    }
}
void push_down(int o){
    if(high[o]!=INF){turn(ls,high[o],2),turn(rs,high[o],2),high[o]=INF;}
    if(low[o]!=0){turn(ls,low[o],1),turn(rs,low[o],1),low[o]=0;}
}
void update(int o,int l,int r,int ql,int qr,int v,int op){
    if(ql <= l && r <= qr)
        turn(o,v,op);
    else{
        push_down(o);
        if(ql <= mid) update(ls,l,mid,ql,qr,v,op);
        if(qr >= mid+1) update(rs,mid+1,r,ql,qr,v,op);
    }
}
void output(int o,int l,int r,int *num){
    if(l == r) num[l] = high[o];
    else{
        push_down(o);
        output(ls,l,mid,num);
        output(rs,mid+1,r,num);
    }
}
}
int n,m;

void init(){
    read(n),read(m);
}

void solve(){
    int op,l,r,c;
    for(int i = 1;i<=m;i++){
        read(op),read(l),read(r),read(c);
        SegTree::update(1,1,n,l+1,r+1,c,op);
    }
    static int ans[MAXN];
    SegTree::output(1,1,n,ans);
    for(int i = 1;i<=n;i++){
        print(ans[i]),print('\n');
    }
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

