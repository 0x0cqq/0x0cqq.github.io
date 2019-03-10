---
title: 「NOI2007」货币兑换-Splay+斜率优化
urlname: NOI2007-cash
date: 2018-08-28 22:59:54
tags:
- 题解
- Splay
- 平衡树
- 斜率优化
- 动态规划
categories: OI
visible:
---

小 $Y$ 最近在一家金券交易所工作。该金券交易所只发行交易两种金券：$A$ 纪念券（以下简称 $A$ 券）和 $B$ 纪念券（以下简称 $B$ 券）。每个持有金券的顾客都有一个自己的帐户。金券的数目可以是一个实数。每天随着市场的起伏波动，两种金券都有自己当时的价值，即每一单位金券当天可以兑换的人民币数目。我们记录第 $K$ 天中 $A$ 券 和 $B$ 券的价值分别为 $A_K$ 和 $B_K$（元/单位金券）。为了方便顾客，金券交易所提供了一种非常方便的交易方式：比例交易法。比例交易法分为两个方面：

（a）卖出金券：顾客提供一个 $[0,100]$ 内的实数 $OP$ 作为卖出比例，其意义为：将 $OP\%$ 的 $A$ 券和 $OP\%$ 的 $B$ 券以当时的价值兑换为人民币；

（b）买入金券：顾客支付 $IP$ 元人民币，交易所将会兑换给用户总价值为 $IP$ 的金券，并且，满足提供给顾客的 $A$ 券和 $B$ 券的比例在第 $K$ 天恰好为 $Rate_K$ ；

注意到，**同一天内可以进行多次操作**。小 $Y$ 是一个很有经济头脑的员工，通过较长时间的运作和行情测算，他已经知道了未来 $N$ 天内的 $A$ 券和 $B$ 券的价值以及 $Rate$ 。他还希望能够计算出来，如果开始时拥有 $S$ 元钱，那么 $N$ 天后最多能够获得多少元钱。

<!-- more -->

例如，假定接下来 $3$ 天内的 $A_k$、$B_k$、$Rate_K$ 的变化分别为：

