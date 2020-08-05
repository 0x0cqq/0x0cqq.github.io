---
title: 「HNOI2014」世界树-虚树+树形dp
urlname: HNOI2014-worldtree
date: 2018-10-21 22:29:12
tags:
- 虚树
- 树形结构
- 树形dp
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

世界树的形态可以用一个数学模型来描述：世界树中有 $n$ 个种族，种族的编号分别从 $1$ 到 $n$，分别生活在编号为 $1$ 到 $n$ 的聚居地上，种族的编号与其聚居地的编号相同。有的聚居地之间有双向的道路相连，道路的长度为 $1$。保证连接的方式会形成一棵树结构，即所有的聚居地之间可以互相到达，并且不会出现环。定义两个聚居地之间的距离为连接他们的道路的长度；例如，若聚居地 $a$ 和 $b$ 之间有道路，$b$ 和 $c$ 之间有道路，因为每条道路长度为 $1$ 而且又不可能出现环，所以 $a$ 与 $c$ 之间的距离为 $2$。

出于对公平的考虑，第 $i$ 年，世界树的国王需要授权 $m_i$ 个种族的聚居地为临时议事处。对于某个种族 $x$（$x$ 为种族的编号），如果距离该种族最近的临时议事处为 $y$（$y$ 为议事处所在聚居地的编号），则种族 $x$ 将接受 $y$ 议事处的管辖（如果有多个临时议事处到该聚居地的距离一样，则 $y$ 为其中编号最小的临时议事处）。

现在国王想知道，在 $q$ 年的时间里，每一年完成授权后，当年每个临时议事处将会管理多少个种族（议事处所在的聚居地也将接受该议事处管理）。 现在这个任务交给了以智慧著称的灵长类的你：程序猿。请帮国王完成这个任务吧。

<!--more-->

## 链接

