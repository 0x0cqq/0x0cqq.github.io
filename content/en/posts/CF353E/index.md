---
title: 「CF353E」 Antichain-乱搞
urlname: CF353E
date: 2019-03-02 12:20:52
tags:
- 乱搞
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

给定一个长度为 $n$ 的 $01$ 序列，第 $i$ 位是 $0$ 代表 节点 $i$ 到节点 $i \bmod n + 1$ 有一条有向边，第 $i$ 位是 $1$ 代表 节点 $i \bmod n + 1$ 到节点 i 有一条有向边。

我们称一个节点对 $(u,v)$ 是妙的当且仅当不存在 $u$ 到 $v$ 和 $v$ 到 $u$ 的路径任何两者之一。

现在你要从这个图里面挑出一个集合，使得集合中任意两个不同的节点 $u$ 和 $v$ 之间构成的节点对 $(u,v)$ 都是妙的。

请你输出这个集合的大小的最大值。

<!--more-->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/353/E)

## 题解

不会做，看了题解也不会做...看懂题解是不可能看懂的，只好去看看代码过过日子。

于是研究了一番 rng_58 的代码，大概搞懂了这个题。

- - -

我们把这 $n$ 个点复制一倍，放在一条直线上。我们把具有相同方向的称为一个连续段，其长度为连续的边的数量，然后我们找到一个位置切掉这个序列，相当于断环为链，然后我们发现这个东西可以贪心解决了。

我们如果遇到一个长度大于等于 2 的，我们就把答案 + 1，然后在两个长度大于等于 2 的之间，全都是长度大于等于 1 的，我们发现这样的话，为了不影响到长度大于等于 2 的，我们能取的个数就是 $\frac{len}{2}$ 。然后就可以计算答案了。

如果不存在长度大于等于 2 的序列，那么我们的答案就是 $\frac{n}{2}$

贪心的去想一想，很有正确的道理。

时间复杂度： $O(n)$

## 代码


```cpp
#include <bits/stdc++.h>
#define ui unsigned 
using namespace std;

ui n,st;
string s,t;

int main(){
  cin >> s;n = s.length();

  s = s+s;
  for(ui i = 1;i<s.length();i++){
    if(s[i] != s[i-1]){st = i;break;}
  }
  s = s.substr(st,n);
  int ans = 0;
  for(ui i = 0;i < s.length();){
    for(ui j = i+1;;j++){
      if(j == s.length() || s[j] != s[i]){
        t.push_back(j - i == 1?'1':'2');
        i = j;
        break;
      }
    }
  }
  int M = t.length();
  t = t + t;
  for(int i = 1;i<=M;i++){
    if(i == M || t[i] != t[i-1]){
      t = t.substr(i,M);
      break;
    }
  }
  for(ui i = 0;i<t.length();){
    for(ui j = i+1;;j++){
      if(j == t.length() || t[j] != t[i]){
        ans += (j-i) / (t[i]=='1'?2:1);
        i = j;
        break;
      }
    }
  }
  cout << ans << endl;
  return 0;
}
```

