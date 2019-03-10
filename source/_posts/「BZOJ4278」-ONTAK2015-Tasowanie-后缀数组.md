---
title: 「BZOJ4278」[ONTAK2015]Tasowanie-后缀数组
urlname: BZOJ4278-Tasowanie
date: 2018-08-14 19:56:00
tags:
- 题解
- 后缀数组
- 字符串
categories: OI
visible:
---

给定两个数字串 $A$ 和 $B$ ，通过将 $A$ 和 $B$ 进行二路归并得到一个新的数字串 $T$ ，请找到字典序最小的 $T$ 。

<!-- more -->

## 链接

[BZOJ](https://ruanx.pw/bzojch/p/4278.html)
（离线题面）
[data](data.zip)（数据）

## 题解

如果前面两个字符不同，显然选取小的一个。

分情况讨论，我们可以发现，如果相同，那么就应该取目前后缀字典序较小的一个。

所以事实上就是取后缀字典序比较小的。

此题亦可hash二分。

## 代码


```cpp
#include <cstdio>
using namespace std;

const int MAXN = 410000;

namespace SA{
int s[MAXN],sa[MAXN],ht[MAXN],rk[MAXN],x[MAXN],y[MAXN];
int cnt[MAXN];
void get_sa(int n,int m){
    for(int i = 0;i<m;i++) cnt[i] = 0;
    for(int i = 0;i<n;i++) cnt[s[i]]++;
    for(int i = 1;i<m;i++) cnt[i] += cnt[i-1];
    for(int i = n-1;~i;--i) sa[--cnt[s[i]]] = i;
    m = rk[sa[0]] = 0;
    for(int i = 1;i<n;i++) rk[sa[i]] = s[sa[i]] != s[sa[i-1]]?++m:m;
    for(int j = 1;;j<<=1){
        if(++m == n) break;
        for(int i = 0;i<j;i++) y[i] = n-j+i;
        for(int i = 0,k = j;i<n;i++) if(sa[i] >= j) y[k++] = sa[i] - j;
        for(int i = 0;i<n;i++) x[i] = rk[y[i]];
        for(int i = 0;i<m;i++) cnt[i] = 0;
        for(int i = 0;i<n;i++) cnt[x[i]]++;
        for(int i = 1;i<m;i++) cnt[i] += cnt[i-1];
        for(int i = n-1;~i;--i) sa[--cnt[x[i]]] = y[i];
        m = rk[sa[0]] = 0;
        for(int i = 1;i<n;i++) rk[sa[i]] = (y[sa[i]] != y[sa[i-1]] || y[sa[i]+j] != y[sa[i-1]+j])?++m:m;
    }
}
void build(int n,int* str){
    int m = 1002;str[n++] = 0;
    for(int i = 0;i<n;i++) s[i] = str[i];
    get_sa(n,m);
}
bool cmp(int i,int j){
    return rk[i+1] < rk[j+1];
}
}

int n;
int u,v;
int a[MAXN],b[MAXN],t[MAXN],ans[MAXN];

void init(){
    scanf("%d",&u);
    for(int i = 0;i<u;i++) scanf("%d",&a[i]);
    scanf("%d",&v);
    for(int i = 0;i<v;i++) scanf("%d",&b[i]);
    for(int i = 0;i<u;i++) t[n++] = a[i];
    t[n++] = 0;
    for(int i = 0;i<v;i++) t[n++] = b[i];
    SA::build(n,t);
}

void solve(){
    int l = 0,r = 0,t = 0;
    while(t <= u+v){
        // printf("l:%d,%d r:%d,%d\n",l,a[l],r,b[r]);
        if(l == u) ans[t++] = b[r++];
        else if(r == v) ans[t++] = a[l++];
        else{
            if(a[l]==b[r])
                ans[t++] = SA::cmp(l,u+1+r)?a[l++]:b[r++];
            else
                ans[t++] = a[l] < b[r]?a[l++]:b[r++];
        }
    }
    for(int i = 0;i<u+v;i++)
        printf("%d ",ans[i]);
    printf("\n");
}

int main(){
    init();
    solve();
    return 0;
}
```

