---
title: 莫比乌斯反演入门题目-题解
urlname: mobius-inversion
date: 2018-08-25 09:18:08
tags:
- 数学
- 莫比乌斯反演
categories: 
- OI
- 题解
series:
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: false
---

以下有几道莫比乌斯反演入门题的详尽版的题解（公式推演）。

<!--more-->

## [POI2007]ZAP-Queries

### 题意
求：
$$
\sum _ {i=1}^n \sum _ {j=1}^m [\gcd(i,j)=d]
$$
- - -
### 解法1
倒一倒式子：
$$
\text{ans} = \sum _ {i=1}^n \sum _ {j=1}^m [\gcd(i,j)=d]\\
=\sum _ {i=1}^{\lfloor \frac{n}{d} \rfloor} \sum _ {j=1}^{\lfloor \frac{m}{d} \rfloor} [\gcd(i,j)=1]\\
$$

设 
$$
f(d) = \sum _ {i=1}^{x}\sum _ {j=1}^{y} [\gcd(i,j)=d]\\
$$

若：
$$
g(d) = \sum _ {d|k} f(k)
$$

则可以发现 $g(d) = \lfloor \frac{x}{d} \rfloor \cdot \lfloor \frac{y}{d} \rfloor$

反演得：
$$
f(d) = \sum _ {d|k} \mu(\frac{k}{d}) g(k)
$$

那么：
$$
f(1) = \sum _ {k=1}^{\min(x,y)} \mu(k) g(k)
$$

所以：
$$
\text{ans} = f(1) = \sum _ {k=1}^{\min(\lfloor \frac{n}{d} \rfloor,\lfloor \frac{m}{d} \rfloor)} \mu(k) g(k)\\
= \sum _ {k=1}^{\min(\lfloor \frac{n}{d} \rfloor,\lfloor \frac{m}{d} \rfloor)} \mu(k) \cdot \lfloor \frac{x}{d} \rfloor \lfloor \frac{y}{d} \rfloor\\
$$

可以利用整除分块，单次查询时间时间复杂度 $O(\sqrt n)$。所以时间复杂度是 $O(n + T\sqrt n)$ 。

## [HAOI2011]Problem b

### 题意
求：
$$
\sum _ {x=a}^b \sum _ {y=c}^d [gcd(x,y)=d]
$$
- - -
### 解法
设：
$$
\text{ans} = F(a,b,c,d) = \sum _ {x=a}^b \sum _ {y=c}^d [gcd(x,y)=d],\\
G(n,m) = \sum _ {x=1}^n \sum _ {y=1}^m [gcd(x,y)=d]
$$
利用容斥原理，可以发现这个式子可以转化成
$$
F(a,b,c,d) \\= G(b,d) - G(a-1,d) - G(b,c-1) + G(a-1,c-1)
$$
然后每一个 $G(n,m)$ 都可以按照上题的单次 $O(\sqrt n)$ 的做法求出。所以时间复杂度是 $O(n + T\sqrt n)$ 。

## YY的GCD
### 题意
求：
$$
\sum _ {i=1}^{k} \sum _ {x=1}^n \sum _ {y=1}^m [gcd(i,j)=p_i]\\
$$

- - -

### 解法1
$$
\sum _ {i=1}^{k} \sum _ {x=1}^n \sum _ {y=1}^m [gcd(i,j)=p_i]\\
= \sum _ {i=1}^k \sum _ {x=1}^{\lfloor \frac{n}{p_i} \rfloor} \sum _ {y=1} ^{\lfloor \frac{m}{p_i}\rfloor}
[gcd(i,j)=1]
$$

设
$$
f(k) = \sum _ {i=1}^n \sum _ {j=1}^m [gcd(i,j)=k]
$$

若
$$
g(k) = \sum _ {k|d} f(d) 
= \lfloor \frac{n}{k} \rfloor \cdot \lfloor \frac{m}{k} \rfloor
$$

莫比乌斯反演得

