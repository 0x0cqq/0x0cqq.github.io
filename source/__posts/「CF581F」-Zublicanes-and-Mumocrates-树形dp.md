---
title: 「CF581F」 Zublicanes and Mumocrates - 树形dp
urlname: CF581F
date: 2019-03-02 12:19:10
tags:
- 题解
- 动态规划
- 树形dp
categories: OI
visible:
---

一棵树上有 $n$ 个节点，把每个节点染成黑色或白色，要求叶子节点一半是黑色，一半是白色（保证叶子节点的个数是偶数）。

求在满足要求的情况下，最小的两端颜色不同的边的数量。

<!-- more -->

## 链接
[Codeforces](http://codeforces.com/contest/581/problem/F)

## 题解

我们考虑树形dp，令 $dp[x][v][0/1]$ 表示节点 $x$ 代表的子树里面，为白色的叶子节点有 $v$ 个，$x$ 节点的颜色是白色（0）还是黑色（1）的情况下，最小的两端颜色不同的边的数量。

然后我们可以用那种 $O(n^2)$ 完成树形 dp 的套路去搞它就可以了。

然后转移的时候还要枚举第三维是 0 还是 1 ，然后计算贡献，不要忘掉（

这个跟普通的树形dp不太一样，需要在开始的时候多特殊判断一些，而且你加入子树更新dp数组的时候不能遗传这个数组，只能用新算出来的数来更新。

时间复杂度：$O(n^2)$

## 代码

{% fold %}
```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 5100;

struct Edge{
  int to,nex;
}edge[MAXN*2];
int fir[MAXN],ecnt = 2;
void addedge(int a,int b){
  edge[ecnt] = (Edge){b,fir[a]};
  fir[a] = ecnt++;
}

int n;
int in[MAXN],siz[MAXN],sum,rt = 0;

int dp[MAXN][MAXN][2];// dp[x][v][0/1] v 个白色的
void dfs(int x,int fa){
  if(in[x] == 1){
    siz[x] = 1,dp[x][1][0] = 0,dp[x][0][1] = 0;
    return;
  }
  int f = 0;
  for(int nowe = fir[x];nowe;nowe = edge[nowe].nex){
    int v = edge[nowe].to;
    if(v == fa) continue;
    dfs(v,x);
    if(f == 0){
      for(int k = 0;k <= siz[v];k++){
        dp[x][k][1] = min(dp[v][k][0]+1,dp[v][k][1]);
        dp[x][k][0] = min(dp[v][k][1]+1,dp[v][k][0]);
      }     
    }
    else{
      for(int j = siz[v] + siz[x];j >= 0;j--){
        int tmp[2] = {0x3f3f3f3f,0x3f3f3f3f};
        for(int k = 0;k <= min(j,siz[v]);k++){
          // dp[x][j-k] 与 dp[v][k] 之间的碰撞和激情
          tmp[1] = min(tmp[1],dp[x][j-k][1] + min(dp[v][k][0]+1,dp[v][k][1]));
          tmp[0] = min(tmp[0],dp[x][j-k][0] + min(dp[v][k][1]+1,dp[v][k][0]));
        }
        dp[x][j][0] = tmp[0],dp[x][j][1] = tmp[1];
      }
    }
    f = 1;
    siz[x] += siz[v];
  }
}

void init(){
  scanf("%d",&n);
  for(int i = 2;i<=n;i++){
    int a,b;
    scanf("%d %d",&a,&b);
    addedge(a,b),addedge(b,a);
    in[a]++,in[b]++;
  }
  for(int i = 1;i<=n;i++){
    if(in[i] == 1) sum++;
    if(in[i] > in[rt]) rt = i;
  }
}

void solve(){
  if(n == 2){printf("1\n");return;}
  memset(dp,0x3f,sizeof(dp));
  dfs(rt,0);
  printf("%d\n",min(dp[rt][sum/2][0],dp[rt][sum/2][1]));
}

int main(){
  init();
  solve();
  return 0;
}

```
{% endfold %}