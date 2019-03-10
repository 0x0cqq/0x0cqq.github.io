---
title: 「Luogu3765」总统选举-平衡树-线段树
urlname: luogu-3765
date: 2018-04-25 23:30:25
tags:
- 题解
- 数据结构
- 平衡树
- 线段树
categories: OI
visible:
---


秋之国共有$n$个人，分别编号为$1,2,...,n$，一开始每个人都投了一票，范围$[1,n]$，表示支持对应编号的人当总统。共有$m$次预选，每次选取编号$[l_i,r_i]$内的选民展开小规模预选，在该区间内获得超过区间大小一半的票的人获胜，如果没有人获胜，则由小$C$钦定一位候选者获得此次预选的胜利（获胜者可以不在该区间内），每次预选的结果需要公布出来，并且每次会有$k_i$个人决定将票改投向该次预选的获胜者。全部预选结束后，公布最后成为总统的候选人，没有候选人的话输出$-1$。

<!-- more -->

## 链接

[Luogu P3765](https://www.luogu.org/problemnew/show/P3765)

## 题解

非常有趣的一道题。

BZOJ的2456可以启发到这道题。

那道题是：

> 给你一个$n$个数的数列，其中某个数出现了超过$\frac {n}{2}$次即为绝对众数，请你找出那个数。

做法则是:

> 如果众数出现了超过$\frac {n}{2}$次，那么任意删除序列中的两个不同的数，众数的出现次数仍然超过一半。不停地进行下去，最终剩下的一个数即为众数。*(摘自[Menci's Blog](https://oi.men.ci/bzoj-2456))*

这件事是可以用线段树维护的。

所以可以用线段树维护这个信息，就可以在$O(\log {n})$的时间里查询到某个区间可能的区间绝对众数。可以证明，如果区间有绝对众数，那么这个数一定就是。但是也可以发现，这个数不一定就是绝对众数，所以我们需要检验。

这个时候我们建立$n$棵平衡树，共用一个$pool$。我们可以直接用数组中的节点编号来代表它的$val$。检验的时候，找到待查询数字的根节点，然后查询在$[l,r]$区间内有多少个数，也就是$getrank(r+1) - getrank(l)$。然后就可以检验出给定的数是不是给定的区间的绝对众数了。

修改投票也很简单，线段树直接修改然后一路维护就好，平衡树的话就在旧树里删掉，新树里加上就可以了。

时间复杂度大概是

$$O((n+\sum_{i = 1}^{n} {k_i}) \log {n})$$

可以过掉本题。

> 妙啊！

## 代码



```cpp
#include <cstdio>
#include <cctype>
#include <cstdlib>
#include <algorithm>
using namespace std;

namespace fast_io {
    //...
}using namespace fast_io;
const int MAXN = 550000;
int n,m,num[MAXN];

//平衡树
namespace Treap{
int nowcnt = 0;
int p[MAXN],son[MAXN][2];
int siz[MAXN];
int root[MAXN];
void update(int x){
    siz[x] = siz[son[x][0]] + siz[son[x][1]] + 1;
}
void rotate(int &x,int t){
    int y = son[x][t];
    son[x][t] = son[y][1-t];
    son[y][1-t] = x;
    update(x),update(y);
    x = y;
}
void insert(int &x,int v){
    if(!x){
        x = v,p[x] = rand();
    }
    else{
        int t = v > x;
        insert(son[x][t],v);
        if(p[son[x][t]] < p[x])
            rotate(x,t);
    }
    update(x);
}
void erase(int &x,int v){
    if(x == v){
        if(!son[x][0] && !son[x][1]){
            x = 0;return;
        }
        int t = p[son[x][0]] > p[son[x][1]];
        rotate(x,t);
        erase(x,v);
    }
    else{
        erase(son[x][v > x],v);
    }
    update(x);
}
int grank(int r,int v){
    int x = r,ans = 0;
    while(x){
        if(v < x)
            x = son[x][0];
        else if(v == x)
            ans += siz[son[x][0]],x = 0;
        else
            ans += siz[son[x][0]]+1,x = son[x][1]; 
    }
    return ans;
}
void __print(int x,int dep){
    if(dep == 0)
        printf("%d:-------------------\n",x);
    if(x == 0) return;
    __print(son[x][0],dep+1);
    for(int i = 0;i<dep;i++) putchar(' ');
    printf("v:%d p:%d siz:%d son:%d %d\n",x,p[x],siz[x],son[x][0],son[x][1]);
    __print(son[x][1],dep+1);
    if(dep == 0)
        printf("---------------------\n");
}
bool check(int num,int l,int r){
    return 2*(grank(root[num],r+1)-grank(root[num],l)) > r-l+1;
}
void update(int pos,int last,int now){
    erase(root[last],pos);
    insert(root[now],pos);
}
void init(int *a){
    p[0] = 2147483647;
    for(int i = 1;i<=n;i++)
        insert(root[a[i]],i);
}
}

//线段树
namespace seg_tree{
#define lson (nown<<1)
#define rson ((nown<<1)|1)
#define mid ((l+r)>>1)
#define pp pair<int,int>
#define fr first
#define sc second
pp tree[MAXN<<2];
pp merge(pp a,pp b){
    pp ans;
    if(a.fr == b.fr)
        ans.fr = a.fr,ans.sc = a.sc + b.sc;
    else{
        ans.fr = a.sc > b.sc?a.fr:b.fr;
        ans.sc = a.sc - b.sc;
        if(ans.sc < 0) ans.sc *= -1;
    }
    return ans;
}
void update(int nown){
    tree[nown] = merge(tree[lson],tree[rson]);
}
void build(int nown,int l,int r,int *a){
    if(l == r){
        tree[nown] = make_pair(a[l],1);
        return;
    }
    build(lson,l,mid,a);
    build(rson,mid+1,r,a);
    update(nown);
}
pp query(int nown,int l,int r,int ql,int qr){
    if(ql <= l && r <= qr)
        return tree[nown];
    else{
        pp ans;
        if(ql <= mid && mid+1 <= qr)
            ans = merge(query(lson,l,mid,ql,qr),query(rson,mid+1,r,ql,qr));              
        else if(ql <= mid)
            ans = query(lson,l,mid,ql,qr);
        else if(mid+1 <= qr)
            ans = query(rson,mid+1,r,ql,qr);
        return ans;
    }
}
void update(int nown,int l,int r,int pos,int val){
    if(l == r)
        tree[nown] = make_pair(val,1);
    else{
        if(pos<=mid)
            update(lson,l,mid,pos,val);
        if(pos>=mid+1)
            update(rson,mid+1,r,pos,val);
        update(nown);
    }
}
}

void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++)
        read(num[i]);
    seg_tree::build(1,1,n,num);
    Treap::init(num);
}

void solve(){
    int l,r,s,k,t,win;
    for(int i = 1;i<=m;i++){
        read(l),read(r),read(s),read(k);
        win = seg_tree::query(1,1,n,l,r).first;
        win = Treap::check(win,l,r)? win:s;
        for(int i = 1;i<=k;i++){
            read(t);
            Treap::update(t,num[t],win);
            seg_tree::update(1,1,n,t,win);
            num[t] = win;
        }
        print(win),print('\n');
    }
    win = seg_tree::query(1,1,n,1,n).first;
    win = Treap::check(win,1,n)?win:-1;
    print(win),print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```