$$
f(k) = \sum _ {k|d} \mu(\frac{d}{k}) g(d)
= \sum _ {i = 1}^{\lfloor \frac{\min(n,m)}{k} \rfloor}\mu(i)g(ik)\\
= \sum _ {i = 1}^{\lfloor \frac{\min(n,m)}{k} \rfloor}\mu(i) \lfloor \frac{n}{ik} \rfloor \cdot \lfloor \frac{m}{ik} \rfloor
$$

所以

$$
f(1) = \sum _ {i = 1}^{ \min(n,m) }\mu(i) \cdot \lfloor \frac{n}{i} \rfloor \cdot \lfloor \frac{m}{i} \rfloor
$$

则原式：

$$
\sum _ {i=1}^k \sum _ {x=1}^{\lfloor \frac{n}{p_i} \rfloor} \sum _ {y=1} ^{\lfloor \frac{m}{p_i}\rfloor}
[gcd(i,j)=1]\\
= \sum _ {i=1}^k \sum _ {d=1}^{\min(\lfloor \frac{n}{p_i} \rfloor,\lfloor \frac{m}{p_i} \rfloor )}\mu(d) \cdot \lfloor \frac{n}{d p_i} \rfloor \cdot \lfloor \frac{m}{dp_i} \rfloor\\
$$

设$T_i = d p_i$，则有：
原式
$$
\sum _ {i=1}^k \sum _ {d=1}^{\min(\lfloor \frac{n}{p_i} \rfloor,\lfloor \frac{m}{p_i} \rfloor )}\mu(d) \cdot \lfloor \frac{n}{d p_i} \rfloor \cdot \lfloor \frac{m}{dp_i} \rfloor\\
= \sum _ {i=1}^k \sum _ {d=1}^{\min(\lfloor \frac{n}{p_i} \rfloor,\lfloor \frac{m}{p_i} \rfloor )}\mu(\frac{T_i}{p_i}) \cdot \lfloor \frac{n}{T_i} \rfloor \cdot \lfloor \frac{m}{T_i} \rfloor\\
= \sum _ {i=1}^k \sum _ {p_i | T}\mu(\frac{T}{p_i}) \cdot \lfloor \frac{n}{T} \rfloor \cdot \lfloor \frac{m}{T} \rfloor\\
= \sum _ {T=1}^{\min(n,m)} \sum _ {p_i|T} \mu(\frac{T}{p_i}) \cdot \lfloor \frac{n}{T} \rfloor \cdot \lfloor \frac{m}{T} \rfloor\\
= \sum _ {T=1}^{\min(n,m)} \lfloor \frac{n}{T} \rfloor \lfloor \frac{m}{T} \rfloor \sum _ {p_i|T} \mu(\frac{T}{p_i}) \\
$$

令
$$
h(x) = \sum _ {p_i|x} \mu(\frac{x}{p_i})
$$

所以原式化为：

$$
\sum _ {T=1}^{\min(n,m)} \lfloor \frac{n}{T} \rfloor \lfloor \frac{m}{T} \rfloor \sum _ {p_i|T} \mu(\frac{T}{p_i}) \\
= \sum _ {i=1}^{\min(n,m)} \lfloor \frac{n}{i} \rfloor \lfloor \frac{m}{i} \rfloor h(i)
$$

只需要求出 $h(i)$ 的前缀和，我们就可以 $O(\sqrt{n})$ 整除分块算出。

观察 
$$
h(x) = \sum _ {p_i|x} \mu(\frac{x}{p_i})
$$

可以发现，如果我们枚举每个质数，再将所有的该质数的倍数的`g[i * prime[j]] += mu[i]`都加上去。

由于枚举倍数的调和级数 $\frac{n}{1} + \frac{n}{2} + \cdots + \frac{n}{n} = O(\ln n + r)$ ,所以这个枚举过程的复杂度是 $O(n \ln n)$ 的。

注意到这个 $h(x)$ 应当也是一个积性函数，所以事实上可以在线性素数筛的时候直接计算出 $h(x)$ 的值，这个过程就是 $O(n)$ 的。

## [NOI2010]能量采集

