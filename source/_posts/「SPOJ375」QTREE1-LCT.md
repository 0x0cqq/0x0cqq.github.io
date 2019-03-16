---
title: 「SPOJ375」QTREE1-LCT
urlname: SPOJ375-QTREE1
date: 2019-03-15 20:59:53
tags:
- 数据结构
- 动态树
categories:
- OI
- 题解
visible:
---

给定 $n$ 个点的树，边按输入顺序编号为 $1,2,...,n-1$，要求作以下操作： 
+ `CHANGE i v` ：将第 $i$ 条边权值改为 $v$
+ `QUERY a b` ：询问从 $a$ 点到 $b$ 点路径上的最大边权

有多组测试数据，每组数据以 `DONE` 结尾。

<!-- more -->

## 链接

[Luogu](https://www.luogu.org/problemnew/show/SP375)

## 题解

可以用 LCT 完成本题。

我们考虑每个边和每个点建立一个 LCT 中的点，然后边的点的点权就是边的边权，这样就可以修改边的权值了。

查询的话，直接 `split` 出来查询最大值即可，点对应的 LCT 中的点的权值为 $-\inf$。

时间复杂度： $O(n \log n)$

## 代码

Luogu 版本；

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 210000;

struct LCT{
  int c[MAXN][2],f[MAXN],v[MAXN],mx[MAXN],r[MAXN];
  void init(int n){for(int i = 0;i<=n;i++) v[i]=mx[i] = -inf, c[i][0]=c[i][1]=f[i]=r[i] = 0;}
  bool noroot(int x){return c[f[x]][0] == x || c[f[x]][1] == x;}
  void push_up(int x){mx[x] = max(v[x],max(mx[c[x][0]],mx[c[x][1]]));}
  void rev(int x){r[x] ^= 1,swap(c[x][0],c[x][1]);}
  void push_down(int x){if(r[x]) rev(c[x][0]),rev(c[x][1]),r[x] = 0;}
  void push_all(int x){
    static int S[MAXN];S[0] = 0;
    while(noroot(x)) S[++S[0]] = x,x = f[x];
    S[++S[0]] = x;
    for(int i = S[0];i>=1;--i) push_down(S[i]);
  }
  void rotate(int x){
    int y = f[x],z = f[y],t = (c[y][1] == x),w = c[x][1-t];
    if(noroot(y)) c[z][c[z][1]==y] = x;
    c[x][1-t] = y,c[y][t] = w;
    if(w) f[w] = y;
    f[x] = z,f[y] = x;
    push_up(y);
  }
  void splay(int x){
    push_all(x);
    while(noroot(x)){
      int y = f[x],z = f[y];
      if(noroot(y)){
        (c[y][1] == x) ^ (c[z][1] == y) ? rotate(x) : rotate(y);
      }rotate(x);
    }push_up(x);
  }
  void access(int x){
    for(int y = 0;x;x = f[y=x]){
      splay(x),c[x][1] = y,push_up(x);
    }
  }
  void makeroot(int x){access(x),splay(x),rev(x);}
  void update(int x,int val){v[x] = val,push_up(x);}
  void modify(int x,int val){access(x),splay(x),update(x,val);}
  void split(int x,int y){makeroot(x),access(y),splay(y);}
  int query(int x,int y){return x == y ? 0 : (split(x,y),mx[y]);}
  void addedge(int x,int fa){f[x] = fa;}
}T;

struct Edge{
  int id,to,len,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int id,int a,int b,int c){
  edge[ecnt] = (Edge){id,b,c,fir[a]};
  fir[a] = ecnt++;
}
void _clear(int n){ecnt = 2;for(int i = 1;i<=n;i++) fir[i] = 0;}

int n,q;

void dfs(int x,int fa){
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to,l = edge[e].len,id = edge[e].id;
    if(v == fa) continue;
    T.update(n+id,l),T.addedge(v,n+id),T.addedge(n+id,x);
    dfs(v,x);
  }
}


void init(){
  scanf("%d",&n);
  _clear(2*n);
  T.init(2*n);
  for(int i = 1;i<=n-1;i++){
    int a,b,c;
    scanf("%d %d %d",&a,&b,&c);
    addedge(i,a,b,c),addedge(i,b,a,c);
  }
  dfs(1,0);
}

