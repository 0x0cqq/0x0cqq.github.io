---
##-- draftstate --##
draft: false
##-- page info --##
title: "「CF750E」New Year and Old Subsequence-矩阵+线段树+dp"
type: "post"
date: 2020-08-09T12:45:20+08:00
slug: ""
categories:
- OI
- 题解
tags:
- 矩阵
- 线段树
- 动态规划
series:
- Codeforces
##-- page setting --##
pinned: false
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
##-- author --##
# author: ""
# authorEmoji: 
# authorImageUrl: ""
# authorImage: ""
# authorDesc: ""
# socialOptions:  
#   email: ""
#   facebook: ""
---

定义一个数字串为“妙”的当且仅当：该串包含某一子序列为 $2017$ ，且不包含子序列 $2016$。

定义一个数字串的“丑值”为：该串至少删去几个字符，可以使得剩余串变“妙”；如果删去任意多个字符，均无法使该串变“妙”，则该串的“丑值”是 $-1$。

给定一个长度为 $n$ 的数字串 $s$ 。有 $q$ 次询问，每次询问用 $(l_i,r_i)$ 表示。对于每次询问，回答子串 $s[l_i...r_i]$ 的“丑值”。

<!-- more -->

## 链接

[Codeforces](http://codeforces.com/problemset/problem/750/E)

## 题解

我们考虑只有一个询问而且子串是整个字符串的做法。

我们令 $dp[i][p]$ (其中 $p \in \{0,1,2,3,4\}$) 表示使 $p$ 最多恰好匹配到 $2017$ 的第 $p$ 个位置的最小删除代价，那么我们可以写出如下的 dp 转移方程：

$$
dp[0][0] = 1,dp[0][1] = dp[0][2] = dp[0][3] = dp[0][4] = \infty\\
\begin{aligned}
dp[i][0] = &\left\{\begin{aligned}
dp[i-1][0] + 1&, s_i \in \{2\}\\
dp[i-1][0]&, s_i \not\in \{2\}\\
\end{aligned} 
\right.\\
dp[i][1] = &\left\{\begin{aligned}
\min(dp[i-1][0],dp[i-1][1])&,s_i \in \{2\}\\
dp[i-1][1] + 1&,s_i \in \{0\}\\
dp[i-1][1]&,s_i \not \in \{2,0\}
\end{aligned}\right.\\
dp[i][2] = &\left\{\begin{aligned}
\min(dp[i-1][1],dp[i-1][2])&,s_i \in \{0\}\\
dp[i-1][2] + 1&,s_i \in \{1\}\\
dp[i-1][2]&,s_i \not \in \{0,1\}
\end{aligned}\right.\\
dp[i][3] = &\left\{\begin{aligned}
\min(dp[i-1][2],dp[i-1][3])&,s_i \in \{1\}\\
dp[i-1][3] + 1&,s_i \in \{7,6\}\\
dp[i-1][3]&,s_i \not \in \{1,6,7\}
\end{aligned}\right.\\
dp[i][4] = &\left\{\begin{aligned}
\min(dp[i-1][3],dp[i-1][4])&,s_i \in \{7\}\\
dp[i-1][4] + 1&,s_i \in \{6\}\\
dp[i-1][4]&,s_i \not \in \{6,7\}
\end{aligned}\right.\\
\end{aligned}
$$

如果我们把一般矩阵的 $(\mathbb Z, \cdot,+)$ 变成 $(\mathbb Z,+,\min)$ ，因为我们的转移只与这个位置的字符有关，那么我们可以写出状态矩阵 $M_i$ ， 使：

$$
M_i\left[\begin{matrix}
    dp[i-1][0]\\
    dp[i-1][1]\\
    dp[i-1][2]\\
    dp[i-1][3]\\
    dp[i-1][4]\\
\end{matrix}\right]
= 
\left[\begin{matrix}
    dp[i][0]\\
    dp[i][1]\\
    dp[i][2]\\
    dp[i][3]\\
    dp[i][4]\\
\end{matrix}\right]
$$


1. $s_i = 2$ 时：
$$
M_i = \left[\begin{matrix}{}
1 & \inf & \inf & \inf & \inf\\ 
0 & 0 & \inf & \inf & \inf\\ 
\inf & \inf & 0 & \inf & \inf\\ 
\inf & \inf & \inf & 0 & \inf\\ 
\inf & \inf & \inf & \inf & 0\\ 
\end{matrix}\right]
$$

2. $s_i = 0$ 时：
$$
M_i = \left[\begin{matrix}{}
0 & \inf & \inf & \inf & \inf\\ 
\inf & 1 & \inf & \inf & \inf\\ 
\inf & 0 & 0 & \inf & \inf\\ 
\inf & \inf & \inf & 0 & \inf\\ 
\inf & \inf & \inf & \inf & 0\\ 
\end{matrix}\right]
$$

3. $s_i = 1$ 时 
$$
M_i = \left[\begin{matrix}{}
0 & \inf & \inf & \inf & \inf\\ 
\inf & 0 & \inf & \inf & \inf\\ 
\inf & \inf & 1 & \inf & \inf\\ 
\inf & \inf & 0 & 0 & \inf\\ 
\inf & \inf & \inf & \inf & 0\\ 
\end{matrix}\right]
$$

4. $s_i = 7$ 时：
$$
M_i = \left[\begin{matrix}{}
0 & \inf & \inf & \inf & \inf\\ 
\inf & 0 & \inf & \inf & \inf\\ 
\inf & \inf & 0 & \inf & \inf\\ 
\inf & \inf & \inf & 1 & \inf\\ 
\inf & \inf & \inf & 0 & 0\\ 
\end{matrix}\right]
$$

5. $s_i = 6$ 时
$$
M_i = \left[\begin{matrix}{}
0 & \inf & \inf & \inf & \inf\\ 
\inf & 0 & \inf & \inf & \inf\\ 
\inf & \inf & 0 & \inf & \inf\\ 
\inf & \inf & \inf & 1 & \inf\\ 
\inf & \inf & \inf & \inf & 1\\ 
\end{matrix}\right]
$$

6. other
$$
M_i = \left[\begin{matrix}{}
0 & \inf & \inf & \inf & \inf\\ 
\inf & 0 & \inf & \inf & \inf\\ 
\inf & \inf & 0 & \inf & \inf\\ 
\inf & \inf & \inf & 0 & \inf\\ 
\inf & \inf & \inf & \inf & 0\\ 
\end{matrix}\right]
$$

初始矩阵：

$$
D= \left[\begin{matrix}
    0\\
    \inf\\
    \inf\\
    \inf\\
    \inf\\
\end{matrix}\right]
$$

- - -

对于询问，我们把矩阵扔到线段树上，因为有结合律（什么你问为什么？我也不知道），每次查询线段树即可，注意合并的时候要右边的矩阵在左，左边的矩阵在右做乘法。

事实上这道题可以支持单点修改的呢（

时间复杂度：$O(5^2 q \log n )$

## 代码

```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 410000,N = 5;

struct Matrix{
  int num[N][N];
  Matrix(int op = 0){
    memset(num,0x3f,sizeof(num));
    if(op == 1) for(int i = 0;i<N;i++){
      num[i][i] = 0;
    }
  }
  int *operator [] (int n){return num[n];}
};

Matrix mul(Matrix &a,Matrix &b){
  Matrix ans;
  for(int i = 0;i<N;i++){
    for(int j = 0;j<N;j++){
      for(int k = 0;k<N;k++){
        ans[i][j] = min(ans[i][j],a[i][k] + b[k][j]);
      }
    }
  }
  return ans;
}
Matrix get(int x){
  Matrix t(1);
  if(x == 2) t[0][0] = 1,t[1][0] = 0;
  if(x == 0) t[1][1] = 1,t[2][1] = 0;
  if(x == 1) t[2][2] = 1,t[3][2] = 0;
  if(x == 7) t[3][3] = 1,t[4][3] = 0;
  if(x == 6) t[4][4] = 1,t[3][3] = 1;
  return t;
}

int n,q;
char s[MAXN];

namespace Seg{
  Matrix sum[MAXN<<2];
  #define lson (nown<<1)
  #define rson (nown<<1|1)
  #define mid ((l+r)>>1)
  void build(int nown,int l,int r,char *s){
    if(l == r) sum[nown] = get(s[l] - '0');
    else{
      build(lson,l,mid,s),build(rson,mid+1,r,s);
      sum[nown] = mul(sum[rson],sum[lson]);
    }
  }
  Matrix query(int nown,int l,int r,int ql,int qr){
    if(ql <= l && r <= qr){
      return sum[nown];
    }
    else{
      Matrix L(1),R(1);
      if(ql <= mid) L = query(lson,l,mid,ql,qr);
      if(qr >= mid+1) R = query(rson,mid+1,r,ql,qr);
      return mul(R,L);
    } 
  }
}
int main(){
  scanf("%d %d",&n,&q);
  scanf("%s",s+1);
  Seg::build(1,1,n,s);
  for(int i = 1;i<=q;i++){
    int l,r;
    scanf("%d %d",&l,&r);
    Matrix ans = Seg::query(1,1,n,l,r);
    printf("%d\n",ans[4][0] > (r-l+1)?-1:ans[4][0]);
  }
  return 0;
}
```