### 题意
给定两个整数$n,m$，对于平面上的整点 $\{(x,y)|x \in [1,n],y \in [1,m],x,y \in \mathbb Z\}$ 。若 $(x,y)$  与 $(0,0)$ 的连线上有 $k$ 个整点（不包括 $(0,0)$ , $(n,m)$），则产生的贡献为 $2k+1$ 。求所有满足条件的点的贡献总和。

- - -
### 解法
一个结论：从 $(0,0)$ 到 $(n,m)$ 的线路上，有 $\gcd(n,m)-1$ 个整点(不包括 $(0,0)$ , $(n,m)$ )。

想一想很好明白：令 $t$ 是 $n,m$ 的公因数 $(\frac {n}{t} , \frac {m}{t})$ 就相当于步长， $m,n$ 一定时 $t$ 越大，步长越小，整点就越多。 $\gcd(n,m)$ 是 $n$ ,$ m$ 的最大公因数，所以就是最多整点的个数了。

所以问题转化为：
求
$$
\sum _ {i = 1}^{n} \sum _ {j = 1}^{m}2\times \gcd(n,m)-1
$$
的值。

我们进行一些微小的变换：

$$
\sum _ {i = 1}^{n} \sum _ {j = 1}^{m}2\times \gcd(n,m)-1\\
= (2 \sum _ {i = 1}^{n} \sum _ {j = 1}^{m}\gcd(n,m)) - n \times m
$$

问题转化为求：
$$
\sum _ {i = 1}^{n} \sum _ {j = 1}^{m}\gcd(n,m)
$$

- - -

$$
\text{ans} = \sum _ {i = 1}^{n} \sum _ {j = 1}^{m}\gcd(n,m)\\
= \sum _ {d=1}^{\min(n,m)} d \times (\sum _ {i=1}^{\lfloor \frac{n}{d} \rfloor} \sum _ {j=1}^{\lfloor \frac{m}{d} \rfloor} [\gcd(i,j)=1])\\
$$

设：

$$
f(d) = \sum _ {i=1}^{x} \sum _ {j=1}^{y} [\gcd(i,j)=d]
$$

由第一题，可以发现：

$$
f(1) = \sum _ {i = 1}^{ \min(x,y) }\mu(i) \cdot \lfloor \frac{x}{i} \rfloor \cdot \lfloor \frac{y}{i} \rfloor
$$

回代得：

$$
\text{ans} = \sum _ {d=1}^{\min(n,m)} d \times (\sum _ {i = 1}^{ \min(\lfloor \frac{n}{d} \rfloor,\lfloor \frac{m}{d} \rfloor) }\mu(i) \cdot \lfloor \frac{n}{id} \rfloor \cdot \lfloor \frac{m}{id} \rfloor)\\
$$

设 $T = id$，可以得到：
$$
\text{ans} = \sum _ {d=1}^{\min(n,m)} d \times (\sum _ {i = 1}^{ \min(\lfloor \frac{n}{d} \rfloor,\lfloor \frac{m}{d} \rfloor) }\mu(i) \cdot \lfloor \frac{n}{T} \rfloor \cdot \lfloor \frac{m}{T} \rfloor)\\
$$

改为枚举 $T$，得到：
$$
\text{ans} = \sum _ {T=1}^{\min(n,m)} \lfloor \frac{n}{T} \rfloor \cdot \lfloor \frac{m}{T} \rfloor (\sum _ {d|T} \mu(\frac{T}{d}) \cdot d)
$$

如果令：
$$
h(T) = \sum _ {d|T} \mu(\frac{T}{d}) \cdot d
$$

发现 $h(T)$ 是一个积性函数，所以可以 $O(n)$ 线性筛出来， 然后就可以得到：

$$
\text{ans} = \sum _ {T=1}^{\min(n,m)} h(T) \cdot \lfloor \frac{n}{T} \rfloor \cdot \lfloor \frac{m}{T} \rfloor
$$

利用整除分块可以做到 $O(\sqrt n)$ 单次询问。

时间复杂度： $O(n + \sqrt n)$
- - -

