---
##-- draftstate --##
draft: false
##-- page info --##
title: "欧几里得算法学习笔记"
date: 2020-08-09T19:58:59+08:00
categories:
- OI
- 学习笔记
tags:
- 数学
- 欧几里得算法
- 模板
- 笔记
series:
##-- page setting --##
pinned: false
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: true
---

关于最大公约数的欧几里得算法及其拓展。

<!--more-->

## 前置知识
### 整除
#### 定义
对于 $a,b \in \mathbb Z$ ，若存在 $q\in \mathbb Z$ 使 $a = qb$ 成立，则称 **$b$ 整除 $a$** 或 **$a$ 被 $b$ 整除**，记作 $b\mid a$ 。
我们称 $b$ 是 $a$ 的**因数**， $a$ 是 $b$ 的**倍数**。
否则，我们称 **$b$ 不整除 $a$** 或 **$a$ 不被 $b$ 整除**，记作 $b\nmid a$ 。
#### 性质
1. $c\mid b,b\mid a \implies c \mid a$
2. $x,y \in \mathbb Z, m|a,m|b \implies m|(ax+by)$
### 带余数除法
#### 定义
若 $a,b\in \mathbb Z,b>0$ ，则存在**唯一**的 $q,r\in \mathbb Z$ ，使
$$
a = bq+r,0\leq r < b
$$
这里的 $q$ 称作不完全商， $r$ 称为余数。

### 取整
#### 定义
$\lfloor x \rfloor$ 和 $\lceil x \rceil$ 分别代表向下和向上取整。
#### 性质
1. 在带余除法中，$q = \lfloor \frac{a}{b} \rfloor$.
2. 若$n\in \mathbb Z$：$\lfloor x + n \rfloor = \lfloor x \rfloor + n$
3. $\lceil x \rceil  = − \lfloor −x \rfloor , − \lfloor x\rfloor  = − \lceil −x \rceil$
4. $\lceil \frac{n}{m} \rceil = \lfloor \frac{n+m-1}{m} \rfloor$
5. $round(x) = \lfloor x+0.5\rfloor$
6. $\lfloor\frac{\lfloor x \rfloor}{n}\rfloor = \lfloor \frac{x}{n}\rfloor$
7. $\lfloor\frac{n}{\lfloor x \rfloor}\rfloor \neq \lfloor \frac{n}{x}\rfloor$
8. $\lfloor \sqrt{x}\rfloor = \lfloor \sqrt{\lfloor x \rfloor} \rfloor$
9. $\lfloor \frac{n}{ab} \rfloor = \lfloor \frac{\lfloor \frac{n}{a} \rfloor }{b} \rfloor$

## 最大公约数$\gcd$（`greatest common divisor`）
### 定义

最大公约数，即给定两个整数 $a,b$ ，求最大的正整数 $w$，满足 $w$ 整除 $a$ 且 $w$ 整除 $b$ ( $w|a$ 且 $w|b$ ).记作 $\gcd(a,b) = w$ .

定义$gcd(0,0) = 0$。

### 一些性质
+ $gcd(a,0) = |a|$
+ $gcd(a,ka) = |a|,\,k \in \mathbb Z$
+ $gcd(a,b) = gcd(b,a)$
+ $gcd(a,b) = gcd(a,-b)$
+ $gcd(a,gcd(b,c)) = gcd(gcd(a,b),c)$
+ 在 $(0,0)$ 到 $(a,b)$（ $a,b \in \mathbb Z$ ）的线段上，有 $gcd(a,b)+1$ 个整点（包括两端点）


### 求法

辗转相除法。

其本质上是一个递归算法，通过不断递归的方式计算这两个数的最大公约数。

过程：$gcd(a,b) = gcd(b,a \bmod b)$
边界：$gcd(a,0) = a$

### 证明
（有限性）
令 $k$ 表示我们计算的步骤数（从 $0$ 开始计数）。

