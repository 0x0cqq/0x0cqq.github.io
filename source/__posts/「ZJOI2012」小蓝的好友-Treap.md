---
title: 「ZJOI2012」小蓝的好友-Treap
urlname: ZJOI2012-friend
date: 2018-08-16 21:24:02
tags:
- 题解
- 数据结构
- Treap
categories: OI
visible:
---

简单版题意：

给定一个 $R \times C$ 的矩形，在其中 $N$ 个位置有资源点。现在请你求出在所有的子矩形中，至少包含一个资源点的矩形数量。

<!-- more -->
- - -
完整版题意：

终于到达了这次选拔赛的最后一题，想必你已经厌倦了小蓝和小白的故事，为了回馈各位比赛选手，此题的主角是贯穿这次比赛的关键人物——小蓝的好友。

在帮小蓝确定了旅游路线后，小蓝的好友也不会浪费这个难得的暑假。与小蓝不同，小蓝的好友并不想将时间花在旅游上，而是盯上了最近发行的即时战略游戏——`SangoCraft`。但在前往通关之路的道路上，一个小游戏挡住了小蓝的好友的步伐。

“国家的战争其本质是抢夺资源的战争”是整款游戏的核心理念，这个小游戏也不例外。简单来说，用户需要在给定的大小为 $R \times C$ 长方形土地上选出一块子矩形，而系统随机生成了 $N$ 个资源点，位于用户所选的长方形土地上的资源点越多，给予用户的奖励也越多。悲剧的是，小蓝的好友虽然拥有着极其优秀的能力，但同时也有着极差的`RP`，小蓝的好友所选的区域总是没有一个资源点。

终于有一天，小蓝的好友决定投诉这款游戏的制造厂商，为了搜集证据，小蓝的好友想算出至少包含一个资源点的区域的数量。作为小蓝的好友，这自然是你分内之事。

数据范围：对于$100\%$的数据，$R,C \leq 40000$, $N \leq 100000$，资源点的位置两两不同，且位置为 **随机生成** 。

<!-- more -->


## 链接

[Luogu P2611](https://www.luogu.org/problemnew/show/P2611)

## 题解

神题orz

首先把问题转化成不包含一个资源点的子矩形数目。

简直不可做好吗！枚举矩形都gg，简直很不可做...

所以说，我们需要用一些东西来加速这个过程。我也不知道，怎么就想到了笛卡尔树...

> 笛卡尔树是一棵二叉树，树的每个节点有两个值，一个为 $\text{key}$，一个为 $\text{val}$。光看 $\text{key}$ 的话，笛卡尔树是一棵二叉搜索树，每个节点的左子树的 $\text{key}$ 都比它小，右子树都比它大；光看 $\text{val}$ 的话，笛卡尔树有点类似堆，根节点的 $\text{val}$ 是最小（或者最大）的，每个节点的 $\text{val}$ 都比它的子树要大。
> 
> From: [SengXian's Blog](https://blog.sengxian.com/algorithms/treap)


我们用扫描线，从上往下扫描，然后我们的笛卡尔树维护的是每一列，中序遍历就是列从左到右的顺序，每一个节点的 $\text{val}$ 就是这条扫描线到这一列最低的资源点的高度。

这里的笛卡尔树，我们不维护 $\text{key}$ ，是以序列下标来建树，类似文艺平衡树的 `Splay` ；堆则是小根堆。

由于高度的随机性，我们可以发现，这棵笛卡尔树的期望高度是 $O(\log{n})$ 的。

所以我们可以维护一点东西，来加速我们的运算。

我们维护一个$sum$，代表下界在当前扫描线，上界在这个节点高度以下的子矩形的个数。我们可以发现，当前的节点的siz，就是上界高度在其下的宽度（列数），然后我们可以得出满足这个条件的子矩形。然后所有的下界在扫描线上的矩形，都可以在这个笛卡尔树的所有节点处被不重不漏的包含。

然后我们思考如何更新。扫描线往下的话就是所有的 $ht+1$，发现可以打标记 $O(1)$ 解决。出现一个点事实上就是单点修改优先值（ $\text{val}$ ），然后往上转，也可以在 $O(\log {n})$ 内解决。

然后计算就好了。有不少细节...怪难调的...要不是数据结构基础好估计就gg了...

最后的复杂度大约是$O(C + N \log R)$？

## 代码

{% fold %}
```cpp
#include <cstdio>
#include <algorithm>
#include <cctype>
#define ll long long
typedef int T;
using namespace std;
#define calc(x) (((ll)(x)*((x)+1))/2)

namespace fast_io{
    //...
}using namespace fast_io;

const int MAXN = 110000;

namespace Treap{
    //小根堆
    #define ls c[x][0]
    #define rs c[x][1]
    ll ans[MAXN],addn[MAXN];
    int ht[MAXN],siz[MAXN];
    int c[MAXN][2],cnt = 0;
    int root;
    void maintain(int x){//确保合法才能maintain
        siz[x] = siz[ls] + siz[rs] + 1;
        ans[x] = ans[ls] + ans[rs];
        ans[x] += (ll)(ht[ls] - ht[x])*calc(siz[ls]);
        ans[x] += (ll)(ht[rs] - ht[x])*calc(siz[rs]); 
    }
    int __build(int l,int r){
        if(l > r) return 0;
        int x = ++cnt,mid = (l+r)>>1;
        siz[x] = 1;
        ls = __build(l,mid-1),rs = __build(mid+1,r);
        maintain(x);
        return x;
    }
    void add(int x,int v){
        addn[x] += v,ht[x] += v;
    }
    void push_down(int x){
        if(addn[x]){
            add(ls,addn[x]),add(rs,addn[x]);
            addn[x] = 0;
        }
    }
    void rotate(int &x,int t){
        int y = c[x][t];
        c[x][t] = c[y][1-t];
        c[y][1-t] = x;
        maintain(x),maintain(y);
        x = y;        
    }
    void modify(int &x,int r){
        push_down(x);int t = siz[ls] + 1;
        if(r == t){
            ht[x] = 0;maintain(x);return;
        }
        else{
            if(r < t){
                modify(ls,r);
                if(ht[ls]<ht[x]) rotate(x,0);
                else             maintain(x);
            }
            else{
                modify(rs,r-t);
                if(ht[rs]<ht[x]) rotate(x,1);
                else             maintain(x);
            }
        }
    }
    void add(){add(root,1);}
    void modify(int r){modify(root,r);}
    ll query(){return ans[root];}
    int getheight(){return ht[root];}
    void build(int n){root = __build(1,n);}
}

int n,m,k;

struct Point{
    int x,y;
    bool operator < (const Point & _a)const{
        if(x != _a.x) return x < _a.x;  
        else return y < _a.y;
    }
}p[MAXN];

void init(){
    read(n),read(m),read(k);
    for(int i = 1;i<=k;i++){
        read(p[i].x),read(p[i].y);
    }
}

void build(){
    sort(p+1,p+k+1);
    Treap::build(m);
}

void solve(){
    static ll ans = calc(n)*calc(m);
    for(int i = 1,j = 1;i<=n;i++){
        Treap::add();
        //printf("%d %d\n",p[j].x,p[j].y);
        while(j <= k && p[j].x == i){
            Treap::modify(p[j].y);j++;
        }
        ans -= Treap::query() + calc(Treap::siz[Treap::root]) * Treap::getheight(); 
    }
    printf("%lld\n",ans);
}

int main(){
    init();
    build();
    solve();
    return 0;
}
```
{% endfold %}