---
title: 「HNOI2010」平面图判定-2-SAT
urlname: HNOI2010-planarity
date: 2019-04-09 22:51:53
tags:
- 图论
- 2-SAT
categories:
- OI
- 题解
visible:
---

若能将无向图 $G=(V, E)$ 画在平面上使得任意两条无重合顶点的边不相交，则称 $G$ 是平面图。判定一个图是否为平面图的问题是图论中的一个重要问题。现在假设你要判定的是一类特殊的图，图中存在一个包含所有顶点的环，即存在哈密顿回路。

<!-- more -->

## 链接

[Luogu P3209](https://www.luogu.org/problemnew/show/P3209)

## 题解

我们把哈密顿回路拎出来，剩下的边要么在环外要么在环内，如果两条边同时在环内会导致相交（判定比较啰嗦就不说了），我们就建边约束 $x_i \oplus x_j = 1$ 即可。

可以用 2-SAT 模型解决该问题。

## 代码

```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 11000;

struct Edge{
  int to,nex;
}edge[MAXN*100];int ecnt = 2;
int fir[MAXN];
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]},fir[a] = ecnt++;
}
void clear(){ecnt = 2;memset(fir,0,sizeof(fir));}


int n,m;
int s[MAXN];
int p(int i,int op){return i + op * m;}
void add_xor(int i,int j){// i xor j == 1
  addedge(p(i,1),p(j,0)),addedge(p(i,0),p(j,1));
  addedge(p(j,0),p(i,1)),addedge(p(j,1),p(i,0));
}

int dfn[MAXN],low[MAXN],S[MAXN],col[MAXN],cnum;

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
  memset(dfn,0,sizeof(dfn)),memset(col,0,sizeof(col));
  memset(S,0,sizeof(S)),memset(low,0,sizeof(low));
  cnum = 0;
  for(int i = 1;i <= 2 * m;i++) if(!dfn[i]) tarjan(i);
  for(int i = 1;i <= m;i++) if(col[p(i,0)] == col[p(i,1)]) return 0;
  return 1;
}

set<pair<int,int> > Set;
int u[MAXN],v[MAXN];
int vis[MAXN],pos[MAXN];

int judge(int i,int j){
  if(vis[i] || vis[j]) return 0;
  if(make_pair(u[i],-v[i]) > make_pair(u[j],-v[j])) swap(i,j);
  if(v[j] <= v[i] || u[j] >= v[i]) return 0;
  else return 1;
}

void init(){
  Set.clear();
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=m;i++){
    scanf("%d %d",&u[i],&v[i]);
    if(u[i] > v[i]) swap(u[i],v[i]);
  }
  for(int i = 1;i<=n;i++) scanf("%d",&s[i]);
  s[0] = s[n];
  for(int i = 1;i<=n;i++){
    int u = s[i-1],v = s[i];
    if(u > v) swap(u,v);
    Set.insert(make_pair(u,v));
  }
  for(int i = 1;i<=m;i++) vis[i] = Set.count(make_pair(u[i],v[i]));
  for(int i = 1;i<=n;i++) pos[s[i]] = i;
  for(int i = 1;i<=m;i++) {
    u[i] = pos[u[i]],v[i] = pos[v[i]];
    if(u[i] > v[i]) swap(u[i],v[i]);
  }
}

void solve(){
  if(m > 3 * n - 6) return (void)(printf("NO\n"));
  for(int i = 1;i <= m;i++){
    for(int j = i+1;j <= m;j++){
      if(judge(i,j)) add_xor(i,j);
    }
  }
  printf(solve_sat()?"YES\n":"NO\n");
}

int main(){
  int T;scanf("%d",&T);
  for(int i = 1;i<=T;i++){
    clear(),init();
    solve();
  }
  return 0;
}
```


