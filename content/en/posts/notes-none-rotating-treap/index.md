---
title: 非旋Treap学习笔记
urlname: none-rotating-treap-notes
date: 2018-02-17 19:45:17
tags:
- Treap
- 平衡树
- 数据结构
- 模板
categories:
- OI
- 学习笔记
series:
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: true
---

非旋 $Treap$ ，是一种不基于旋转的平衡树。它基于 $Treap$ 的树堆思想，并且能够高效的完成某些对区间的操作，而且灵活性比较高。它也可以进行可持久化的操作。

<!--more-->

{%post_link Treap学习笔记 这篇文章 %}，介绍了基于旋转的 Treap 的基本概念等等，在这里不再赘述。

## 代码简述

这里以[这道题](https://www.luogu.org/problemnew/show/P3391)题作为模板。

### 节点的定义

```cpp
struct node_t{
    int val,p,size;
    // val 是数值，p 是优先级，size 是当前节点代表的区间的大小
    bool rev;
    node_t *son[2],**null;
    //下放标记
    void pushdown(){
        if(this == *null) return;
        if(rev) {
            son[0]->reverse(),son[1]->reverse();
            rev = 0;
        }
    }
    //更新节点
    void pushup(){
        if(this == *null) return;
        size = son[0]->size + son[1]->size + 1;
    }
    //反转以当前节点为父节点所代表的区间
    void reverse(){
        if(this == *null) return;
        swap(son[0],son[1]);
        rev^=1;
    }
};
```
这里的代码很简单，不作赘述。

不过有一点要说的。这里的双重指针`**null`的目的主要是让这里的节点能够快速的判断是否这个节点是下面平衡树的`null`节点。

### Treap结构体定义 & 初始化函数

```cpp
struct fhqtreap{
    node_t pool[MAXN],*tmp[MAXN],*stack[MAXN];
    //tmp 和 stack 数组都是为了后面的$O(n)$建树做准备
    node_t *root,*null;
    int cnt;
    fhqtreap(){
        cnt = 0;
        srand(time(NULL));
        newnode(null);
        null->p = MAX;
        root = null;
        null->size = 0;
    }
    void newnode(node_t *&r,int val = 0){
        r = &pool[cnt++];//分配内存
        r->val = val;r->size = 1;
        r->son[0] = r->son[1] = null;
        r->rev = 0;//置0
        r->null = &null;
        r->p = rand();
    }
```

初始化也没有什么难点。主要需要注意：**null的size应当为0，优先级应当是最大的。**

### 建树

```cpp
    void read_tree(int n){
        //把节点全部扔到tmp里面去
        for(int i = 1;i<=n;i++)
            newnode(tmp[i],i);
    }
    node_t *build(int n){
        read_tree(n);
        int top = 1;
        newnode(stack[0],-MAX);stack[0]->p = -MAX;
        //需要保证超级根能呆在最上面
        for(int i = 1;i<=n;i++){
            int nowp = top - 1;
            node_t *r = tmp[i],*pre = null;// r 是待添加节点
            while(stack[nowp]->p > r -> p){
                stack[nowp]->pushup();//这里需要pushup！因为应当保证下面是一个合法的treap;
                pre = stack[nowp];
                stack[nowp] = null;
                nowp--;// 出栈
            }
            stack[nowp+1] = stack[nowp]->son[1] = r;//把r链接到链上
            stack[nowp+1]->son[0] = pre;//把下面的链连到r的左儿子
            top = nowp+2;//更新栈内元素
        }
        while(top) stack[--top]->pushup();//更新
        return stack[0]->son[1];//返回根节点
    }
```

这里比较复杂。简单来说就是一个[笛卡尔树](https://baike.baidu.com/item/%E7%AC%9B%E5%8D%A1%E5%B0%94%E6%A0%91/7579802)的构造。

这样做的主要好处是可以在$O(n)$之内完成建树。在这里给出一个链接：[Sengxian's Blog](https://blog.sengxian.com/algorithms/treap#%E5%BB%BA%E6%A0%91),我觉得这位神犇讲的比较通俗易懂。

其实我们也可以通过一个简单的方式在 $O(n \log {n})$ 的时间内完成建树，就是一个一个的插入进去。但这样真的，很慢。

- - -

主要步骤如下：

这里对于 $\text{p}$ 而言，我们构造小根堆。
我们将一个节点表示为：$(\text{key}, \text{p})$。首先将所有节点按照 $\text{key}$ 从小到大排序。*在这里，就是我们的序列顺序。*

引入一个栈，栈底存放一个元素 $(-\infty, -\infty)$，表示超级根，这样保证它总在最上面，他的右儿子即为我们真正的树根。这个栈，维护了笛卡尔树最右边的一条链上面的元素。*（始终往右的一条链）*

从前往后遍历 $(\text{key}, \text{p})$：

>对于每一个 $(\text{key}\_i, \text{p}\_i)$，从栈中找出（从栈顶往栈底遍历）第一个$p$小于等于 $\text{p}\_i$ 的元素 $j$。

>将 $j$ 之上即 $\text{p} > \text{p}\_o$ 的点全部弹出。

>我们在这里记 $j$ 的右子节点为 $pre$ 。在树中，将 $pre$ 挂在 $j$ 的左子树上，将 $r$ 挂在原来 $j$ 的右子树的位置。

可以证明这个构造的时间复杂度是 $O(n)$ 。

*以上关于笛卡尔树的介绍转载自Sengxian的Blog，略有改写。*

### 分裂

```cpp
//分裂为两颗子树，左子树的大小为lsize
void split(node_t *r,int lsize,node_t *&ls,node_t *&rs){
    if(r == null){//边界
        ls = null;rs = null;
        return;
    }
    r->pushdown();//很重要！
    if(r->son[0]->size + 1 <= lsize){
        ls = r;
        split(r->son[1],lsize - r->son[0]->size - 1,ls->son[1],rs);
    }
    else{
        rs = r;
        split(r->son[0],lsize,ls,rs->son[0]);
    }
    ls->pushup();rs->pushup();
}
```

看起来很难，但其实很简单。

我们面临的只有一个问题：**当前节点属于左子树还是右子树？**

判定标准一般是数值大小或者排名来决定的。

> 如果我们判定当前根节点属于分裂后左子树，那么根节点的左子树就一定属于分裂后的左子树，那么我们只需要关心根节点的右子树属于分裂后那颗子树了，然后这个就可以递归下去了；判定属于分裂后的右子树是同理的。

代码也没有什么注意事项。可以证明，分裂的时间复杂度是 $O(\log {n})$ 。

### 合并

```cpp
node_t *merge(node_t *ls,node_t *rs){
    if(ls == null) return rs;
    if(rs == null) return ls;
    // 边界
    if(ls->p < rs->p){
        ls->pushdown(); //需要pushdown！
        ls->son[1] = merge(ls->son[1],rs);
        ls->pushup();//需要pushup！
        return ls;
    }
    else{
        rs->pushdown();//需要pushdown！
        rs->son[0] = merge(ls,rs->son[0]);
        rs->pushup();//需要pushup！
        return rs;
    }
}
```

这个和分裂也是类似的。

我们的主要任务变成了判断：**左子树右子树的根节点哪个应该放在总树的根节点？**

判断的依据十分显然。就是两个根节点的优先值。结合上面的分裂，我们也可以发现这里的递归规律：

> 如果合并后根节点是左子树的根节点，那么我们就可以把整个左子树的左子树保留下来，从而把左子树的右子树和右子树一起合并到左子树的右子树，然后左子树就可以作为返回的节点了。右子树同理。

可以证明，合并的时间复杂度也是 $O(\log {n})$ 。

### split to three

```cpp
//ls是左子树的size，rs是中间子树的size
void split(int ls,int ms,node_t *&l,node_t *&m,node_t *&r){
    node_t *m1;
    split(root,ls,l,m1);
    split(m1,ms,m,r);
}
```
太简单了，不说这个。

### 区间翻转

```cpp
//这里使用的是左边和右边的边界
void reverse(int lb,int rb){
    node_t *l,*m,*r;
    split(lb-1,rb-lb+1,l,m,r);
    m->reverse();  
    root = merge(l,merge(m,r));
}
```

也不太想说。主要就是要注意一点。我们在这里，要保证打过标记以后，这个节点的信息已然正确。这个在其他的例题里会比较令人舒服，可以减少一些pushdown。

虽然这道题只有区间翻转，但是其他的区间操作也可以同理完成。Splay能做的，非旋Treap都能做，而且他还可以进行持久化，这是Splay比不了的。（然而我并不会写


## 完整代码



```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 510000;
const int MAX = 2147483647;

/*以下为输入输出优化*/
namespace fast_IO {
    inline char read() {
        static const int IN_LEN = 1000000;
        static char buf[IN_LEN], *s, *t;
        return s==t?t=(s=buf)+fread(buf,1,IN_LEN,stdin),*s++:*s++;
    }
    inline void read(int &x) {
        static bool iosig;
        static char c;
        for (iosig = false, c = read(); !isdigit(c); c = read()) {
            if (c == '-') iosig = true;
            if (c == -1) return;
        }
        for (x = 0; isdigit(c); c = read())
            x = (x << 1) + (x << 3) + (c ^ '0');
        if (iosig) x = -x;
    }
    const int OUT_LEN = 10000000;
    char obuf[OUT_LEN], *ooh = obuf;
    inline void print(char c) {
        if (ooh == obuf + OUT_LEN) fwrite(obuf, 1, OUT_LEN, stdout), ooh = obuf;
        *ooh++ = c;
    }
    inline void print(int x) {
        static int buf[30], cnt;
        if (x == 0) {
            print('0');
        }
        else {
            if (x < 0) print('-'), x = -x;
            for (cnt = 0; x; x /= 10) buf[++cnt] = x % 10 + 48;
            while (cnt) print((char)buf[cnt--]);
        }
    }
    inline void flush() {
        fwrite(obuf, 1, ooh - obuf, stdout);
    }
}using namespace fast_IO;
/*以上为输入输出优化*/


int k,n;

struct node_t{
    int val,p,size;
    bool rev;
    node_t *son[2],**null;
    void pushdown(){
        if(this == *null) return;
        if(rev) {
            son[0]->reverse(),son[1]->reverse();
            rev = 0;
        }
    }
    void pushup(){
        if(this == *null) return;
        size = son[0]->size + son[1]->size + 1;
    }
    void reverse(){
        if(this == *null) return;
        swap(son[0],son[1]);
        rev^=1;
    }
};


struct fhqtreap{
    node_t pool[MAXN],*tmp[MAXN],*stack[MAXN];
    node_t *root,*null;
    int cnt,tot;
    void newnode(node_t *&r,int val = 0){
        r = &pool[cnt++];
        r->val = val;r->size = 1;
        r->son[0] = r->son[1] = null;r->rev = 0;
        r->null = &null;
        r->p = rand();
    }
    fhqtreap(){
        cnt = 0;
        srand(time(NULL));
        newnode(null);
        null->p = MAX;
        root = null;
        null->size = 0;
    }
    void read_tree(int n){
        for(int i = 1;i<=n;i++)
            newnode(tmp[i],i);
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
            ls = null;rs = null;
            return;
        }
        r->pushdown();
        if(r->son[0]->size + 1 <= lsize){
            ls = r;
            split(r->son[1],lsize - r->son[0]->size - 1,ls->son[1],rs);
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
    void split(int ls,int ms,node_t *&l,node_t *&m,node_t *&r){
        node_t *m1;
        split(root,ls,l,m1);
        split(m1,ms,m,r);
    }
    void reverse(int lb,int rb){
        node_t *l,*m,*r;
        split(lb-1,rb-lb+1,l,m,r);
        m->reverse();  
        root = merge(l,merge(m,r));
    }
    void output(node_t *r,int *a){
        if(r == null) return;
        r->pushdown();
        output(r->son[0],a);
        a[r->son[0]->size] = r->val;
        output(r->son[1],a + r->son[0]->size+1);
    }
    void print(node_t *r = NULL,int depth = 0){
        if(r == NULL) r = root;
        if(r == null) return;
        print(r->son[0],depth+1);
        
        for(int i = 0;i<depth;i++) putchar(' ');
        printf("val:%d p:%d size:%d son:%d %d rev?:%d\n",r->val,r->p,r->size,r->son[0] != null,r->son[1] != null,r->rev);

        print(r->son[1],depth+1);
        return;
    }
};

fhqtreap w;

int ans[MAXN];

void init(){
    read(n),read(k);
    w.root = w.build(n);
}

void solve(){
    int a,b;
    for(int i = 1;i<=k;i++){
        read(a),read(b);
        w.reverse(a,b);
    }
    w.output(w.root,ans);
    for(int i = 0;i<n;i++){
        print(ans[i]);print(' ');
    }
    print('\n');
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```



## 例题

{% post_link 「NOI2005」维护数列-非旋Treap 「NOI2005」维护数列 %}

## 一些参考

这里有一些讲非旋转$Treap$的博客：

[Sengxian's Blog](https://blog.sengxian.com/algorithms/treap)

[xehoth's Blog](https://blog.xehoth.cc/NoneRotatingTreap/)

[Memphis's Blog](http://memphis.is-programmer.com/posts/46317.html)
