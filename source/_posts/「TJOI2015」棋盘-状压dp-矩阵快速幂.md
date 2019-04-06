---
title: 「TJOI2015」棋盘-状压dp+矩阵快速幂
urlname: TJOI2015-board
date: 2018-10-04 21:43:30
tags:
- 状压dp
- 动态规划
- 矩阵快速幂
categories: 
- OI
- 题解
visible:
---

有一个  $n$  行  $m$  列的棋盘，棋盘上可以放很多特殊的棋子，每个棋子的攻击范围是  $3$  行  $p$  列。输入数据用一个 $3 \times p$  的矩阵给出了棋子攻击范围的模板，棋子被默认在模板中的第 [二] 行，第 [$k+1$] 列，模板中棋子能攻击到的位置标记为  `1`，不能攻击到的位置是  `0`  $(1 \leq p \leq m, 0 \leq k < p)$。输入数据保证模板中的第 [二] 行第 [$k+1$]  列是  `1`。

打开门的密码是这样的：在要求棋子互相不能攻击到的前提下，摆放棋子的方案数。注意什么棋子都不摆也算作一种可行方案。请求出方案对  $2^{32}$  取余的结果即可。

<!-- more -->
注：为使题面符合正常人的思维，对其做了微小的修改，已经用粗体标出。

## 题解

很显然， $m$ 那么小，我们肯定可以状态压缩了。

我们注意到，相当于你在某一行放置的棋子，都只会对本行和前后各一行行产生影响，所以事实上如果我们记录前一行就可以完成状态的记录。

我们可以得到一个状态转移方程，令 $i$ 为还剩下的行数， $S$ 为上一行的状态：

$$
dp[i][S] = 
\left\{
\begin{aligned}{}
&[S\text{为合法状态}]&,&i = 0\\
&\sum dp[i-1][S'] ,SS'\text{满足条件A} &,&i \neq 0  \\
\end{aligned}
\right.
$$

其中条件 $A$ 为 $S,S'均合法 且 SS' 不冲突$。

计算合法、不冲突就直接状压按照规则来就可以了，枚举每个位置，然后计算不能放棋子的位置，在取一个与即可。

注意到复杂度有些高...貌似是 $O(n(2^m)^2)  = 10^6 \times 64 \times 64 \approx 4 \times 10^9$ ，再加上我们对于任意的 $i$ ，我们的转移是一样，就可以套上矩阵快速幂，复杂度即为 $O((2^m)^3 \times \log n) \approx 5 \times 10^6$ 可过...

取模使用 `unsigned int` 自然溢出即可。

## 代码


```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
#define ui unsigned int
using namespace std;

const int MAXN = 70;

int n,m,p,k,M;
int limit[3];


struct Matrix{
  ui num[MAXN][MAXN];
  Matrix(int op = 0){
    memset(num,0,sizeof(num));
    for(int i = 0;i<MAXN;i++){num[i][i] = op;}
  }
  ui * operator [](int n){return num[n];}
};

Matrix mul(Matrix &_x,Matrix &_y){
  Matrix ans;
  for(int i = 0;i<M;i++)
    for(int j = 0;j<M;j++)
      for(int k = 0;k<M;k++)
        ans[i][j] += _x[i][k] * _y[k][j];
  return ans;
}

Matrix pow(Matrix x,int k){
  Matrix ans(1);
  for(int i = k;i;i>>=1,x = mul(x,x)) if(i&1) ans = mul(ans,x);
  return ans;
}

int getv(int x,int op){
  int ans = 0;
  for(int i = 0;i<m;i++)
    if(x&(1<<i)) ans |= (i<=k?limit[op]>>(k-i):limit[op]<<(i-k));
  return ans;
}

bool judge_self(int x){return x & getv(x,1);}
bool judge_next(int L,int R){return (L & getv(R,0)) || (R & getv(L,2));}

void init(){
  scanf("%d %d %d %d",&n,&m,&p,&k);M = 1 << m;
  for(int i = 0;i<3;i++){
    for(int j = 0;j<p;j++){
      int t;scanf("%d",&t);
      limit[i] |= t * (1<<j);
    }
  }
  limit[1] -= (1<<k);
}

void solve(){
  Matrix a;
  for(int i = 0;i<M;i++){
    if(judge_self(i)) continue;
    for(int j = 0;j<M;j++){
      if(judge_self(j)) continue;
      if(!judge_next(j,i)){
        a[i][j]++;
      }
    }
  }
  a = pow(a,n);
  ui ans = 0;
  for(int i = 0;i<M;i++){
    if(!judge_self(i)) ans += a[0][i];
  }
  printf("%u\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```

