---
title: 「SHOI2014」概率充电器-树形dp
urlname: SHOI2014-charger
date: 2018-10-18 19:50:03
tags:
- 树形dp
- 期望
- 树形结构
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

著名的电子产品品牌 SHOI 刚刚发布了引领世界潮流的下一代电子产品—— 概率充电器：

“采用全新纳米级加工技术，实现元件与导线能否通电完全由真随机数决定！SHOI 概率充电器，您生活不可或缺的必需品！能充上电吗？现在就试试看吧！”

SHOI 概率充电器由 $n-1$ 条导线连通了 $n$ 个充电元件。进行充电时，每条导 线是否可以导电以概率决定，每一个充电元件自身是否直接进行充电也由概率 决定。随后电能可以从直接充电的元件经过通电的导线使得其他充电元件进行间接充电。

作为 SHOI 公司的忠实客户，你无法抑制自己购买 SHOI 产品的冲动。在排 了一个星期的长队之后终于入手了最新型号的 SHOI 概率充电器。你迫不及待地将 SHOI 概率充电器插入电源——这时你突然想知道，进入充电状态的元件个数的期望是多少呢？

<!--more-->


## 链接

[Luogu P4284](https://www.luogu.org/problemnew/show/P4284)

## 题解

我们注意到这道题可以用树形dp的方法来解决。

设 $f[x]$ 表示 $x$ 节点由不被其子节点（含本身）点亮的概率，那么我们有如下转移：

对于每个子节点， $f[x]$ 分为这几部分：子节点不被点亮 或 该节点的边 不被点亮，用公式表示即为：

我们令 $s(i,j) = i+j-i \times j$， 令 $w[x] =  s(f[v],1-q_{(fa[x],x)})$，那么：

$$
f[x] = (1-p[x]) \prod_{\text{v is x's son}} w[v] 
$$

我们定义该节点不被其父节点点亮的概率为 $g[x]$。 $g[x]$ 即为 父节点不被其父节点点亮 且 父节点不被其他子节点（含本身）点亮 或 导线不通，可以得到 $g[x]$ 表达式为：

$$
g[x] = s(q_{(fa[x],x)} , g[fa[x]] \times \frac{f[x]}{w[x]} )
$$
（此处若 $w[x] = 0$，则直接令 $g[x] = 0$ 即可）

答案即为 

$$
ans[x] = 1 - f[x] \times g[x]
$$

树形 $dp$ 即可。

## 代码



```cpp
#include <cstdio>
using namespace std;

const int MAXN= 510000;

struct Edge{
  int to,nex;
  double q;
}edge[MAXN*2];int ecnt = 2;
int fir[MAXN];
void addedge(int a,int b,double q){
  edge[ecnt] = (Edge){b,fir[a],q};
  fir[a] = ecnt++;
}

int n;
double p[MAXN];
double f[MAXN],g[MAXN],w[MAXN];
double s(double i,double j){
  return i+j-i*j;
}

void dfs1(int x,int fa){
  f[x] = 1;
  for(int nowe = fir[x];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;double q = edge[nowe].q;
    if(v == fa) continue;
    dfs1(v,x);
    w[v] = s(f[v],1-q);
    f[x] *= w[v];
  }
  f[x] *= (1-p[x]);
}

void dfs2(int x,int fa){
  for(int nowe = fir[x];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;double q = edge[nowe].q;
    if(v == fa) continue;
    if(w[v] != 0){
      g[v] = s(1-q,g[x] * f[x] / w[v]);
    }
    dfs2(v,x);
  }
}

void solve(){
  g[1] = 1;
  dfs1(1,0),dfs2(1,0);
  double ans = 0;
  for(int i = 1;i<=n;i++){
    //printf("f:%lf g:%lf\n",f[i],g[i]);
    ans += 1-f[i]*g[i];
  }
  printf("%.6lf\n",ans);
}

void init(){
  scanf("%d",&n);
  for(int i = 2;i<=n;i++){
    int a,b,p;
    scanf("%d %d %d",&a,&b,&p);
    addedge(a,b,double(p)/100);
    addedge(b,a,double(p)/100);
  }   
  for(int i = 1;i<=n;i++){
    scanf("%lf",&p[i]);
    p[i]/=100;
  }
}

int main(){
  init();
  solve();
  return 0;
}
```

