---
title: 「CF476E」Dreamoon and Strings-动态规划
urlname: CF476E
date: 2019-02-11 23:23:18
tags:
- 动态规划
- 题解
categories: OI
visible:
---


Dreamoon 有一个字符串  $s$  和一个模式串  $p$，他会先从  $s$  中删除恰好  $x$  个字符来产生一个新的字符串  $s'$ 。然后他会计算  $occ(s',p)$，即从  $s'$  中能找到的等于  pp  的不相交的子串数量的最大值。他想让 $occ(s',p)$  的值尽可能大。

更形式地说，让我们用  $ans(x)$  表示所有可以从  $s$  中删去恰好  $x$  个字符得到的  $s'$  中  $occ(s',p)$  的最大值。Dreamoon 想要知道对于所有的  $x$  $(0 \leq x \leq |s|)$， $ans(x)$ 的值。

<!-- more -->

## 题解

这题我用了一个极其麻烦的 $dp$，需要记录四个数组，有一大堆细节，我简略的说下。

$f[i][j]$ 表示在 $s$ 串前 $i$ 位，当前匹配到 $p$ 串第 $j$ 位，$p$ 串最靠右时，第一位的位置。

$h[i]$ 表示在 $s$ 串前 $i$ 位，匹配一个完整的 $p$ 串，$p$ 串最靠右时，需要使这个子序列变成子串的最小代价。

$g[i][j]$ 表示在 $s$ 串的前 $i$ 位，前面出现完整的 $j$ 次 $p$ 串时，第一次出现的 $p$ 串最靠右时，第一次出现的 $p$ 串的第一个位置。

$p[i][j]$ 表示如上条件下的代价是多少。

计算出如上四个数组之后，我们计算出 $\text{minlen}[i]$ ，意为搞出 $i$ 个 $p$ 串的最小代价。

然后对于每一个 $i$ ，当 $t \in [\text{minlen}[i-1],\text{minlen[i]-1]}$ ， $ans(t) = i$ 。后面还有一些就是逆序的递增数列，如 $...444333222111000$ ，长度取决于最大能搞出来多少个。

反正超级麻烦，但是过掉了2333

时间复杂度和空间复杂度都是 $O(n^2)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;

const int MAXN = 2100;

int n,m;
char s[MAXN],t[MAXN];
int last[MAXN][30];
int f[MAXN][MAXN],h[MAXN];
int g[MAXN][MAXN],p[MAXN][MAXN];

void init(){
  scanf("%s",s+1),scanf("%s",t+1);
  n = strlen(s+1),m = strlen(t+1);
}

void build(){
  static int l[30];
  for(int i = 1;i<=n;i++){
    for(int c = 0;c<26;c++) last[i][c] = l[c];
    l[s[i]-'a'] = i; 
  }
}

void solve(){
  h[0] = 0x3f3f3f3f;
  for(int i = 1;i<=n;i++){
    for(int j = 1;j<=m;j++){
      if(s[i] == t[j]){
        f[i][j] = (j == 1?i:f[i-1][j-1]);
        if(j == m) h[i] = (i - f[i][m] + 1 - m);
      }
      else{
        f[i][j] = f[i-1][j];
        if(j == m) h[i] = h[i-1];
      }

      if(f[i][j] == f[i-1][j]) h[i] = min(h[i],h[i-1]);
    } 
  }
  static int minl[MAXN],ans[MAXN],maxn = 0;
  memset(minl,0x3f,sizeof(minl));
  for(int j = 1;j<=n;j++){
    for(int i = 1;i<=n;i++){
      if(f[i][m]){
        g[i][j] = (j == 1?f[i][m]:g[f[i][m]-1][j-1]);
        p[i][j] = (j == 1?h[i]   :p[f[i][m]-1][j-1] + h[i]);
      }
      else{
        g[i][j] = g[i-1][j];
        p[i][j] = p[i-1][j];
      }
      if(g[i-1][j]) p[i][j] = min(p[i][j],p[i-1][j]);
      if(g[i][j]){
        minl[j] = min(minl[j],p[i][j]);
        maxn = max(maxn,j);
        if(p[i][j] == 0) ans[0] = max(ans[0],j);
      }
    }
  }
  minl[0] = 1,minl[n+1] = 0x3f3f3f3f;
  for(int i = 1;i<=n;i++){
    for(int x = minl[i-1];x <= min(minl[i]-1,n);x++) ans[x] = i-1;
  }
  for(int i = n;i>=1;--i){
    if((n-i+1) > maxn * (m)+1) break;
    ans[i] = ((i + m > n)?0:ans[i+m]+1);
  }
  for(int i = 0;i<=n;i++) printf("%d ",ans[i]);
  printf("\n");
}

int main(){
  init();
  build();
  solve();
  return 0;
}
```

