---
title: 「SCOI2013」多项式的运算-Splay
urlname: SCOI2013-function
date: 2018-06-01 21:12:47
tags:
- 题解
- Splay
- 数据结构
- 平衡树
categories: OI
visible:
---

维护一个动态的关于$x$的无穷多项式 ，这个多项式初始时对于所有$i$有$a_i = 0$

$f(x)=a_0x^0+a_1x^1+a_2x^2...$
操作者可以进行四种操作：

+ `mul L R V`表示将 $x^L$ 到 $x^R$ 这些项的系数乘上某个定值$v$；

+ `add L R V`表示将$x^L$ 到 $x^R $这些项的系数加上某个定值$v$；

+ `mulx L R`表示将$x^L$ 到 $x^R$ 这些项乘上x变量；

+ `query V`求$f(v)$的值。


操作集中在前三种，第四种操作不会出现超过$10$次。

<!-- more -->

## 链接

[Luogu P3278](https://www.luogu.org/problemnew/show/P3278)

## 题解

Splay大毒瘤题。

前两个操作让我们想到线段树的模板，第三个操作如果从序列的角度来看就像是把一个序列向右移动，在把被冲掉的那一个位置加到原来的位数上去。

显然啊！同志们，这是送分题啊！Splay套套套...

- - -

- `add`操作：提取区间，打标记，维护信息。

- `mul`操作：提取区间，打标记，维护信息。

- `mulx`操作：呃...先找到rank为l-1,l,r,r+1,r+2的节点。删除掉r+1号节点，把其值加到r上去，然后在l-1和l之间插入一个值为0的节点，维护信息。

注意：push_down操作先传muln，再传addn。

打标记几乎同线段树模板，就不说了。

## 代码

```cpp
#include <cstdio>
#include <unistd.h>
#include <cctype>
#define ll long long
using namespace std;

const int MAXN = 210000;
const ll p = 20130426LL;

namespace fast_io {
	//...
}using namespace fast_io;

inline void mod(ll &x){x %= p;}

struct Splay{
    ll val[MAXN],addn[MAXN],muln[MAXN];
    int f[MAXN],c[MAXN][2],siz[MAXN],tot,root;
    int newnode(int v = 0){
        val[++tot] = v;
        siz[tot] = 1;
        addn[tot] = 0,muln[tot] = 1;
        return tot;     
    }
    void add(int x,int num){
        if(!x) return;
        addn[x] += num,val[x] += num;
        mod(val[x]),mod(addn[x]);
    }
    void mul(int x,int num){
        if(!x) return;
        muln[x] *= num,addn[x] *= num,val[x] *= num;
        mod(addn[x]),mod(muln[x]),mod(val[x]);
    }
    void push_down(int x){
        if(!x) return;
        if(muln[x]!=1){
            mul(c[x][0],muln[x]);
            mul(c[x][1],muln[x]);
            muln[x] = 1;
        }
        if(addn[x] != 0){
            add(c[x][0],addn[x]);
            add(c[x][1],addn[x]);
            addn[x] = 0;
        }
    }
    void  push_up(int x){
        if(!x) return;
        siz[x] = siz[c[x][0]] + siz[c[x][1]] + 1;
    }
    void rotate(int x){
        int y = f[x],z = f[y],t = (c[y][1]==x),w = c[x][1-t];
        push_down(y),push_down(x);
        f[x] = z;f[y] = x;
        if(w) f[w] = y;
        c[x][1-t] = y,c[y][t] = w;
        if(z) c[z][c[z][1]==y] = x;
        push_up(y),push_up(x);
        if(!f[x]) root = x;
    }
    void splay(int x,int target = 0){
        while(f[x]!=target){
            int y = f[x],z = f[y];
            if(z!=target)
                (c[z][1]==y) ^ (c[y][1]==x)?rotate(x):rotate(y);
            rotate(x);
        }
    }
    int qrank(int r){
        int x = root;
        while(2333){
            if(r <= siz[c[x][0]])
                x = c[x][0];
            else if(r == siz[c[x][0]] + 1)
                break;
            else
                r -= siz[c[x][0]] + 1,x = c[x][1];
        }
        return x;
    }
    int __build(int l,int r,int fa){
        if(l > r) return 0;
        int mid = (l+r)>>1;
        int x = newnode();
        f[x] = fa;
        c[x][0] = __build(l,mid-1,x);
        c[x][1] = __build(mid+1,r,x);
        push_up(x);
        return x;
    }
    void build(int num){
        root = __build(1,num,0);
    }
    void __output(int x,ll *a){
        if(!x) return;
        push_down(x);
        __output(c[x][0],a);
        a += siz[c[x][0]],*a = val[x];
        __output(c[x][1],a+1);
    }
    void output(ll *a){
        __output(root,a);
    }
    void add(int l,int r,int num){
        int lb = qrank(l),rb = qrank(r+2);
        splay(lb),splay(rb,lb);
        add(c[rb][0],num);
        push_up(rb),push_up(lb);
    }
    void mul(int l,int r,int num){
        int lb = qrank(l),rb = qrank(r+2);
        splay(lb),splay(rb,lb);
        mul(c[rb][0],num);
        push_up(rb),push_up(lb);
    }
    void mulx(int l,int r){
        int x = qrank(l),y = qrank(l+1),z = qrank(r+1),a = qrank(r+2),b = qrank(r+3);
        splay(z),splay(b,z);
        c[b][0] = 0;push_up(b),push_up(z);
        val[z] += val[a];
        splay(x),splay(y,x);
        c[y][0] = newnode(),f[c[y][0]] = y;
        push_up(y),push_up(x);
    }
}T;

int n,m = 110000;

ll query(ll v){
    static ll o[MAXN];
    T.output(o);
    ll ans = 0;
    for(int i = m;i>=1;i--){
        ans = ans * v + o[i];
        mod(ans);
    }
    return ans;
}


void init(){
    read(n);
    T.build(m+3);
}

void solve(){
    char op[10];int l,r,v;
    for(int i = 1;i<=n;i++){
        read(op);
        if(op[0] == 'q'){
            read(v);
            print(int(query(v))),print('\n');
        }
        else{
            read(l),read(r);
            if(op[3] == 'x')
                T.mulx(l+1,r+1);
            else{
                read(v);
                if(op[0] == 'm')
                    T.mul(l+1,r+1,v);
                else if(op[0] == 'a')
                    T.add(l+1,r+1,v);
            }
        }
    }
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```


