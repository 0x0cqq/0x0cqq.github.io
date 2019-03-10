---
title: 「SDOI2009」HH去散步-矩阵快速幂+dp
urlname: SDOI2009-walk
date: 2018-08-09 10:41:45
tags:
- 矩阵快速幂
- 动态规划
- 题解
- 图论
categories: OI
visible:
---

`HH`又是个喜欢变化的人，所以他不会立刻沿着刚刚走来的路走回。 又因为`HH`是个喜欢变化的人，所以他每天走过的路径都不完全一样，他想知道他究竟有多少种散步的方法。

现在给你学校的地图（假设每条路的长度都是一样的都是$1$），问长度为$t$，从给定地点$A$走到给定地点$B$共有多少条符合上述条件的路径。

<!-- more -->

## 链接

[Luogu P2151](https://www.luogu.org/problemnew/show/P2151)


## 题解

可以发现这是一道dp。

如果令状态为$dp[i][t]$，在第$i$个点，再走t步到达B点的方案数。但是我们注意到这个就很难满足：

> 他不会立刻沿着刚刚走来的路走回

的限制条件。

- - -

所以我们为了体现出刚走过的边，同时还能体现出刚走过的点，就重新设计一下状态：

令$dp[e][t]$为刚刚走过第$e$条边，再走$t$步到达$B$点的方案数。

具体实现的时候要建两条单向边，然后状态转移方程大概是：

$$
dp[e][t] = \sum dp[e'][t-1]
$$

其中$e'$为所有从$e.to$出发的边，除了$e$的反向边。

注意到这里$t$的范围比较大，对于任意时候的$t$和某个$e$，转移的路径，也就是$e'$都不会变，所以我们用矩阵快速幂优化这一过程。

这里的模数要用`define`样式的比较好，对于常数比较有利。


时间复杂度：$O((2m)^3 \times \log{t})$

## 代码



```cpp
#include <cstdio>
#include <cstring>
#include <vector>
using namespace std;
const int MAXN = 200;
typedef long long ll;
#define mod 45989

int n,m,t,A,B;
struct Edge{
    int to,nex;
}edge[MAXN];
int fir[MAXN],ecnt = 2;

inline void addedge(int u,int v){
    edge[ecnt] = (Edge){v,fir[u]};
    fir[u] = ecnt++;
}

struct Matrix{
    ll a[MAXN][MAXN];
    Matrix(){
        memset(a,0,sizeof(a));
    }
};

inline Matrix mul(const Matrix &_a,const Matrix &_b){
    Matrix tmp;
    for(int i = 1;i<=2*m;i++){
        for(int j = 1;j<=2*m;j++){
            for(int k = 1;k<=2*m;k++){
                tmp.a[i][j] += _a.a[i][k] * _b.a[k][j]; 
            }
            if(tmp.a[i][j] >= mod) tmp.a[i][j] %= mod;
        }
    }
    return tmp;
}

inline Matrix pow(Matrix x,int k){
    Matrix ans;
    for(int i = 1;i<=2*m;i++) ans.a[i][i] = 1;
    for(int i = k;i;i>>=1,x = mul(x,x)){
        if(i&1) ans = mul(ans,x);
    }
    return ans;
}

inline void init(){
    scanf("%d %d %d %d %d",&n,&m,&t,&A,&B);
    A++,B++; 
    int u,v;
    for(int i = 1;i<=m;i++){
        scanf("%d %d",&u,&v);
        u++,v++;
        addedge(u,v);
        addedge(v,u);
    }
    m++;
    edge[2*m] = (Edge){A,fir[0]};
    fir[0] = 1;
}

void solve(){
    Matrix M,I;
    for(int e = 2;e<=2*m;e++){
        int x = edge[e].to;
        if(x == B) I.a[e][1] = 1;
        for(int nowe = fir[x];nowe;nowe = edge[nowe].nex){
            if((e^1)==nowe) continue;
            M.a[e][nowe] = 1;
        }
    }
    M = pow(M,t);
    static ll ans[MAXN];
    for(int i = 1;i<=2*m;i++){
        for(int j = 1;j<=2*m;j++){
            ans[i] += M.a[i][j] * I.a[j][1];
        }
    }
    printf("%lld\n",ans[2*m] % mod);
}


int main(){
    init();
    solve();
    return 0;
}
```


