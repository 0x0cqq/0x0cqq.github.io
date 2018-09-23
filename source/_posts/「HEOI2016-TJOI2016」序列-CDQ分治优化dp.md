---
title: 「HEOI2016/TJOI2016」序列-CDQ分治优化dp
urlname: HEOI2016-TJOI2016-sequence
date: 2018-09-20 20:09:29
tags:
- 题解
- CDQ分治
- 动态规划
categories: OI
visible:
---


佳媛姐姐过生日的时候，她的小伙伴从某宝上买了一个有趣的玩具送给他。玩具上有一个数列，数列中某些项的值可能会变化，但同一个时刻最多只有一个值发生变化。

现在佳媛姐姐已经研究出了所有变化的可能性，她想请教你，能否选出一个子序列，使得在任意一种变化中，这个子序列都是不降的？请你告诉她这个子序列的最长长度即可 。

注意：每种变化最多只有一个值发生变化。

<!-- more -->

## 链接

[Luogu P4093](https://www.luogu.org/problemnew/show/P4093)

## 题解

我们可以发现，如果 $x$ 位置的变化能够影响到经过它的最长不降子序列，那么需要关心的只有两个值：该点可能变化到的最小值 $\min_x$ 与可能变化到的最大值 $\max_x$ 。所以我们只需要存储每个位置的 $\min_x$ 和 $\max_x$ 即可。

然后我们发现这个东西可以用 $O(n^2)$ 的朴素 $dp$ 来完成对 $\text{LIS}$ 的计算。

方程为（其中 $a_0 = max_0 = min_0 = - \inf$）：

$$
dp[i] = 
\left\{
\begin{aligned}{}
&0&,\;&\text{if } i = 0\\
&\max_{j=0}^{i-1}{(dp[j] + 1)}&,\;& \text{if } \text{max}_j \leq a_i \text{ and } a_j \leq \text{min}_i
\end{aligned}
\right.
$$

发现 $\text{max}_j \leq a_i$ 且 $a_j \leq \text{min}_i$ 事实上是一个二维的偏序关系，所以我们可以用 $\text{CDQ}$ 分治计算满足该条件的 $dp$ 最大值。

但是这里有一个与普通 $\text{CDQ}$ 不相同的地方，我们必须要计算完在 $i$ 前面的 $dp$ 值，才能开始计算 $dp[i]$。

所以这里的 $\text{CDQ}$ 分治应当做一些微小的更改。

我们不用归并完成对 $2d$  的排序，而是直接调用 $sort$ 。

对于区间 $[l,r]$ ，我们先递归完成 $[l,mid]$ ，排序第二关键字后处理左半对右半的贡献，然后重新按照第一关键字排序后再递归解决 $[mid+1,r]$ 子问题。

最近 $\text{CDQ}$ 老写错字母emmm 大约没救了...

时间复杂度 $O(n \log ^2 n)$ 。

## 代码

{% fold %}
```cpp
// luogu-judger-enable-o2
#include <cstdio>
#include <algorithm>
#include <cstdio>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 210000;

struct T{
  int id,op,a,b;
  T(){id=op=a=b=0;}
  T(int _id,int _op,int _a,int _b){
    id = _id,op = _op,a = _a,b = _b;
  }
  // op = 1 -> (max_j,a_j) 修改
  // op = 2 -> (a_i,min_i) 查询
}q[MAXN];int tot;

struct BIT{
  int maxn[MAXN];
  int lowbit(int x){
    return x & (-x);
  }
  void update(int x,int v){
    while(x <= 100000){
      maxn[x] = max(maxn[x],v);
      x += lowbit(x);
    }
  }
  int query(int x){
    int ans = 0;
    while(x >= 1){
      ans = max(ans,maxn[x]);
      x -= lowbit(x);
    }
    return ans;
  }
  void clear(int x){
    while(x <= 100000){
      if(maxn[x] == 0) break;
      maxn[x] = 0;
      x += lowbit(x);
    }
  }
}S;

int n,m;
int dp[MAXN];
int num[MAXN],maxn[MAXN],minn[MAXN];

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    scanf("%d",&num[i]);
    maxn[i] = minn[i] = num[i];
  }
  for(int i = 1;i<=m;i++){
    int x,v;
    scanf("%d %d",&x,&v);
    minn[x] = min(minn[x],v);
    maxn[x] = max(maxn[x],v);
  }
  q[++tot] = T(0,1,-inf,1);
  for(int i = 1;i<=n;i++){
    q[++tot] = T(i,2,num[i],minn[i]);
    q[++tot] = T(i,1,maxn[i],num[i]);
  }
}

bool cmp1d(int x,int y){
  if(q[x].a != q[y].a){
    return q[x].a < q[y].a;
  }
  else{
    return q[x].id < q[y].id;
  }
}

bool cmpid(int x,int y){
  if(q[x].id != q[y].id){
    return q[x].id < q[y].id;
  }
  else{
    return q[x].op > q[y].op;
  }
}

int cdq[MAXN];
int tmp1d[MAXN];
void CDQ(int *w,int l,int r){
  #define ql q[w[L]]
  #define qr q[w[R]]
  if(l == r) return;
  int mid = (l+r)>>1;
  CDQ(w,l,mid);
  sort(w+l,w+mid+1,cmp1d),sort(w+mid+1,w+r+1,cmp1d);
  int L = l,R = mid+1,c = l;
  while(c <= r){
    if(R > r ||(L <= mid && ql.a <= qr.a)){
      if(ql.op == 1)
        S.update(ql.b,dp[ql.id]);
      tmp1d[c++] = L++;
    }
    else{
      if(qr.op == 2){
        //printf("%d qr.id:%d\n",w[R],qr.id);
        int t = S.query(qr.b);
        dp[qr.id] = max(dp[qr.id],t+1);
      }
      tmp1d[c++] = R++;
    }
  }
  for(int i = l;i<=mid;i++) S.clear(q[w[i]].b);
  sort(w+l,w+r+1,cmpid);
  CDQ(w,mid+1,r);
  #undef ql
  #undef qr
}

void solve(){
  for(int i = 1;i<=tot;i++) cdq[i] = i;
  CDQ(cdq,1,tot);
  int ans = 0;
  for(int i = 1;i<=n;i++){
    ans = max(ans,dp[i]);
  }
  printf("%d\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```
{% endfold %}