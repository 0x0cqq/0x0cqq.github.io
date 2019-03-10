---
title: 「POI2011」Tree Rotations-线段树合并
urlname: POI2011-Tree-Rotations
date: 2018-07-23 22:51:45
tags:
- 题解
- 数据结构
- 线段树
- 树形结构
- 线段树合并
categories: OI
visible:
---

现在有一棵二叉树，所有非叶子节点都有两个孩子。在每个叶子节点上有一个权值(有$n$个叶子节点，满足这些权值为$1...n$的一个排列)。可以任意交换每个非叶子节点的左右孩子。
要求进行一系列交换，使得最终所有叶子节点的权值按照前序遍历序写出来，逆序对个数最少。

<!-- more -->

**输入方式：**

第一行一个整数n；

下面每行，一个数x；
+ 如果$x==0$，表示这个节点非叶子节点，递归地向下读入其左孩子和右孩子的信息；
+ 如果$x!=0$，表示这个节点是叶子节点，权值为$x$。

## 链接

[Luogu P3521](https://www.luogu.org/problemnew/show/P3521)`// 数据太弱`

[BZOJ 2212](https://www.lydsy.com/JudgeOnline/problem.php?id=2212)`// 时间限制太长`

[LOJ 2163](https://loj.ac/problem/2163) `// 单点时限0.2s 十分适合卡常`

## 题解

### 线段树合并

这里的线段树合并讨论的都是动态开点的线段树的合并。

我们注意到，如果给定元素个数（值域区间），那么这个线段树的每个节点对应的区间是唯一确定的，这也是我们可以在一个较低的复杂度里面将若干棵动态开点的线段树合到一起去的一个基础。

我们在这里假设我们可以在$O(1)$的时间里面合并两个树的叶子的信息，并从线段树的两个子树O(1)的得到更大的区间的信息（区间合并），其实这也是线段树的基础。

我们其实可以暴力的写出合并的伪代码：

```cpp
node merge(node u,node v):
    if u,v 中存在一个节点为空节点:
        return 另一个节点 // O(1)
    if u,v 均为叶节点:
        return 合并u,v 两个叶节点 // O(1)
    
    u.leftchild = merge(u.leftchild,v.leftchild) 

    u.rightchild = merge(u.rightchild,v.rightchild) 

    合并 u.leftchild 和 u.rightchild 的信息为 u // O(1)

    return u
```

线段树合并的过程也可以很容易的可持久化，只需要把上面的代码中后面的几个$u$修改成一个新创建的$w$即可。

- - -

关于复杂度，可以显而易见的注意到，`merge`两个动态开点线段树的时候，其复杂度与公共节点的数量成正比，也就是减少的节点数目。


动态开点线段树每次插入一个节点，其空间会增加$\log n$。这样如果我们有了$n$颗只有一个节点的动态开点线段树，总共的点有$O(n \log n)$个。

如果将这样$n$个动态开点的线段树合并到一棵线段树，最后剩下的节点数是在$O(n)$量级的，减少的节点数目是在$O(n \log n)$量级的，所以这样合并的时间复杂度是$O(n \log n)$。

### 题目解法

这道题主要就是权值线段树合并的一个过程。我们对每个叶子结点开一个权值线段树，然后逐步合并。

考虑到一件事情：如果在**原树**有一个根节点x，和其左儿子$ls$，右儿子$rs$。我们要合并的是$ls$的权值线段树和$rs$的权值线段树。

发现交换$ls$和$rs$并不会对更上层之间的逆序对产生影响，于是我们只需要每次合并都让逆序对最少。

于是我们的问题转化为了给定两个权值线段树，问把它们哪个放在左边可以使逆序对个数最小，为多少。

考虑我们合并到一个节点，其权值范围为$[l,r]$，中点为$mid$。这个时候我们有两棵树，我们要分别计算出某棵树在左边的时候和某棵树在右边的时候的逆序对个数。事实上我们只需要处理权值跨过中点$mid$的逆序对，那么所有的逆序对都会在递归过程中被处理仅一次（类似一个分治的过程）。而我们这个时候可以轻易的算出两种情况的逆序对个数，不交换的话是左边那棵树的右半边乘上左边那棵树的的右半边的大小；交换的话则是左边那棵树的左半边乘上左边那棵树的的左半边的大小。

然后每次合并由于都可以交换左右子树，我们就把这次合并中交换和不交换的情况计算一下，取最小值累积就可以了。

空间复杂度：$O(n \log n)$，时间复杂度 $O(n \log n)$。

另，洛谷上这题数据极弱，`LOJ`上的数据就很强，线段树合并卡过去略微费劲，可以体验一下不断$TLE$的感觉qwq。

另另，这道题的读入很迷，附上一点人话：

> 第一行一个数$n$，表示该二叉树的叶节点的个数；
> 下面若干行，每行一个数$x$：
> 如果$x = 0$，表示这个节点不是叶节点，递归地向下读入其左孩子和右孩子的信息；
> 如果$x \neq 0$，表示这个节点是叶节点，权值为$x$。

## 代码


```cpp
#include <cstdio>
#include <cctype>
using namespace std;
#define mid ((l+r)>>1)
typedef long long ll;

inline char read(){
    static const int SIZE = 1024*1024;
    static char *s,*t,ibuf[SIZE];
    if(s == t) t = (s=ibuf) + fread(ibuf,1,SIZE,stdin);
    return s == t ? -1:(*s++);
}

template<typename T>
inline void read(T &x){
    static bool iosig = 0;static char ch;
    for(ch = read(),iosig = 0;!isdigit(ch);ch = read()){
        if(ch == -1) return;
        if(ch =='-') iosig = 1;
    }
    for(x = 0;isdigit(ch);ch =read())
        x = (((x<<2)+x)<<1) + (ch^48);
    if(iosig) x = -x;
}

inline ll min(ll a,ll b){
    return a > b?b : a;
}

const int MAXN = 210000;
ll ANS = 0,ans1 = 0,ans2 = 0;
int n,pos;

struct node{
    int sumn,ls,rs;
}aa[MAXN*30];

int cnt = 0;
void update(int &nown,int l,int r){
    if(!nown) nown = ++cnt;
    aa[nown].sumn++;
    if(l == r) return;
    if(pos <= mid)
        update(aa[nown].ls,l,mid);
    else
        update(aa[nown].rs,mid+1,r);
}
void merge(int &lx,int rx){
    if(!lx || !rx){lx=lx+rx;return;}
    aa[lx].sumn += aa[rx].sumn;
    ans1 += (ll)aa[aa[lx].rs].sumn*aa[aa[rx].ls].sumn;
    ans2 += (ll)aa[aa[lx].ls].sumn*aa[aa[rx].rs].sumn;
    merge(aa[lx].ls,aa[rx].ls);
    merge(aa[lx].rs,aa[rx].rs);
}

void solve(int &x){
    int t,ls,rs;x = 0;
    read(t);
    if(!t){
        solve(ls),solve(rs);
        ans1 = ans2 = 0;
        x = ls;merge(x,rs);
        ANS += min(ans1,ans2);
    }
    else
        pos = t,update(x,1,n);
}

signed main(){
    read(n);
    int t = 0;
    solve(t);
    printf("%lld\n",ANS);
    return 0;
}
```





