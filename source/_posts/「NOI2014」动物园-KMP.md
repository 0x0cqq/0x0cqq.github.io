---
title: 「NOI2014」动物园-KMP
urlname: NOI2014-zoo
date: 2018-04-05 16:55:40
tags:
- 题解
- 字符串
- KMP
categories: OI
visible:
---

给定一个字符串$S$，求出$num$数组——对于字符串$S$的前$i$个字符构成的子串，既是它的后缀同时又是它的前缀，并且该后缀与该前缀不重叠，将这种字符串的数量记作$num[i]$。

特别地，为了避免大量的输出，你不需要输出$num[i]$分别是多少，你只需要输出所有$(num[i]+1)$的乘积，对$10^9+7$取模的结果即可。

<!-- more -->

## 链接

[Luogu P2375](https://www.luogu.org/problemnew/show/P2375)

[BZOJ 3670](https://www.lydsy.com/JudgeOnline/problem.php?id=3670)

## 题解

终于开始怼字符串的题了。

这一道题让我们求$num$的个数，其实联系一下`AC`自动机，很容易就想到沿着$nex$数组往回跳。跳的次数就是相同前后缀的个数，这个可以在求$nex$的时候直接预处理出来，记为$cnt$数组。

但题目中有一个限制比较烦人：

> 该后缀与该前缀不重叠

一个简单的想法就是求出$nex$数组，对于每一个$i$，先将$nex$降到$\frac{i}{2}$以下，然后看这个$nex$还能跳多少次。但是很遗憾，这个`TLE`了，只有$50$分。因为每一次都跳$nex$代价太高，`gg`。

- - -

一个简单的改进就可以过掉这道题。

我们只需要像跳普通的$nex$一样去跳这个地方的$nex$，只需要每次确保其在$\frac{i}{2}$以下就可以。然后就可以找到$nex$，从而得到$num$。

说长度在$\frac{i}{2}$以下其实不太严谨，具体看代码吧。

## 代码

+ AC代码：


```cpp
#include <cstdio>
#include <cstring>
#define ll long long
using namespace std;

const int MAXN = 1110000;

int n,p = 1000000007;
int nex[MAXN],cnt[MAXN];
char s[MAXN];

void cal(){
    memset(nex,0,sizeof(nex));
    memset(cnt,0,sizeof(cnt));
    nex[0] = 0;
    int len = strlen(s);
    int j = 0;
    for(int i = 1;i<len;i++){
        while(j > 0 && s[i]!=s[j])
            j = nex[j-1];
        if(s[i] == s[j]) ++j;
        nex[i] = j;
        cnt[i] = cnt[nex[i-1]]+1;
    }
    ll ans = 1;
    j = 0;
    for(int i = 1;i<len;i++){
        while(j > 0 && s[i]!=s[j])
            j = nex[j-1];
        if(s[i] == s[j]) ++j;
        while(j>0 && 2*j > i+1)
            j = nex[j-1];
        ans *= (cnt[j]+1),ans%=p;
    }
    printf("%lld\n",ans);
}

void solve(){
    scanf("%d",&n);
    for(int i = 1;i<=n;i++){
        scanf("%s",s);
        cal();
    }
}

int main(){
    solve();
    return 0;
}
```



+ 另附50分代码：


```cpp
#include <cstdio>
#include <cstring>
#define ll long long
using namespace std;

const int MAXN = 1110000;

int n,p = 1000000007;
int nex[MAXN],cnt[MAXN];
char s[MAXN];

void cal(){
    memset(nex,0,sizeof(nex));
    memset(cnt,0,sizeof(cnt));
    nex[0] = 0;
    int j = 0,len = strlen(s);
    ll ans = 1;
    for(int i = 1;i<len;i++){
        while(j > 0 && s[i]!=s[j])
            j = nex[j-1];
        if(s[i] == s[j]) ++j;
        nex[i] = j;
        cnt[i] = cnt[nex[i-1]]+1;
    }
    for(int i = 1;i<len;i++){
        j = nex[i];
        while(j>0 && 2*j > i+1)
            j = nex[j-1];
        ans *= (cnt[j]+1),ans%=p;
    }
    printf("%lld\n",ans);
}

void solve(){
    scanf("%d",&n);
    for(int i = 1;i<=n;i++){
        scanf("%s",s);
        cal();
    }
}

int main(){
    solve();
    return 0;
}
```

