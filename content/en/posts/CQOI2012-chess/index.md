---
title: 「CQOI2012」交换棋子-费用流
urlname: CQOI2012-chess
date: 2018-04-25 23:29:56
tags:
- 图论
- 费用流
categories: 
- OI
- 题解
visible:
series:
- 各省省选
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

有一个 $n$ 行 $m$ 列的黑白棋盘，你每次可以交换两个相邻格子（相邻是指有公共边或公共顶点）中的棋子，最终达到目标状态。要求第 $i$ 行第 $j$ 列的格子只能参与 $m _ {i,j}$ 次交换。

输出仅一行，为最小交换总次数。如果无解，输出 $-1$ 。

<!--more-->

## 链接

[Luogu P3159](https://www.luogu.org/problemnew/show/P3159)

## 题解

比较难以实现的是对交换次数的限制。注意到如果一个点是起点或者终点，那么它的交换次数应当是奇数，其余的都是偶数，而且是经过这个点的棋子数目的两倍。所以我们可以按照如下方法建图：

对于棋盘上的每个点，我们把它拆成三个点：$A _ {i,j},B _ {i,j},C _ {i,j}$ 。

对于一个既是起点也是终点的点或者既不是起点也不是终点的点，我们从 $A _ {i,j}$ 向 $C _ {i,j}$ 和 $C _ {i,j}$ 向 $B _ {i,j}$ 连一条容量是 $\lfloor \frac {m _ {i,j}}{2} \rfloor$ ，费用为 $0$ 的边。

对于一个只是起点的点，我们从起点 $S$ 向 $C _ {i,j}$ 连一条容量为 $1$ ，费用为 $0$ 的边。从 $A _ {i,j}$ 向 $C _ {i,j}$ 连一条容量是 $\lfloor \frac {m _ {i,j} \, -1}{2} \rfloor$ ，费用为 $0$ 的边。从 $C _ {i,j}$ 向 $B _ {i,j}$ 连一条容量是 $\lfloor \frac {m _ {i,j} \, -1}{2} +1 \rfloor$ ，费用为 $0$ 的边。

对于一个只是终点的点，我们反过来就可以了。

还需要从 $C _ {i,j}$ 向 $B _ {i,j-1},B _ {i-1,j+1}...$ ，也就是周围的八个点连一条容量是 $+\infty$ ,费用是 $1$ 的边。

显然这样可以保证个点的交换次数不超过 $m _ {i,j}$ 。然后我们求出起点 $S$ 到终点 $T$ 最小费用最大流，如果满流有解，不满流就无解。

## 代码



```cpp
#include <cstdio>
#include <queue>
#include <cstring>
#include <algorithm>
using namespace std;

const int MAXN = 5000,MAXM = 500000;

struct Edge{
    int from,to;
    int cap,flow;
    int cost,nex;
}edge[MAXM];

int n,m,s,t;
int fir[MAXN],ecnt = 2,maxf = 0;
int dis[MAXN],instack[MAXN],pree[MAXN];
int b[25][25],e[25][25],num[25][25];
queue<int> q;

int tr(int a,int b){
    if(a == 0 || b == 0 || a>n||b>m)
        return -1;
    return (a-1)*m+b;
}

void addedge(int a,int b,int c,int d){
    if(a <= 0 || b <= 0 || c == 0) return;
    edge[ecnt] = (Edge){a,b,c,0,d,fir[a]};
    fir[a] = ecnt++;
    edge[ecnt] = (Edge){b,a,0,0,-d,fir[b]};
    fir[b] = ecnt++;    
}

bool spfa(){
    memset(dis,0x3f,sizeof(dis));
    memset(instack,0,sizeof(instack));
    while(!q.empty()) q.pop();
    dis[s] = 0;q.push(s);
    while(!q.empty()){
        int nown = q.front();q.pop();
        instack[nown] = 0;
        for(int nowe = fir[nown];nowe;nowe = edge[nowe].nex){
            Edge e = edge[nowe];
            if(dis[e.to] > dis[nown] + e.cost && e.cap > e.flow){
                dis[e.to] = dis[nown] + e.cost;
                pree[e.to] = nowe;
                if(instack[e.to] == 0){
                    q.push(e.to);
                    instack[e.to] = 1;
                }
            }
        }
    }
    return dis[t] < 0x3f3f3f3f;
}

void argument(int &sumf,int &sumc){
    int nown = t,limit = 0x3f3f3f3f,nowe;
    while(nown!=s){
        nowe = pree[nown];
        limit = min(limit,edge[nowe].cap - edge[nowe].flow);
        nown = edge[nowe].from;
    }
    nown = t;
    while(nown!=s){
        nowe = pree[nown];
        edge[nowe].flow += limit,edge[nowe^1].flow -= limit;
        nown = edge[nowe].from;
    }
    sumf += limit,sumc += limit * dis[t];
}


void init(){
    scanf("%d %d",&n,&m);s = 1,t = 2;
    char tmp[50];
    for(int i = 1;i<=n;i++){
        scanf("%s",tmp);
        for(int j = 1;j<=m;j++)
            b[i][j] = tmp[j-1]^48;
    }
    for(int i = 1;i<=n;i++){
        scanf("%s",tmp);
        for(int j = 1;j<=m;j++)
            e[i][j] = tmp[j-1]^48;
    }
    for(int i = 1;i<=n;i++){
        scanf("%s",tmp);
        for(int j = 1;j<=m;j++)
            num[i][j] = tmp[j-1]^48;
    }
}

void build(){
    int bb = 0,ee = 0;
    for(int i = 1;i<=n;i++){
        for(int j = 1;j<=m;j++){
            int tmp = tr(i,j);
            if(b[i][j] && !e[i][j]){
                num[i][j]-=1;
                addedge(3*tmp+1,3*tmp+3,num[i][j]/2,0);
                addedge(3*tmp+3,3*tmp+2,num[i][j]/2+1,0);
                addedge(s,3*tmp+3,1,0);
                maxf = max(maxf,++bb);
            }
            else if(e[i][j] && !b[i][j]){
                num[i][j]-=1;
                addedge(3*tmp+1,3*tmp+3,num[i][j]/2+1,0);
                addedge(3*tmp+3,3*tmp+2,num[i][j]/2,0);
                addedge(3*tmp+3,t,1,0);
                maxf = max(maxf,++ee);
            }
            else{
                addedge(3*tmp+1,3*tmp+3,num[i][j]/2,0);
                addedge(3*tmp+3,3*tmp+2,num[i][j]/2,0); 
            } 
            addedge(3*tmp+2,3*tr(i-1,j-1)+1,100000,1);
            addedge(3*tmp+2,3*tr(i+1,j+1)+1,100000,1);
            addedge(3*tmp+2,3*tr(i+1,j-1)+1,100000,1);
            addedge(3*tmp+2,3*tr(i-1,j+1)+1,100000,1);        
            addedge(3*tmp+2,3*tr(i,j-1)+1,100000,1);
            addedge(3*tmp+2,3*tr(i,j+1)+1,100000,1);
            addedge(3*tmp+2,3*tr(i+1,j)+1,100000,1);
            addedge(3*tmp+2,3*tr(i-1,j)+1,100000,1);
        }
    }
}

void solve(){
    int f = 0,c = 0;
    while(spfa())
        argument(f,c);
    if(f!=maxf)
        printf("-1");
    else
        printf("%d\n",c);
}

int main(){
    init();
    build();
    solve();
    return 0;
}
```


