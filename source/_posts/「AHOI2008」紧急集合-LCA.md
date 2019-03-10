---
title: 「AHOI2008」紧急集合-LCA
urlname: AHOI2008-emergency
date: 2018-03-23 22:19:33
tags: 
- 最近公共祖先
- 图论
- 题解
categories: OI
visible:
---

给出一颗$n$个节点的无权树，$m$次询问，每次给出三个点编号为$a$，$b$，$c$，询问到这三个点距离最小的点的编号以及其距离和。

<!-- more -->

## 链接

[Luogu P4281](https://www.luogu.org/problemnew/show/P4281)

## 题解


首先，如果每次询问都只有两个点，这个问题就很简单，只要是树上的路径上的点就可以，寻找树上的路径其实就是寻找$LCA$的过程。这可以启发我们对于三个点的情况的思考。

如果这里有三个点，我们来认真的思考一下。经过上一问的启发，我们来思考一下能不能运用$LCA$来解决这道题。

我们可以发现，树上三个点的三对$LCA$一定有两个是相同的。这是一件想想的话比较显然的事情。必然能够找到某个节点，让三个点中的两个在一侧，一个在另一侧。而这个点就是两个公共的$LCA$。思考的再深入些（并且结合瞎蒙），我们会发现这个相同的$LCA$肯定是深度最小的一个$LCA$。

这里，我们首先可以显而易见的发现，这个点必须在三个点互相通达的路径上。

我们再思考一下$LCA$与路径和的关系。假设我们知道$a$和$b$的$LCA$是$x$，而且$x$是上述的3个$LCA$中深度最大的那个，那么可以发现从$x$到$a$的距离加上从$x$到$b$的距离一定是最小的。根据上面的结论，我们知道$a$，$c$和$b$，$c$的$LCA$点$y$一定在一个点上，而且这个$y$一定比$x$深度小。

那么这个时候，我们会发现此时$a$，$b$，$c$到$x$的距离和是最小的。证明的话可以这么想：如果$x'$比$x$高，那么虽然$c$到$x$的距离减小了$w$，但是$a$，$b$到$x'$的距离均增大了$w$，显然距离和增大。如果$x'$比$x$低，有一个节点到$x'$的距离减小了$w$，剩下两个节点到$x'$的距离均增大了$w$，显然距离和也增大。

所以我们就找到了到三个点距离和最小的点：这三个点的三对$LCA$中，深度大的那两个LCA就是答案。

我们在求$LCA$之前，可以先预处理出深度$dep$，那么从节点$u$到$v$的路径长度就是$dis = dep[u] + dep[v] - 2*dep[lca(u,v)]$。运用这个式子分别算出$a$,$b$,$c$到$a1$,$b1$,$c1$（三个$LCA$）的距离，最后发现总的$dis$居然是轮换式：$ans = dep[a]+dep[b]+dep[c]-dep[a1]-dep[b1]-dep[c1]$， 所以就不用分类讨论了。

$LCA$ 我用了树链剖分来求，顺带处理深度。

## 代码


```cpp
#include <cstdio>
#include <cctype>
#include <vector>
using namespace std;

namespace fast_io {
    inline char read() {
        static const int IN_LEN = 1000000;
        static char buf[IN_LEN], *s, *t;
        return s==t?(((t=(s=buf)+fread(buf,1,IN_LEN,stdin))== s)?-1:*s++) : *s++;
    }
    inline void read(int &x) {
        static bool iosig;
        static char c;
        for (iosig = false, c = read(); !isdigit(c); c = read()) {
            if (c == '-') iosig = true;
            if (c == -1) return;
        }
        for (x = 0; isdigit(c); c = read())
            x = ((x+(x<<2))<<1) + (c ^ '0');
        if (iosig) x = -x;
    }
    const int OUT_LEN = 1000000;char obuf[OUT_LEN], *ooh = obuf;
    inline void print(char c) {
        if (ooh == obuf + OUT_LEN) fwrite(obuf, 1, OUT_LEN, stdout), ooh = obuf;
        *ooh++ = c;
    }
    inline void print(int x) {
        static int buf[30], cnt;
        if (x == 0) 
            print('0');
        else {
            if (x < 0) print('-'), x = -x;
            for (cnt = 0; x; x /= 10) buf[++cnt] = x % 10 + 48;
            while (cnt) print((char)buf[cnt--]);
        }
    }
    inline void flush() {
        fwrite(obuf, 1, ooh - obuf, stdout);
    }
}using namespace fast_io;

const int MAXN = 510000;

vector<int> edge[MAXN];

int n,m;
int dep[MAXN],siz[MAXN],fa[MAXN],son[MAXN],top[MAXN],id[MAXN],cnt = 1;


//添加从a到b的无向边
void addedge(int a,int b){
    edge[a].push_back(b);
    edge[b].push_back(a);
}

//树链剖分的第一个dfs
void dfs1(int nown,int f,int depth){
    siz[nown] = 1,fa[nown] = f,dep[nown] = depth;
    int maxsum = -1;son[nown] = 0;
    for(int i = 0;i<edge[nown].size();i++){
        int to = edge[nown][i];
        if(to == f) continue;
        dfs1(to,nown,depth+1);
        if(siz[to] > maxsum) maxsum = siz[to],son[nown] = to;
        siz[nown] += siz[to];
    }
}

//树链剖分的第二个dfs
void dfs2(int nown,int topf){
    id[nown] = cnt++;top[nown] = topf;
    if(son[nown] == 0) return;
    dfs2(son[nown],topf);
    for(int i = 0;i<edge[nown].size();i++){
        int to = edge[nown][i];
        if(to == fa[nown]|| to == son[nown]) continue;
        dfs2(to,to);
    }
}

//求a,b两点的LCA
int lca(int a,int b){
    while(top[a]!=top[b]){
        if(dep[top[a]] < dep[top[b]]) swap(a,b);
        a = fa[top[a]];
    }
    if(dep[a] < dep[b]) swap(a,b);
    return b;
}

//初始化以及dfs
void init(){
    read(n),read(m);
    int a,b;
    for(int i = 1;i<=n-1;i++){
        read(a),read(b);
        addedge(a,b);
    }
    dfs1(1,0,1);
    dfs2(1,1);
}

//回应询问
void solve(){
    int a,b,c,a1,b1,c1,ans,dis;
    for(int i = 1;i<=m;i++){
        read(a),read(b),read(c);
        //a1,b1,c1的意义见下
        a1 = lca(a,b),b1 = lca(b,c),c1 = lca(c,a);
        dis = 0;
        if(a1 == b1) 
            ans = c1;
        else if(b1 == c1)
            ans = a1;
        else if(c1 == a1)
            ans = b1;
        //计算dis的公式
        dis = dep[a] + dep[b] + dep[c] - dep[a1] - dep[b1] - dep[c1];
        print(ans),print(' '),print(dis),print('\n');
    }
}

int main(){
    init();
    solve();
    flush();
    return 0;
}
```


