---
title: 「SDOI2011」拦截导弹-CDQ分治优化dp
urlname: SDOI2011-missile
date: 2018-09-20 20:08:40
tags:
- CDQ分治
- 树状数组
- 动态规划
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


某国为了防御敌国的导弹袭击，发展出一种导弹拦截系统。但是这种导弹拦截系统有一个缺陷：虽然它的第一发炮弹能够到达任意的高度、并且能够拦截任意速度的导弹，但是以后每一发炮弹都不能高于前一发的高度，其拦截的导弹的飞行速度也不能大于前一发。某天，雷达捕捉到敌国的导弹来袭。由于该系统还在试用阶段，所以只有一套系统，因此有可能不能拦截所有的导弹。

在不能拦截所有的导弹的情况下，我们当然要选择使国家损失最小、也就是拦截导弹的数量最多的方案。但是拦截导弹数量的最多的方案有可能有多个，如果有多个最优方案，那么我们会随机选取一个作为最终的拦截导弹行动蓝图。

我方间谍已经获取了所有敌军导弹的高度和速度，你的任务是计算出在执行上述决策时，每枚导弹被拦截掉的概率。

<!--more-->

## 链接

[Luogu P2487](https://www.luogu.org/problemnew/show/P2487)

## 题解

​ $\text{CDQ}$ 分治优化 $dp$​ 。

这是一个三维偏序问题。

如果我们令 $a_i$ 为第 $i$ 个导弹的高度， $b_i$ 为第 $i$ 个导弹的速度，$dp[i]$ 为以第 $i$ 个结尾的导弹能拦截的最大数量， $sum[i]$ 为以第 $i$ 个导弹为结尾能够拦截最大导弹数的方案数，那么我们有如下的转移：


$$
dp[i] = 
\left\{
\begin{aligned}{}
&0&,\;&\text{if } i = 0\\
&\max _ {j=0}^{i-1}{(dp[j] + 1)}&,\;& \text{if } a_j \geq a_i \text{ and } b_j \geq b_i
\end{aligned}
\right.
$$

$$
sum[i] = 
\left\{
\begin{aligned}{}
&1&,\;&\text{if } i = 0\\
&\sum _ {j=0}^{i-1}{sum[j]}&,\;&  \text{if } a_j \geq a_i \text{ and } b_j \geq b_i \text{ and }dp[j] = dp[i]-1
\end{aligned}
\right.
$$

我们设 $M = \max _ {i=1}^n dp[i]$，那么我们可以计算出所有的长度为最长值的序列的个数，就是：

$$
tot = \sum _ {i=1}^{n} [dp[i] = M] \times sum[i]
$$

然后我们只要计算出每个点经过的路径条数就可以了。

对于 $sum[i]$ ，其实我们可以在 $\text{CDQ}$ 分治的途中一并计算。

注意到，每个位置上我事实上都维护了一个最大值，它标记着从 $（i-\text{lowbit}(i),i]$ 的最大值，我们在同样的位置维护一个 $sum$ 即可。

- - -

我们把数字取反，数组翻转，再做一遍 $\text{CDQ}$ 分治，然后得到的两个对应位置上，如果有 $dp1[i] + dp2[i] - 1 = M$ ，那么我们的 $path[i] = sum1[i] \times sum2[i]$ ，否则就是 $0$。

注意这题要离散化。

- - -
这道题得到的启示：

我们有的时候计算经过某点的路径可以按照该点分别计算两个路径然后乘法原理。

## 代码


```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
#include <map>
using namespace std;

const int MAXN = 100000;

struct T{
  int a,b;
}q[MAXN];
int cnt = 0;
int n;

struct BIT{
  int maxn[MAXN];double sumn[MAXN];
  int lowbit(int x){
    return x & (-x);
  }
  void update(int x,int mx,double g){
    while(x <= n){
      if(maxn[x] == mx) sumn[x] += g;
      else if(mx > maxn[x]) sumn[x] = g;
      maxn[x] = max(maxn[x],mx);
      x += lowbit(x);
    }
  }
  void query(int x,int &mx,double &s){
    mx = s = 0;
    while(x >= 1){
      if(maxn[x] == mx) s += sumn[x];
      else if(maxn[x] > mx) s = sumn[x];
      mx = max(mx,maxn[x]);
      x -= lowbit(x);
    }
  }
  void clear(int x){
    while(x <= n){
      maxn[x] = 0,sumn[x] = 0;
      x += lowbit(x);
    }    
  }
}T;

int nowa[MAXN],nowb[MAXN];

map<int,int> A,B;

void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n;i++){
    scanf("%d %d",&q[i].a,&q[i].b);
    A[q[i].a] = 0;
    B[q[i].b] = 0;
  }
  for(map<int,int>::iterator it = A.begin();it!=A.end();it++)
    it->second = ++cnt;
  cnt = 0;
  for(map<int,int>::iterator it = B.begin();it!=B.end();it++)
    it->second = ++cnt;
  for(int i = 1;i<=n;i++){
    q[i].a = n-A[q[i].a]+1;
    q[i].b = n-B[q[i].b]+1;
  }
}

bool cmpa(int x,int y){return nowa[x] < nowa[y];}
bool cmpid(int x,int y){return x < y;}

int cdq[MAXN];
int tmp1d[MAXN];
int dp[MAXN];double sum[MAXN];
int dp1[MAXN],dp2[MAXN],mx;
double ans1[MAXN],ans2[MAXN],tot;

void CDQ1d(int *w,int l,int r){
  if(l == r) return;
  int mid = (l+r)>>1;
  CDQ1d(w,l,mid);
  sort(w+l,w+mid+1,cmpa),sort(w+mid+1,w+r+1,cmpa);

  int L = l,R = mid+1,c = l;
  while(c <= r){
    if(R > r || (L <= mid && nowa[w[L]] <= nowa[w[R]])){
      T.update(nowb[w[L]],dp[w[L]],sum[w[L]]);
      c++;L++;
    }
    else{
      int mx = 0;double g = 0;
      T.query(nowb[w[R]],mx,g);
      mx++;
      if(mx == dp[w[R]]) sum[w[R]] += g;
      else if(mx > dp[w[R]]) sum[w[R]] = g;
      dp[w[R]] = max(mx,dp[w[R]]);
      sum[w[R]] = max(1.0,sum[w[R]]);
      c++;R++;
    }
  }
  for(int i = l;i<=mid;i++) T.clear(nowb[w[i]]);
  sort(w+l,w+r+1,cmpid);
  CDQ1d(w,mid+1,r);
}

void solve(){
  memset(dp,0,sizeof(dp)),memset(sum,0,sizeof(sum));
  dp[1] = 1,sum[1] = 1;
  for(int i = 1;i<=n;i++) cdq[i] = i,nowa[i] = q[i].a,nowb[i] = q[i].b;
  
  CDQ1d(cdq,1,n);

  for(int i = 1;i<=n;i++) mx = max(mx,dp[i]);
  for(int i = 1;i<=n;i++){
    if(dp[i] == mx) tot += sum[i];
    dp1[i] = dp[i];
    ans1[i] = sum[i]; 
  }
  
  memset(dp,0,sizeof(dp)),memset(sum,0,sizeof(sum));
  dp[1] = 1,sum[1] = 1;
  for(int i = 1;i<=n;i++) cdq[i] = i,nowa[i] = n - q[n-i+1].a + 1,nowb[i] = n - q[n-i+1].b + 1;
  CDQ1d(cdq,1,n);
  for(int i = 1;i<=n;i++){
    dp2[i] = dp[n-i+1];
    ans2[i] = sum[n-i+1]; 
  }
  printf("%d\n",mx);
  for(int i = 1;i<=n;i++){
    if(dp1[i] + dp2[i] - 1 == mx)
      printf("%.10lf ",double(ans1[i]) * ans2[i] / tot);
    else
      printf("%.10lf ",0.0);
  }
  printf("\n");
}

int main(){
  init();
  solve();
  return 0;
}
```

