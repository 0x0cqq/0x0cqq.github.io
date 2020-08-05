---
title: 「HAOI2016」找相同字符-后缀数组+单调栈
urlname: HAOI2016-same
date: 2018-07-04 20:39:30
tags:
- 字符串
- 单调栈
- 后缀数组
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

给定两个字符串，求出在两个字符串中各取出一个子串使得这两个子串相同的方案数。当这两个子串中只要有一个取得位置不同时，两个方案不同。

<!--more-->

## 链接

[Luogu P3181](https://www.luogu.org/problemnew/show/P3181)

## 题解

### 解法一：$O(n^4)$

暴力枚举两个起始位置，然后枚举每个起始长度， $O(n)$ 的判断子串是否相同，这个算法是 $O(n^4)$ 的。

### 解法二：$O(n^3)$

暴力枚举两个起始位置，然后从 $1$ 到 $n$ ，每次判断新增的一个字符是否相同，从而判断子串是否相同。这样对于每一个起始位置的判断就是 $O(n)$ ，最后的复杂度就是 $O(n^3)$ 。

### 解法三：$O(n^2)$

我们学会了后缀数组，我们知道了我们事实上可以在 $O(n\log n)$ 预处理的情况下 $O(1)$ 的得到解法二的 $O(n)$ 的过程，也就是求一下 $LCP$ 。这样的话，复杂度是 $O(n^2)$ 。

### 解法四：$O(n \log n)$

我们先转化一下问题。这道题要求的是两个串的每一个位置两两之间的 $LCP$ 的和。但是如果我们枚举的话，时间复杂度至少是 $O(n^2)$ 。那么我们肯定要用一些数据结构之类来批量求和，最后才能够降低复杂度。

其次，我们发现这个问题可以拆解。我们只需要找出一个解法，解得在**一个字符串里面任取两个位置不同的子串，取得子串相同的方案数。**

令 `s_3 = s_1 + "?" + s_2` ，那么答案就是 `cal(s3)-cal(s1)-cal(s2)` ，其中 `?` 是一个没有在字符串里面出现的字符。

那么我们发现，对于每一个位置来说，我们可以将其视作以这个位置开始的后缀，那么其顺序对于每一个位置两两之间 LCP 的和是无关紧要的。

所以我们按 $sa[i]$ ，也就是后缀字典序的顺序来遍历。每次我们都要求这个位置和前面所有位置的 LCP 的和。那么这个时候，我们就可以把**前面的所有后缀到按字典序前一个后缀的LCP长度**扔到一个 Splay 或者什么权值线段树里面去。

然后这个时候我们新加入了一个后缀，需要更新这个数据结构。我们需要把这个数据结构里面所有的大于 $ht[i]$ 的数都拎出来，改成 $ht[i]$ ，然后再塞回去就可以了。然后每次给 $ans$ 加上这个数据结构里面所有数的总和就可以了。

这个算法的时间复杂度应当是 $O(n \log n)$ 。

### 解法五：$O(n)$

什么？？？这种东西还能 $O(n)$ ？？？

反正我很震惊。

于是我就在合格考的考场上苦思冥想，最后自己脑补出了一个数据结构。用摊还证了下复杂度，竟然发现是 $O(n)$ 的...仔细一想，这个东西叫单调栈2333......

其他都同上，我们现在解决的是这里：

**我们需要把这个数据结构里面所有的大于 $ht[i]$ 的数都拎出来，改成 $ht[i]$ ，然后再塞回去就可以了。然后每次给 $ans$ 加上这个数据结构里面所有数的总和就可以了。**

怎么办呢？我们想能不能暴力解决这个问题。注意到我们每次用 $ht[i]$ 更新之后，所有的这些数我们都可以只用一个数(数对)来表示，也就是 $(ht[i],cnt)$ 。我们维护一个有序表。然后每次从大端把所有大于等于 $ht[i]$ 的数给拿出来，更新 $cnt$ ，最后在插回去一个新的节点。

然后数据结构里面的数的和的更新就比较简单了...记一下出来的数的和，再记一下进去的数的和，然后加一下减一下即可。

可以用摊还证明，这个东西是 $O(n)$ 的。

我用的后缀数组是 $SA-IS$ 算法，也是 $O(n)$ 的。

- - -

语言很混乱，哪看不懂可以问我23333

## 代码


```cpp
#include <bits/stdc++.h>
#define ll long long
#define pp pair<int,int>
using namespace std;

const int MAXN = 233333;

template<size_t siz>
struct SA{
int s[siz<<1],p[siz],t[siz<<1];
int sa[siz],rk[siz],ht[siz];
int b[siz],cur[siz];
#define pushL(x) sa[cur[s[x]]++] = x
#define pushS(x) sa[cur[s[x]]--] = x
#define inducedSort(v)\
    fill_n(b,m,0),fill_n(sa,n,-1);\
    for(int i = 0;i<n;i++) b[s[i]]++;\
    for(int i = 1;i<m;i++) b[i] += b[i-1];\
    for(int i = 0;i<m;i++) cur[i] = b[i]-1;\
    for(int i=n1-1;~i;--i) pushS(v[i]);\
    for(int i = 1;i<m;i++) cur[i] = b[i-1];\
    for(int i = 0;i<n;i++) if(sa[i]>0&&t[sa[i]-1]) pushL(sa[i]-1);\
    for(int i = 0;i<m;i++) cur[i] = b[i]-1;\
    for(int i =n-1;~i;--i) if(sa[i]>0&&!t[sa[i]-1]) pushS(sa[i]-1);
void sais(int n,int m,int *s,int *t,int *p){
    int ch = rk[0] = -1,n1 = t[n-1] = 0,*s1 = s+n;
    for(int i = n-2;~i;--i) t[i] = s[i]==s[i+1]?t[i+1]:s[i]>s[i+1];
    for(int i = 1;i<n;i++) rk[i] = (!t[i]&&t[i-1])?(p[n1]=i,n1++):-1;
    inducedSort(p);
    for(int i = 0,x,y;i<n;i++)if(~(x=rk[sa[i]])){
        if(ch<1||p[x+1]-p[x] != p[y+1]-p[y]) ch++;
        else for(int j=p[x],k=p[y];j<=p[x+1];j++,k++)
            if((s[j]<<1|t[j])!=(s[k]<<1|t[k])){ch++;break;}
        s1[y=x] = ch;
    }
    if(ch+1 < n1) sais(n1,ch+1,s1,t+n,p+n1);
    else for(int i = 0;i<n1;i++) sa[s1[i]] = i;
    for(int i = 0;i<n1;i++) s1[i] = p[sa[i]];
    inducedSort(s1);
}
template<typename T>
int mapp(const T *str,int n){
    int m = *max_element(str,str+n);
    fill_n(rk,m+1,0);
    for(int i = 0;i<n;i++) rk[str[i]] = 1;
    for(int i = 0;i<m;i++) rk[i+1] += rk[i];
    for(int i = 0;i<n;i++) s[i] = rk[str[i]]-1;
    return rk[m];
}
// 这个时候传正确的字符串大小，++n对str[n]做处理
template<typename T>
void SuffixArray(const T *str,int n){
    int m = mapp(str,++n);
    sais(n,m,s,t,p);
}
void getheight(int n){
    for(int i = 0;i<=n;i++) rk[sa[i]] = i;
    for(int i = 0,h=ht[0]=0;i<=n;i++){
        int j = sa[rk[i]-1];
        while(i+h<n&&j+h<n&&s[i+h]==s[j+h]) ++h;
        if(ht[rk[i]] = h) --h;
    } 
}
template<typename T>
void build(const T *str,int n){
    SuffixArray(str,n);
    getheight(n);
}
};

char s1[MAXN],s2[MAXN],s3[MAXN<<1];

void init(){
    scanf("%s",s1);
    scanf("%s",s2);
}

ll cal(char *a){
    int n = strlen(a);
    a[n] = 'A'-1;
    static SA<401000> T;
    T.build(a,n);

    ll ans = 0,tmp = 0;
    stack<pp> S;
    for(int i = 1;i<=n;i++){
        ll cnt = 1,tot = 0;
        while(!S.empty() && S.top().first >= T.ht[i]){
            cnt += S.top().second;
            tot += 1LL * S.top().first * S.top().second;
            S.pop();
        }
        S.push(make_pair(T.ht[i],int(cnt)));
        
        tmp += T.ht[i]*cnt - tot;
        ans += tmp;
    }
    return ans;
}

void solve(){
    int n = strlen(s1),m = strlen(s2);
    memcpy(s3,s1,n),memcpy(s3+n+1,s2,m);s3[n] = 'A';
    printf("%lld\n",cal(s3)-cal(s1)-cal(s2));
}

signed main(){
    init();
    solve();
    return 0;
}
```

