---
title: 「CF990G」GCD Counting-并查集/点分治
urlname: CF990G-GCD-Counting
date: 2018-07-17 19:48:45
tags:
- 题解
- 并查集
- 点分治
categories: OI
visible:
---

给定一个$n$个节点的树，每个点有一个正整数权值$a_i$。我们定义$g(x,y)$为$x,y$之间简单路径上所有点（包括端点）的权值的最大公约数。
现在请求出对于所有的$i∈[1,2×10^5]$，满足$1≤x≤y≤n$且$g(x,y)= i$的点对$(x,y)$的数目。

<!-- more -->

## 链接

[Codeforces 990G](http://codeforces.com/problemset/problem/990/G)

## 题解

一个结论：一个数的约数个数不会很多。
在$100000000$之内，约数最多的数是$73513440$，有$768$个因子。这大约不是$log$级别的？令它是一个$O(d(n))$级别的吧。

### Solution A:
容斥原理：
所有以$q$为最大公约数的点对的数目等于所有以$q$为公约数的点对数目减去以$2q,3q,...,kq$为最大公约数的点对数目。

所以我们采用逆序计算以$q$为公约数的点对数目，就可以推出以q$$为最大公约数的点对数目。

考虑怎么计算这个问题。如果两个点对的公约数是$q$，那么他们路径上的所有边两端连的点的$gcd$都是$q$或者$q$的倍数，经过的点的权值也一定是$q$或者$q$的倍数。因为权值不大，我们用权值记录点，用$gcd$记录边。考虑到如果把所有的$gcd$为$q$或者$q$的倍数的边全都连起来，这样图里所有联通的点都是满足条件的。所以我们只需要连边，然后维护点对数目。

我们维护一个并查集。记录集合大小。每次先将上述的点初始化，然后把边连上。用一个cnt维护所有联通点对数目，注意一个点也算点对。然后联通集合的时候加上从这端到那端的所有点对就可以了。

来分析一下复杂度。这里的复杂度主要集中在：并查集的初始化（满足条件的点）和并查集的合并（满足条件的边），每个操作都是$O(1)$的，我们考虑一下它会被执行多少次。发现每个点都会被权值的因数初始化一次，所以这个是$O(nd(n))$的。对于边的话也是一样，所以复杂度大约是$O(n d(n))$的。

如果$d(n)$不是很大，那么这个东西过掉问题不大。

### Solution B:

树上点对的问题让我们想到了点分治。

考虑点分治的过程，我们要计算过当前根点的所有点对的gcd及其数量。根节点的约数个数是O(d)的，那么我们所有数与根节点的$gcd$最多也只能是$O(d)$种。
先枚举根节点的所有约数，复杂度是$O(d)$。

对于每个子树我们可以用$O(n)$的时间完成dfs、去重。然后我们有$O(d^2)$的时间完成对所有前面的和现在这个子树的gcd的一一枚举，然后在将这个子树添加到前面去。

然后这个点分治的过程应该是$O(d n log n)$的?复杂度比较迷。

不过能过，跑的很快。

## 代码


```cpp
#include <bits/stdc++.h>
using namespace std;
typedef long long ll;
const int MAXN = 300000;

int gcd(int x,int y){
    return y == 0?x:gcd(y,x%y);
}

namespace BCJ{
    int f[MAXN],siz[MAXN];
    int find(int x){
        return f[x] == x?x:f[x] = find(f[x]);
    }
    void un(int x,int y,ll &cur){
        int fx = find(x),fy = find(y);
        if(fx == fy) return;
        cur -= 1LL*siz[fx]*(siz[fx]+1)/2;
        cur -= 1LL*siz[fy]*(siz[fy]+1)/2;
        f[fy] = fx,siz[fx] += siz[fy];
        cur += 1LL*siz[fx]*(siz[fx]+1)/2;
    }
}

struct Edge{
    int u,v;
}edge[MAXN];

vector<int> V[MAXN];
vector<int> E[MAXN];

int n,a[MAXN];

void init(){
    scanf("%d",&n);
    for(int i = 1;i<=n;i++){
        scanf("%d",&a[i]);
        V[a[i]].push_back(i);
    }
    for(int i = 1;i<=n-1;i++){
        scanf("%d %d",&edge[i].u,&edge[i].v);
        E[gcd(a[edge[i].u],a[edge[i].v])].push_back(i);
    }
}

void solve(){
    int maxn = 200000;
    static ll res[MAXN],cur = 0;
    for(int i = maxn;i>=1;--i){
        cur = 0;
        for(int j = i;j<=maxn;j+=i){
            for(int k = 0;k<V[j].size();k++){
                int t = V[j][k];
                BCJ::siz[t] = 1,BCJ::f[t] = t;
                cur++;
            }
            if(j > i)
                res[i] -= res[j];
        }
        for(int j = i;j<=maxn;j+=i)
            for(int k = 0;k<E[j].size();k++)
                BCJ::un(edge[E[j][k]].u,edge[E[j][k]].v,cur);
        res[i] += cur;
    }
    for(int i = 1;i<=maxn;i++){
        if(res[i])
            printf("%d %lld\n",i,res[i]);
    }
}

int main(){
    init();
    solve();
    return 0;
}
```

- - -


```cpp
// 非本人创作
#include<bits/stdc++.h>
#define gcd(a,b) __gcd(a,b)
using namespace std;const int N=2e5+7;typedef long long ll;
struct data{int to,next;}e[N<<1];int n,m,i,j,cnt,a[N],d[N],vis[N],head[N],f[N],q[N],qq[N],u,v,root,sum,num[N],Tnum[N],size[N],fr[N],T,tt,tot;ll ans[N];
void ins(int u,int v){e[++cnt].to=v;e[cnt].next=head[u];head[u]=cnt;}
void insert(int u,int v){ins(u,v);ins(v,u);}
void getroot(int x,int fa){
    size[x]=1;f[x]=0;
    for(int i=head[x];i;i=e[i].next)if(e[i].to!=fa&&!vis[e[i].to])
        getroot(e[i].to,x),size[x]+=size[e[i].to],f[x]=max(f[x],size[e[i].to]);
    f[x]=max(f[x],sum-size[x]);
    if(f[x]<f[root])root=x;
}
void getdis(int x,int fa){
    q[++tt]=d[x];
    for(int i=head[x];i;i=e[i].next)if(!vis[e[i].to]&&e[i].to!=fa)d[e[i].to]=gcd(d[x],a[e[i].to]),getdis(e[i].to,x);
}
void work(int x){
    vis[x]=1;T=0;
    for(int i=head[x],j,k;i;i=e[i].next)if(!vis[e[i].to]){
        tot=tt=0;d[e[i].to]=gcd(a[x],a[e[i].to]);getdis(e[i].to,0);
        for(sort(q+1,q+tt+1),j=1;j<=tt;++j)if(q[j]==q[j-1])num[tot]++;else q[++tot]=q[j],num[tot]=1;
        for(j=1;j<=tot;++j)for(k=1;k<=T;++k)ans[gcd(q[j],qq[k])]+=1ll*num[j]*Tnum[k];
        for(j=1;j<=tot;++j)ans[q[j]]+=num[j];
        for(j=1;j<=tot;++j)if(!fr[q[j]])qq[++T]=q[j],Tnum[T]=num[j],fr[q[j]]=T;
        else Tnum[fr[q[j]]]+=num[j];
    }ans[a[x]]++;for(int i=1;i<=T;++i)fr[qq[i]]=0;
    for(int i=head[x];i;i=e[i].next)if(!vis[e[i].to])
        root=0,sum=size[e[i].to],getroot(e[i].to,x),work(root);
}
int main(){
    for(scanf("%d",&n),i=1;i<=n;++i)scanf("%d",a+i);for(i=1;i<n;++i)scanf("%d%d",&u,&v),insert(u,v);
    f[0]=N;sum=n;root=0;getroot(1,0);work(root);
    for(i=1;i<N;++i)if(ans[i])printf("%d %lld\n",i,ans[i]);
}
```