这题亦可 $O(n \log n)$ 手动模拟容斥原理。

## [国家集训队]Crash的数字表格
### 题意
求：
$$
\sum _ {x=1}^{n} \sum _ {y=1}^{m} \text{lcm}(x,y)
$$
数据范围： $n,m \leq 10^7$ 

- - -

### 解法1 $O(n)$
$$
\sum _ {x=1}^{n} \sum _ {y=1}^{m} \text{lcm}(x,y)\\
= \sum _ {x=1}^{n} \sum _ {y=1}^{m} \frac{xy}{\gcd(x,y)}
$$

我们可以枚举 $\gcd(x,y)$ 的值 $d$ ，然后就把式子化成：
$$
\sum _ {x=1}^{n} \sum _ {y=1}^{m} \frac{xy}{\gcd(x,y)}\\
= \sum _ {d=1}^{\min(n,m)}\sum _ {x=1}^{n} \sum _ {y=1}^m \frac{xy}{d} [\gcd(x,y) = d]\\
= \sum _ {d=1}^{\min(n,m)} d \; \sum _ {i=1}^{\lfloor \frac{n}{d} \rfloor} \sum _ {j=1}^{\lfloor \frac{m}{d} \rfloor} ij[\gcd(i,j)=1]\\
$$

设：
$$
F(x,y) = \sum _ {i=1}^{x} \sum _ {j=1}^{y} ij[\gcd(i,j)=1]\\
$$

则：
$$
\text{ans} = \sum _ {d=1}^{\min(n,m)} d \cdot F(\lfloor \frac{n}{d}\rfloor,\lfloor \frac{m}{d}\rfloor)
$$

- - -
设：
$$
h(x,y) = \sum _ {i=1}^x \sum _ {j=1}^y ij
= \frac{x(x+1)}{2} \cdot \frac{y(y+1)}{2}
$$

$h(x,y)$ 可以 $O(1)$ 计算得到。

- - -

我们进行莫比乌斯反演，尝试求出 $F(x,y)$ 的值：

（以下默认上界分别为 $x,y$）
设
$$
f(d) = \sum _ {i=1}^{x} \sum _ {j=1}^{y} ij[\gcd(i,j)=d],g(d) = \sum _ {d|k} f(k)\\
$$

我们发现， $g(d)$ 事实上可以表示为：

$$
g(d) = d^2 \times \sum _ {i=1}^{\lfloor \frac{x}{d} \rfloor} \sum _ {j=1}^{\lfloor \frac{y}{d} \rfloor} ij = d^2 \times h(\lfloor \frac{x}{d} \rfloor, \lfloor \frac{y}{d} \rfloor)
$$

经过反演：

$$
f(d) = \sum _ {d|k} \mu(\frac{k}{d}) g(k)\\
= \sum _ {d|k} \mu(\frac{k}{d}) \cdot  k^2 \cdot h(\lfloor \frac{x}{k} \rfloor, \lfloor \frac{y}{k} \rfloor)
$$


所以：

$$
f(1) = \sum _ {k=1}^{\min(x,y)} \mu(k) \cdot  k^2 \cdot h(\lfloor \frac{x}{k} \rfloor, \lfloor \frac{y}{k} \rfloor)
$$

那么， 
$$
F(x,y) = f(1) = \sum _ {k=1}^{\min(x,y)} \mu(k) \cdot  k^2 \cdot h(\lfloor \frac{x}{k} \rfloor, \lfloor \frac{y}{k} \rfloor)
$$

这个东西可以整除分块，所以我们每计算一个 $F(x,y)$ 的复杂度是 $O(\sqrt{n})$，根据：

$$
\text{ans} = \sum _ {d=1}^{\min(n,m)} d \cdot F(\lfloor \frac{n}{d}\rfloor,\lfloor \frac{m}{d}\rfloor)
$$

