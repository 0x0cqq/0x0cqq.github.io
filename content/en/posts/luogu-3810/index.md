---
title: 「模板」陌上花开-CDQ分治+树状数组
urlname: template-flowers
date: 2018-06-06 19:16:30
tags:
- CDQ分治
- 树状数组
- 模板
categories: 
- OI
- 题解
series:
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

有 $n$ 朵花,每朵花有三个属性：花形( $s$ )、颜色( $c$ )、气味( $m$ )，用三个整数表示。显然，两朵花可能有同样的属性。

定义一朵花 $A$ 比另一朵花 $B$ 要美丽，当且仅当 $S_a\geq S_b$ , $C_a\geq C_b$ , $M_a \geq M_b$ 。定义一朵花的等级是它拥有的美丽能超过的花的数量。

求出每个等级的花的数量。

<!--more-->

> 陌上花开，可缓缓归矣。

## 链接

[Luogu P3810](https://www.luogu.org/problemnew/show/P3810)

## 题解

这道题还有一个名字叫「三维偏序」，题面如下：

> 有 $n$ 个元素，第 $i$ 个元素有 $a_i$ 、$b_i$ 、$c_i$ 三个属性，设 $f(i)$ 表示满足 $a_j \leq a_i$ 且 $b_j \leq b_i$ 且 $c_j \leq c_i$ 的 $j$ 的数量。
>
> 对于$d \in [0, n)$，求$f(i) = d$的数量

我在这里使用上面的题面。（虽然是一样的。

这是一道三维偏序的模版题。很多一些二维的问题经过转化也可以变成三维偏序的类似问题，套用排序+CDQ分治+BIT来解决。

假设所有的 $(a,b,c)$ 互不相同。

- - -

第一维：排序

按照 $a$ 的大小排序从新编号 $1 -> n$ ，排序完成后就可以发现对于第 $i$ 个元素，满足条件的元素只存在于 $[1,i-1]$ 中。问题转化为：在 $[1,i-1]$ 中有多少个满足 $b_i \geq b_j$ 且 $c_i \geq c_j$ 的元素。

这个问题其实就是二维数点。因为 $b$ 乱序添加，所以不能离线解决，可以用树套树在线解决。

但是呢，我们用 $CDQ$ 分治，就可以化动态为静态。

- - -

第二维：$CDQ$ 分治

什么是 $CDQ$ 分治呢？在这里就是一个类似归并排序的东西，因为我们要统计的是小于一个数的个数。

事实上在这里，我们对于每一个元素 $i$ ，都将其看成同样内容的一次询问和一次修改。

我们在解决一个询问的区间 $[L,R]$ 时，我们**只需要累计这个区间里左半部分的修改对右半部分的查询的贡献**就可以了。正确性不太显然，跟树状数组类似，查询时能够涵盖 $[1,i-1]$区间。

第三维也可以接着用 $CDQ$ 分治，那就真的是归并排序了。就像归并统计逆序对似的，我们在第三维按 $c$ 进行归并排序。只需要多维护一个标记，标记在上一维里面其属于左区间还是右区间，来决定在归并时是否累及答案。

- - -

第三维：树状数组

第三维有更方便的做法，也就是用树状数组。

第二维中，我们只需要将左侧的 $c$ 按照 $b$ 在归并中的顺序加入树状数组，然后归并加入右侧元素的时候查询比 $c$ 小的数累积答案，最后得到的就是在左半区间所有 $b$ 比它小，而且 $c$ 也比它小的数的个数。

- - -

相同元素怎么处理？

在改之前强行累积一下就可以了，把后面的数对于前面的贡献给预先加上去就可以了。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

int n,k;
const int MAXN = 210000;

namespace fast_io{
    //...
}using namespace fast_io;

namespace BIT{
    int sumn[MAXN];
    int lowbit(int x){return x & (-x);}
    void add(int x,int d){
        for(;x <= k;x += lowbit(x))
            sumn[x] += d;
    }
    int query(int x){
        int ans = 0;
        for(;x >= 1;x -= lowbit(x))
            ans += sumn[x];
        return ans;
    }
}


struct Q{
    int a,b,c;
    Q(){}
    Q(int x,int y,int z):a(x),b(y),c(z){}
    bool operator < (Q w)const{
        if(a != w.a) return a < w.a;
        if(b != w.b) return b < w.b;
        else         return c < w.c;
    }
    bool operator == (Q w)const{
        return a == w.a && b == w.b && c == w.c;
    }
}q[MAXN];

bool judge(int x,int y){
    // 用于第二维的归并判断
    if(q[x].b!=q[y].b)
        return q[x].b < q[y].b;//比较两数的c
    if(q[x].c!=q[y].c)
        return q[x].c < q[y].c;//比较两数的c
    else
        return x < y;//最后比较两数的id
}

int d[MAXN],ans[MAXN],tt[MAXN];

int tmp[MAXN];

int tot,l,r;

void CDQ(int *t,int num,int depth = 0){
    //t[0] -> t[num-1] (num个元素） 
    if(num == 1) return;
    int mid = num/2;
    CDQ(t,mid,depth+1),CDQ(t+mid,num-mid,depth+1);
    // 递归分治问题
    for(tot = 0,l = 0,r = mid;l < mid && r < num;tot++){
        //归并过程，统计左半区间对右半区间的贡献
        //如果在左区间，就把其当作修改，更新树状数组
        //如果在右区间，就把其当作查询，查询树状数组，更新答案
        if(judge(t[l],t[r]))
            BIT::add(q[t[l]].c,1),tmp[tot] = t[l++];
        else
            ans[t[r]] += BIT::query(q[t[r]].c),tmp[tot] = t[r++];
    }
    //剩余的归并
    while(l < mid)
        BIT::add(q[t[l]].c,1),tmp[tot++] = t[l++];
    while(r < num)
        ans[t[r]] += BIT::query(q[t[r]].c),tmp[tot++] = t[r++];
    for(int i = 0;i<mid;i++) BIT::add(q[t[i]].c,-1);//清空树状数组
    memcpy(t,tmp,sizeof(int) * num);//拷贝数组
}

void init(){
    read(n),read(k);
    int a,b,c;
    for(int i = 1;i<=n;i++){
        read(a),read(b),read(c);
        q[i] = Q(a,b,c);
    }
}

void solve(){
    sort(q+1,q+n+1);
    for(int i = n;i>=1;--i){
        // 累计相同元素的贡献
        if(q[i] == q[i+1])
            ans[i] = ans[i+1] + 1;
        tt[i] = i;
    }
    CDQ(tt+1,n);
    for(int i = 1;i<=n;i++)
        ++d[ans[i]];
    for(int i = 0;i<n;i++)
        print(d[i]),print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
} 
```




