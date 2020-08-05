---
title: 「SPOJ2666」QTREE4-LCT
urlname: SPOJ2666-QTREE4
date: 2019-03-12 20:51:57
tags:
- 数据结构
- LCT
categories: 
- OI
- 题解
series:
- QTREE
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

你被给定一棵 $n$ 个点的带边权的树（边权可以为负）。每个点可能有两种颜色：黑或白。我们定义 $dist(a,b)$ 为点 $a$ 至点 $b$ 路径上的边权值之和。一开始所有的点都是**白色**的。

要求作以下操作：

+ `C a` 将点a的颜色反转（黑变白，白变黑）

+ `A` 询问 $dist(a,b)$ 的最大值。$a,b$ 点都必须为白色（ $a$ 与 $b$ 可以相同），显然如果树上仍存在白点，查询得到的值一定是个非负数。
特别地，如果进行 `A` 操作时树上没有白点，输出 `They have disappeared.`。

<!--more-->

## 链接

[Luogu](https://www.luogu.org/problemnew/show/SP2666)

## 题解

可以用LCT解决这个问题。

我们先考虑链上的情况。如果这个问题在链上，我们可以用线段树维护若干个变量：区间左端点往右最远的白点，区间右端点往左最远的白点的距离，这个区间内部两个白点之间的距离。这样我们就可以在 $O(\log n)$ 的时间内合并区间。

我们考虑树上没有修改的问题。我们都会点分治：在考虑每个树的时候，我们找到不同子树里面最长的两个链，他们合并到一起 和 子树内部的最长链 取最大值，答案就是这个子树里面最长白点之间的距离，分治之后就是 $O(n \log n)$。

我觉得 LCT 的解法颇有 2 合 1 的意思。

我们令 1 号节点为根，然后所有点的权值都是这个点到父亲的边的权值（ $1$ 号节点的权值为 $0$ ），这样两个节点之间的距离就是两个点上的简单路径的权值之和。

每个节点我们需要维护以下信息： 
+ `sum[x]` ： $x$ 的 `splay` 上子树的链和（到链的父节点）
+ `lmax[x]`，`rmax[x]` ： $x$ 所在 $splay$ 的子树上对应原树上最浅（深）的点（最浅的点的父亲）出发能够到达最远的白点（只在当前节点的 $splay$ 和虚子树的并里面走）
+ `maxs[x]` ：我们只考虑这个 splay 和这个 splay 对应的节点的虚子树里面乱跑，能获得的最长的路径
+ 两个 `multiset` ： `chain[x]` , `path[x]` 表示 $x$ 节点的虚子树里面到 $x$ 节点的最长链 和 最长路径

我们主要有两个特异的函数：

+ 一个特别长的 `push_up` ：
  具体维护在代码里面里面看吧qwq
+ 稍微有些不同的 `access`：
  其实是维护虚子树的常规操作：考虑消除和新添影响即可。

我们就 win 掉了。 

时间复杂度为 $O(n \log^2 n)$ 。

为什么跑的飞快啊...

## 代码

```cpp
#include <bits/stdc++.h>
#define inf 0x3f3f3f3f
using namespace std;

const int MAXN = 210000;

struct Edge{
  int to,len;
  int nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b,int c){
  edge[ecnt] = (Edge){b,c,fir[a]};
  fir[a] = ecnt++;
}

inline int _f(multiset<int> &S){return S.size()?*S.rbegin():-inf;}
inline int _s(multiset<int> &S){return S.size()>1?*(++S.rbegin()):-inf;}

struct LCT{
  int c[MAXN][2],w[MAXN],f[MAXN],sum[MAXN],len[MAXN];
  int lmax[MAXN],rmax[MAXN],maxs[MAXN],ans;
  multiset<int> Ch[MAXN],Pa[MAXN];
  void init(int n){for(int i = 0;i<=n;i++) lmax[i] = rmax[i] = maxs[i] = -inf;}
  bool noroot(int x){return c[f[x]][0] == x || c[f[x]][1] == x;}
  void push_up(int x){assert(x);
    #define ls c[x][0]
    #define rs c[x][1]
    // sum[x] : 链子的长度，由左右加起来
    sum[x] = sum[ls] + sum[rs] + len[x];
    // maxc : 从虚子树里面 最长的到这个点的链的长度
    // L/R ：从这个点左/右侧（或者虚子树）过来能够跑最远的距离 
    // l/rmax : 这个子 splay 里面最浅的节点的父节点 / 最深的点 能够走到最远的距离
    int maxc = max(w[x],_f(Ch[x]));
    int L = max(maxc,rmax[ls]+len[x]),R=max(maxc,lmax[rs]);
    lmax[x] = max(lmax[ls],R + sum[ls] + len[x]);
    rmax[x] = max(rmax[rs],L + sum[rs]);

    maxs[x] = -inf;
    // 1 : 两个虚子树里面组合 2 : 虚子树里面的最长路径
    // 3 & 4 : 一个虚子树和左/右 出来到 右/左侧 边中
    // 5 & 6 ： 两个子 splay 中的最长路径
    // 7 : 虚子树中的链到这个节点的距离
    maxs[x] = max(maxs[x],max(_f(Ch[x])+_s(Ch[x]),_f(Pa[x])));
    maxs[x] = max(maxs[x],max(rmax[ls]+len[x]+R,lmax[rs]+L));
    maxs[x] = max(maxs[x],max(maxs[ls],maxs[rs]));
    if(w[x]==0) maxs[x] = max(maxs[x],_f(Ch[x])),maxs[x] = max(maxs[x],0);
    #undef ls
    #undef rs
  }
  void rotate(int x){
    int y = f[x],z = f[y],t = c[y][1] == x,w = c[x][1-t];
    if(noroot(y)) c[z][c[z][1]==y] = x;
    c[x][1-t] = y,c[y][t] = w;
    if(w) f[w] = y;
    f[y] = x,f[x] = z;
    push_up(y);
  }
  void splay(int x){
    while(noroot(x)){
      int y = f[x],z = f[y];
      if(noroot(y)){
        (c[y][1]==x)^(c[z][1]==y)?rotate(x):rotate(y);
      }rotate(x);
    }push_up(x);
  }
  void access(int x){
    for(int y = 0;x;x = f[y=x]){
      splay(x);
      if(c[x][1]) 
        Ch[x].insert(lmax[c[x][1]]),Pa[x].insert(maxs[c[x][1]]);
      if(y) 
        Ch[x].erase(Ch[x].find(lmax[y])),Pa[x].erase(Pa[x].find(maxs[y]));
      c[x][1] = y,push_up(x);
    }
  }
  void modify(int x){
    access(x),splay(x);
    w[x] = w[x]==0?-inf:0;
    push_up(x);
    ans = maxs[x];
  }
  void add(int x,int v){
    Ch[x].insert(lmax[v]),Pa[x].insert(maxs[v]);
  }
  int query(){return ans;}
  void print(int n){
    printf("--------------------\n");
    for(int x = 1;x<=n;x++){
      printf("%d: c:%d %d f:%d | sum:%d len:%d w:%d | max: l:%d r:%d s:%d\n",x,c[x][0],c[x][1],f[x],sum[x],len[x],w[x],lmax[x],rmax[x],maxs[x]);
      printf("Ch: ");
      for(auto x : Ch[x]) printf("%d ",x);
      printf("\n");
      printf("Pa: ");
      for(auto x : Pa[x]) printf("%d ",x);
      printf("\n");    
    }
    printf("--------------------\n");
  }
}T;


void dfs1(int x,int fa){
  for(int nowe = fir[x];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to,l = edge[nowe].len;
    if(v == fa) continue;
    T.f[v] = x,T.len[v] = l,dfs1(v,x);
    T.add(x,v);
  }
  T.push_up(x);
}

int n,q;

void init(){
  scanf("%d",&n);
  for(int i = 2;i<=n;i++){
    int a,b,c;
    scanf("%d %d %d",&a,&b,&c);
    addedge(a,b,c),addedge(b,a,c);
  }
  T.init(n);dfs1(1,0);T.ans = T.maxs[1];
}

void solve(){
  scanf("%d",&q);
  char op[10];int x;
  for(int i = 1;i<=q;i++){
    scanf("%s",op);
    if(op[0] == 'A'){
      int ans = T.query();
      if(ans >= 0) printf("%d\n",ans);
      else         printf("They have disappeared.\n");
    }else if(op[0] == 'C') scanf("%d",&x),T.modify(x);
    

  }
}

int main(){
  init();
  solve();
  return 0;
}

```