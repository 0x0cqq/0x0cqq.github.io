---
title: 「POI2015」Myjnie-区间dp
urlname: POI2015-Myjnie
date: 2018-09-23 19:32:19
tags:
- 题解
- 动态规划
- 区间dp
categories: OI
visible:
---

有 $n$ 家洗车店从左往右排成一排，每家店都有一个正整数价格 $p_i$ 。有 $m$ 个人要来消费，第 $i$ 个人会驶过第 $a_i$ 个开始一直到第 $b_i$ 个洗车店，且会选择这些店中最便宜的一个进行一次消费。但是如果这个最便宜的价格大于 $c_i$，那么这个人就不洗车了。

请给每家店指定一个价格，使得所有人花的钱的总和最大。

<!-- more -->

## 链接

[Luogu P3592](https://www.luogu.org/problemnew/show/P3592)

## 题解

首先我们可以明显的发现一个结论：所有 $p_i$ 都只可能是给定的 $c_i$  中的数。

所以我们可以先对 $c_i$ 离散化，这样我们的 $c_i$ 的范围就是 $[1,4000]$ 了。我们只要计算出每个人以哪个 $c_i$ 作为最小值，一样可以求得答案。

如果我们知道一个区间的最小值在什么位置，那么我们事实上可以把所有经过这个点的人的花费直接计算，剩下的人选择的区间（假设我们只考虑被 $[l,r]$ 包含的线段 ）都不会跨过中间的最小值，那么完全可以递归子问题解决。

所以我们 $dp$ 解决这个问题。

我们设 $f[i][j][k]$ 表示所有被 $[l,r]$ 包含的线段中，区间中存在最小值为 $k$ （离散化后）的点。

那么我们可以枚举值为 $k$ 的点的出现位置 $p$ ，就可以得到以下的方程：

$$
f[l][r][k] = \max_{p=l}^{r}(g[l][p-1][k] + g[p+1][r][k] + v[k] \times c[p][k])
$$

其中：

$g[l][r][k] = \max_{w = k}^{n} (f[l][r][w])$意为这个区间中最小值大于等于 $k$ 的情况下，收费的最大值；$c[p][k]$ 意为在所有被 $[l,r]$ 包含且穿过 $p$ 位置而且 $c_i \geq  k$ 的线段的个数； $v[k]$ 代表 $k$ 的真实大小。

最后答案即为 $g[1][n][1]$。

分析下复杂度：

枚举区间 $[l,r]$ 为 $O(n^2)$ ，对于每一个区间，我们计算 $c[p][k]$ 复杂度为 $O(nm)$ ；我们枚举断点、最小价格的复杂度也是 $O(nm)$；$g$ 数组计算的复杂度明显可以在一个较低的复杂度下进行，最后的时间复杂度就是 $O(n^3m)$；空间复杂度 $O(n^2m)$ 。

计算路径的时候，我们记录每个 $f[l][r][k]$ 对应的最优分割位置 $p$ 以及 $g[l][r][k]$ 的最优权值选择 $k$ ，就可以递归计算了。

## 代码 

{% fold %}
```cpp
#include <cstdio>
#include <map>
#include <unistd.h>
#include <algorithm>
using namespace std;

const int MAXN = 60,MAXM = 4100;

int n,m;
int A[MAXM],B[MAXM],C[MAXM];
map<int,int> S;int val[MAXM],cnt;
int f[MAXN][MAXN][MAXM],g[MAXN][MAXN][MAXM];
int pp[MAXN][MAXN][MAXM],gk[MAXN][MAXN][MAXM];
// pp 记录 f 的位置， gk 记录 g 的权值（记录路径用）
int c[MAXN][MAXM];

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=m;i++){
    scanf("%d %d %d",&A[i],&B[i],&C[i]);
    S[C[i]] = 0;
  }
  for(map<int,int>::iterator it = S.begin();it != S.end();it++){
    it->second = ++cnt;
    val[cnt] = it->first;
  }
  for(int i = 1;i<=m;i++){
    C[i] = S[C[i]];
  }
}

void solve(){
  for(int len = 1;len<=n;len++){
    for(int l = 1,r = len;r<=n;l++,r++){
      //计算c
      for(int pos = l;pos<=r;pos++){
        for(int i = 1;i<=m;i++)
          c[pos][i] = 0;
        for(int s = 1;s<=m;s++){
          if(l <= A[s] && B[s] <= r && A[s] <= pos && pos <= B[s]){
            c[pos][C[s]]++;
          }
        }
        for(int i = m;i>=1;i--)
          c[pos][i] += c[pos][i+1];
      }
      // 转移 f 以及 pp
      for(int k = 1;k<=m;k++){
        for(int p = l;p<=r;p++){
          int t = g[l][p-1][k]+g[p+1][r][k]+val[k]*c[p][k];
          if(t > f[l][r][k]) pp[l][r][k] = p; //最优的转移位置 p 
          f[l][r][k] = max(f[l][r][k],t);
        }
        g[l][r][k] = f[l][r][k];
      }
      // 计算 k 以及 gk
      for(int k = m;k>=1;k--){
        gk[l][r][k] = g[l][r][k] > g[l][r][k+1]?k:gk[l][r][k+1];
        g[l][r][k] = max(g[l][r][k],g[l][r][k+1]);
      }
    }
  }
  printf("%d\n",g[1][n][1]);  
}

int ans[MAXN];
void output(int l,int r,int k){
  if(l>r) return;
  if(g[l][r][k] == 0){
    for(int i = l;i<=r;i++) ans[i] = val[cnt];// 这里要设置成最大值
    // 因为这个区间不存在可能的贡献，所以我们就直接赋权值最大，防止对其他造成影响
  }
  else{
    int _k = gk[l][r][k],_p = pp[l][r][_k];
	ans[_p] = val[_k];
    output(l,_p-1,_k),output(_p+1,r,_k);
  }
}

void output(){
  output(1,n,1);
  for(int i = 1;i<=n;i++)
    printf("%d ",ans[i]);
  printf("\n");
}

int main(){
  init();
  solve();
  output();
  return 0;
}
```
{% endfold %}