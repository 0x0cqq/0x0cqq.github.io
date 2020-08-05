---
title: 「POI2000」病毒-AC自动机
urlname: POI2000-virus
date: 2018-08-09 11:03:59
tags:
- AC自动机
- 字符串
- 图论
categories: 
- OI
- 题解
series:
- 各国OI
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---


二进制病毒审查委员会最近发现了如下的规律：某些确定的二进制串是病毒的代码。如果某段代码中不存在任何一段病毒代码，那么我们就称这段代码是安全的。现在委员会已经找出了所有的病毒代码段，试问，是否存在一个无限长的安全的二进制代码。

<!--more-->

## 链接

[Luogu P2444](https://www.luogu.org/problemnew/show/P2444)

## 题解

对所有的模版串建立 `AC` 自动机，补全 `Trie` 图，在 `Trie` 图上找环。

注意这里不能到达单词结束的节点，也不能到达所有 `fail` 节点是单词结束的点。

## 代码



```cpp
#include <cstdio>
#include <cstring>
#include <queue>
using namespace std;

const int MAXN = 1001000;

template <int sigma_size>
struct AC_automaton{
    bool vis[MAXN],flag;
    bool instack[MAXN];
    int f[MAXN],c[MAXN][sigma_size],end[MAXN];
    int root,cnt;
    AC_automaton(){root=cnt=0;}
    void clear(){}
    //qwq
    void insert(char *str){
        int n = strlen(str),nown = root;
        for(int i = 0;i<n;i++){
            if(!c[nown][str[i]-'0'])
                c[nown][str[i]-'0'] = ++cnt;
            nown = c[nown][str[i]-'0'];
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
    bool judge(){
        memset(vis,0,sizeof(vis));
        memset(instack,0,sizeof(instack));
        flag = 0;
        for(int i = 0;i<=cnt;i++){
            if(!vis[i] && !end[i]) flag |= dfs(i);
            if(flag) return true;
        }
        return false;
    }
    bool dfs(int x){
        instack[x] = vis[x] = 1;
        for(int i = 0;i<sigma_size;i++){
            int v = c[x][i];
            if(end[v]) continue;
            if(instack[v] || (!vis[v] && dfs(v))) 
                return true;
        }
        instack[x] = 0;
        return false;
    }
};

AC_automaton<2> AC;

int n;
char s[MAXN];

void init(){
    scanf("%d",&n);
    for(int i = 1;i<=n;i++){
        scanf("%s",s);
        AC.insert(s);
    }
}

void solve(){
    AC.get_fail();
    if(AC.judge()){
        printf("TAK\n");
    }
    else{
        printf("NIE\n");
    }
}

int main(){
    init();
    solve();
    return 0;
}
```

