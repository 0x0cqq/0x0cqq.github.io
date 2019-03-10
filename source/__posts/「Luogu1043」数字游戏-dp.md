---
title: 「Luogu1043」数字游戏-dp
date: 2017-12-23 13:15:19
tags:
- 动态规划
- 题解
categories: OI
visible:
urlname: luogu-1043
---

在你面前有一圈整数（一共$n$个），你要按顺序将其分为$m$个部分，各部分内的数字相加，相加所得的$m$个结果对10取模后再相乘，最终得到一个数$k$。游戏的要求是使你所得的$k$最大或者最小。
<!-- more -->

例如，对于下面这圈数字（$n$=4，$m$=2）：

![](description.png)

要求最小值时，$((2-1) mod 10)×((4+3) mod 10)=1×7=7$，要求最大值时，为$((2+4+3) mod 10)×(-1 mod 10)=9×9=81$。特别值得注意的是，无论是负数还是正数，对$10$取模的结果均为非负值。

丁丁请你编写程序帮他赢得这个游戏。

## 链接

[Luogu P1043](https://www.luogu.org/problemnew/show/P1043)

## 题解
很水的一道$dp$题目。只要知道断环为链剩下的也都不难。题解洛谷没给过，现在也找不到了，只有代码还剩了下来。代码里面也有注释，凑活看看也可以。

update: 这是我写的第一篇题解啦！

## 代码

{% fold %}

```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
#include <cmath>
using namespace std;

long long num[150],dp_1[150],dp_2[150];//_1放最大值,_2放最小值

int n,m;

inline int mod(long long nnn){//mod函数
    int w = int(floor(double(nnn)/10));
    return nnn - w*10;
}

int main(){
    scanf("%d %d",&n,&m);
    for(int i = 1;i<=n;i++){//断环为链的准备
        scanf("%lld",&(num[i]));
        num[i+n] = num[i];
    }
    for(int i = 1;i<=2*n;i++)//前缀和的处理
        num[i] = num[i-1]+num[i];
    //正经dp
    long long maxn = -1,minn = 0x3f3f3f3f;
    for(int s = 1;s<=n;s++){//枚举起点
        memset(dp_1,0,sizeof(dp_1));//清零dp数组
        memset(dp_2,0,sizeof(dp_2));
        for(int j = 0;j<m;j++){//板子由少到多
            for(int i = s;i<=s+n;i++){//上一个插板子的地方
                if(j == 0){//j==0的时候的处理，其实也可以叫初始化
                    dp_1[i] = dp_2[i] = mod(num[s+n]-num[i]);
                    continue;
                }
                long long maxtmp = -1,mintmp = 0x3f3f3f3f;//对所有可能下一状态的遍历，并取最大或最小值
                for(int x = i+1;x<=s+n-j-1;x++){
                    maxtmp = max(maxtmp,dp_1[x]*mod(num[x]-num[i]));
                    mintmp = min(mintmp,dp_2[x]*mod(num[x]-num[i]));
                }
                dp_1[i] = maxtmp;//取最大最小值
                dp_2[i] = mintmp;
            }
        }
        maxn = max(dp_1[s],maxn);//对于起点不同的最大最小值进行更新
        minn = min(dp_2[s],minn);
    }
    printf("%lld\n%lld\n",minn,maxn);
    return 0;
}
```
{% endfold %}

