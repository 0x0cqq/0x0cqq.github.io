---
title: 「POI2006」Periods of Words-KMP
urlname: POI2006-okr
date: 2018-08-14 19:50:59
tags:
- 字符串
- KMP
categories: 
- OI
- 题解
visible:
---

一个串是有限个小写字符的序列,特别的,一个空序列也可以是一个串. 一个串 $P$ 是串 $A$ 的前缀, 当且仅当存在串 $B$ , 使得 $A = PB$. 如果 $P \neq A$ 并且 $P$ 不是一个空串,那么我们说 $P$ 是 $A$ 的一个 $proper$ 前缀. 定义 $Q$ 是 $A$ 的周期, 当且仅当 $Q$ 是 $A$ 的一个 $proper$ 前缀并且 $A$ 是 $QQ$ 的前缀(不一定要是 $proper$ 前缀). 

比如串 $abab$ 和 $ababab$ 都是串 $abababa$ 的周期. 串 $A$ 的最大周期就是它最长的一个周期或者是一个空串(当 $A$ 没有周期的时候), 比如说, $ababab$ 的最大周期是 $abab$ . 串 $abc$ 的最大周期是空串. 给出一个串,求出它所有前缀的最大周期长度之和.

<!-- more -->

## 链接

[Luogu P3435](https://www.luogu.org/problemnew/show/P3435)

## 题解

分析一下，可以发现我们要求的是所有前缀的**最短的相同的前后缀**，且还有长度的限制，不能超过字符串的一半。

这个可以联想到$KMP$，所以我们思考如何在$KMP$的基础上维护这个事情。因为$KMP$在往回跳的话，是可以找到所有的相同的前后缀的。所以给定一个前缀，它沿$nex$数组的转移是确定的，我们也就可以维护一个$near[i]$，就是最近能够跳到的长度，也就是相同的前后缀最短值，所以我们就可以$O(1)$的根据$nex$数组计算这个$near$数组，然后得到最后的答案。

## 代码


```cpp
#include <cstdio>
using namespace std;

const int MAXN = 1100000;

char s[MAXN];
int n,nex[MAXN],near[MAXN];

void solve(){
    int j;j = nex[0] = 0;
    for(int i = 1;i<n;i++){
        while(j > 0 && s[i] != s[j])
            j = nex[j-1];
        if(s[i]==s[j]) j++;
        nex[i] = j;
    }
    j = 0;
    long long ans = 0;
    near[0] = 0;
    for(int i = 1;i<n;i++){
        int w = nex[i] - 1;
        if(w >= 0)
            near[i] = near[w] == -1?w:near[w];
        else
            near[i] = -1;
        j = near[i]+1;
        if(j > 0 && j <= (i+1)/2)
            ans += (i+1)-j;
        // printf("i:%d j:%d\n",i,j);
    }
    printf("%lld\n",ans);
}

void init(){
    scanf("%d",&n);
    scanf("%s",s);
}

int main(){
    init();
    solve();
    return 0;
}
```

