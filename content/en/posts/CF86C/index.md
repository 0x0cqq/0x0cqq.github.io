---
title: 「CF86C」Genetic engineering-AC自动机+dp
urlname: CF86C
date: 2019-01-09 19:18:07
tags:
- 字符串
- 动态规划
- AC自动机
categories: 
- OI
- 题解
series:
- Codeforces
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

我们定义一个 DNA 序列为仅有 `ATCG` 四个字母的字符串。

给出 $m(1 \le m \le 10)$ 个 DNA 序列模式串 $s_i$，每个长度均不超过 $10$ ，我们定义一个 DNA 序列 $w$ 是好的，当且仅当对于 $w$ 的每一个位置 $i$ ，都存在至少一个模式串 $s_j$ ， 使得 $w[l...r] = s_j$（ $w[l...r]$ 表示一个原字符串的一个子串） ， 其中 $1 \le l \le i \le r \le |w|$（ $|w|$ 为 DNA序列 $w$ 的长度） 。

请你计算出所有长度为 $n(1 \le n \le 1000)$ 的好的 DNA 序列的个数。

<!--more-->

答案对 $1000000009(10^9+9)$ 取模。

## 链接

[Codeforces](https://codeforces.com/problemset/problem/83/D)

## 题解

我们对所有模式串建立 AC 自动机，获取 fail 指针，同时计算 fail 链上的最长的结束字符串的长度 $l[x]$ ，补全 Trie 图。

设状态如 $dp[\text{len}][\text{nownode}][\text{nowleft}]$ ，其中 $\text{len}$ 表示还剩余的位数，$\text{nownode}$ 表示当前在 AC 自动机的哪个点，$\text{nowleft}$ 表示当前未匹配的后缀长度还有多少。

我们每次枚举下一位填什么。如果我们发现到达的位置可以存在一个覆盖 $\text{nowleft}$ 的模式串，我们就更新一下 $\text{nowleft} = 0$ ，否则 $\text{nowleft}$ 加 $1$ 即可。

如果进行到某个状态，剩下的的后缀大于你最大的字符串的长度，就可以直接返回 $0$ 了。

时间复杂度 $O(n m \cdot \text{maxlen}^2)$ 。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;
const int MAXN = 1005,mod = 1e9+9;

namespace AC{
  int c[MAXN][5],len[MAXN],maxlen[MAXN],fail[MAXN],cnt,rt;
  void ins(char *s){
    int n = strlen(s);
    int now = rt;
    for(int i = 0;i<n;i++){
      int a = s[i] - 'a';
      if(!c[now][a]) c[now][a] = ++cnt;
      now = c[now][a];
    }
    len[now] = max(len[now],n);
  }
  void getfail(){
    queue<int> q;
    for(int i = 0;i<4;i++){
      if(c[rt][i] != 0){
        fail[c[rt][i]] = rt;
        q.push(c[rt][i]);
      }
    }
    while(!q.empty()){
      int nown = q.front();q.pop();
      for(int i = 0;i<4;i++){
        int &v = c[nown][i];
        if(v == 0){
          v = c[fail[nown]][i];
        }
        else{
          fail[v] = c[fail[nown]][i];
          len[v] = max(len[v],len[fail[v]]);
          q.push(v);
        }
      }
    }
  }
}

int n,m;
int dp[MAXN][105][12];
char s[MAXN];


int dfs(int len,int nownode,int nowleft){
  if(nowleft > 10) return 0;
  if(dp[len][nownode][nowleft] != -1){
    return dp[len][nownode][nowleft];
  }
  if(len == 0 && nowleft == 0) return 1;
  else if(len == 0) return 0;
  int ans = 0;
  for(int i = 0;i<4;i++){
    int v = AC::c[nownode][i];
    ans += dfs(len-1,v,(AC::len[v] >= nowleft+1)?0:nowleft+1);
    ans %= mod;
  }
  return dp[len][nownode][nowleft] = ans;
}

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=m;i++){
    scanf("%s",s);
    int t = strlen(s);
    for(int i = 0;i<t;i++){
      if(s[i] == 'A'){s[i] = 'a';}
      else if(s[i] == 'C'){s[i] = 'b';}
      else if(s[i] == 'T'){s[i] = 'c';}
      else if(s[i] == 'G'){s[i] = 'd';}
      else{printf("-1\n");}
    }
    AC::ins(s);
  }
}

void solve(){
  AC::getfail();
  memset(dp,-1,sizeof(dp));
  printf("%d\n",dfs(n,0,0));
}

int main(){
  init();
  solve();
  return 0;
}
```

