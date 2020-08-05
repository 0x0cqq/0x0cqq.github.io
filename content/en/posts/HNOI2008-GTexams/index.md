---
title: 「HNOI2008」GT考试-KMP+dp+矩阵快速幂
urlname: HNOI2008-GTexams
date: 2018-08-09 11:19:09
tags:
- 动态规划
- KMP
- 矩阵快速幂
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

阿申准备报名参加 $GT$ 考试，准考证号为 $n$ 位数 $X_1X_2\cdots X_n(0\le X_i\le 9)$，他不希望准考证号上出现不吉利的数字。

他的不吉利数字 $A_1A_2\cdots A_m(0\le A_i\le 9)$ 有 $m$ 位，不出现是指 $X_1X_2\cdots X_n$ 中没有恰好一段等于 $A_1A_2\cdots A_m$，$A_1$​ 和 $X_1$ 可以为 $0$。

阿申想知道不出现不吉利数字的号码有多少种，输出模 $K$ 取余的结果。

<!--more-->

## 链接

[Luogu P3193](https://www.luogu.org/problemnew/show/P3193)

## 题解

显然`dp`...

令 $dp[i][j]$ 为准考证已经匹配了 $i$ 位，不吉利数字（模版）最长可以匹配了 $j$ 位的方案数。

下一位有 $10$ 种情况，在 $nex$ 数组上分别转移即可。

注意到 $n$ 的大小比较大， $m$ 的大小比较小，可以用矩阵快速幂化掉第一维。

时间复杂度: $O(m^3 \times \log{n})$


## 代码



```cpp
#include <cstdio>
#include <cstring>
using namespace std;

const int MAXM = 30;

int n,m,k;
char s[MAXM];
int nex[MAXM];


struct Matrix{
    int a[MAXM][MAXM];
    Matrix(){memset(a,0,sizeof(a));}
};

Matrix mul(Matrix &_a,Matrix &_b){
    Matrix ans;
    for(int i = 0;i<=m;i++){
        for(int j = 0;j<=m;j++){
            for(int k = 0;k<=m;k++){
                ans.a[i][j] += _a.a[i][k] * _b.a[k][j];
            }
            if(ans.a[i][j] >= k) ans.a[i][j] %= k;
        }
    }
    return ans;
}

Matrix pow(Matrix x,int k){
    Matrix ans;
    for(int i = 0;i<=m;i++) ans.a[i][i] = 1;
    for(int i = k;i;i>>=1,x = mul(x,x)) if(i & 1) ans = mul(ans,x);
    return ans;
}

void init(){
    scanf("%d %d %d",&n,&m,&k);
    scanf("%s",s);
}

//dp[i][j]表示已经匹配了i位，模版已经匹配了j位

void get_next(){
    nex[0] = 0;
    int j = 0;
    for(int i = 1;i<m;i++){
        while(j > 0 && s[i] != s[j]) 
            j = nex[j-1];
        if(s[i] == s[j]) j++;
        nex[i] = j;
    }
}


void solve(){
    get_next();
    Matrix tmp;
    for(int i = 0;i<m;i++){
        int t = i;
        for(int w = '0';w<='9';w++){
            t = i;
            while(t > 0 && s[t] != w)
                t = nex[t-1];
            if(s[t] == w) t++;
            tmp.a[t][i]++;
        }
    }
    tmp = pow(tmp,n);
    int ans = 0;
    for(int i = 0;i<m;i++){
        ans += tmp.a[i][0];
    }
    ans %= k;
    printf("%d\n",ans);
}

int main(){
    init();
    solve();
    return 0;
}
```

