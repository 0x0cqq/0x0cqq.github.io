---
title: 「BOI2007」Mokia-CDQ分治套CDQ分治
urlname: BOI2007-Mokia
date: 2018-09-17 21:55:21
tags:
- 题解
- CDQ分治
- 数据结构
categories: OI
visible:
---


在定位系统中，世界被认为是一个 $W \times W$ 的正方形区域，由 $1 \times 1$ 的方格组成。每个方格都有一个坐标 $(x,y)$ ， $1 \leq x,y \leq W$。

有三种命令，意义如下：
- `0 W` 初始化一个全零矩阵。本命令仅开始时出现一次。
- `1 x y A` 向方格(x,y)中添加A个用户。A是正整数。
- `2 X1 Y1 X2 Y2` 查询 $X1 \leq x \leq X_2$ ， $Y_1 \leq y \leq Y_2$ 所规定的矩形中的用户数量
- `3` 无参数 结束程序。本命令仅结束时出现一次。

<!-- more -->
## 链接

[Luogu P4390](https://www.luogu.org/problemnew/show/P4390)

## 题解

二维动态数点问题。

有很多种解法，树套树，$\text{CDQ}$ 分治 + 树状数组，$\text{CDQ}$ 分治套 $\text{CDQ}$ 分治。

这里选择了最后一种方法，练习一下 $\text{CDQ}$ 分治。

首先要明确，第 $x$ 个维度的  $\text{CDQ}$ 分治解决的是所有在前 $x-1$ 次分治中划分的（左/右）都相同的询问中，左->右的贡献。

在这里叙述一下 $\text{CDQ}$ 套 $\text{CDQ}$ 解决三维偏序问题（也可以推广到更高维的一个过程）：

以三维偏序为例子，我们的三元组令其为 $(a,b,c)$ 。

预处理（相当于消掉一个维度）：

1. 对第一维 $a$ 进行排序

对第一维分治 `CDQ1d(L,R)`：

2. 对第一维 $a$ 进行分治，递归处理 `CDQ1d(L,mid)` 和 `CDQ1d(mid,R)` 
3. 按第二维 $b$ 进行归并，此时不计算答案，只记录在**这次**分治中，该询问/修改属于左半区间 $\text{LEFT}$ 或者 右半区间 $\text{RIGHT}$ 。
4. 复制一份归并后的该区间 $[l,r]$ 的询问数组，用其进行**第二维的分治**。

对第二维分治 `CDQ2d(L,R)`：

5. 对**第二维** $b$ 进行分治，递归处理 `CDQ2d(L,mid)` 和 `CDQ2d(mid,R)` 
6. 按**第三维** $c$ 进行归并，此时**需要**计算答案，记录一个临时变量 $\text{tmp}$ （树状数组）。如果归并左侧新加入的查询/修改在**之前维度的分治中均属于左半区间** $\text{LEFT}$ ，则给 $\text{tmp}$ （树状数组）做对应的修改； 如果归并右侧新加入的查询/修改在**之前维度的分治中均属于右半区间** $\text{RIGHT}$ ，则计算相关贡献。

可以发现，这个递归是可以再次嵌套的，只有最外面一维是需要计算贡献的，前面只要记录每一维的 $\text{LEFT}$ 或 $\text{RIGHT}$，在最后计算即可。

事实上，我们在最后一层递归需要计算的只有 $(\text{LEFT},...,\text{LEFT},x_1)$ 对 $(\text{RIGHT},..,\text{RIGHT},x_2)$ 的贡献。

为什么这样就可以计算完全呢？

我们考虑到，如果在前 $x-1$ 个维度其有任意一个维度被划分到了一个区间，那么他们就会共同进入一次分治，那么这两个询问/查询之间的影响就会在子问题里面被解决，所以我们这样做的正确性是可以保证的。

## 代码


```cpp
#include <cstdio>
using namespace std;

const int MAXN = 300000;

int n,qaq;

struct T{
  int id,op,a,b,add,ans,part;
  //add = 1/-1
  T(){
    id = op = a = b = add = ans = part = 0;
  }
  T(int _id,int _op,int _a,int _b,int _add,int _ans = 0,int _p = 0){
    id = _id,op = _op,a = _a,b = _b,add = _add,ans = _ans,part = _p;
  }
}t[MAXN];int tot;

int ans[MAXN],vis[MAXN];
int cdq[MAXN],tmp1d[MAXN],tmp2d[MAXN];

const int LEFT = 0,RIGHT = 1;

void CDQ2d(int *w,int l,int r){//对第二维(a) 分治，对第三维 (b) 合并
  // 这里给出序列 w 的时候应该其第一维坐标 (a) 已经有序
  if(l == r) return;
  int mid = (l+r)>>1;
  CDQ2d(w,l,mid),CDQ2d(w,mid+1,r);//递归解决子问题
  int L = l,R = mid+1,c = l;//现在左边第二维全部小于右边
  int tmp = 0;
  // 跨越维度的分治只需要考虑 (L,b1) 对 (R,b2) 的影响，剩余的在1d的分治里面已经解决
  // 更高维度的分治同理，只需要考虑 (L,...,L,b1) 对 (R,...,R,b2) 的影响；
  // 第一维相同的在 1d 里面解决，第二维相同的在 2d 里面解决
  while(c <= r){// 对第三维度进行归并排序
    if(R > r || (L<=mid && t[w[L]].b <= t[w[R]].b)){
      if(t[w[L]].part == LEFT && t[w[L]].op == 1) tmp += t[w[L]].add;
      tmp2d[c++] = w[L++];
    }
    else{
      if(t[w[R]].part == RIGHT && t[w[R]].op == 2) t[w[R]].ans += tmp;
      tmp2d[c++] = w[R++];
    }
  }
  for(int i = l;i<=r;i++) w[i] = tmp2d[i];
}

void CDQ1d(int *w,int l,int r){//对第一维（隐去）分治，对第二维合并
  if(l == r) return;
  int mid = (l+r)>>1;
  CDQ1d(w,l,mid),CDQ1d(w,mid+1,r);// 递归解决子问题
  int L = l,R = mid+1,c = l;
  while(c <= r){
    if(R > r || (L <= mid && t[w[L]].a <= t[w[R]].a))// 对第二维进行归并
      t[w[L]].part = LEFT,tmp1d[c++] = w[L++];
    else
      t[w[R]].part = RIGHT,tmp1d[c++] = w[R++];
  }
  for(int i = l;i<=r;i++) w[i] = tmp1d[i];// tmp1d相当于复制的一份
  CDQ2d(tmp1d,l,r);
}

void init(){
  scanf("%d %d",&qaq,&n);
  for(int i = 1;;i++){
    int op,x,y,x1,y1,v;
    scanf("%d",&op);
    if(op == 3){break;}
    if(op == 1){
      scanf("%d %d %d",&x,&y,&v);
      t[++tot] = T(i,1,x,y,v);
    }
    else if(op == 2){
      vis[i] = 1;
      scanf("%d %d %d %d",&x,&y,&x1,&y1);
      t[++tot] = T(i,2,x-1,y-1,1);
      t[++tot] = T(i,2,x-1,y1,-1);
      t[++tot] = T(i,2,x1,y-1,-1);
      t[++tot] = T(i,2,x1,y1,1);
    }
    else{return;}
  }
}

void solve(){
  for(int i = 1;i<=tot;i++){
    cdq[i] = i;
  }
  CDQ1d(cdq,1,tot);
  for(int i = 1;i<=tot;i++){
    if(vis[t[i].id])
      ans[t[i].id] += t[i].add * t[i].ans;
  }
  for(int i = 1;i<=tot;i++){
    if(vis[i]){
      printf("%d\n",ans[i]);
    }
  }
}

int main(){
  init();
  solve();
  return 0;
}
```

