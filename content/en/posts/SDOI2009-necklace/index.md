---
title: 「SDOI2009」HH的项链-莫队or树状数组
urlname: SDOI2009-necklace
date: 2018-02-05 18:11:47
tags:
- 莫队
- 树状数组
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

给定一个长度为 $n$ 的正整数序列 $A$ ,有 $m$ 次询问在 $[l,r]$ 区间内有多少个不同的数。

<!--more-->

## 链接

[Luogu P1972](https://www.luogu.org/problemnew/show/P1972)

## 题解

这道题目前我只会两种离线的做法。

### 做法一：莫队

其实做这道题的时候我是不会莫队了。但现在会了，又想写篇莫队的笔记，所以我把这篇题解写出来了。

首先对序列分块，以查询的左端点所在块的序号为第一关键字，右端点的位置为第二关键字排序，然后暴力转移。

时间复杂度： $O((m+n) \sqrt{n})$ 或者简单点： $O(n^\frac{3}{2})$

代码见最后。

### 做法二：离散化+树状数组

注意到，我们最重要的需要处理的就是重复的问题。如果不需要处理重复的问题，那么就可以直接用树状数组或者前缀和出解了。所以我们考虑到这样一个事情，能否使用某些~~玄学~~高端操作，使得我们不需要考虑重复的问题呢？

可以发现，如果一个数已经出现，那么我们就不需要考虑这个数在其他位置上的出现。因此我们有如下的思路：

把查询按照查询的右端点位置从小到大排序。为了发现某个数是否会在我们的查询的序列中出现，我们需要记录这个数最后一次在序列中出现的位置。如果查询区间的左端点在这个数的位置以左，那么查询区间内一定有这个数；而在这个数以右的话，查询区间里一定没有这个数。由于这个数出现多少次我们都只能算一次，所以这个最后出现的数就是我们判断是否含有这个数的依据。

所以我们在树状数组中只给每个数最后出现的这一位赋值 $1$ ,其余的由于上述，不能计入个数，值也就是 $0$ 。这样操作就满足了区间可减性，然后直接树状数组前缀和相减就可以得到每次的结果。

由于数字的范围较大，应该需要离散化。但由于这个跟时间复杂度关系不大，只与空间复杂度有关，所以我就没有这么写。

时间复杂度：$O((m+n) \log{n})$ 或者大体来说 $O(n \log{n})$

代码见下。

## 代码

这里提供两种方法的代码。

莫队代码：



```cpp
#include <cstdio>
#include <cmath>
#include <algorithm>
using namespace std;

struct Query{
    int id,l,r;
}query[201000];

int times[1001000],res[201000],num[51000];
int n,m,q;

bool cmp(Query a,Query b){
    if(a.l/q!=b.l/q)
        return a.l/q<b.l/q;
    else
        return a.r<b.r;
}


int main(){
    scanf("%d",&n);
    q = sqrt(n);//q是分块大小
    for(int i = 1;i<=n;i++)
        scanf("%d",&num[i]);
    scanf("%d",&m);
    for(int i = 0;i<m;i++){
        scanf("%d %d",&query[i].l,&query[i].r);
        query[i].id = i;
    }
    sort(query,query+m,cmp);//排序
    int l = 1,r = 1;
    int ans = 1;times[num[1]]++;
    for(int i = 0;i<m;i++){
        int ql = query[i].l,qr = query[i].r;
        //转移时先扩大再缩小
        while(ql<l){
            l--;
            if(times[num[l]]++ == 0) ans++;
        }
        while(r<qr){
            r++;
            if(times[num[r]]++ == 0) ans++;
        }
        while(l<ql){
            if(--times[num[l]] == 0) ans--;
            l++;
        }
        while(qr<r){
            if(--times[num[r]] == 0) ans--;
            r--;
        }
        res[query[i].id] = ans;
    }
    for(int i = 0;i<m;i++)
        printf("%d\n",res[i]);
    return 0;
}
```



- - -

离散化+树状数组代码：



```cpp
#include <cstdio>
#include <algorithm>
using namespace std;

inline int lowbit(int x){
    return x&(-x);
}

int n,m,num[51000],ans[201000],last[1001000];

int tree[201000];

struct que{
    int id,l,r,res;
}qq[1000000];

bool cmp(que a,que b){
    if(a.r!=b.r)
        return a.r<b.r;
    return a.l<b.l;
}

inline void insert(int nown,int val){
    for(int i = nown;i<=n;i+=lowbit(i))
        tree[i]+=val;
}

inline int query(int nown){
    int res = 0;
    for(int i = nown;i>0;i-=lowbit(i))
        res += tree[i];
    return res;
}

int main(){
    scanf("%d",&n);
    for(int i = 1;i<=n;i++)
        scanf("%d",&num[i]);
    scanf("%d",&m);
    for(int i = 0;i<m;i++){
        scanf("%d %d",&qq[i].l,&qq[i].r);
        qq[i].id = i;
    }
    sort(qq,qq+m,cmp);
    int end = 0;
    for(int i = 0;i<m;i++){
        while(end<qq[i].r){//更新last&树状数组
            end++;
            if(last[num[end]]!=0)//原来出现过就抹去last位置的数
                insert(last[num[end]],-1);
            insert(end,1);//树状数组加入新标记
            last[num[end]] = end;//更新last值
        }
        ans[qq[i].id] = query(qq[i].r) - query(qq[i].l-1);
    }
    for(int i = 0;i<m;i++)
        printf("%d\n",ans[i]);
    return 0;
}
```