![img](https://www.lydsy.com/JudgeOnline/upload/201604/dd(1).png)

假定在第一天时，用户手中有 $100$ 元 人民币但是没有任何金券。用户可以执行以下的操作：

![img](https://www.lydsy.com/JudgeOnline/upload/201604/dd(2).png)

提示：

+ 输入文件可能很大，请采用快速的读入方式。
+ 必然存在一种最优的买卖方案满足：每次买进操作使用完所有的人民币；每次卖出操作卖出所有的金券。

## 链接

[LOJ 2353](https://loj.ac/problem/2353)

[BZOJ 1492](https://www.lydsy.com/JudgeOnline/problem.php?id=1492)

[Luogu P4027](https://www.luogu.org/problemnew/show/P4027)

## 题解

最优策略肯定是只有两种状态：全仓/空仓，然后每天我们只有若干种选择：全买，全卖，全买+全卖，啥都不做。

注意到我们可以 $dp$ ...

先写暴力转移...注意到我们事实上只需要记录我们有多少钱，在哪天买入的话就会有多少的比例。

所以我们令 $dp[i]$ 为在第 $i$ 天拥有的最多钱，假设我们上次全部卖出+全部买入在第 $j$ 天，状态转移：
$$
dp[i] = \max\left(\max_{j=1}^{i-1}(dp[j]\times \frac{r[j]*a[i] + b[i]}{r[j]*a[j]+b[j]}),dp[i-1]\right)
$$
很好理解嘛...就是一个决策在哪天全买/全卖的问题。

暴力转移可以拿到 $60$ 分…上古时代的暴力分还是很好拿的。

---

正解的话，需要我们深入挖掘这个式子。

我们先忽略最后一个不买不卖的情况，来继续看：
$$
dp[i] = \max_{j=1}^{i-1}(dp[j]\times \frac{r[j]\cdot a[i] + b[i]}{r[j] \cdot a[j]+b[j]})
$$
对于给定的决策点 $j$ ，则有：
$$
dp[i] = dp[j] \times \frac{r[j]\cdot a[i] + b[i]}{r[j]\cdot a[j]+b[j]}\\
dp[i] = (r[j]\cdot a[i] + b[i])\times \frac{dp[j]}{r[j]\cdot a[j]+b[j]}\\
dp[i] = b[i]\times \frac{dp[j]}{r[j]\cdot a[j]+b[j]} + a[i] \times \frac{r[j]\cdot dp[j]}{r[j]\cdot a[j]+b[j]}
$$
如果我们令：
$$
x[j] = \frac{r[j]\cdot dp[j]}{r[j]*a[j]+b[j]}, y[j] = \frac{dp[j]}{r[j]\cdot a[j]+b[j]}
$$
那么式子就会变成：
$$
dp[i] = a[i] \times x[j] + b[i] \times y[j]
$$
略微变换：
$$
y[j] = - \frac{a[i]}{b[i]} \cdot x[j] + \frac{dp[i]}{b[i]}
$$


我们注意到，这里面的斜率仅与 $i$ 相关，$x,y$ 均只与 $j$ 相关，最后的截距下面除的是一个常数，那么只要截距最大， $dp[i]$ 就会最大。

而且，只要 $x[j]$ 和 $y[j]$ 一经确定，便不改变。

所以现在问题变成：支持插入点，查询某个给定斜率的直线且经过某个点，使得这条直线的截距最大。

在以往的斜率优化问题里面，我们一般有两个单调性：插入的点的  $x$ 坐标单调，直线的斜率单调。那么我们用单调队列就可以维护凸包，然而这里我们这两个性质全都没有，所以我们只能用更高级的东西，比如 $\text{CDQ}$ 分治，比如 $\text{Splay}$ 。

我用了 $\text{Splay}$ 来维护这个上凸包。

---

具体实现的话，就是需要处理两个问题：找到第一个斜率较给定值大的点，和插入一个点。

1. 在 $\text{Splay}$ 上二分即可。最好是每个点代表这个点到前一个点的斜率。

2. 先判断在不在凸包里，再根据x坐标插入，然后在向两边pop，维护凸包性质。注意pop的条件比较容易写错。

不知道为啥，BZOJ 上过不了。本地下下来数据、传到 luogu 上都可以过。

## 代码



```cpp
#include <cstdio>
#include <algorithm>
#include <ctime>
#include <cmath>
#include <cstring>
#define eps 1e-10
#define inf 1e10
using namespace std;

const int MAXN = 1100000;

int n,s;
double a[MAXN],b[MAXN],r[MAXN];
double dp[MAXN];
int last[MAXN];

double calx(int j){if(j == 0) return inf;return dp[j]*r[j] / (r[j]*a[j] + b[j]);}
double caly(int j){return dp[j] / (r[j]*a[j]+b[j]);}
double calc(int i,int j){return calx(j) * a[i] + caly(j) * b[i]; }

double cals(int i,int j){
    if(j == 0) return -inf;
    if(i == 0) return inf;
    double _x = calx(i)-calx(j);
    double _y = caly(i)-caly(j);
    //if(fabs(_x) < eps) return _y>0?inf:-inf;
    return _y/_x;
}

namespace Splay{
  int p[MAXN<<2];double v[MAXN<<2];
  int f[MAXN<<2],c[MAXN<<2][2],cnt;
  int root;//v 向左连 
  int newnode(int point,double val = 0){
    int x = ++cnt;
    v[x] = val,p[x] = point;
    c[x][0] = c[x][1] = 0;
    return x;
  } 
  void rotate(int x){
    if(!x) return;
    int y = f[x],z = f[y],t = c[y][1] == x,w = c[x][1-t];
    if(z) c[z][c[z][1]==y] = x;
    c[y][t] = w,c[x][1-t] = y;
    if(w) f[w] = y;
    f[x] = z;f[y] = x;
    if(!f[x]) root = x; 
  }
  void splay(int x,int tar = 0){
    while(f[x]!=tar){
      int y = f[x],z = f[y];
      if(f[y] != tar){
        (c[y][1]==x)^(c[z][1]==y)?rotate(x):rotate(y);
      }rotate(x);
    }
  }
  int find(int x,double _v){
    if(!x) return 0;
    if(_v > v[x])
      return find(c[x][0],_v);
    else{
      int j = find(c[x][1],_v);
      return j!=0?j:x;
    }
  }
  int nxt(int x,int tmp){
    if(!x) return 0; splay(x);
    int r = c[x][tmp]; if(!r) return 0;
    while(1){
      if(c[r][1-tmp]) r = c[r][1-tmp];
      else return r;
    }
  }
  int insert(int x,int fa,int point){
    if(!x){
      int w = newnode(point);
      if(fa == 0) root = w;
      c[fa][calx(point) > calx(p[fa])] = w,f[w] = fa;
      int _x = nxt(w,0),_y = nxt(w,1);
      v[w] = cals(p[_x],p[w]);
      if(_y) v[_y] = cals(p[w],p[_y]);
      return w;
    }
    int tmp = calx(point) > calx(p[x]);
    return insert(c[x][tmp],x,point);
  }
  void erase(int x){
    int _x = nxt(x,0),_y = nxt(x,1);
    if(!_x && !_y) root = 0;
    else if(!_x || !_y){
      int t = _x == 0?_y:_x,tmp = _x==0?0:1;
      splay(t),c[t][tmp] = 0;
    }
    else{
      splay(_x),splay(_y,_x);
      c[_y][0] = 0;
    }
    if(_y) v[_y] = cals(p[_x],p[_y]);
  }
  void update(int i){
    int w = insert(root,0,i);
    int x,y;
    x = nxt(w,0),y = nxt(w,1);
    if(y && cals(p[x],p[y]) < v[y]){
      erase(w);return;
    }
    x = nxt(w,1),y = nxt(x,1);
    while(y!=0){
      if(cals(i,p[x]) > cals(i,p[y])) break;
      erase(x);
      x = y;
      y = nxt(x,1);
    }
    x = nxt(w,0),y = nxt(x,0);
    while(y!=0){
      if(cals(p[y],i) > cals(p[x],i)) break;
      erase(x);
      x = y;
      y = nxt(x,0);
    }    
  }
  int query(int i){
    return find(root,-a[i]/b[i]);
  }
};


int main(){
  scanf("%d %d",&n,&s);
  for(int i = 1;i<=n;i++)
    scanf("%lf %lf %lf",&a[i],&b[i],&r[i]);
    
  dp[1] = s;
  Splay::update(1);
    for(int i = 2;i<=n;i++){
    dp[i] = dp[i-1],last[i] = i;
    int j = Splay::query(i);
    if(calc(i,j) > dp[i])
      last[i] = j,dp[i] = calc(i,j);
    Splay::update(i);
  }
  printf("%.6lf\n",dp[n]);
  return 0;
}
```





 
