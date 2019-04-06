---
title: 「NOI2005」维护数列-非旋Treap
urlname: NOI2005-sequence
date: 2018-02-17 21:48:01
tags:
- Treap
- 平衡树
- 数据结构
categories: 
- OI
- 题解
visible:
---

维护一个数列，给定初始的 $n$ 个数字。

现有六种命令：
+ 在第 $pos$ 个数后插入 $tot$ 个数
+ 翻转从第 $pos$ 个数开始的 $tot$ 个数
+ 删除从第 $pos$ 个数开始的 $tot$ 个数
+ 查询从第 $pos$ 个数开始的 $tot$ 个数的和
+ 设定从第 $pos$ 个数开始的 $tot$ 个数设定为 $c$ 
+ 查询整个数列中和最大的连续子区间的和


<!-- more -->

## 链接

[Luogu P2042](https://www.luogu.org/problemnew/show/P2042)

## 题解

这是一道经典的平衡树的题，被我用来练手非旋$Treap$。

因为我太弱了，所以写的很痛苦。

关于合并和分裂的主要思想参见{% post_link 非旋Treap学习笔记 学习笔记 %}。

- - -
对于节点，要维护：

树的大小，树的权值和，树从左端点开始的最大连续和，树从右端点开始的最大连续和，和树的最大连续子区间和。

- - -
主要操作：

+ $pushdown$

往下$push$，修改两个子节点并打上标记。

+ $pushup$

更新所有信息，维护三个$max$信息的方式有些特殊，但仔细想想应当能想到。

这里我被坑了。这个与线段树的区间最大查询有点不太一样，根节点也有代表的数，这个需要记住。

- - -

+ 建树

构建笛卡尔树。详见{% post_link 非旋Treap学习笔记 学习笔记 %}。

+ 最大查询连续和

直接输出根节点维护的最大连续子区间的值即可。

+ 插入

把即将插入的$tot$个数按照上文的介绍方法建树。

把原来的数按照$size$裂成两棵树，分别按顺序合起来就可以了。

- - -

接下来的操作都需要裂成三棵树，左边的有$pos-1$个树，中间有$tot$个数。

+ 删除

直接删除中间子树，左右合并。因为内存不够（$64MB$），需要垃圾回收。

+ 求和

输出中间子树的和，再把三个子树顺次合并起来。

+ 翻转

翻转中间子树并打标记，再把三个子树顺次合并起来。

+ 设定

对中间子树完成设定并打标记，再将三个子树顺次合并起来。

- - -

还有一点就是垃圾回收。简略来说就是把删除的节点暴力的扔到一个栈里面，然后能用就用，不能有就再新开内存池。

其他也没有什么重要的。多$pushdown pushup$几次，然后这些操作都是要注意边界，也就是`null`时候的条件的。$pushup$的合并公式也需要好好斟酌。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 510000;

const int MAX = 2147483647;

int k,n;

struct node_t{
    int val,p;
    int lmax,rmax,maxn,sumn,tag;
    int size;
    bool rev,is_tag;
    node_t *son[2],**null;
    void pushdown(){
        if(this == *null) return;
        if(is_tag){
            son[0]->cover(tag),son[1]->cover(tag);
            is_tag = tag = 0;
        }
        if(rev) {
            son[0]->reverse(),son[1]->reverse();
            rev = 0;
        }
    }
    void pushup(){
        if(this == *null) return;
        if(son[0] == *null && son[1] == *null){
            size = 1;sumn = lmax = rmax = maxn = val;
            return;
        }
        size = son[0]->size + son[1]->size + 1;
        sumn = son[0]->sumn + son[1]->sumn + val;
        lmax = max(son[0]->lmax,son[0]->sumn + val + max(0,son[1]->lmax));
        rmax = max(son[1]->rmax,son[1]->sumn + val + max(0,son[0]->rmax));
        maxn = max(0,son[0]->rmax) + val + max(0,son[1]->lmax);
        maxn = max(maxn,max(son[0]->maxn,son[1]->maxn));
    }
    void cover(int v){
        if(this == *null) return;
        val = v;sumn = size * v;
        lmax = rmax = maxn = max(v,sumn);
        is_tag = 1;tag = v;
    }
    void reverse(){
        if(this == *null) return;
        swap(son[0],son[1]);
        swap(lmax,rmax);
        rev^=1;
    }
};


struct fhqtreap{
    node_t pool[MAXN],*tmp[MAXN],*stack[MAXN],*garbage[MAXN];
    node_t *root,*null;
    int cnt,tot;
    void newnode(node_t *&r,int val = 0){
        if(tot == 0) r = &pool[cnt++];
        else         r = garbage[--tot];//垃圾回收
        r->val = val;r->size = 1;
        r->lmax = r->rmax = r->maxn = r->sumn = val;
        r->son[0] = r->son[1] = null;
        r->is_tag = r->rev = 0;
        r->null = &null;
        r->p = rand();
    }
    fhqtreap(){
        tot = 0;cnt = 0;
        srand(time(NULL));
        newnode(null,-MAX);
        null->p = MAX;
        root = null;
        null -> sumn = null->size = 0;
    }
    void cycle(node_t *r){
        if(r == null) return;
        garbage[tot++] = r;
        cycle(r->son[0]);
        cycle(r->son[1]);
    }
    void read_tree(int n){
        for(int i = 1;i<=n;i++){
            int t;scanf("%d",&t);
            newnode(tmp[i],t);
        }
    }
    node_t *build(int n){
        read_tree(n);
        int top = 1;
        newnode(stack[0],-MAX);
        stack[0]->p = -MAX;
        for(int i = 1;i<=n;i++){
            int nowp = top - 1;
            node_t *r = tmp[i],*pre = null;
            while(stack[nowp]->p > r -> p){
                stack[nowp]->pushup();
                pre = stack[nowp];
                stack[nowp] = null;
                nowp--;
            }
            stack[nowp+1] = stack[nowp]->son[1] = r;
            stack[nowp+1]->son[0] = pre;
            top = nowp+2;
        }
        while(top) stack[--top]->pushup();
        return stack[0]->son[1];
    }
    void split(node_t *r,int lsize,node_t *&ls,node_t *&rs){
        if(r == null){
            ls = null;rs = null;return;
        }
        r->pushdown();
        if(r->son[0]->size + 1 <= lsize){
            ls = r;
            split(r->son[1],lsize-r->son[0]->size-1,ls->son[1],rs);
        }
        else{
            rs = r;
            split(r->son[0],lsize,ls,rs->son[0]);
        }
        ls->pushup();rs->pushup();
    }
    node_t *merge(node_t *ls,node_t *rs){
        if(ls == null) return rs;
        if(rs == null) return ls;
        if(ls->p < rs->p){
            ls->pushdown();
            ls->son[1] = merge(ls->son[1],rs);
            ls->pushup();
            return ls;
        }
        else{
            rs->pushdown();
            rs->son[0] = merge(ls,rs->son[0]);
            rs->pushup();
            return rs;
        }
    }
    void insert(int rank,int n){
        if(n == 0) return;
        node_t *ls,*rs,*newn,*ret;
        split(root,rank,ls,rs);
        newn = build(n);
        root = merge(merge(ls,newn),rs);
    }
    void split(int ls,int ms,node_t *&l,node_t *&m,node_t *&r){
        node_t *m1;
        split(root,ls,l,m1);
        split(m1,ms,m,r);
    }
    void erase(int lb,int ms){
        if(ms == 0) return;
        node_t *l,*m,*r,*ret;
        split(lb-1,ms,l,m,r);
        cycle(m);
        root = merge(l,r);
    }
    int get_sum(int lb,int ms){
        if(ms == 0) return 0;
        node_t *l,*m,*r;
        split(lb-1,ms,l,m,r);
        int ans = m->sumn;
        root = merge(l,merge(m,r));
        return ans;
    }
    int max_sum(){
        return root->maxn;
    }
    void reverse(int lb,int ms){
        if(ms == 0) return;
        node_t *l,*m,*r;
        split(lb-1,ms,l,m,r);
        m->reverse();       
        root = merge(l,merge(m,r));
    }
    void make_same(int lb,int ms,int c){
        if(ms == 0) return;
        node_t *l,*m,*r;
        split(lb-1,ms,l,m,r);
        m->cover(c);
        root = merge(l,merge(m,r));
    }
};

fhqtreap w;

void init(){
    scanf("%d %d",&n,&k);
    w.root = w.build(n);
}

void solve(){
    for(int i = 1;i<=k;i++){
        char op[50];int a,b,c;
        scanf("%s",op);
        if(op[0] == 'M'&&op[2] == 'X')
            printf("%d\n",w.max_sum());
        else{
            scanf("%d %d",&a,&b);
            if(op[0] == 'I')
                w.insert(a,b);
            else if(op[0] == 'D')
                w.erase(a,b);
            else if(op[0] == 'G'){
                printf("%d\n",w.get_sum(a,b));
            }
            else if(op[0] == 'M'){
                scanf("%d",&c);
                w.make_same(a,b,c);
            }
            else if(op[0] == 'R'){
                w.reverse(a,b);
            }
        }
    }
}

int main(){
    init();
    solve();
    return 0;
}
```


