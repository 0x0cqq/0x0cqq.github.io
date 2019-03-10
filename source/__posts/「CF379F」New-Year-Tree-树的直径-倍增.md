---
title: 「CF379F」New Year Tree-树的直径-倍增
urlname: CF379F
date: 2018-12-30 09:35:29
tags:
- 题解
- 数据结构
- 树形结构
- 树的直径
categories: OI
visible:
---

你是一个程序猿，现在有一棵新年树（并不是传统的带着叶子的树）——它有四个节点： $1$ ，$2$ ，$3$ ，$4$ . 其中$2$ ，$3$ ，$4$ 的父亲都是 $1$ .

新年里，程序猿们往往会做一些有趣的事情。你则选择以往这棵树上加节点来取乐。 一个添加节点的操作是这样的：

1. 找到树上的一个叶子结点 $v$ .
2. 设现在树上有 $n$ 个节点，那么你现在会加入两个节点$n+1$ 和 $n+2$ ，它们都会成为 $v$ 的儿子.

你的任务是在做 $q$ 次这样的操作，并在每做完一次后计算一次树的直径。来吧，我们一起来解决这道新年问题吧！

<!-- more -->

## 链接

[Codeforces](https://codeforces.com/problemset/problem/379/F)

## 伪题解

我们考虑树形dp计算树的直径的过程。

我们如果令 $f[i]$ 为以 $i$ 为根的子树中最长的链的长度，$g[i]$ 为以 $i$ 为根的子树中的直径长度（过根节点），那么就有如下转移：

$$
f[v] = \max(f[v_1] + f[v_2]) + 1\\
g[v] = f[v_1] + f[v_2] + 2
$$

如果我们令 $dep[v]$ 为 $v$ 的深度，那么我们可以将第一个改写如下：

$$
f[v] = \max_{v_i \text{ is in the subtree of } v}(dep[v_i]) - dep[v]
$$

我们可以用倍增在 $O(\log n)$ 的时间内找到第一个不需要更新的位置，然后在倍增上用 $O(\log n)$ 的时间内更新 $f$ 值，计算得到 $delta$（每次深度只增加1，所以一定会只有一个delta），然后将 $g$ 修改维护即可。

- - - 

看了 [Tutorial](https://codeforc.es/blog/entry/10171 "Tutorial Good Bye 2013") 之后有些自闭，题解给出了一个非常轻松愉悦的办法。

## 题解

我们思考 $\text{dfs}$ 计算直径的过程，从一个节点找到最远的一个节点，这个节点一定是直径的一个端点，然后我们再进行一遍 $\text{dfs}$ 最远点就是直径的另一个的端点。

所以我们考虑从根节点进行第一次 $\text{dfs}$ ，找到最远的第一个节点（事实上是深度最大的节点之一皆可）。

如果我们给一个节点新建了两个子节点，我们发现它们的父亲是当前最远的节点，那么答案一定增加且只增加了 $1$；

否则，答案只有可能被当前最远的节点和新增加的节点之间的距离更新。

那么就可以倍增维护 $\text{LCA}$ 计算树上距离，在 $O(n \log n)$ 的时间内解决这个问题。

## 代码

{% fold %}
```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 1001000,logn = 22;

int q;
int f[MAXN][logn],dep[MAXN],t[MAXN];

int lca(int x,int y){
  if(dep[x] < dep[y]) swap(x,y);
  for(int i = logn-1;i>=0;--i){
    if(dep[f[x][i]] >= dep[y]) x = f[x][i];
  }
  if(x == y) return x;
  for(int i = logn-1;i>=0;--i){
    if(f[x][i] != f[y][i]) x = f[x][i],y = f[y][i];
  }
  return f[x][0];
}

void addnode(int x,int fa){
  f[x][0] = fa,dep[x] = dep[fa]+1;
  for(int i = 1;i<logn;i++){
    f[x][i] = f[f[x][i-1]][i-1];
  }
}

int caldis(int x,int y){
  return dep[x] + dep[y] - 2 * dep[lca(x,y)];
}

void init(){
  scanf("%d",&q);
  for(int i = 1;i<=q;i++)
    scanf("%d",&t[i]);
}

void solve(){
  dep[1] = 1,dep[2] = dep[3] = dep[4] = 2;
  f[2][0] = f[3][0] = f[4][0] = 1;
  int maxdep = 2,maxnode = 2,ans = 2,n = 4;
  for(int i = 1;i<=q;i++){
    int x = t[i];
    addnode(++n,x),addnode(++n,x);
    if(dep[x] == maxdep){
      maxdep++,maxnode = n,ans++;
    }
    else{
      ans = max(ans,caldis(maxnode,n));
    }
    printf("%d\n",ans);
  }
}

int main(){
  init();
  solve();
  return 0;
}
```
{% endfold %}
