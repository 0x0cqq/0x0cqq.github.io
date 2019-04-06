---
title: 「CQOI2011」动态逆序对-CDQ分治
urlname: CQOI2011-inverse
date: 2018-06-07 20:58:32
tags: 
- CDQ分治
- 数据结构
categories: 
- OI
- 题解
visible:
---

对于序列 $A$ ，它的逆序对数定义为满足 $i<j$ ，且 $A_i>A_j$ 的数对 $(i,j)$ 的个数。
给出一个 $1$ 到 $n$ 的排列，按照某种顺序依次删除 $m$ 个元素，你的任务是在每次删除一个元素之前统计整个序列的逆序对数。

<!-- more -->

## 链接

[BZOJ 3295](https://www.lydsy.com/JudgeOnline/problem.php?id=3295)

[Luogu P3157](https://www.luogu.org/problemnew/show/P3157)

## 题解

CDQ分治强啊。

这道题可以用树状数组&主席树做，不过很难写。

CDQ分治的话，实现难度上比较低一些吧。

首先，我们转化问题为每次在某个位置添加一个数，并查询能贡献出来的逆序对个数。这个问题和题目是等价的。

然后我们令这个删除的反着的顺序为$id$，其插入的位置为$b$，插入的值为$c$，我们要求的就是在$id \in [1,id - 1]$的数中，满足$b_j < b_i,c_j > c_i$或者$b_j > b_i,c_j < c_i$的j有多少个。

这个问题我们用CDQ归并解决。先按照id排序，然后对b进行归并，完成后正序和倒序各扫一遍，统计贡献，最后作前缀和即可。

实现有一点点不好写。

## 代码


```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
#include <cctype>
#define ll long long
using namespace std;

const int MAXN = 110000;

namespace fast_io{
    //...
}using namespace fast_io;

struct Q{
    bool w;
    int id,b,c;
    // id -> 加入时间 b -> 加入的位置 c -> 这个数的大小
    Q(int x,int y,int z):id(x),b(y),c(z){}
    Q(){}
    bool operator < (Q w)const{//用于排序
        if(id!=w.id) 
            return id < w.id;
        if(b!=w.b)
            return b < w.b;
        return c < w.c;
    }
}q[MAXN];

int n,m;
int num[MAXN],pos[MAXN],del[MAXN];
ll ans[MAXN];
// num -> 原数组
// pos -> 值对应的位置
// del -> 删除第 pos 个数的序顺 

namespace BIT{
    ll sumn[MAXN];
    int lowbit(int x){
        return x & (-x);
    }
    void add(int x,int d){
        while(x <= n) sumn[x] += d,x += lowbit(x);
    }
    ll query(int x){
        ll ans = 0;
        while(x >= 1) ans += sumn[x],x -= lowbit(x);
        return ans;
    }
}

void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++){
        read(num[i]);
        pos[num[i]] = i;
    }
    int tmp; 
    for(int i = 1;i<=m;i++){
        read(tmp);
        del[pos[tmp]] = i;
    }
}

int l,r,tot,tmp[MAXN];

inline bool judge(int x,int y){
    //判断归并顺序函数 这里因为不重复，可以不写其他维判定
    return q[x].b < q[y].b;
}


void CDQ(int *t,int num){
    if(num == 1) return;
    int mid = num/2;
    CDQ(t,mid),CDQ(t+mid,num-mid);//分治解决问题
    //进行归并
    for(l=0,r=mid,tot=0;tot < num;tot++){
        if((r==num)||(l<mid && judge(t[l],t[r])))//这一行的条件易错
            q[t[l]].w = 0,tmp[tot] = t[l++];
        else
            q[t[r]].w = 1,tmp[tot] = t[r++];
    }
    for(int i = 0;i<num;i++) t[i] = tmp[i];

    //统计id(time)比其小 b(pos)比其小 c(val)比其大的数的个数
    for(int i = 0;i<num;i++)
        if(!q[t[i]].w) BIT::add(q[t[i]].c,1);
        else ans[q[t[i]].id] += BIT::query(n)-BIT::query(q[t[i]].c);
    for(int i = 0;i<num;i++)
        if(!q[t[i]].w) BIT::add(q[t[i]].c,-1);
    //统计id(time)比其小 b(pos)比其大 c(val)比其小的数的个数
    for(int i = num-1;i>=0;--i)
        if(!q[t[i]].w) BIT::add(q[t[i]].c,1);
        else ans[q[t[i]].id] += BIT::query(q[t[i]].c-1);
    for(int i = num-1;i>=0;--i)
        if(!q[t[i]].w) BIT::add(q[t[i]].c,-1);
}

void solve(){
    int nowcnt = 0;
    static int tt[MAXN];
    for(int i = 1;i<=n;i++){
        //遍历每个pos 
        if(del[i] == 0) q[i] = Q(1,i,num[i]);
        else q[i] = Q(m-del[i]+2,i,num[i]);
    }
    sort(q+1,q+1+n);
    for(int i = 1;i<=n;i++)
        tt[i] = i;
    CDQ(tt+1,n);
    // 前缀和统计答案
    for(int i = 1;i<=m+1;i++)
        ans[i] += ans[i-1];
    for(int i = m+1;i>1;--i)
        print(ans[i]),print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

