---
title: 「HNOI2011」XOR和路径-高斯消元
urlname: HNOI2011-XOR
date: 2018-10-02 09:39:42
tags:
- 期望
- 高斯消元
categories: 
- OI
- 题解
visible:
---

给定一个无向连通图，其节点编号为 $1$ 到 $N$，其边的权值为非负整数。试求出一条从 $1$ 号节点到 $N$ 号节点的路径，使得该路径上经过的边的权值的 “ $\text{XOR}$ 和” 最大。该路径可以重复经过某些节点或边，当一条边在路径中出现多次时，其权值在计算 “$\text{XOR}$ 和” 时也要被重复计算相应多的次数。

直接求解上述问题比较困难，于是你决定使用非完美算法。具体来说，从 $1$ 号节点开始，以相等的概率，随机选择与当前节点相关联的某条边，并沿这条边走到下一个节点，重复这个过程，直到走到 $N$ 号节点为止，便得到一条从 $1$ 号节点到 $N$ 号节点的路径。显然得到每条这样的路径的概率是不同的，并且每条这样的路径的 “ $\text{XOR}$ 和” 也不一样。现在请你求出该算法得到的路径的 “ $\text{XOR}$ 和” 的期望值。
<!-- more -->

## 链接
[Luogu P3211](https://www.luogu.org/problemnew/show/P3211)

## 题解

注意到每位独立，所以我们可以考虑分别考虑每位再进行相加。

具体来说，如果我们用 $P[i]$ 表示在 $i$ 号节点时，到达 $N$ 号节点时该位为 $1$ 的概率，那么我们有如下转移：

$$
P[i] = 
\left\{
\begin{aligned}{}
&\sum_{\text{i,j have a edge}} \frac{P[j]}{d[i]}&,i \neq N\\
&1&,i = N
\end{aligned}
\right.
$$ 

其中 $d[i]$ 为 $i$ 节点度数。

高斯消元即可。

## 代码


```cpp
#include <cstdio>
#include <cmath>
#include <cstring>
#include <algorithm>
using namespace std;

const double eps = 1e-7;
const int MAXN = 110,MAXM = 11000;

struct Edge{
  int to,len;
  int nex;
}edge[MAXM*2];int ecnt = 2;
int fir[MAXN];

void addedge(int u,int v,int c){
  edge[ecnt] = (Edge){v,c,fir[u]};
  fir[u] = ecnt++;
}

int n,m;
double de[MAXN];

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=m;i++){
    int u,v,c;
    scanf("%d %d %d",&u,&v,&c);
    addedge(u,v,c);de[u]++;
    if(u!=v){
      addedge(v,u,c);de[v]++;
    }
  }
}

bool gauss(double a[MAXN][MAXN],int n){
  for(int i = 1;i<=n;i++){
    int r = i;
    for(int j = i+1;j<=n;j++){
      if(fabs(a[j][i]) > fabs(a[r][i])) 
        r = j;
    }
    if(r != i){
      for(int j = 1;j<=n+1;j++)
        swap(a[i][j],a[r][j]);
    }
    if(fabs(a[i][i]) < eps) return 0;
    for(int j = 1;j<=n;j++)if(j!=i){
      double t = a[j][i]/a[i][i];
      for(int k = 1;k<=n+1;k++){
        a[j][k] -= a[i][k] * t;
      }
    }
  }
  for(int i = 1;i<=n;i++)
    a[i][n+1]/=a[i][i],a[i][i] = 1;
  return 1;
}

double ju[MAXN][MAXN];
int num[MAXN];


void solve(){
  double ans = 0;
  for(int i = 0;i<30;i++){
    // printf("i:%d\n",i);
    memset(ju,0,sizeof(ju));
    for(int nown = 1;nown<=n;nown++){
      int cnt = 0;
      ju[nown][nown] = 1;
      for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to,l = edge[nowe].len;
        if((l & (1<<i)) == 0)
          ju[nown][v] += -1/de[nown];
        else
          ju[nown][v] += 1/de[nown],cnt++;
      }
      ju[nown][n+1] = cnt/de[nown];
    }
    for(int i = 1;i<=n;i++) ju[n][i] = 0;
    ju[n][n] = 1,ju[n][n+1] = 0;
    gauss(ju,n);
    ans += ju[1][n+1] * pow(2,i);
    // printf("--------------------\n");
  }
  printf("%.3lf\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```

