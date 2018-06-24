---
title: 「ZJOI2013」K大数查询-整体二分
urlname: ZJOI2013-kth
date: 2018-06-06 19:17:02
tags:
- 题解
- 整体二分
- 数据结构
categories: OI
visible:
---

有$N$个位置，$M$个操作。

操作有两种：
+ 如果是`1 a b c`的形式表示在第$a$个位置到第$b$个位置，每个位置加入一个数$c$；
+ 如果是`2 a b c`形式，表示询问从第$a$个位置到第$b$个位置，第$C$大的数是多少。

<!-- more -->

## 链接

[Luogu P3332](https://www.luogu.org/problemnew/show/P3332)

## 题解

可以树套树。然后基本上就会死在树上。

正解整体二分。

比较模板，就不讲思路了，主要说一说实现。这个地方的区间加数其实和单点加数是一样的，只不过把原来单点修改的树状数组改成区间修改的线段树。

注意，整体二分是按答案二分，每次二分我们的在原区间上处理范围仍然是整个区间，不要搞错成啥的...

还有注意，这里每一层递归的复杂度一定只能与你的正在处理的询问的个数有关！不能带有其他项，所以我们这里归零线段树的时候是一个个减回去，复杂度就是$O(n \log {n})$。

递归的每层都要处理$n$个操作，一共有$\log n$层，处理每个询问的时间是$O(\log n)$，最后的复杂度就是$O(n \log ^{2} {n})$。

莫名跑的就特别慢...明明我写了$zkw$线段树啊...`BZOJ`莫名$RE$...明明我`luogu`和`codevs`上全$AC$了啊...

## 代码

{% fold %}
```cpp
#include <cstdio>
#include <cstring>
#include <cctype>
using namespace std;
#define ll long long
#define mid ((l+r)>>1)
const int MAXN = 51000;

namespace fast_io{
    //...
}using namespace fast_io;

struct ZKW{
    //区间修改、求和zkw线段树
    ll sumn[MAXN<<2],addn[MAXN<<2];
    int M;
    void init(int n){
        for(M = 1;M<=n+2;M<<=1);
    }
    void update(int l,int r,ll d){
        int i=1,L=0,R=0;
        for(l=l+M-1,r=r+M+1;l^r^1;l>>=1,r>>=1,i<<=1){
            sumn[l]+=L*d,sumn[r]+=R*d;
            if(~l&1) addn[l^1]+=d,sumn[l^1]+=d*i,L+=i;
            if(r&1) addn[r^1]+=d,sumn[r^1]+=d*i,R+=i;
        }
        sumn[l]+=L*d,sumn[r]+=R*d;
        while(l>>=1) sumn[l]+=(L+R)*d;
    }
    ll query(int l,int r){
        ll ans = 0;int i=1,L=0,R=0;
        for(l=l+M-1,r=r+M+1;l^r^1;l>>=1,r>>=1,i<<=1){
            ans+=addn[l]*L,ans+=addn[r]*R;
            if(~l&1) ans+=sumn[l^1],L+=i;
            if(r&1) ans+=sumn[r^1],R+=i;
        }
        ans+=addn[l]*L,ans+=addn[r]*R;
        while(l>>=1) ans+=addn[l]*(L+R);
        return ans;
    }
}tree;

struct Q{
    int o,ql,qr;
    ll k;
    // o == 0 -> update l r val; o == 1 -> query l r k
    Q(){}
    Q(int a,int b,int c,ll d):o(a),ql(b),qr(c),k(d){}
}query[MAXN];

int tl[MAXN],tr[MAXN],ans[MAXN];

void solve(int *a,int n,int l,int r){
    //表示要处理的询问在q[0]->q[n-1]，二分答案范围为[l,r]
    if(n == 0) return;//一个微小的剪枝
    if(l == r){
        //递归边界
        for(int i = 0;i<n;i++) ans[a[i]] = l;
        return;
    }
    int n1 = 0,n2 = 0;ll sum;
    for(int i = 0;i<n;i++){
        Q &q = query[a[i]];
        if(q.o == 1){
            //修改如果值大于mid，就应用修改；否则不管
            if(q.k > mid) tree.update(q.ql,q.qr,1),tr[n2++] = a[i];
            else tl[n1++] = a[i];
        }
        else if(q.o == 2){
            //查询的结果sum大于k，二分到右边；否则左边
            sum = tree.query(q.ql,q.qr);
            if(q.k <= sum) tr[n2++] = a[i];
            else q.k -= sum,tl[n1++] = a[i];
        }
    }
    //原样减回去
    for(int i = 0;i<n;i++){
        Q &q = query[a[i]];
        if(q.o == 1 && q.k > mid) tree.update(q.ql,q.qr,-1);
    }
    memcpy(a,tl,sizeof(int) * n1),memcpy(a+n1,tr,sizeof(int) * n2);
    //递归二分
    solve(a,n1,l,mid),solve(a+n1,n2,mid+1,r);
}

int n,m,t[MAXN];

void init(){
    read(n),read(m);
    tree.init(n);
    int op,l,r;ll c;
    for(int i = 0;i<m;i++){
        read(op),read(l),read(r),read(c);
        query[i] = Q(op,l,r,c);
        t[i] = i;
    }
}

void solve(){
    solve(t,m,-n,n);
    for(int i = 0;i<m;i++){
        if(query[i].o == 2)
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
{% endfold %}