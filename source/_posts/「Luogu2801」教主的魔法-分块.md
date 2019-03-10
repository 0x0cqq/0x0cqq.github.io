---
title: 「Luogu 2801」教主的魔法-分块
urlname: luogu-2801
date: 2018-09-09 20:00:07
tags: 
- 题解
- 分块
- 数据结构
categories: OI
visible:
---

给定一个长度为 $N$ 的数列，每次一个操作或询问：

+ 把闭区间 $[L, R]$ 内的数全部加上一个整数 $W$ 
+ 问闭区间 $[L, R]$ 内有多少英雄身高大于等于 $C$

<!-- more -->

## 链接

[Luogu P2801](https://www.luogu.org/problemnew/show/P2801)

## 题解

分块，每块维护一个 $\text{add}$ 标记，保证块内有序。

整块的修改直接打标记，零散数先减去标记后逐个修改，块内重排。

整块查询减去标记后二分，零散数暴力判断。

注意边界。

## 代码



```cpp
#include <cstdio>
#include <algorithm>
#include <cstring>
#include <cmath>
using namespace std;

const int MAXN = 1100000,MAXQ = 50000;

void read(int &x){scanf("%d",&x);}
void read(char *x){scanf("%s",x);}

int n,m,a[MAXN],Q;
int add[MAXN];
int num[MAXN];

bool cmp(int a,int b){return a > b;}
void cpy(int q){memcpy(num+q*Q,a+q*Q,sizeof(int)*Q);}
void sort(int q){sort(num+q*Q,num+min(n,(q+1)*Q),cmp);}

int query(int q,int c){
  int t = upper_bound(num+q*Q,num+min(n,(q+1)*Q),c,cmp) - (num+q*Q);
  // printf("q:%d c:%d t:%d\n",q,c,t);
  return t;
}

void init(){
  read(n),read(m);Q = sqrt(n)+1;
  for(int i = 0;i<n;i++){
    read(a[i]);
    if(i/Q != (i+1)/Q || i == n-1)
      cpy(i/Q),sort(i/Q);
  }
}

void modify(int l,int r,int w){
  int lq = l/Q,rq = r/Q;
  if(lq == rq || lq + 1 == rq){
    for(int i = l;i<=r;i++)
      a[i] += w;
    cpy(lq),sort(lq);
    cpy(rq),sort(rq);
  }
  else{
    for(int i = lq+1;i<=rq-1;i++) add[i] += w;
    for(int i = l;i<(lq+1)*Q;i++) a[i] += w;
    for(int i = rq*Q;i<=r;i++)    a[i] += w;
    cpy(lq),sort(lq);
    cpy(rq),sort(rq);
  }
}

int query(int l,int r,int c){
  int lq = l/Q,rq = r/Q,ans = 0;
  if(lq == rq || lq + 1 == rq){
    for(int i = l;i<=r;i++)
      if(a[i] + add[i/Q] >= c) ans ++;
    return ans;
  }
  else{
    for(int i = lq+1;i<=rq-1;i++)
      ans += query(i,c-add[i]);
    for(int i = l;i<(lq+1)*Q;i++)
      if(a[i] + add[i/Q] >= c) ans ++;
    for(int i = rq*Q;i<=r;i++)
      if(a[i] + add[i/Q] >= c) ans ++;
    return ans; 
  }  
}


void solve(){
  char op[10];
  int l,r,c;
  for(int i = 1;i<=m;i++){
    read(op),read(l),read(r),read(c);
    if(op[0] == 'M')
      modify(l-1,r-1,c);
    if(op[0] == 'A')
      printf("%d\n",query(l-1,r-1,c));
  }
}

int main(){
  init();
  solve();
  return 0;
}
```




