---
title: 「HNOI2007」梦幻岛宝珠-背包dp
urlname: HNOI2007-diamond
date: 2018-11-03 09:57:05
tags:
- 题解
- 动态规划
- 背包
categories: OI
visible:
---

给你 $N$ 颗宝石，每颗宝石都有重量 $w_i$ 和价值 $v_i$。要你从这些宝石中选取一些宝石，保证其总重量不超过 $W$ ，且总价值最大。

请你输出最大的总价值。

<!-- more -->
数据范围：$N \leq 100;W \leq 2^{30}$，并且保证每颗宝石的重量符合 $w_i = a \cdot 2^b$（ $a \leq 10;b \leq 30$ ）。

## 题解

先按照 $w_i = a_i \cdot 2^{b_i}$ 中 $b_i$ 为第一关键字， $a_i$ 为第二关键字均从大到小给物品排序。

我们发现，如果 $dp$ 过程中考虑当前物体的重量是 $a_i \cdot 2^{b_i}$ ，（因为剩下的物体不可能超过 $n \leq 100$ 个，每个物体的重量又不超过 $a_i \cdot 2^{b_i}$，又 $a_i \leq 10$，）那么剩下所有的物品的重量之和也不可能超过 $n \times a_i \cdot 2^{b_i} \leq 1024 \cdot 2^{b_i}$ 。（因为剩下的物品的重量之和不超过 $2^{10} \cdot 2^{b_i}$，）这意味着剩余的重量只有在比 $b_i$ 高的前 $10$ 个二进制位置（也就是代表 $2^{b_{i+1}},...,2^{b_{i+10}}$ 的二进制位）是可能有用的，否则如果剩余重量在（比 $b_i$ 高的）第 $11$ 个位置（或更高位）存在一个 $1$，（也就是剩下的重量大于等于 $2^{11} \cdot 2^{b_i}$ ，也就大于 $2^{10} \cdot 2^{b_i}$ ，你剩下的所有物品的重量），那么这个时候的最优策略一定是把剩下的全取完，重量还可以有剩余，（这样对答案的贡献计算是 $O(1)$ 的）。

正常的背包中我们的状态有两个维度，当前考虑的物品和剩余的背包容积。但是这里的 $W$ 过于大，以至于这种表示方法不能成立。但上面提到我们事实上只需要比 $b_i$ 高的那 $10$ 个二进制位的状况，否则我们就可以直接更新最后的答案。

所以状态就可以表示为 $dp[i][s]$，表示考虑完前 $i$ 个物品时， $s$ 为考虑到当前物品时剩余的 $W$ 在 $b_i$ 前 $10$ 个二进制位（压缩成一个 $1 到 1024$ 的十进制整数）的情况。我们注意到我们考虑到第 $i$ 个物品的时候，对于所有比 $b_i$ 低的二进制位我们不可能在前 $i$ 个物品中改变，所以剩余重量比 $2^{b_i}$ 低的二进制位事实上就是 $W$ 的这些二进制位，我们不在 dp 状态中显性表示罢了。

我们考虑这个物体决策取或者不取，转移是非常简单的，就是普通背包的转移就可以了。

当我们考虑完了当前的物品，考虑下一个物品之前，我们需要做一些变换。

现在我们有两种情况，第一种是 $w_{i+1}$ 和 $w_i$ 的二进制非 $0$ 最低位相同，那我们就不需要做什么特殊的处理，直接用 $w_i$ 转移得到数组即可。

第二种情况是 $w_{i+1}$ 的最低非 $0$ 二进制位比 $w_i$ 的低，那么这个时候我们就遍历所有1024种状态，如果左移到最低位之后这个状态的剩余价值大于等于 $2^{10} \cdot 2^{b_{w+1}}$ ，那么直接处理掉这个状态，否则就加上 $W$ 的低位之后转移即可。

时间复杂度大约是 $O((n+30) \times 2^{10})$ 。

## 代码

{% fold %}
```cpp
#include <algorithm>
#include <cstdio>
#define inf 0x3f3f3f3f
#define maxn 1024
using namespace std;

const int MAXN = 1100;

int n,W;

struct wupin{
  int a,b,v;
  bool operator < (const wupin &x)const{
    if(b != x.b) return b > x.b;
    else         return a > x.a;
  }
}w[MAXN];

bool init(){
  scanf("%d %d",&n,&W);
  if(n == -1 && W == -1) return 0;
  for(int i = 1;i<=n;i++){
    int weight,val,cnt = 0;
    scanf("%d %d",&weight,&val);
    while((weight & 1) == 0)
      weight >>= 1,cnt++;
    w[i] = (wupin){weight,cnt,val};
  }
  return 1;
}


void solve(){
  sort(w+1,w+n+1);
  static int sum[MAXN], dp[MAXN],tmp[MAXN];//dp[j] -> dp[i][j]，后10位的状况
  int noww = 31,ans = 0;;
  for(int i = 1;i<=n;i++) sum[i] = sum[i-1] + w[i].v;
  for(int j = 0;j<maxn;j++) dp[j] = -inf;
  dp[0] = 0;
  for(int i  = 1;i<=n;i++){
    while(noww > w[i].b){
      for(int j = 0;j<maxn;j++) tmp[j] = -inf;
      for(int j = 0;j<maxn;j++){
        if((j<<1) >= maxn)
          ans = max(ans,dp[j] + sum[n] - sum[i-1]);
        else{
          int newn = (j<<1) | ((W>>(noww-1))&1);
          tmp[newn] = max(tmp[newn],dp[j]);
        }
      }
      for(int j = 0;j<maxn;j++) dp[j] = tmp[j];
      noww--;
    }
    for(int j = 0;j<maxn;j++) tmp[j] = -inf;
    for(int j = 0;j<maxn;j++){//(111111111)_2
      tmp[j] = max(tmp[j],dp[j]);
      if(j - w[i].a >= 0)
        tmp[j-w[i].a] = max(tmp[j-w[i].a],dp[j] + w[i].v);
    }
    for(int j = 0;j<maxn;j++) dp[j] = tmp[j];
  }
  for(int j = 0;j<maxn;j++) ans = max(ans,dp[j]);
  printf("%d\n",ans);
}

signed main(){
  while(init()) solve();
  return 0;
}
```
{% endfold %}