void solve(){
  char op[10];int x,y;
  while(true){
    scanf("%s",op);
    if(op[0] == 'D') break;
    scanf("%d %d",&x,&y);
    if(op[0] == 'C') T.modify(n+x,y);
    else if(op[0] == 'Q') printf("%d\n",T.query(x,y));
  }
}

int main(){
  int T = 1;
  for(int i = 1;i<=T;i++) init(),solve();
  return 0;
}
```

SPOJ 版本：

```c
#include <stdio.h>
#define inf 0x3f3f3f3f
#define MAXN 210000

int max(int x,int y){return x > y ? x : y;}
int swap(int *x,int *y){(*x) ^= (*y),(*y) ^= (*x),(*x) ^= (*y);}

int c[MAXN][2],f[MAXN],v[MAXN],mx[MAXN],r[MAXN];
void _init_(int n){for(int i = 0;i<=n;i++) v[i]=mx[i] = -inf, c[i][0]=c[i][1]=f[i]=r[i] = 0;}
int noroot(int x){return c[f[x]][0] == x || c[f[x]][1] == x;}
void push_up(int x){mx[x] = max(v[x],max(mx[c[x][0]],mx[c[x][1]]));}
void rev(int x){r[x] ^= 1,swap(&c[x][0],&c[x][1]);}
void push_down(int x){if(r[x]) rev(c[x][0]),rev(c[x][1]),r[x] = 0;}
void push_all(int x){
  static int S[MAXN];S[0] = 0;
  while(noroot(x)) S[++S[0]] = x,x = f[x];
  S[++S[0]] = x;
  for(int i = S[0];i>=1;--i) push_down(S[i]);
}
void rotate(int x){
  int y = f[x],z = f[y],t = (c[y][1] == x),w = c[x][1-t];
  if(noroot(y)) c[z][c[z][1]==y] = x;
  c[x][1-t] = y,c[y][t] = w;
  if(w) f[w] = y;
  f[x] = z,f[y] = x;
  push_up(y);
}
void splay(int x){
  push_all(x);
  while(noroot(x)){
    int y = f[x],z = f[y];
    if(noroot(y)){
      (c[y][1] == x) ^ (c[z][1] == y) ? rotate(x) : rotate(y);
    }rotate(x);
  }push_up(x);
}
void access(int x){
  for(int y = 0;x;x = f[y=x]){
    splay(x),c[x][1] = y,push_up(x);
  }
}
void makeroot(int x){access(x),splay(x),rev(x);}
void update(int x,int val){v[x] = val,push_up(x);}
void modify(int x,int val){access(x),splay(x),update(x,val);}
void split(int x,int y){makeroot(x),access(y),splay(y);}
int query(int x,int y){split(x,y);return x == y ? 0 : mx[y];}
void _addedge(int x,int fa){f[x] = fa;}

struct Edge{
  int id,to,len,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int id,int a,int b,int c){
  edge[ecnt].id = id,edge[ecnt].to = b,edge[ecnt].nex = fir[a],edge[ecnt].len = c;
  fir[a] = ecnt++;
}

int n,q;

void dfs(int x,int fa){
  for(int e = fir[x];e;e = edge[e].nex){
    int v = edge[e].to,l = edge[e].len,id = edge[e].id;
    if(v == fa) continue;
    update(n+id,l),_addedge(v,n+id),_addedge(n+id,x);
    dfs(v,x);
  }
}


void _clear(int n){
  ecnt = 2;for(int i = 1;i<=n;i++) fir[i] = 0;
}

void init(){
  scanf("%d",&n);
  _clear(2*n);
  _init_(2*n);
  for(int i = 1;i<=n-1;i++){
    int a,b,c;
    scanf("%d %d %d",&a,&b,&c);
    addedge(i,a,b,c),addedge(i,b,a,c);
  }
  dfs(1,0);
}

void solve(){
  char op[10];int x,y;
  while(1){
    scanf("%s",op);
    if(op[0] == 'D') break;
    scanf("%d %d",&x,&y);
    if(op[0] == 'C') modify(n+x,y);
    else if(op[0] == 'Q') printf("%d\n",query(x,y));
  }
}

int main(){
  int T = 0;
  scanf("%d",&T);
  for(int i = 1;i<=T;i++) init(),solve();
  return 0;
}
```