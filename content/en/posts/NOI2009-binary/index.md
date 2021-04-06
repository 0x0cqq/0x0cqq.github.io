---
title: 「NOI2009」二叉查找树-区间dp
urlname: NOI2009-binary
date: 2018-04-28 20:21:18
tags:
- 动态规划
- 平衡树
categories: 
- OI
- 题解
series:
- NOI
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---


给定 $n$ 个结点的数据值 $V_i$ ，权值 $P_i$ ，访问频度 $T_i(T_i \geq 0)$ 。对于 $\forall i,j \in V$ 且 $i \neq j$ ，有 $V_i \neq V_j, P_i \neq P_j$ 。

现令这 $n$ 个点组成一颗二叉树，且满足 $\forall \, i \in V$ ，若 $p$ 为 $i$ 的左子节点， $q$ 为 $i$ 的右子节点，则 $V_p < V_i < V_q$ 且 $P_i < P_p,\; P_i < P_q$ 。可以证明，这样的二叉树是唯一的。点$i$ 在树中的深度 $D_i$ 定义为它到根的距离加 $1$ 。定义结点 $i$ 的访问代价 $E_i = T_i \times D_i$ 。可以修改每个点的权值为任意实数，其代价均为给定的正整数 $K$ ，但需保证任两点权值仍互不相同。

现求上文所述二叉树中，其 $\sum^n  _ {i = 1}{E_i} + \sum K$ 的最小值。
<!--more-->
原文描述：


- - -
已知一棵特殊的二叉查找树。根据定义，该二叉查找树中每个结点的数据值都比它左儿子结点的数据值大，而比它右儿子结点的数据值小。

另一方面，这棵查找树中每个结点都有一个权值，每个结点的权值都比它的儿子结点的权值要小。

已知树中所有结点的数据值各不相同；所有结点的权值也各不相同。这时可得出这样一个有趣的结论：如果能够确定树中每个结点的数据值和权值，那么树的形态便可以唯一确定。因为这样的一棵树可以看成是按照权值从小到大顺序插入结点所得到的、按照数据值排序的二叉查找树。

一个结点在树中的深度定义为它到树根的距离加1。因此树的根结点的深度为1。

每个结点除了数据值和权值以外，还有一个访问频度。我们定义一个结点在树中的访问代价为它的访问频度乘以它在树中的深度。整棵树的访问代价定义为所有结点在树中的访问代价之和。

现在给定每个结点的数据值、权值和访问频度，你可以根据需要修改某些结点的权值，但每次修改你会付出K的额外修改代价。你可以把结点的权值改为任何实数，但是修改后所有结点的权值必须仍保持互不相同。现在你要解决的问题是，整棵树的访问代价与额外修改代价的和最小是多少？
- - -


## 链接

[Luogu P1864](https://www.luogu.org/problemnew/show/P1864)

## 题解
比较简单的区间dp。

首先对点的权值离散化，然后按照点的数据值排序。注意到点的顺序是确定的，所以如果给定区间 $[l,r]$ 以及其根节点能取到的最大的权值 $p$ ，就可以确定这个最小值。这个问题还满足局部最优解，所以搞一搞 $dp$ 就可以了。定义 $w(i,j)= \sum _ {k = i}^j {T_i}$ 。转移方程如下：

$$
m(l,r,p) = 0\; (l \geq r),
$$

$$
\min _ {k = l}^r{(\, m(l,k-1,p)+m(k+1,r,p)+ K), \;
m(l,k-1,P_k)+m(k+1,r,P_k))+w(i,j) \; \;(l < r)}
$$


## 代码

```cpp
#include <cstdio>
#include <algorithm>
#define pp node
using namespace std;

const int MAXN = 80;
int n,K;
int sum[MAXN],num[MAXN];
int dp[MAXN][MAXN][MAXN];
struct node{
    int fr,sc,tr;
    bool operator < (const node a)const{
        return fr < a.fr;
    }
};

void init(){
    scanf("%d %d",&n,&K);
    pp tmp[MAXN];int t[MAXN];
    for(int i = 1;i<=n;i++)
        scanf("%d",&tmp[i].fr);
    for(int i = 1;i<=n;i++){
        scanf("%d",&tmp[i].sc);
        t[i] = tmp[i].sc;
    }
    for(int i = 1;i<=n;i++)
        scanf("%d",&tmp[i].tr);
    sort(tmp+1,tmp+n+1),sort(t+1,t+n+1);
    for(int i = 1;i<=n;i++){
        num[i] = lower_bound(t+1,t+n+1,tmp[i].sc)-t;
        sum[i] = sum[i-1]+tmp[i].tr;
    }
}

void solve(){
    int tmp;
    for(int w = 1;w<=n;w++){
        for(int l = 1,r = w;r<=n;l++,r++){
            for(int p = 0;p<=n;p++){
                dp[l][r][p] = 0x3f3f3f3f;
                for(int k = l;k<=r;k++){
                    tmp = min(dp[l][k-1][p] + dp[k+1][r][p] + K,
                    num[k] > p? dp[l][k-1][num[k]] + dp[k+1][r][num[k]]: 0x3f3f3f3f);
                    dp[l][r][p] = min(dp[l][r][p],tmp);
                }
                dp[l][r][p] += sum[r] - sum[l-1];
            }
        }
    }
    printf("%d\n",dp[1][n][0]);
}

int main(){
    init();
    solve();
    return 0;
}
```