我们发现，这里对于所有的 $d$ 来说， $\lfloor \frac{n}{d}\rfloor$ 与 $\lfloor \frac{m}{d}\rfloor$ 也最多分别有 $\sqrt{n}$ 个取值，所以我们最多只需要计算 $O(\sqrt{n})$ 次 $F(x,y)$ ，所以最后的时间复杂度是 $O(n)$。

### 解法2 $O(n + T\sqrt {n})$

我们有
$$
\text{ans} = \sum _ {d=1}^{\min(n,m)} d \cdot F(\lfloor \frac{n}{d}\rfloor,\lfloor \frac{m}{d}\rfloor)
$$

又：
$$
F(x,y) = \sum _ {k=1}^{\min(x,y)} \mu(k) \cdot  k^2 \cdot h(\lfloor \frac{x}{k} \rfloor, \lfloor \frac{y}{k} \rfloor)\\
$$

代入得：
$$
\text{ans} = \sum _ {d=1}^{\min(n,m)} d \cdot \sum _ {k=1}^{\min(\lfloor \frac{n}{d}\rfloor,\lfloor \frac{m}{d}\rfloor)} \mu(k) \cdot  k^2 \cdot h(\lfloor \frac{n}{dk} \rfloor, \lfloor \frac{m}{dk} \rfloor)
$$

设 $dk = T$，则有：

$$
\text{ans} = \sum _ {d=1}^{\min(n,m)} d \cdot \sum _ {k=1}^{\min(\lfloor \frac{n}{d}\rfloor,\lfloor \frac{m}{d}\rfloor)} \mu(k) \cdot  k^2 \cdot h(\lfloor \frac{n}{T} \rfloor, \lfloor \frac{m}{T} \rfloor)
$$

枚举 $T$ ，则有：
$$
\text{ans} = \sum _ {T=1}^{\min(n,m)} \sum _ {d|T} d \cdot {\lfloor \frac{T}{d} \rfloor}^2 \mu(\lfloor \frac{T}{d} \rfloor) \cdot h(\lfloor \frac{n}{T} \rfloor, \lfloor \frac{m}{T} \rfloor)
$$

简单整理下：

$$
\text{ans} = \sum _ {T=1}^{\min(n,m)} h(\lfloor \frac{n}{T} \rfloor, \lfloor \frac{m}{T} \rfloor) \sum _ {d|T} \lfloor \frac{T}{d} \rfloor \cdot {d}^2 \mu(d)
$$

拎出来后面的一坨：
$$
f'(T) = \sum _ {d|T} \lfloor \frac{T}{d} \rfloor \cdot {d}^2 \mu(d)
$$

发现这是一个积性函数，所以可以 $O(n)$ 线性筛出来，然后就可以配合整除分块 $O(\sqrt n)$ 完成单词询问。

## [SDOI2015]约数个数和
### 题意
设 $d(x)$ 为 $x$ 的约数个数，给定 $N$ 、$M$ ，求 

$$\sum^N _ {i=1}\sum^M _ {j=1}d(ij)$$

- - -

### 解法
我们有如下结论：

$$
d(ij) = \sum _ {x|i} \sum _ {y|j} [\gcd(x,y) = 1]
$$

证明：

我们对 $i$ 和 $j$ 两个数做唯一分解 ，得到：
$$
i = {p_1}^{a_1} \times {p_2}^{a_2} \times  \cdots \times {p_n}^{a_n}\\
j = {p_1}^{b_1} \times {p_2}^{b_2} \times  \cdots \times {p_n}^{b_n}\\
$$

所以我们知道 
$$
d(ij) = \prod _ {x=1}^n {(a_x + b_x + 1)}
$$

我们需要证明，分别从 $i$ 和 $j$ 中选择两个互质的约数的方案数也等于上式。

我们发现，在约数的构造中，不同质因子的选取是独立的。所以我们只需要考虑一个质因子的选取方案数，然后把所有质因子做一个连乘即可。

因为不能有公共的因子，所以对 $p_1$ 这个质因子来说，我们可以正好找出 $a_1+b_1+1$ 种选取方法，分别为：

$$
(1,0),(2,0),\cdots,(a_1,0)\\
(0,1),(0,2),\cdots,(0,b_1)\\
(0,0)
$$

