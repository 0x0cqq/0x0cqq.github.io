---
title: 「CF543C」Remembering Strings-状态压缩dp
urlname: CF543C
date: 2019-02-15 16:30:51
tags:
- 动态规划
- 题解
- 状压dp
categories: OI
visible:
---

给定 $n$ 个长度均为 $m$ 的字符串，再给出一个 $n$ 行 $m$ 列的矩阵 $\{a_{nm}\}$。
矩阵元素 $a_{ij}$ 代表把第 $i$ 个字符串第 j 个字符改成其它任意字符所需要的代价。

现在要求对于任意一个字符串，总存在某一位置 $j$ 使得该位置上的字符在任意其他字符串该位置的字符不同。

即为对于第 x 个字符串 ，有 $\exists j \in [1,m] , \forall i \in [1,n],s_{xj} \neq s_{ij}$ 。

求把所有字符串修改成满足上述要求的字符串的最小代价是多少？

数据范围： $1 \le n,m \le 20,1\le a_{ij} \le 10^6$ 。

<!-- more -->

## 题解

我们发现，无论其他字符串是什么情况，我们总能找到在这一位没有用过的字符，这也是后面dp正确性的保障。

我们状态压缩一波，令 $dp[S]$ 表示在 $S$ 中为 $1$ 的这些都已经好记了的情况下，想要好记还需要多少代价。

我们注意到，它们的更改应当是不会干扰的（我都改到从没人用过的），所以我们每次都考虑最靠左的不是 $1$ 的位置，把它变成 $1$ 。我们依次考虑每列，我们有两种办法：

1. 把这个字符串的这个字符改了
2. 把这个字符串这个位置上所有拥有和它一样的字符的字符串的这个位置都改掉，只剩下一个 a 最大的

分类讨论转移即可。

时间复杂度 $O(m 2 ^ n)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int N = 21,MAXN = (1<<N);

int n,m,dp[MAXN];
int a[N][N];char s[N][N];
int ss[N][N],ms[N][N];// ss 与 s[i][j] 同列相同的集合列表, ms ... 减去最大的 

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++) 
    scanf("%s",s[i]+1);
  for(int i = 1;i<=n;i++)
    for(int j = 1;j<=m;j++)
      scanf("%d",&a[i][j]);

  for(int i = 1;i<=n;i++){
    for(int j = 1;j<=m;j++){
      ss[i][j] = (1<<(i-1));
      ms[i][j] = a[i][j];int sum = a[i][j];
      for(int k = 1;k<=n;k++)if(i != k){
        if(s[i][j] == s[k][j]){
          ss[i][j] |= (1<<(k-1));
          ms[i][j] = max(a[k][j],ms[i][j]);
          sum += a[k][j];
        }
      }
      ms[i][j] = sum - ms[i][j];
    }
  }
}

int dfs(int S){
  if(dp[S] < inf) return dp[S];
  if(S == (1<<n)-1) return 0;
  int ans = inf,low;
  for(int i = 1;i<=n;i++){
    if((S & (1<<(i-1))) == 0){
      low = i;break;
    }
  }
  for(int j = 1;j<=m;j++)
    ans = min(ans,min(
        dfs(S|(1<<(low-1))) + a[low][j],
        dfs(S|ss[low][j])   + ms[low][j]));
  return dp[S] = ans;
}

int main(){
  init();
  memset(dp,0x3f,sizeof(dp));
  printf("%d\n",dfs(0));  
  return 0;
}
```