[Luogu P3233](https://www.luogu.org/problemnew/show/P3233)

## 题解

我们可以对于每次询问先构造出虚树。

对于虚树上的节点，我们可以用 $O(m_i)$ 的时间求出虚树上的每个节点距离最近的点。（树形 dp 求出每个节点上方和下方的节点的最近距离然后取 min）

然后我们对于每条边分类讨论，我们可以计算出来所有连接到这个虚树边上的点的个数，也就是 $siz[u] - siz[v]$。如果这个时候我们的 $u,v$ 能够到达的最近关键点相同，那么这个时候我们就把连到这个边上的点全部都划分给这个相同的关键点；否则我们求出两个点到关键的距离差，然后找到划分最近关键点，用倍增找到这个点，然后划分出两部分分别累加至对应关键点即可。（看起来没几句话，调起来emmm）

时间复杂度大约是 $O(n \log n)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 310000,logn = 19;

struct Graph{
  struct Edge{
    int to,nex;
  }edge[MAXN*2];int ecnt;
  int fir[MAXN];
  void addedge(int u,int v){
    edge[ecnt] = (Edge){v,fir[u]};
    fir[u] = ecnt++;
  }
  Edge & operator [](int e){
    return edge[e];
  }
  Graph(){
    ecnt = 2;
  }
}G1,G2;

int n,q,m;

struct Node{
  int x;
}h[MAXN];
int f[MAXN][logn],vis[MAXN],dfn[MAXN],ans[MAXN],siz[MAXN],dep[MAXN],cnt;

bool cmp(Node a,Node b){
  return dfn[a.x] < dfn[b.x];
}

int lca(int x,int y){
  if(x == 0 || y == 0) return 0;
  if(dep[x] < dep[y]) swap(x,y);
  for(int j = logn-1;j>=0;j--){
    if(dep[f[x][j]] >= dep[y]) 
      x = f[x][j];
  }
  if(x == y) return x;
  for(int j = logn-1;j>=0;j--){
    if(f[x][j] != f[y][j])
      x = f[x][j],y = f[y][j];
  } 
  return f[x][0];
}

int find_fa(int x,int t){
  int tar = dep[x]-t;
  for(int j = logn-1;j>=0;--j){
    if(dep[f[x][j]] >= tar)
      x = f[x][j];
  }
  return x;
}

int dis(int x,int y){
  return dep[x] + dep[y] - 2*dep[lca(x,y)];
}

void dfs0(int nown,int fa,int depth){
  f[nown][0] = fa,dfn[nown] = ++cnt,siz[nown] = 1;
  dep[nown] = depth;
  for(int nowe = G1.fir[nown];nowe;nowe = G1[nowe].nex){
    int v = G1[nowe].to;
    if(v == fa) continue;
    dfs0(v,nown,depth+1);
    siz[nown] += siz[v];
  }
}

void build(){
  dfs0(1,0,1);
  for(int j = 1;j<=logn-1;j++){
    for(int i = 1;i<=n;i++){
      f[i][j] = f[f[i][j-1]][j-1];
    }
  }
}

void build_tree(){
  if(vis[1] == 0) h[++m] = (Node){1};
  G2.ecnt = 2;
  sort(h+1,h+m+1,cmp);
  static int stk[MAXN];int top = 0;//[0,top]
  for(int i = 1;i<=m;i++){
    int L = lca(h[i].x,stk[top]);
    if(L == stk[top]){
      stk[++top] = h[i].x;
    }
    else{
      while(top >= 1 && dep[stk[top-1]] >= dep[L]){
        int nown = stk[top-1],v = stk[top];
        G2.addedge(nown,v);
        top--;
      }
      if(stk[top] != L){
        G2.addedge(L,stk[top]);
        stk[top] = L;
      }
      stk[++top] = h[i].x;
    }
  }
  while(top >= 1){
    G2.addedge(stk[top-1],stk[top]);
    top--;
  }
}

int near[MAXN],dist[MAXN];

void dfs1(int nown,int fa){
  if(vis[nown] == 1) near[nown] = nown,dist[nown] = 0;
  else dist[nown] = 0x3f3f3f3f;
  for(int nowe = G2.fir[nown];nowe;nowe = G2[nowe].nex){
    int v = G2[nowe].to;
    dfs1(v,nown);
    int d = dist[v] - dep[nown] + dep[v];
    if(d < dist[nown] || 
      (d == dist[nown] && near[v] < near[nown])){
      near[nown] = near[v];
      dist[nown] = d;
    }
  }
}

void dfs2(int nown,int fa,int nst){
  int d = dis(nst,nown);
  if(nst != -1 && (d < dist[nown] || (d == dist[nown] && nst < near[nown]))){
    near[nown] = nst;
    dist[nown] = d;
  }
  else{
    nst = near[nown];
  }
  for(int nowe = G2.fir[nown];nowe;nowe = G2[nowe].nex){
    int v = G2[nowe].to;
    if(v == fa) continue;
    dfs2(v,nown,nst);
  }
}


int id[MAXN];

void dfs3(int nown,int fa){
  int _siz = 0;
  for(int nowe = G2.fir[nown];nowe;nowe = G2[nowe].nex){
    int v = G2[nowe].to,len = dep[v] - dep[nown];
    dfs3(v,nown);
    _siz += siz[find_fa(v,len-1)];
  }
  ans[id[near[nown]]] += siz[nown] - _siz;
  // 直接与当前节点相邻的子树（不在虚树路径上）都属于该节点

  for(int nowe = G2.fir[nown];nowe;nowe = G2[nowe].nex){
    int v = G2[nowe].to,len = dep[v] - dep[nown];
    int tmp = siz[find_fa(v,len-1)] - siz[v];// 所有可能被这两个节点掌控的节点
    if(len == 1) continue;
    if(near[nown] == near[v]){
      ans[id[near[nown]]] += tmp;
      continue;
    }
    else{
      int ww = dist[nown] - dist[v] + len;// 理论上第 ww/2 个祖先相同距离
      if(ww == 0){
        ans[id[near[nown]]] += tmp;continue;
      }
      if(ww == 2*len){
        ans[id[near[v]]] += tmp; continue;
      }
      if((ww & 1) == 0){
        int x = find_fa(v,ww/2-1),y = f[x][0];
        ans[id[min(near[v],near[nown])]] += siz[y] - siz[x];
        tmp -= (siz[y] - siz[x]);
      }
      int xx = find_fa(v,(ww-1)/2),tt = siz[xx] - siz[v];
      ans[id[near[v]]] += tt,ans[id[near[nown]]] += tmp - tt; 
    }
  }
  G2.fir[nown] = 0;
}

void calc(){
  build_tree();
  dfs1(1,0);
  dfs2(1,0,-1);
  dfs3(1,0);
}


void init(){
  scanf("%d",&n);
  for(int i = 1;i<=n-1;i++){
    int u,v;
    scanf("%d %d",&u,&v);
    G1.addedge(u,v),G1.addedge(v,u);        
  }
}

void solve(){
  scanf("%d",&q);
  for(int i = 1;i<=q;i++){
    scanf("%d",&m);
    for(int j = 1;j<=m;j++){
      int x;
      scanf("%d",&x);
      h[j] = (Node){x};
      ans[j] = 0,id[x] = j;
      vis[x] = 1;
    }
    int mm = m;
    calc();
    for(int j = 1;j<=mm;j++){
      printf("%d ",ans[j]);
      vis[h[j].x] = 0;
    }
    vis[h[m].x] = 0;
    printf("\n");
  }
}

int main(){
  init();
  build();
  solve();
  return 0;   
} 
```

