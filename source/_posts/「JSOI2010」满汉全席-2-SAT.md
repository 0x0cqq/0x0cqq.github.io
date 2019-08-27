---
title: 「JSOI2010」满汉全席-2-SAT
urlname: JSOI2010-feast
date: 2019-04-09 22:51:59
tags:
- 图论
- 2-SAT
categories:
- OI
- 题解
visible:
---

题意过长，概括如下：

你有 $n$ 种食材，评委 $m$ 个要求，你需要加工这 $n$ 种食材，每种从"汉式（`h`）"或者"满式（`m`）"中选择**一种**。每个要求用两个形如 $\text{h} x$ 或者 $\text{m}x$ （ $x$ 为一个 $1 \sim n$ 的正整数），意为第 $x$ 道菜需要用用"汉式（`h`）"或者"满式（`m`）"来进行加工，每个要求中的两个条件必须至少满足一个，每种食材最多只能用一种方式来加工。

请你判断存不存在一个合法的方式。

<!-- more -->

## 链接

[Luogu P4171](https://www.luogu.org/problemnew/show/P4171) 

## 题解

如果我们把做满式和汉式看成一个变量的 $0/1$ 取值，我们注意到这个就是个 2-SAT 模型。

练习模版背诵技巧（

## 代码

```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 11100;

struct Edge{
  int to,nex;
}edge[MAXN*2];int ecnt = 2;
int fir[MAXN];
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]},fir[a] = ecnt++;
}
void clear(){ecnt = 2;memset(fir,0,sizeof(fir));}

int n,m;

int p(int x,int op){return x + op * n;}
void add(int i,int a,int j,int b){
  addedge(p(i,a^1),p(j,b)),addedge(p(j,b^1),p(i,a));
}

int dfn[MAXN],low[MAXN],col[MAXN],cnum,S[MAXN];

void tarjan(int x){
  dfn[x] = low[x] = ++dfn[0];S[++S[0]] = x;
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to;
    if(!dfn[v]) tarjan(v),low[x] = min(low[x],low[v]);
    else if(!col[v]) low[x] = min(low[x],dfn[v]);
  }
  if(low[x] == dfn[x]){
    for(++cnum;S[S[0]] != x;--S[0]) col[S[S[0]]] = cnum;
    col[S[S[0]--]] = cnum;
  }
}

bool solve_sat(){
  memset(dfn,0,sizeof(dfn)),memset(low,0,sizeof(low));
  memset(S,0,sizeof(S)),memset(col,0,sizeof(col));
  cnum = 0;
  for(int i = 1;i <= 2*n;i++) if(!dfn[i]) tarjan(i);
  for(int i = 1;i<=n;i++) if(col[p(i,0)] == col[p(i,1)]) return 0;
  return 1;
}

void init(){
  scanf("%d %d",&n,&m);
  char s1[10],s2[10];int x,y;
  for(int i = 1;i<=m;i++){
    scanf("%s %s",s1,s2);
    sscanf(s1+1,"%d",&x),sscanf(s2+1,"%d",&y);
    add(x,s1[0]=='h',y,s2[0]=='h');
  }
}

int main(){
  int T;scanf("%d",&T);
  for(int i = 1;i<=T;i++){
    clear(),init();
    printf(solve_sat()?"GOOD\n":"BAD\n");
  }
  return 0;
}
```


