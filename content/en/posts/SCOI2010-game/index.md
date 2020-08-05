---
title: 「SCOI2010」连续攻击游戏-二分图匹配
urlname: SCOI2010-game
date: 2018-04-27 18:48:55
tags:
- 图论
- 二分图匹配
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

`lxhgww` 最近迷上了一款游戏，在游戏里，他拥有 $n$ 个装备（ $n \le 1000000$ ），每种装备都有 $2$ 个属性，这些属性的值用 $[1,10000]$ 之间的数表示。当他使用某种装备时，他只能使用该装备的某一个属性。并且每种装备最多只能使用一次。

游戏进行到最后， `lxhgww` 遇到了终极 `boss` ，这个终极 `boss` 很奇怪，攻击他的装备所使用的属性值必须从 $1$ 开始连续递增地攻击，才能对 `boss` 产生伤害。现在`lxhgww`想知道他最多能连续攻击 `boss` 多少次？

<!--more-->

## 链接

[Luogu P1640](https://www.luogu.org/problemnew/show/P1640)


## 题解

upd on 2019.4.5 这是个假做法。

可以看出，这个东西可以转换成二分图的模版。左边的 $10000$ 个点代表属性值，右边的 $n$ 个点代表装备。

从属性值 $1$ 开始跑匈牙利的 $dfs$ ，如果能增广，就接着往下。不能的话，输出答案返回。复杂度不太会算...不过可以过的。

值得一提的是，网络流虽然我每次直接在残量网络上增广...但仍然慢的要死...$40$分TLE再也优化不了了...


## 代码


```cpp
#include <cstdio>
#include <cstring>
#include <cctype>
using namespace std;

const int MAXN = 2000000,MAXM = 5000000;

namespace fast_io {
    //...
}using namespace fast_io;


struct Edge{
    int from,to;
    int nex;
}edge[MAXM];
int fir[MAXN],ecnt = 1;
void addedge(int a,int b){
    edge[ecnt] = (Edge){a,b,fir[a]};
    fir[a] = ecnt++;
}
int n,a,b;
int pre[1100000],vis[11000];

void init(){
    read(n);
    for(int i = 1;i<=n;i++){
        read(a),read(b);
        addedge(a,100000+i),addedge(b,100000+i);	
    }
}

bool dfs(int nown){
    if(vis[nown]) return 0;
    vis[nown] = 1;
    for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
        int v = edge[nowe].to;
        if(!pre[v] || dfs(pre[v])){
            pre[v] = nown;
            return 1;
        }
    }
    return 0;
}

void solve(){
    int ans = 0;
    for(int i = 1;i<=10000;i++){
        memset(vis,0,sizeof(vis));
        if(dfs(i)) ans++;
        else break;
    }
    print(ans);
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```

