---
title: 「POI2014」Salad Bar-瞎搞
urlname: POI2014-Salad-Bar
date: 2018-08-16 21:23:22
tags:
- 题解
- 瞎搞
categories: OI
visible:
---

有一个长度为$n$的字符串，每一位只会是 $\text{p}$ 或 $\text{j}$ 。求一个最长子串，使得不管是从左往右还是从右往左取，都保证每时每刻已取出的 $\text{p}$ 的个数不小于 $\text{j}$ 的个数。

<!-- more -->

## 链接

[Luogu P3564](https://www.luogu.org/problemnew/show/P3564)

## 题解

瞎搞题。

把 $p$ 看做 $1$ ，$j$ 看做 $-1$ ，那么问题转化为：求最长的子串 $s[l...r]$ ，使得$sum[l-1] \leq sum[i] \leq sum[r]$对于任意$i \in [l,r]$成立。

我们首先建一个类似图的东西，把所有sum相同的位连到一起去，让 $nex[i]$ 表示下一个 $sum[x] = sum[i]$ 的位置，没有的话就是$-1$；让$to[i-1]$表示我们从第$i$位开始找到的最远的满足该性质的位置。

然后我们发现，答案就是$\max(to[i-1]-i+1)$。

所以我们只要推出$to[i]$数组就可以了。

剩下的我就说不明白了2333，看代码感性理解吧。

为啥它是最长的我也不知道，反正能过。

复杂度$O(n)$。

## 代码

{% fold %}
```cpp
#include <cstdio>
#include <algorithm>
#include <cstring>
using namespace std;

const int MAXN = 1100000;

int n;
char str[MAXN];
int a[MAXN],sum[MAXN];
int minsum = 0;
int fir[MAXN],nex[MAXN],to[MAXN];
// fir仅做建图方便用，nex表示下一个sum相同的位置
// to表示区间最远能够延伸的距离

void init(){
    scanf("%d",&n);
    scanf("%s",str + 1);
    memset(fir,-1,sizeof(fir));
    for(int i = 1;i<=n;i++){
        a[i] = str[i] == 'p' ? 1 : -1;
        sum[i] = sum[i-1] + a[i];
        minsum = min(sum[i],minsum);
    }
    for(int i = n;~i;--i){
        int x = sum[i] - minsum;
        nex[i] = fir[x],to[i] = i,fir[x] = i;
    }
}

void solve(){
    static int ans = 0;
    int r = n;
    for(int l = n;l>=1;--l){
        if(a[l] == -1){
            r = l-1;
        }
        else{
            int t = nex[l-1];
            if(~t && sum[to[t]] >= sum[r])
                r = to[t];
            to[l-1] = r;
            ans = max(ans,r-l+1);
        }
    }
    printf("%d\n",ans);
}

int main(){
    init();
    solve();
    return 0;
}

```
{% endfold %}