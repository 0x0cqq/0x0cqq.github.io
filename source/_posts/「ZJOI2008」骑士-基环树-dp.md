---
title: 「ZJOI2008」骑士-基环树+dp
urlname: ZJOI2008-knight
date: 2018-11-27 23:11:53
tags:
- 题解
- 基环树
- 动态规划
categories: OI
visible:
---

每个骑士都有且仅有一个自己最厌恶的骑士（当然不是他自己），他是绝对不会与自己最厌恶的人一同出征的。

请你从所有的骑士中选出一个骑士军团，使得军团内没有矛盾的两人（不存在一个骑士与他最痛恨的人一同被选入骑士军团的情况），并且使得这支骑士军团最具有战斗力。

为了描述战斗力，我们将骑士按照 $1$ 至 $n$ 编号，给每名骑士一个战斗力的估计，一个军团的战斗力为所有骑士的战斗力总和。

<!-- more -->

## 链接

[LuoguP2607](https://www.luogu.org/problemnew/show/P2607)

## 题解

先考虑一个 $n$ 条边、 $n$ 个点的无向连通图的情况。这个环中只有一个环，我们在任意位置断掉这个环（并查集），让这个图成为一个树，记两端点为 $X$,$Y$。

注意到由于 $X$ 和 $Y$ 不能同时取得，如果我们分别以 $X$ 和 $Y$ 作为树根进行一次树形 dp ，那么我们的答案肯定在第一次的 $dp[X][0]$ 和第二次的 $dp[Y][0]$ 中的某一个，因为不可能两个都选，我们令一个不选之后，剩下的就只剩下树的限制，我们也一定能够达成最大的情况。

不是特别好理解，但好好理一下也不是特别难吧。

这里没有保证联通，但对于任意一个联通块由于其特殊的建图方式，导致也均为基环树或树。

时间复杂度： $O(n)$.

## 代码

{% fold %}
```cpp
#include <cstdio>
#include <cstring>
#include <algorithm>
#define ll long long
using namespace std;

const int MAXN = 1e6+10;

struct Edge{
  int to,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]};
  fir[a] = ecnt++;
}

int n;
namespace BCJ{
  int f[MAXN];
  void init(int n){
    for(int i = 1;i<=n;i++){
      f[i] = i;
    }
  }
  int find(int x){
    return f[x] == x ? x : f[x] = find(f[x]);
  }
}
int X[MAXN],Y[MAXN],cnt;
bool vis[MAXN];
ll p[MAXN];

void init(){
  scanf("%d",&n);
  BCJ::init(n);
  int a,b;
  for(int i = 1;i<=n;i++){
    scanf("%lld %d",&p[i],&b);
    a = i;
    int fa = BCJ::find(a),fb = BCJ::find(b);
    if(fa == fb){
      X[++cnt] = a, Y[cnt] = b;
    }
    else{
      addedge(a,b),addedge(b,a);
      BCJ::f[fa] = fb;
    }
  }
}

ll dp[MAXN][2];


void dfs(int nown,int fa){
  dp[nown][0] = dp[nown][1] = 0;
  vis[nown] = 1;
  for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;
    if(v == fa) continue;
    dfs(v,nown);
    dp[nown][1] += dp[v][0];
    dp[nown][0] += max(dp[v][0],dp[v][1]);
  }
  dp[nown][1] += p[nown];
}

void solve(){
  ll ans = 0;
  for(int i = 1;i<=cnt;i++){
    ll tmp = 0;
    dfs(X[i],0);
    tmp = max(dp[X[i]][0],tmp);
    dfs(Y[i],0);
    tmp = max(dp[Y[i]][0],tmp);
    ans += tmp;
  }
  for(int i = 1;i<=n;i++){
    if(vis[i] == 0){
      dfs(i,0);
      ans += max(dp[i][0],dp[i][1]);
    }
  }
  printf("%lld\n",ans);
}

int main(){
  init();
  solve();
  return 0;
}
```
{% endfold %}