每一步的输入是都是前两次计算的非负余数 $r _ {k−1}$ 和 $r _ {k−2}$ 。

因为余数肯定小于除数，所以 $r _ {k−1}$ 小于 $r _ {k−2}$ 。在第 $k$ 步中，算法计算出满足以下等式的商 $q_k$ 和余数 $r_k$ ：

$$
r _ {k−2} = q _ {k} \times r _ {k−1} + r_k,\; \text{其中}0\leq r_k<r _ {k-1}
$$

此时，$r _ {k-1}$ 和 $r_k$ 就是下一次递归的输入。

如果把所有式子都列出来，就会是这个样子：

$$
\begin{aligned}{}
a =& q_0 \times b + r_0\\
b =& q_1 \times r_0 + r_1\\
r_0 =& q_2 \times r_1 + r_2\\
r_1 =& q_3 \times r_2 + r_3\\
...\\
r _ {n-2} =& q_n \times r _ {n-1} + r_n\\
\end{aligned}
$$

这里的 $a,b$ 的大小在第一次除法的时候就会调节，所以不必关心，不妨设 $a>b$ 。

注意到 $a > b > r_1 > r_2 > r_3 > r_4... > r_n >=0$ ，所以一定能在 $n$ 次递归过后使得递归到边界情形，即 $r_n = 0$ 。

此时 $r _ {n-1}$ 就是我们求得的 $\gcd(a,b)$ 。

（正确性）
设 $\gcd(a,b) = g$ ，我们需要证明 $r _ {n-1} = g$ 。

**第一步：**
因为 $r_n = 0$ ，又 $r _ {n-2} = q_n \times r _ {n-1} + r_n$ ，所以 $r _ {n-2}$ 是 $r _ {n-1}$ 的整数倍。 $r _ {n-3}$ 由整数倍的 $r _ {n-2}$ 和一个 $r _ {n-1}$ 构成，所以 $r _ {n-3}$ 是 $r _ {n-1}$ 的整数倍。同理可得 $a,b$ 都是 $r _ {n-1}$ 的整数倍。

所以 $r _ {n-1}$ 就是 $a,b$ 的公因数，又 $g$ 是 $a,b$ 的最大公因数，所以 $g \geq r _ {n-1}$ 。

**第二步：**
因为 $g = gcd(a,b)$ ，令 $a = mg,b = ng$ ，其中 $n,m$ 均为自然数。

因为 $a = q_0 \times b + r_0$ ，所以 $r_0 = (m - q_0 \times n)g$ ，即 $g$ 也为 $r_0$ 的因数。同理下去就可以得到 $g$ 整除 $r_0,r_1,r_2,...,r _ {n-1}$ 。所以 $g \leq r _ {n-1}$ 。

综上可得： $g = r _ {n-1}$ 。

所以，辗转相除法的正确性可以如上证明。

### 实现
直接按照思路实现即可：

```cpp
template<typename T>
T gcd(T a,T b){
    return b==0?a:gcd(b,a%b);
}
```
时间复杂度 $O(\log n)$ ，证明参见 *Lamé定理* 。

### 扩展欧几里得算法（`exgcd`）
#### 定义

扩展欧几里得算法，即给定两个正整数 $a,b$ ，我们可以在运用欧几里得算法求出 $gcd(a,b)$ 的同时，我们也可以求出 $ax+by = gcd(a,b)$ 的一组整数解 $x_0,y_0$ 。

其方程所有解为：

