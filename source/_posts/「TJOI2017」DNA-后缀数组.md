---
title: 「TJOI2017」DNA-后缀数组
urlname: TJOI2017-DNA
date: 2018-06-23 20:43:31
tags:
- 字符串
- 题解
- 后缀数组
categories: OI
visible:
---

加里敦大学的生物研究所发现了决定人喜不喜欢吃藕的基因序列$S$,有这个序列的碱基序列就会表现出喜欢吃藕的性状，但是研究人员发现对碱基序列$S$,任意修改其中不超过$3$个碱基，依然能够表现出吃藕的性状。现在研究人员想知道这个基因在$DNA$链$S0$上的位置。所以你需要统计在一个表现出吃藕性状的人的$DNA$序列$S0$上，有多少个连续子串可能是该基因，即有多少个$S0$的连续子串修改小于等于三个字母能够变成$S$。

<!-- more -->

## 链接

[Luogu P3763](https://www.luogu.org/problemnew/show/P3763)

## 题解

先把两个串拼到一起，然后处理出后缀数组，建立出RMQ的ST表。然后对于每一位都判断是否满足条件即可，即往后取三个LCP，然后判断长度关系即可。

时间复杂度O(n)。

## 代码

{% fold %}
```cpp
#include <cstdio>
#include <algorithm>
#include <cstring>
#include <cmath>
using namespace std;

const int MAXN = 210000;

namespace SA{
int sa[MAXN],rk[MAXN],ht[MAXN],s[MAXN<<1],t[MAXN<<1];
int p[MAXN],b[MAXN],cur[MAXN];
#define pushS(x) sa[cur[s[x]]--] = x
#define pushL(x) sa[cur[s[x]]++] = x
#define inducedSort(v)\
    fill_n(b,m,0),fill_n(sa,n,-1);\
    for(int i=0;i<n;i++) b[s[i]]++;\
    for(int j=1;j<m;j++) b[j]+=b[j-1];\
    for(int j=0;j<m;j++) cur[j] = b[j]-1;\
    for(int i=n1-1;~i;--i) pushS(v[i]);\
    for(int j=1;j<m;j++) cur[j] = b[j-1];\
    for(int i=0;i<n;i++) if(sa[i]>0 && t[sa[i]-1]) pushL(sa[i]-1);\
    for(int j=0;j<m;j++) cur[j] = b[j]-1;\
    for(int i=n-1;~i;--i) if(sa[i]>0 && !t[sa[i]-1]) pushS(sa[i]-1);
void sais(int n,int m,int *s,int *t,int *p){
    int n1 = t[n-1] = 0,ch = rk[0] = -1,*s1 = s+n;
    for(int i=n-2;~i;--i) t[i] = s[i]==s[i+1]?t[i+1]:s[i]>s[i+1];
    for(int i=1;i<n;i++) rk[i] = (t[i-1]&&!t[i])?(p[n1] = i,n1++):-1;
    inducedSort(p);
    for(int i=0,x,y;i<n;i++)if(~(x=rk[sa[i]])){
        if(ch<1||p[x+1]-p[x]!=p[y+1]-p[y]) ch++;
        else for(int j=p[x],k=p[y];j<=p[x+1];j++,k++)
            if((s[j]<<1|t[j]) != (s[k]<<1|t[k])){ch++;break;}
        s1[y=x] = ch;
    }
    if(ch+1 < n1) sais(n1,ch+1,s1,t+n,p+n1);
    else for(int i = 0;i<n1;i++) sa[s1[i]] = i;
    for(int i = 0;i<n1;i++) s1[i] = p[sa[i]];
    inducedSort(s1);
}
template <typename T>
int mapChartoInt(int n,const T *str){
    int m = *max_element(str,str+n);
    fill_n(rk,m+1,0);//+1!!!
    for(int i = 0;i<n;i++) rk[str[i]] = 1;//=1!
    for(int j = 0;j<m;j++) rk[j+1] += rk[j]; 
    for(int i = 0;i<n;i++) s[i] = rk[str[i]]-1;
    return rk[m];
}
// str[n] yange zidianxu zuixiao
template <typename T>
void suffixArray(int n,const T *str){
    int m = mapChartoInt(++n,str);
    sais(n,m,s,t,p);
}
void getHeight(int n){
    // 这里的循环一定要到a！
    for(int i = 0;i<=n;i++) rk[sa[i]] = i;
    for(int i = 0,h = ht[0] = 0;i<=n;i++){
        int j = sa[rk[i]-1];
        while(i+h<n && j+h<n && s[i+h] == s[j+h]) h++;
        if(ht[rk[i]] = h) --h;
    }
}
}

int n,x,y;
char s[MAXN];

namespace ST{
    int st[20][MAXN];
    void build(int n,int *num){
        for(int i = 1;i<=n;i++) st[0][i] = num[i];
        for(int j = 1,t = 2;t<=n;j++,t<<=1)
            for(int i = 1;i+(t>>1)<=n;i++)
                st[j][i] = min(st[j-1][i],st[j-1][i+(t>>1)]);
    }
    int query(int l,int r){
        int t = log2(r-l+1);
        return min(st[t][l],st[t][r-(1<<t)+1]);
    }
}

void init(){
    scanf("%s",s);
    x = strlen(s);
    scanf("%s",s+x);
    n = strlen(s);
    y = n-x;
    s[n] = 'A'-1;
    SA::suffixArray(n,s);
    SA::getHeight(n);
    ST::build(n,SA::ht);
}

int lcp(int a,int b){
    if(a == b) return n - a + 1;
    a = SA::rk[a],b = SA::rk[b];
    if(a > b) swap(a,b);
    return ST::query(a+1,b);
}

bool judge(int p){
    int cnt = 0,len = 0;
    while(len < y){
        len += lcp(p+len,x+len);
        if(cnt >= 3 && len < y) return false;
        len++,cnt++;
    }
    return true;
}

void solve(){
    int ans = 0;
    for(int i = 0;i<=x-y;i++)
        if(judge(i)) ans++;
    printf("%d\n",ans);
}

int main(){
    int T;scanf("%d",&T);
    for(int i = 1;i<=T;i++)
        init(),solve();
    return 0;
}
```
{% endfold %}