---
title: 「HNOI2009」梦幻布丁-set-启发式合并
urlname: HNOI2009-pudding
date: 2018-05-21 20:08:18
tags:
- 启发式合并
- set
- 平衡树
categories: 
- OI
- 题解
series:
- 各省省选
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

$n$ 个布丁摆成一行，每个布丁最开始都有一个颜色 $c_i$ ，进行 $m$ 次操作。

操作格式：

+ `1 c d` ：将所有的 $c$ 颜色替换为$d$

+ `2` ：查询当前布丁序列一共有多少段颜色。例如颜色分别为 $1,2,2,1$ 的四个布丁一共有3段颜色。

<!--more-->

## 链接

[Luogu P3201](https://www.luogu.org/problemnew/show/P3201)

## 题解

这题非常有趣。开始想倒是像以前做过的 [[SDOI2011]染色]({{< ref "posts/SDOI2011-colour/index.md" >}}) ，不过仔细想想这个东西很难用线段树进行维护。

~~由于这道题放在平衡树的专题里~~，我们思考一下这个东西能不能用平衡树维护。

重点需要解决的问题是如何合并两种颜色（因为颜色段肯定是单调递减的）。我们可以想到使用平衡树的启发式合并。合并的时候更新答案的情况只有当前这个位置的 $pos-1$ 或者 $pos+1$ 的位置有相同颜色的位置的时候，我们都需要对答案减去 1 。

启发式合并可以让复杂度降低一个 $log$ ，最后时间复杂度就是 $O(n \log^2{n})$ 。最坏情况就是每次合并的区间大小都相等的情况，合并起来的次数 $O(n \log {n})$ 。

有 $O(n \log{n})$ 的奇怪做法，具体我也就不会了。

具体实现上，可以维护一个数组记录当前某个数对应的 `set` 位置，就可以减去一些不必要消耗。

## 代码


```cpp
#include <cstdio>
#include <algorithm>
#include <set>
#include <cctype>
using namespace std;

const int MAXN = 1100000;

namespace fast_io {
    //...
}using namespace fast_io;

int n,m,ans = 0;
int num[MAXN],re[MAXN];
set<int> S[MAXN];

void update(int last,int now){
    for(set<int>::iterator it = S[last].begin();it!=S[last].end();it++){
        if(num[(*it)-1] == (now)) 
            ans--;
        if(num[(*it)+1] == (now))
            ans--;
        S[now].insert(*it);
    }
    for(set<int>::iterator it = S[last].begin();it!=S[last].end();it++)
        num[*it] = now;
    S[last].clear();
}

void init(){
    read(n),read(m);
    for(int i = 1;i<=n;i++){
        read(num[i]);
        if(num[i]!=num[i-1]) ans++;
        S[num[i]].insert(i);
        re[num[i]] = num[i];
    }
}

void solve(){
    int op,a,b;
    for(int i = 1;i<=m;i++){
        read(op);
        if(op == 1){
            read(a),read(b);
            if(a == b) continue;//很重要！
            if(S[re[a]].size() > S[re[b]].size()) swap(re[a],re[b]);
            update(re[a],re[b]);
        }
        else if(op == 2){
            print(ans),print('\n');
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