$$
\left\{ 
\begin{aligned}{}
x = x_0+\frac{b}{gcd(a,b)}\\
y = y_0-\frac{a}{gcd(a,b)}
\end{aligned}
\right.
$$

**一个结论： $ax+by$ 的最小正值 $ax_0+by_0 = gcd(a,b)$**

#### 求法&证明
现在我们要求 $ax+by = gcd(a,b)$ 的一组整数解。

考虑到欧几里得算法的公式 $gcd(a,b) = gcd(b,a \bmod b)$

若有一组 $x',y'$ 使得 $bx'+ (a \bmod b)  y' = gcd(b,a \bmod b)$

这个时候我们注意到可以令 $ax+by = bx'+ (a \bmod b) y'$ .

因为 $a \bmod b = a-\lfloor\frac{a}{b}\rfloor b$ ，所以上式可以化为 $ax+by = bx'+(a-\lfloor\frac{a}{b}\rfloor b)y'$ .

这个时候我们已经知道 $x',y',a,b$ ，未知数有 $x,y$ 。所以这个方程事实上是要么无解要么无数个解。而我们这里只需要一个特解，所以我们把上式整理成为关于 $a,b$ 的恒成立式子，就可以通过 $x',y'$ 解出 $x,y$ 。整理得
$$
a(x)+b(y) = a(y') + b(x'-\lfloor\frac{a}{b}\rfloor y')
$$

可以得到一组特解：$x = y',y = x'-\lfloor\frac{a}{b}\rfloor y'$。所以我们就可以递归求解。

**精简版过程：**
令 $\text{exgcd}(a,b)$ 为 $ax+by = gcd(a,b)$ 的解 $(x,y)$ 。

对于 $\text{exgcd}(a,b)$ ，递归求得 $exgcd(b,a \bmod b)$ 的解 $(x',y')$ 。
则 $exgcd(a,b) = (y', x'-\lfloor\frac{a}{b}\rfloor y')$ 。

边界情况为 $b = 0$ 时，此时方程即为 $ax + 0y = a$ ，返回 $(1,0)$ 即可。

#### 代码

```cpp
template<typename T>
T exgcd(T a,T b,T &x,T &y){
    if (!b){x=1,y=0;return a;}
    T d = exgcd(b,a%b,y,x);
    y-=(a/b)*x;
    return d;
}
```

#### 应用
+ $ax+by=c$ 不定方程 
可以证明，仅当 $gcd(a,b)|c$ 时，该方程有整数解。
先用扩展欧几里得算法求出 $ax+by = gcd(a,b)$ 的一组整数解，然后将得到的解均乘上 $\frac{c}{gcd(a,b)}$ 即可。

+ $ax \equiv c \pmod b$ 一次同余方程
转化为 $ax + by = c$ 的一个问题，可以得出有解条件当且仅当 $gcd(a,b)|c$ 。运用上面的方法求解即可。

+ 乘法逆元，将 $ax \equiv 1 \pmod p$ 转化成 $ax + py = 1$ 解不定方程即可。

### 类欧几里得算法
一种用于求解形似
$$
\sum _ {i = 0}^n{\lfloor\frac{ai+b}{c}\rfloor}
$$
的问题的算法。

#### 过程

首先对 $a,b$ 关于 $c$ 取模，使得 $a,b<c$ 。
令 $m = \lfloor\frac{an+b}{c}\rfloor$ 。

此时有：
$$
\sum _ {i = 0}^n{\lfloor\frac{ai+b}{c}\rfloor} \\
= \sum _ {j = 0}^{m-1}\sum _ {i = 0}^n[j < \lfloor\frac{ai+b}{c}\rfloor]\\
= \sum _ {j = 0}^{m-1}\sum _ {i = 0}^n[i > \lfloor\frac{cj+c-b-1}{a}\rfloor]\\
= \sum _ {j = 0}^{m-1}n - \lfloor\frac{cj+c-b-1}{a}\rfloor\\
= nm - \sum _ {j = 0}^{m-1}\lfloor\frac{cj+c-b-1}{a}\rfloor
$$

注意到这个时候 $a,b$ 都是对 $c$ 取模的，所以这个东西很像欧几里得算法，时间复杂度大约也是 $O(\log n)$ .

### 扩展

$$
\sum _ {i = 0}^n{{\lfloor\frac{ai+b}{c}\rfloor}^2}\\
\sum _ {i = 0}^n{i{\lfloor\frac{ai+b}{c}\rfloor}}
$$

