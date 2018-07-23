---
title: 「SHOI2012」随机树-期望dp
urlname: SHOI2012-tree
date: 2018-07-19 20:07:12
tags:
- 题解
- 数学
- 期望
- 树形结构
categories: OI
visible:
---

> 题面以图片显示，请点击“阅读全文”查看。

<!-- more -->

![](problem.png)

## 链接

[Luogu P3830](https://www.luogu.org/problemnew/show/P3830)

## 题解

这题有两问。

### 第一问

如果令$dp[x]$为有$x$个叶节点的时候叶节点的平均深度，那么有如下方程：
$$
\begin{aligned}{}
dp[x] &= \frac{(x-1)dp[x-1] - dp[x-1] + 2 \times (dp[x-1]+1)}{x}\\
&=dp[x-1] + \frac{2}{x}
\end{aligned}
$$

初始$dp[1] = 0$，$O(n)$递推或者搞一搞通项即可qwq。

### 第二问

树的深度不太好搞。

定理：
$$
E(x) = \sum_{i=1}^{+\infty} P(i \leq x)
$$

感性理解：大小为$x$的可能性就会被从$i = 1$到$i = x$一直累积，累积正好就是$x$次，就是这种可能性的值，所以这个式子的值就是期望。

所以我们只要求出在树的叶节点有$x$个的时候，求出树的深度$i$大于$1$，大于$2$，...，一直到大于$n-1$的概率，然后求和之后就是树的期望深度了。

令$dp[x][j]$为有$x$个叶节点时树的深度大于$j$的概率，因为展开在两侧时完全等概率的，所以我们有如下方程：

$$
dp[x][j] = \frac{1}{x-1}(\sum_{i=1}^{x-1} dp[i][j-1] + dp[x-i][j-1] -  dp[i][j-1] \times dp[x-i][j-1]) 
$$

很简单的容斥。转移即可。注意一下边界，和根结点深度为0即可。

## 代码

{% fold %}
```cpp
#include <cstdio>
using namespace std;

const int MAXN = 200;

double cal(int n,int op){
    double ans = 0;
    if(op == 1)
        for(int i = 2;i<=n;i++) ans += (2/double(i));
    else {
        static double d[MAXN][MAXN];
        for(int i = 1;i<=n;i++)
            d[i][0] = 1;
        for(int i = 2;i<=n;i++){
            for(int j = 1;j<i;j++){
                for(int k = 1;k<=i-1;k++)
                    d[i][j] += d[k][j-1] + d[i-k][j-1]- d[k][j-1] * d[i-k][j-1];
                d[i][j] /= (i-1); 
            }
        }
        for(int i = 1;i<=n-1;i++)//从1开始枚举
            ans += d[n][i];
    }
    return ans;
}

int main(){
    int q,n;
    scanf("%d %d",&q,&n);
    printf("%lf\n",cal(n,q));
    return 0;
}
```
{% endfold %}
