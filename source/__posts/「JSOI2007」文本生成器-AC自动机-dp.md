---
title: 「JSOI2007」文本生成器-AC自动机+dp
urlname: JSOI2007-generator
date: 2018-08-11 19:27:37
tags:
- 题解
- 字符串
- AC自动机
- 动态规划
categories: OI
visible:
---

可读版题意：

给定$n$个仅包含大写字母的模板串，求所有的长度为$M$且仅包含大写字母的不同字符串中，有多少个包含至少一个模板串。答案对$10007$取模。

<!-- more -->
- - -
原题意：

$JSOI$交给队员$ZYX$一个任务，编制一个称之为“文本生成器”的电脑软件：该软件的使用者是一些低幼人群，他们现在使用的是$GW$文本生成器$v6$版。

该软件可以随机生成一些文章――总是生成一篇长度固定且完全随机的文章，也就是说，生成的文章中每个字节都是完全随机的。如果一篇文章中至少包含使用者们了解的一个单词，那么我们说这篇文章是可读的（我们称文章$a$包含单词$b$，当且仅当单词$b$是文章$a$的子串）。但是，即使按照这样的标准，使用者现在使用的$GW$文本生成器$v6$版所生成的文章也是几乎完全不可读的。$ZYX$需要指出$GW$文本生成器 $v6$ 生成的所有文本中可读文本的数量，以便能够成功获得 $v7$ 更新版。你能帮助吗？

## 链接

[Luogu P4052](https://www.luogu.org/problemnew/show/P4052)

## 题解

正难则反。不如我们考虑所有长度为$M$的字符串，一个模版串都不出现的情况数。

神似`GT考试`啊，只不过模版从一个变成了多个，那么我们就用$AC$自动机代替KMP。

状态：$dp[i][j]$表示在$AC$自动机的第$i$个节点上，还有$j$位的符合条件的子串数量。

先建立$AC$自动机，补全$Trie$图。

然后将所有不是$end$节点且$fail$指针一路指向的没有$end$节点的点的$dp[i][0]$ 设为$1$。

然后将26种情况转移即可。注意这里也不要转移上面的$dp[i][0] = 0$的节点，来方便我们的处理，不用特判。

最后答案是$dp[root][M]$。

这里比较有趣，我想了想能不能用矩阵快速幂。但是，这个地方的转移矩阵最大有可能到$10000\times 10000$，会凉凉233。


## 代码

{% fold %}
```cpp
#include <cstdio>
#include <cstring>
#include <queue>
#define ll long long
#define mod 10007
#define sigma_size 26
using namespace std;

const int MAXN = 7000,MAXM = 110;


struct AC_automaton{
    int c[MAXN][sigma_size],f[MAXN],end[MAXN];
    int root,cnt;
    AC_automaton(){
        root = cnt = 0;
    }
    void insert(char *str){
        int n = strlen(str),nown = root;
        for(int i = 0;i<n;i++){
            if(!c[nown][str[i]-'A']) 
                c[nown][str[i]-'A'] = ++cnt;
            nown = c[nown][str[i]-'A'];;
        }
        end[nown] |= 1;
    }
    void get_fail(){
        queue<int> q;
        while(!q.empty()) q.pop();
        for(int i = 0;i<sigma_size;i++){
            if(c[root][i]){
                f[c[root][i]] = root;
                q.push(c[root][i]);
            }
        }   
        while(!q.empty()){
            int nown = q.front();q.pop();
            for(int i = 0;i<sigma_size;i++){
                if(c[nown][i]){
                    f[c[nown][i]] = c[f[nown]][i];
                    end[c[nown][i]] |= end[f[c[nown][i]]];
                    q.push(c[nown][i]);
                }
                else c[nown][i] = c[f[nown]][i];
            }
        }
    }
};
AC_automaton AC;

int n,m;
char ch[MAXN];

void init(){
    scanf("%d %d",&n,&m);
    for(int i = 1;i<=n;i++){
        scanf("%s",ch);
        AC.insert(ch);
    }
    AC.get_fail();
}

void solve(){
    static ll dp[MAXN][MAXM];
    for(int i = 0;i<=AC.cnt;i++)
        if(!AC.end[i]) dp[i][0] = 1;
    for(int j = 1;j<=m;j++){
        for(int i = 0;i<=AC.cnt;i++){
            if(!AC.end[i]){
                for(int k = 0;k<sigma_size;k++)
                    dp[i][j] += dp[AC.c[i][k]][j-1];
                dp[i][j] %= mod;
            }
        }
    }
    int ans = 1;
    for(int i = 1;i<=m;i++){
        ans *= sigma_size;
        ans %= mod;
    }
    printf("%lld\n",(ans-dp[0][m]+mod)%mod);
}


int main(){
    init();
    solve();
    return 0;
}
```
{% endfold %}