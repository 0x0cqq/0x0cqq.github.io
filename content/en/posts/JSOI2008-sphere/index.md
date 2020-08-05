---
title: 「JSOI2008」球形空间产生器-高斯消元
urlname: JSOI2008-sphere
date: 2018-11-25 14:57:55
tags:
- 数学
- 高斯消元 
categories: 
- OI
- 题解
series:
- 各省省选
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

有一个球形空间产生器能够在 $n$ 维空间中产生一个坚硬的球体。现在，你被困在了这个 $n$ 维球体中，你只知道球面上 $n+1$ 个点的坐标，你需要以最快的速度确定这个 $n$ 维球体的球心坐标，以便于摧毁这个球形空间产生器。

提示：给出两个定义：

1.  球心：到球面上任意一点距离都相等的点。
2.  距离：设两个n为空间上的点A, B的坐标为$(a_1, a_2, \cdots , a_n)$ , $(b_1, b_2, \cdots , b_n)$，则 AB 的距离定义为：$dist = \sqrt{ \sum_{i=1}^{n}(a_i - b_i)^2 }$

<!--more-->

## 链接 

[Luogu P4035](https://www.luogu.org/problemnew/show/P4035)

## 题解

设圆心为 $(x_1,x_2, \cdots ,x_n)$ 。

则我们有 $n$ 个式子，形如

$$
\sum_{i=1}^{n}(p[j][i] - x_i)^2 = \sum_{i=1}^{n}(p[j+1][i] - x_i)^2
$$

化简得到

$$
\sum_{i=1}^{n}(p[j][i]^2 - 2p[j][i] \cdot x_i) = \sum_{i=1}^{n}(p[j+1][i]^2 - 2p[j+1][i] \cdot x_i)\\
 \sum_{i=1}^{n} [2(p[j+1][i]-p[j][i]) \cdot x_i] = - \sum_{i=1}^{n}(p[j][i]^2 - p[j+1][i]^2)
$$

高斯消元即可...

## 代码


```cpp
#include <cstdio>
#include <cmath>
#include <cstdlib>
#include <algorithm>
using namespace std;
const double eps = 1e-8;
double squ(double x){return x * x;}

const int MAXN = 410;

int n;
double p[MAXN][MAXN];

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n+1;i++){
    for(int j = 1;j<=n;j++){
      scanf("%lf",&p[i][j]);
    }
  }
}


bool gauss(int n,double a[MAXN][MAXN]){
  for(int i = 1;i<=n;i++){
    int r = i;
    for(int j = i+1;j<=n;j++){
      if(fabs(a[j][i]) > fabs(a[r][i])) r = j;
    }
    if(fabs(a[r][i]) <= eps) return false;
    if(r != i){
      for(int j = 1;j<=n+1;j++)
        swap(a[i][j],a[r][j]);
    }
    for(int j = 1;j<=n;j++)if(j!=i){
      double d = a[j][i]/a[i][i];
      for(int k = 1;k<=n+1;k++){
        a[j][k] -= d * a[i][k];
      }
    }
  }
  for(int i = 1;i<=n;i++){
    a[i][n+1] /= a[i][i];
    a[i][i] = 1;
  }
  return true;
}

void solve(){
  static double a[MAXN][MAXN];
  for(int j = 1;j<=n;j++){
    for(int i = 1;i<=n;i++){
      a[j][i] = 2 * (p[j+1][i] - p[j][i]);
      a[j][n+1] -= squ(p[j][i]) - squ(p[j+1][i]);
    }
  }
  gauss(n,a);
  for(int i = 1;i<=n;i++){
    printf("%.3lf ",a[i][n+1]);
  }
  printf("\n");
}

int main(){
  init();
  solve();
  return 0;
}
```

