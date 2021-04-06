---
title: 「CF400E」Inna and Binary Logic-简单数据结构
urlname: CF400E
date: 2018-12-31 15:39:18
tags:
- 数据结构
categories: 
- OI
- 题解
series:
- Codeforces
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---


Inna 有一个一个长度为 $n$ 的数列 $a_1 [1],a_1 [2],\dots,a_1 [n]$。 

她会进行如下操作，分为 $n$ 个阶段：
在第一阶段，Inna 从数组 $a_1$中写出所有数字，在第 $i$ 个 $(i \ge 2)$ 阶段 Inna 会写出数组的所有元素 $a_i$ ，由 $n  -  i + 1$ 个整数组成; 数组 $a_i$ 的第 $k$ 个数定义如下：$a _ {i} [k] = a _ {i-1} [k]\ \mathrm{AND}\ a _ {i-1} [k + 1]$ 。 这里 $\mathrm{AND}$ 是二进制的逐位与运算。

Dima 决定检验 Inna 的技能。 他要求 Inna 改变阵列，进行练习并说出她在当前练习中写出的所有元素的总和，即：

$$
\sum _ {i=1}^n \sum _ {j=1}^{n-i+1} a_i[j]
$$

请帮助 Inna 回答问题！

<!--more-->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/400/E)

## 题解

每位贡献独立，方便合并，一看就要分位考虑嘛。

我们分位考虑后，就只剩下只包含 0/1 ，每次把一个位置 0->1 或者 1->0 ，然后重新计算这一位的贡献。

事实上，我们在一位的情况下，我们只要计算出多少长度在 $[1,n]$ 的区间包含至少 1 个 0 。

我们考虑用唯一性确定这个事情（用最先出现的 0 计算贡献），就是左端点从上一个 0 到这个 0 的区间，右端点在这个 0 以右的区间。

用 `set` 维护每个 0 出现的位置，每次修改计算下贡献就好了。

时间复杂度是 $O(n \log n \log V)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
#define int long long
using namespace std;

const int MAXN = 210000,logn = 21;

int n,m,ANS = 0;
int num[MAXN];
set<int> S[logn];// 维护0出现的位置

int getpre(int pos,int x){// 小于 pos 的第一个 x 
  auto it = S[x].lower_bound(pos);
  return *(--it);
}
int getnex(int pos,int x){// 大于 pos 的第一个 x
  auto it = S[x].upper_bound(pos);
  return *it; 
}
int calc(int now,int last,int x){
  return (now-last) * (n-now+1) * (1LL<<x);
}

void update(int p,int v){
  for(int i = 0;i<logn;i++){
    int tmp = (v&(1<<i))!=0;
    if(tmp != (int)(S[i].count(p))) continue;
    int last = getpre(p,i),nex = getnex(p,i);
    if(!tmp){
      ANS += calc(nex,last,i);
      ANS -= calc(nex,p,i);ANS -= calc(p,last,i);  
      S[i].insert(p);
    }
    else{
      ANS -= calc(nex,last,i);
      ANS += calc(nex,p,i);ANS += calc(p,last,i); 
      S[i].erase(p);
    }
  }
}

void init(){
  scanf("%lld %lld",&n,&m);
  for(int x = 0;x<logn;x++)
    for(int i = 1;i<=n;i++) S[x].insert(i);
  for(int i = 0;i<logn;i++) S[i].insert(0),S[i].insert(n+1);
  for(int i = 1;i<=n;i++){
    scanf("%lld",&num[i]);
    update(i,num[i]);
  }
}

void solve(){
  int v,p;
  for(int i = 1;i<=m;i++){
    scanf("%lld %lld",&p,&v);
    update(p,v);
    printf("%lld\n",ANS);  
  }
}

signed main(){
  init();
  solve();
  return 0;
}
```


