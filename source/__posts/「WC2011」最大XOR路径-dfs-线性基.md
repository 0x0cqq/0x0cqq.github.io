---
title: 「WC2011」最大XOR路径-dfs+线性基
urlname: WC2011-xor
date: 2018-11-27 23:12:14
tags:
- 题解
- 数学
- 线性基
categories: OI
visible:
---

考虑一个边权为非负整数的无向连通图，节点编号为 $1$ 到 $N$ ，试求出一条从 $1$ 号节点到 $N$ 号节点的路径，使得路径上经过的边的权值的 $\text{XOR}$ 和最大。

路径可以重复经过某些点或边，当一条边在路径中出现了多次时，其权值在计算 $\text{XOR}$ 和时也要被计算相应多的次数。

图中可能有重边或自环。

<!-- more -->

## 链接

[Luogu P4151](https://www.luogu.org/problemnew/show/P4151)

## 题解

一个有可能比较常见的套路：

考虑 $1\rightarrow n$ 的路径，一定由一条路径和一些环获得。

我们注意到考虑挂在路径上的环的影响时，不必考虑环如何到达路径，因为我们必然有一条路径使得“去环”和“离开环”恰好抵消。因此我们可以随便加环。

我们甚至还注意到，$1\rightarrow n$ 路径也可以随便选，因为如果是另一条路径的话，事实上异或一个经过 $1$ 和 $n$ 的大环就可以得到另一条 $1 \rightarrow n$ 的路径了。

找环就用 dfs ，其中每一条返祖边都可以对应一个环。即使是有公共边的环也可以用小环异或出来，所以返祖边直接处理环即可。

时间复杂度 $O(n \times 64)$.

## 代码

{% fold %}
```cpp
#include <cstdio>
using namespace std;

typedef long long ll;

const int MAXN = 51000,MAXM = 110000,logn = 61;

struct LB{
  ll basis[logn];
  void insert(ll x){
    if(!x) return;
    for(int i = logn-1;i>=0;--i){
      if((x & (1LL<<i)) == 0) continue;
      if(basis[i] == 0){
        basis[i] = x;
        break;
      }
      else{
        x ^= basis[i];
      }
    }
  }
  ll getmax(ll ans = 0){
    for(int i = logn-1;i>=0;--i){
      if((ans^basis[i]) > ans){
        ans ^= basis[i];
      }
    }
    return ans;
  }
}B;

struct Edge{
  int to,nex;
  ll len;
}edge[MAXM*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b,ll c){
  edge[ecnt] = (Edge){b,fir[a],c};
  fir[a] = ecnt++;
}

int n,m;

void init(){
  scanf("%d %d",&n,&m);
  int a,b;ll c;
  for(int i = 1;i<=m;i++){
    scanf("%d %d %lld",&a,&b,&c);
    addedge(a,b,c);
    addedge(b,a,c);
  }
}

ll dis[MAXN];bool vis[MAXN];


void dfs(int nown){
  vis[nown] = 1;
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;ll len = edge[nowe].len;
    if(vis[v] == 1){
      B.insert(dis[nown]^dis[v]^len);
    }
    else{
      dis[v] = dis[nown] ^ len;
      dfs(v);
    }
  }
}

void solve(){
  dfs(1);
  printf("%lld\n",B.getmax(dis[n]));
}

int main(){
  init();
  solve();
  return 0;
}
```
{% endfold %}
