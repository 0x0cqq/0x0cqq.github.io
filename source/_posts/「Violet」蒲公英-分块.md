---
title: 「Violet」蒲公英-分块
urlname: violet-dandelions
date: 2018-03-31 11:30:45
tags:
- 题解
- 分块
categories: OI
visible:
---

给定一个数列${a\_n}$，$m$次询问在$[l,r]$区间内的最小众数。
强制在线。

<!-- more -->

## 链接

[Luogu P4168](https://www.luogu.org/problemnew/show/P4168)

## 题解

为了在课上讲分块，特地做了一道大分块的题。


做法一：
预处理出$z[i][j]$，表示在$[i,j]$个块的区间中的众数；$cnt[i][c]$，表示在前i个数中颜色为c的数的个数。

可以证明，一个区间的众数，肯定在整块的众数和零散块中出现的数中。

每次查询，先将答案设成整块的众数。对于零散的数，暴力统计出在零散块中出现的次数，然后加上在整块出现的次数（前缀和相减），尝试更新答案。

可以证明，复杂度大约是$O(n\ \sqrt{n} )$。

- - -

做法二：
预处理出$z[i][j]$，表示在$[i,j]$个块的区间中的众数；对于每一种颜色，开一个vector把这个数每次出现的位置，按从前到后顺序加进去。这样，我们可以在$O(\log{n})$的时间内通过二分查询出一个数在[l,r]区间出现了多少次。

可以证明，一个区间的众数，肯定在整块的众数和零散块中出现的数中。

每次查询，先将答案设成整块的众数，并且记录其在$[l,r]$出现次数，然后对于每一个零散块中的数，查询其在[l,r]中出现的次数，并尝试更新答案。

可以证明，复杂度大约是$O(n\ \sqrt {n}\ \log{n})$。这个复杂度存在被卡死的可能。

- - -

由于数据范围很大，需要离散化并且记录离散化后的数对应之前的数是什么。

## 代码

做法一：
{% fold %}
```cpp
#include <cstdio>
#include <cstring>
#include <cctype>
#include <cmath>
#include <algorithm>
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

const int MAXN = 101000,MAXQ = 1000;

struct pu{
    int col,id,belong;
}pgy[MAXN];

int n,m,Q;
int bl[MAXQ],br[MAXQ],id_to[MAXN],numc = 0;
int z[MAXQ][MAXQ],cnt[MAXN][MAXQ],t[MAXN];

bool cmp1(pu a,pu b){return a.col < b.col;}
bool cmp2(pu a,pu b){return a.id < b.id;}

void init(){
    read(n),read(m);Q = sqrt(n);
    for(int i = 1;i<=n;i++){
        read(pgy[i].col);
        pgy[i].id = i,pgy[i].belong = (i-1)/Q+1;

        if(!bl[pgy[i].belong]) 
            bl[pgy[i].belong] = i;
        br[pgy[i].belong] = i;
    }
    sort(pgy+1,pgy+n+1,cmp1);
    int lastc = 0;
    for(int i = 1;i<=n;i++){
        if(pgy[i].col!=lastc)
            numc++,id_to[numc] = pgy[i].col;
        lastc = pgy[i].col;
        pgy[i].col = numc;
    }
    sort(pgy+1,pgy+n+1,cmp2);
    
    for(int i = 1;i<=n;i++)
        cnt[pgy[i].col][pgy[i].belong]++;
    for(int i = 1;i<=numc;i++)
        for(int j = 1;j<=n/Q;j++)
            cnt[i][j] += cnt[i][j-1];
}

void build(){
    for(int i = 1;i<=n;i+=Q){
        memset(t,0,sizeof(t));
        int maxn = 0;
        for(int j = i;j<=n;j++){
            int nowc = pgy[j].col;
            t[nowc]++;
            if(t[nowc] > t[maxn] ||(t[nowc] == t[maxn] && nowc < maxn))
                maxn = nowc;
            if(j%Q == 0)
                z[(i-1)/Q+1][j/Q] = maxn;
        }
    }
}



int answer(int ql,int qr){
    int lb = pgy[ql].belong,rb = pgy[qr].belong,maxn = 0;
    //printf("lblock:%d rblock:%d\n",lb,rb);
    if(lb == rb || lb+1 == rb){
        for(int i = ql;i<=qr;i++)
            t[pgy[i].col] = 0;
        for(int i = ql;i<=qr;i++){
            int nowc = pgy[i].col;
            t[nowc]++;
            if(t[nowc] > t[maxn] ||(t[nowc] == t[maxn] && nowc < maxn))
                maxn = nowc;
        }
    }
    else{
        for(int i = ql;i<bl[lb+1];i++)
            t[pgy[i].col] = 0;
        for(int i = br[rb-1]+1;i<=qr;i++)
            t[pgy[i].col] = 0;
        maxn = z[lb+1][rb-1];
        t[maxn] = 0;
        for(int i = ql;i<bl[lb+1];i++){
            int nowc = pgy[i].col;
            t[nowc]++;
            int maxnum = t[maxn] + cnt[maxn][rb-1]-cnt[maxn][lb];
            int tmp = t[nowc] + cnt[nowc][rb-1]-cnt[nowc][lb];
            if(tmp > maxnum || (tmp == maxnum && nowc < maxn))
                maxn = nowc;
        }
        for(int i = br[rb-1]+1;i<=qr;i++){
            int nowc = pgy[i].col;
            t[nowc]++;
            int maxnum = t[maxn] + cnt[maxn][rb-1]-cnt[maxn][lb];
            int tmp = t[nowc] + cnt[nowc][rb-1]-cnt[nowc][lb];
            if(tmp > maxnum || (tmp == maxnum && nowc < maxn))
                maxn = nowc;
        }
    }
    return id_to[maxn];
}


void solve(){
    int a,b,lastans = 0;
    for(int i = 1;i<=m;i++){
        read(a),read(b);
        a = (a+lastans-1)%n+1,b = (b+lastans-1)%n+1;
        if(a > b) swap(a,b);
        lastans = answer(a,b);
        print(lastans),print('\n');
    }
}

int main(){
    init();
    build();
    solve();
    flush();
    return 0;
}
```
{% endfold %}

做法二：
{% fold %}

```cpp
#include <cstdio>
#include <cstring>
#include <cctype>
#include <cmath>
#include <algorithm>
#include <vector>
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

const int MAXN = 101000,MAXQ = 1000;

vector<int> pos[MAXN];

int n,m,Q;

struct pu{
    int col,id;
}pgy[MAXN];

//在[i,j]块中的众数
int z[MAXQ][MAXQ];

int id_to[MAXN];

bool cmp1(pu a,pu b){
    return a.col < b.col;
}

bool cmp2(pu a,pu b){
    return a.id < b.id;
}

void init(){
    read(n),read(m);Q = sqrt(n*5);
    for(int i = 1;i<=n;i++)
        read(pgy[i].col),pgy[i].id = i;
    sort(pgy+1,pgy+n+1,cmp1);
    int lastc = 0,numc = 0;
    for(int i = 1;i<=n;i++){
        if(pgy[i].col!=lastc)
            numc++,id_to[numc] = pgy[i].col;
        lastc = pgy[i].col;
        pgy[i].col = numc;
    }
    sort(pgy+1,pgy+n+1,cmp2);
    for(int i = 1;i<=n;i++){
        pos[pgy[i].col].push_back(i);
    }
}

void build(){
    static int t[MAXN];
    for(int i = 1;i<=n;i+=Q){
        memset(t,0,sizeof(t));
        int maxn = 0;
        for(int j = i;j<=n;j++){
            int nowc = pgy[j].col;
            t[nowc]++;
            if(t[nowc] > t[maxn] ||(t[nowc] == t[maxn] && nowc < maxn))
                maxn = nowc;
            if(j%Q == 0)
                z[(i-1)/Q+1][j/Q] = maxn;
        }
    }
}


int count_num(int lb,int rb,int num){
    return lower_bound(pos[num].begin(),pos[num].end(),rb+1)-lower_bound(pos[num].begin(),pos[num].end(),lb);
}

int answer(int ql,int qr){
    int lb = floor(double(ql-2)/Q)+2,rb = qr/Q,maxn = 0,maxnum = 0;
    if(lb <= rb) maxn = z[lb][rb],maxnum = count_num(ql,qr,maxn);
    //printf("lblock:%d rblock:%d\n",lb,rb);
    lb = (lb-1)*Q+1,rb = rb*Q;
    //printf("lbound:%d rbound:%d maxn:%d\n",lb,rb,maxn);
    while(ql < lb){
        --lb;
        int c = pgy[lb].col,w = count_num(ql,qr,c);
        if(w > maxnum || (w == maxnum && c < maxn))
            maxn = c,maxnum = w;
    }
    while(rb < qr){
        rb++;
        int c = pgy[rb].col,w = count_num(ql,qr,c);
        if(w > maxnum || (w == maxnum && c < maxn))
            maxn = c,maxnum = w;
    }
    return id_to[maxn];
}


void solve(){
    int a,b,lastans = 0;
    for(int i = 1;i<=m;i++){
        read(a),read(b);
        a = (a+lastans-1)%n+1,b = (b+lastans-1)%n+1;
        if(a > b) swap(a,b);
        lastans = answer(a,b);
        print(lastans),print('\n');
    }
}

int main(){
    init();
    build();
    solve();
    flush();
    return 0;
}
```

{% endfold %}
