---
title: 「POI2010」Antisymmetry-后缀数组
urlname: POI2010-Antisymmetry
date: 2018-08-11 19:25:24
tags:
- 题解
- 字符串
- 后缀数组
categories: OI
visible:
---

对于一个 $0/1$ 字符串，如果将这个字符串 $0$ 和 $1$ 取反后，再将整个串反过来和原串一样，就称作“反对称”字符串。比如 $00001111$ 和 $010101$ 就是反对称的， $1001$ 就不是。

现在给出一个长度为 $n$ 的 $0/1$ 字符串，求它有多少个子串是反对称的。

<!-- more -->

## 链接

[LOJ 2452](https://loj.ac/problem/2452)

[Luogu P3501](https://www.luogu.org/problemnew/show/P3501)

## 题解

本题是胡搞过去的...正解好像是回文自动机...后缀数复杂度多一个$\log$...然后就被卡的死死的emmm最后$LOJ$ `1000ms`极限操作233

注意到...一个串如果想是反对称的，首先要是偶数长度。而且从中间劈开往两边看每个对应位置都相反。

所以我们可以把`这个串+分隔符+这个串的反向&取反`搞一个后缀数组出来，然后枚举中间点，在前后串对应位置取`LCP`就是可能的大小，然后求和即可。

如果后缀数组和ST表的初始化复杂度是$O(n \log n)$，最后$n$次查询每次复杂度都是$O(n)$。

时间复杂度是$O(n \log {n})$，比正解多一个$log$勉强卡过233

## 代码


```cpp
// Code By Chen Qiqian on 2018.08.10
#include <cstdio>
#include <cmath>
#include <algorithm>
using namespace std;

inline int min(int a,int b){return a>b?b:a;}

int n,m;
const int MAXN = 1000100,logn = 20;

namespace SA{
int s[MAXN],sa[MAXN],rk[MAXN],x[MAXN],y[MAXN],ht[MAXN];
int cnt[MAXN];
void get_SA(int n,int m){
    for(int i = 0;i<m;i++) cnt[i] = 0;
    for(int i = 0;i<n;i++) cnt[s[i]]++;
    for(int i = 1;i<m;i++) cnt[i] += cnt[i-1];
    for(int i = n-1;~i;--i) sa[--cnt[s[i]]] = i;
    m = rk[sa[0]] = 0;
    for(int i = 1;i<n;i++) rk[sa[i]] = (s[sa[i]]!=s[sa[i-1]])?++m:m; 
    for(int j = 1;;j<<=1){
        if(++m == n) break;
        for(int i = 0;i<j;i++) y[i] = n-j+i;
        for(int i = 0,k = j;i<n;i++) if(sa[i]>=j) y[k++] = sa[i]-j;
        for(int i = 0;i<n;i++) x[i] = rk[y[i]];
        for(int i = 0;i<m;i++) cnt[i] = 0;
        for(int i = 0;i<n;i++) cnt[x[i]]++;
        for(int i = 1;i<m;i++) cnt[i] += cnt[i-1];
        for(int i = n-1;~i;--i) sa[--cnt[x[i]]] = y[i],y[i] = rk[i];
        m = rk[sa[0]] = 0;
        for(int i = 1;i<n;i++) rk[sa[i]] = (y[sa[i]]!=y[sa[i-1]] || y[sa[i]+j]!=y[sa[i-1]+j])?++m:m;
    }
}
void getheight(int n){
    for(int i = 0, h = ht[0] = 0;i<n;i++){
        int j = sa[rk[i]-1];
        while(i+h<n&&j+h<n&&s[i+h]==s[j+h]) h++;
        if(ht[rk[i]] = h) --h;
    }
}
void build(int n){
    ++n;
    get_SA(n,4);
    getheight(n);
}
}
int _log[MAXN];

namespace ST{
int minn[MAXN][logn];
void build(int n,int *num){
    for(int i = 1;i<=n;i++)
        _log[i] = _log[i-1] + ((i==(1<<(_log[i-1]+1)))?1:0);
    int l = _log[n];
    for(int i = 0;i<=n;i++) minn[i][0] = num[i];
    for(int j = 1;j<=l;j++){
        for(int i = 0;i+(1<<(j-1))<=n;i++){
            minn[i][j] = min(minn[i][j-1],minn[i+(1<<(j-1))][j-1]);
        }
    }
}    
int query(int l,int r){
    int t = _log[r-l+1];
    return min(minn[l][t],minn[r-(1<<t)+1][t]);
}
}

int lcp(int x,int y){
    if(x == y) return n-x+1;
    x = SA::rk[x],y = SA::rk[y];
    if(x > y) swap(x,y);
    return ST::query(x+1,y);
}

char s[MAXN];

void init(){
    scanf("%d\n",&m);
    fread(s,MAXN,1,stdin);
    for(int i = 0;i<m;i++) SA::s[n++] = s[i] - ('0'-1);
    reverse(s,s+n);
    SA::s[n++] = 3;
    for(int i = 0;i<m;i++) SA::s[n++] = (s[i]^1) - ('0'-1);
    SA::s[n] = 0;
    SA::build(n);
    ST::build(n+1,SA::ht);
}

void solve(){
    long long ans = 0;
    for(int i = 0;i<m;i++){
        ans += lcp(i+1,n-i-1);
    }
    printf("%lld\n",ans);
}

int main(){
    init();
    solve();
    return 0;
}
```