可以证明，这些不同的的选取可以保证我们选择的因数不会完全相同。

所以可以证明：
$$
d(ij) = \sum _ {x|i} \sum _ {y|j} [\gcd(x,y) = 1]
$$
- - -

原式：

$$
\sum^N _ {i=1}\sum^M _ {j=1}d(ij)\\
= \sum^N _ {i=1}\sum^M _ {j=1}\sum _ {x|i} \sum _ {y|j} [\gcd(x,y) = 1]\\
= \sum _ {x=1}^N\sum _ {y=1}^M\sum _ {x|i} \sum _ {y|j} [\gcd(x,y) = 1]\\
= \sum _ {x=1}^N\sum _ {y=1}^M [\gcd(x,y) = 1] \sum _ {x|i} \sum _ {y|j} 1\\
= \sum _ {x=1}^N\sum _ {y=1}^M [\gcd(x,y) = 1] \lfloor \frac{N}{x} \rfloor \lfloor \frac{M}{y} \rfloor\\
$$

设 
$$
f(d) = \sum _ {x=1}^N\sum _ {y=1}^M [\gcd(x,y) = d] \lfloor \frac{N}{x} \rfloor \lfloor \frac{M}{y} \rfloor\\
$$

若 
$$
g(d) = \sum _ {d|i} f(i)
$$

可以发现，此时 $x,y$ 为所有 $d$ 的倍数，所以：
$$
g(d) = \sum _ {i=1}^{\lfloor \frac{N}{d} \rfloor} \sum _ {j=1}^{\lfloor \frac{M}{d} \rfloor} \lfloor \frac{N}{id} \rfloor \lfloor \frac{M}{jd} \rfloor
$$




进行一步反演：
$$
f(d) = \sum _ {d|k} \mu(\frac{k}{d}) g(k)
$$

则：

$$
f(1) = \sum _ {k=1}^{\min(n,m)} \mu(k) g(k)\\
=  \sum _ {k=1}^{\min(n,m)} \mu(k) \sum _ {i=1}^{\lfloor \frac{N}{k} \rfloor} \sum _ {j=1}^{\lfloor \frac{M}{k} \rfloor} \lfloor \frac{N}{ik} \rfloor \lfloor \frac{M}{jk} \rfloor\\
= \sum _ {k=1}^{\min(n,m)} \mu(k) (\sum _ {i=1}^{\lfloor \frac{N}{k} \rfloor}\lfloor \frac{N}{ik} \rfloor) (\sum _ {j=1}^{\lfloor \frac{M}{k} \rfloor}  \lfloor \frac{M}{jk} \rfloor)\\
$$

我们发现：

$$
\sum _ {x=1}^nd(x) = \sum _ {i=1}^{n}\lfloor \frac{n}{i} \rfloor
$$

所以：

$$
\text{ans} = \sum _ {k=1}^{\min(n,m)} \mu(k) (\sum _ {i=1}^{\lfloor \frac{N}{k} \rfloor}\lfloor \frac{N}{ik} \rfloor) (\sum _ {j=1}^{\lfloor \frac{M}{k} \rfloor}  \lfloor \frac{M}{jk} \rfloor)\\
= \sum _ {k=1}^{\min(n,m)} \mu(k) \sum _ {i=1}^{\lfloor \frac{N}{k} \rfloor}d(i) \sum _ {j=1}^{\lfloor \frac{M}{k} \rfloor}  d(j)\\
$$

令：

$$
h(x) = \sum _ {i=1}^x d(i)
$$

则：

$$
\text{ans} = \sum _ {k=1}^{\min(n,m)} \mu(k) \cdot h(\lfloor \frac{N}{k} \rfloor) \cdot h(\lfloor \frac{M}{k} \rfloor)\\
$$

我们发现 $d(i)$ 是一个积性函数，可以 $O(n)$ 线性筛，然后 $h(x)$ 可以 $O(n)$ 前缀和，然后就可以 $O(\sqrt n)$ 整除分块单次出解。