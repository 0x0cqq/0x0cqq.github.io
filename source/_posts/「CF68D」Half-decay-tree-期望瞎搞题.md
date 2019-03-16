---
title: 「CF68D」Half-decay tree-期望瞎搞题
urlname: CF68D
date: 2019-01-09 19:23:03
tags:
- 期望
- 树形结构
categories: 
- OI
- 题解
visible:
---

定义一个完全二叉树树高为根节点到叶子节点经过的边数。

给定一个树高为 $h(1 \le h \le 30)$ 的完全二叉树，其中第 $x$ 个节点的左儿子为第 $2x$ 个节点，右儿子为第 $2x+1$ 个节点。

现在有 $q(1 \le q \le 10^{5})$ 个，分为两种操作：

1. `add v e` （ $1 \le v \le 2^{h+1}-1,1 \le e \le 10^4$ ）表示给第 $v$ 个节点的权值加 $e$ 
2. `decay` 操作。我们在这个二叉树里面以等概率选择一个叶子节点，将这个叶子节点到根的路径上所有的边都删去。在删除后，树会形成若干个联通块，我们定义某个联通块的的权值为这个联通块内所有节点的权值之和。我们定义删除后的树的权值为形成的所有联通块的权值的最大值。请你求出这个值的期望。**每次删除后会恢复所有删除的边。**


<!-- more -->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/68/D)

## 题解

考虑我们在树上随机走出一个路径。我们发现，我们每个地方相当于有两个决策：往左走，往右走，两个的概率是相同的。

我们如果设当前节点为为 $x$，那么往左走的话就会产生一个完全不会更改的联通块（$sum[rs[x]] +v[x]$）。如果存在 $sum[rs[x]] + v[x] 
\ge sum[ls[x]]$ 这个时候我们发现，接下来我们怎么走，产生的联通块都不会比已经产生的这个 $sum[rs[x]] + v[x]$ 大。所以我们就不用走 $sum$ 较小的那边了，因为它们的贡献已经可以计算了。

这样的话我们每次决策都可以只走一边，同时计算出剩下的一边的所有答案之和。在走的过程中维护一下已经存在的联通块的最大值即可。

加的话直接暴力在树上维护一个子树和即可。

时间复杂度：$O(q \times h)$

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 110000,LOGN = 31;

namespace Tree{
  int sumn[MAXN*LOGN],ls[MAXN*LOGN],rs[MAXN*LOGN],cnt = 1;
  void upd(int nown,int v){
    static int tmp[40];int ecnt = 0;
    for(int i = nown;i;i>>=1) tmp[++ecnt] = i&1;
    int now = 1;
    for(int i = ecnt-1;i>=0;--i){
      sumn[now] += v;
      if(tmp[i] == 0){
        if(!ls[now]) ls[now] = ++cnt;
        now = ls[now];
      }
      else{
        if(!rs[now]) rs[now] = ++cnt;
        now = rs[now];
      }
    }
  }
  double decay(){
    int now = 1,nowmax = -1e9;
    double ans = 0, p = 1;
    while(now != 0){// now 非空
      int lson = sumn[ls[now]],rson = sumn[rs[now]],val = sumn[now] - lson - rson;
      p *= 0.5;
      ans += p * max(nowmax,max(lson,rson)+val);
      if(lson > rson){
        nowmax = max(nowmax,rson+val);
        now = ls[now];
      }
      else{
        nowmax = max(nowmax,lson+val);
        now = rs[now];
      }
    }
    ans += p * nowmax;
    return ans;
  }
}

int h,q;

void init(){
  scanf("%d %d",&h,&q);
}

void solve(){
  for(int i = 1;i<=q;i++){
    char s[12];
    int a,b;
    scanf("%s",s);
    if(s[0] == 'a'){
      scanf("%d %d",&a,&b);
      Tree::upd(a,b);
    }
    else if(s[0] == 'd'){
      printf("%.8lf\n",Tree::decay());
    }
  }
}

int main(){
  init();
  solve();
  return 0;
}
```

