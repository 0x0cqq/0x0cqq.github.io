---
title: 「HNOI2004」L语言-AC自动机
urlname: HNOI2004-language
date: 2018-09-09 20:11:35
tags:
- 题解
- 字符串
- AC自动机
categories: OI
visible:

---

一段文章 $T$ 是由若干小写字母构成。一个单词 $W$ 也是由若干小写字母构成。一个字典 $D$ 是若干个单词的集合。我们称一段文章 $T$ 在某个字典 $D$ 下是可以被理解的，是指如果文章 $T$ 可以被分成若干部分，且每一个部分都是字典 $D$ 中的单词。

给定一个字典 $D$ ，你的程序需要判断若干段文章在字典 $D$ 下是否能够被理解。并给出其在字典 $D$ 下能够被理解的最长前缀的位置。

<!-- more -->

## 链接

[Luogu P2292](https://www.luogu.org/problemnew/show/P2292)

## 题解

可以想到一个简单的 $\text{dp}$  ，用 $dp[i]$ 表示以 $i$ 为结尾的后缀能否被理解：
$$
dp[i] = \max(dp[i-\text{len}_j]) ,\text{if} \; \text{str}_j \text{在 i 位置上出现}
$$
然后用模版串 $\text{AC}$ 自动机跑一遍母串，得到每个模版串在母串中出现的位置，然后刷表 $dp$ 即可。

注意往回不能暴力跳 $fail$ ，一个简单的优化是记录最近的 $\text{end}$ 节点 $g_i$ ，然后每次都按照 $g_i$ 跳，统计出现位置即可。

时间复杂度 $O(n \times \text{玄学})$ 。

## 代码



```cpp
#include <cstdio>
#include <cstring>
#include <queue>
using namespace std;

const int MAXN = 1000,sigma_size = 26;

vector<int> pos[MAXN];

namespace AC{
  int c[MAXN][sigma_size],fail[MAXN],g[MAXN];
  int end[MAXN];
  int root,cnt,wcnt;
  void insert(char *s){
    int n = strlen(s),nown = root;
    for(int i = 0;i<n;i++){
      if(c[nown][s[i]-'a'] == 0){
        c[nown][s[i]-'a'] = ++cnt;
      }
      nown = c[nown][s[i]-'a'];
    }
    end[nown] = ++wcnt;
  }
  void build(){
    queue<int> q;
    for(int i = 0;i<sigma_size;i++){
      if(c[root][i]){
        fail[c[root][i]] = root;
        q.push(c[root][i]);
      }
    }
    while(!q.empty()){
      int nown = q.front();q.pop();
      for(int i = 0;i<sigma_size;i++){
        g[nown] = end[fail[nown]]?fail[nown]:g[fail[nown]];
        if(c[nown][i] == 0){
          c[nown][i] = c[fail[nown]][i];
        }
        else{
          fail[c[nown][i]] = c[fail[nown]][i];
          q.push(c[nown][i]);
        }
      }
    }
  }
  void query(char *s){
    for(int i = 1;i<=20;i++){
      pos[i].clear();
    }
    int n = strlen(s),nown = root;
    for(int i = 0;i<n;i++){
      nown = c[nown][s[i] - 'a'];
      for(int t = nown;t;t = g[t]){
        if(end[t]){
          pos[end[t]].push_back(i);
        }
      }
    }
  }
}

int n,m;
int now[MAXN],l[MAXN];
char s[1100000];
bool dp[1100000];

int cal(char *s){
  memset(now,0,sizeof(now));
  memset(dp,0,sizeof(dp));//dp -> len
  int len = strlen(s),ans = 0;
  AC::query(s);
  dp[0] = 1;
  for(int i = 1;i<=len;i++){
    for(int j = 1;j <= n;j++){
      if(now[j] != pos[j].size() && pos[j][now[j]] == (i-1)){
        dp[i] |= dp[i-l[j]];
        now[j] ++;
      }
      if(dp[i] == 1){
        ans = max(ans,i);
        continue;
      }
    }
  }
  return ans;
}

void init(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++){
    scanf("%s",s);
    l[i] = strlen(s);
    AC::insert(s);
  }
  AC::build();
}

void solve(){
  for(int i = 1;i<=m;i++){
    scanf("%s",s);
    printf("%d\n",cal(s));
  }
}


int main(){
  init();
  solve();
  return 0;
}
```




