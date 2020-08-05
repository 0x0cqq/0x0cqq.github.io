---
title: 「网络流 24 题」软件补丁-最短路
urlname: loj6009
date: 2019-03-30 08:40:20
tags:
- 图论
- 最短路
categories:
- OI
- 题解
series:
- 网络流 24 题
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

某公司发现其研制的一个软件中有 $n$ 个错误，随即为该软件发放了一批共 $m$ 个补丁程序。每一个补丁程序都有其特定的适用环境，某个补丁只有在软件中包含某些错误而同时又不包含另一些错误时才可以使用。一个补丁在排除某些错误的同时，往往会加入另一些错误。

换句话说，对于每一个补丁 $i$ ，都有 $2$ 个与之相应的错误集合 $B_1(i)$ 和 $B_2(i)$ ，使得仅当软件包含 $B_1(i)$ 中的所有错误，而不包含 $B_2(i)$ 中的任何错误时，才可以使用补丁 $i$ 。补丁 $i$ 将修复软件中的某些错误 $F_1(i)$ ，而同时加入另一些错误 $F_2(i)$ 。另外，每个补丁都耗费一定的时间。

试设计一个算法，利用公司提供的 $m$ 个补丁程序将原软件修复成一个没有错误的软件，并使修复后的软件耗时最少。

<!--more-->

## 链接

[loj6009](https://loj.ac/problem/6009)

## 题解

状态压缩之后直接按照约束跑最短路即可...

注意区分 `~` 和 `!` 的区别。

## 题解

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXM = 110,MAXN = (1<<20)+10;

int n,m;
int T[MAXM],B1[MAXM],B2[MAXM],F1[MAXM],F2[MAXM];
char s[MAXM],t[MAXM];

int dis[MAXN],inq[MAXN];
int spfa(int s,int t){
  static queue<int> q;
  memset(dis,0x3f,sizeof(dis));
  dis[s] = 0,q.push(s);
  while(!q.empty()){
    int x = q.front();q.pop();inq[x] = 0;
    for(int i = 1;i<=m;i++){
      if(!((~x) & B1[i]) && !(x&B2[i])){
        int v = (x & (~F1[i])) | (F2[i]);
        if(dis[v] > dis[x] + T[i]){
          dis[v] = dis[x] + T[i];
          if(!inq[v]) q.push(v),inq[v] = 1;
        }
      }
    }
  }
  return dis[t];
}

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=m;i++){
    scanf("%d %s %s",&T[i],s,t);
    for(int j = 0;j<n;j++){
      if(s[j] == '+') B1[i] |= (1<<j);
      if(s[j] == '-') B2[i] |= (1<<j);
      if(t[j] == '-') F1[i] |= (1<<j);
      if(t[j] == '+') F2[i] |= (1<<j);
    }
  }
}

void solve(){
  int ans = spfa((1<<n)-1,0);
  printf("%d\n",ans==inf ? 0 : ans);
}

int main(){
  init();
  solve();
  return 0;

}
```
