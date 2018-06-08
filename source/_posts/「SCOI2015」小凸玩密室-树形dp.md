---
title: 「SCOI2015」小凸玩密室-树形dp
urlname: SCOI2015-room
date: 2018-06-08 16:08:09
tags:
- 动态规划
- 题解
- 树形结构
categories: OI
visible:
---

小凸和小方相约玩密室逃脱，这个密室是一棵有$n$个节点的完全二叉树，每个节点有一个灯泡。点亮所有灯泡即可逃出密室。

每个灯泡有个权值$a_i$，每条边也有个权值$b_i$。点亮第$1$个灯泡不需要花费，之后每点亮$1$个新的灯泡$v$的花费，等于上一个被点亮的灯泡$u$到这个点$v$的距离$D_{u,v}$，乘以这个点的权值$a_v$。在点灯的过程中，要保证任意时刻所有被点亮的灯泡**必须连通**，在点亮一个灯泡后**必须先点亮其子树所有灯泡才能点亮其他灯泡**。

请告诉他们，逃出密室的最少花费是多少。

<!-- more -->

## 链接

[BZOJ 4446](https://www.lydsy.com/JudgeOnline/problem.php?id=4446)

[Luogu 4253](https://www.luogu.org/problemnew/show/P4253)

## 题解

这个树形dp真是可以说神了`orz`...最近做到的神题真多...（萌萌哒，$LCA$，再加上这个...

思考一下怎么表示状态。如果我们已经第一个点亮了一个点（假设其他点都未被点亮），那么我们必须先点亮这两个子树。由于必须联通而且必须只能点子树，下一步只能点亮两个儿子之一。而点亮的那个儿子的子树肯定要先被全部点亮，然后才能点亮另一个一个子树。

如果我们忽略上一个点点在哪里的话，那么我们事实上发现上述的过程是一个无后效性的子结构，这个东西就可以设置成状态了。但这个事情的最关键的问题在于我们忽略了上一个点点在哪里，那我们怎样去表示这个$D_{u,v} \times a_v$的过程呢？

这个时候我们发现我们不知道上一个点点在哪里，但是我们可以知道下一个点点在哪里。如果我们发现我们点完了一个子树，我们现在只有两种情况：

1. 我们所有目前点完的点构成了一颗更大的完整的子树，这个时候我们就只能去点这个更大的完整的子树的
根节点的父节点。

2. 我们现在所有点完的点不能构成一棵更大的完整的子树，这个时候我们就必须点完最近的没有点的一个子树。

事实上只有两种情况，也就是到某个祖先，或者某个祖先的兄弟。

所以我们用$dp[i][j][0]$表示点完以第$i$个点为根节点的子树之后，再去点其第$j$个祖先的过程需要的最小花费，$dp[i][j][1]$表示点完以第$i$个点为根节点的子树之后，再去点其第$j$个祖先的另一个儿子的过程需要的最小花费。注意到这是一个完全二叉树，所以保证了我们的状态的数目是$O(n \log{n})$的。

- - -

转移方程太长，不写了，简单说一说如何转移。

简单来说，需要分成三类讨论：没有儿子；只有一个儿子；有两个儿子。

没有儿子的没啥好说的。有一个儿子的就相当于不变结束节点进入这个子树。有两个儿子的就有两种情况：先进左子树和先进右子树，分开讨论即可。状态转移是$O(1)$的。

具体来说的话看代码注释。

以上只是我们计算答案的一个辅助。

- - -

我们发现，如果选定一个点作为固定的起点，那么这个东西它点的顺序就是确定的。所以我们按照点灯规则确定子树的顺序，再加上子树之间转移的代价，就可以推出答案。这里需要对有没有兄弟节点进行分类讨论。由于树的高度是严格$O(\log n)$的，所以我们的每个点的递推也是$O(\log n)$的。

时间复杂度与空间复杂度都是$O(n \log n)$。


## 代码

{% fold %}
```cpp
#include <cstring>
#include <cstdio>
#include <algorithm>
#include <cctype>
using namespace std;
#define ll long long

const int SIZE = 1024*1024;char ibuf[SIZE],*s,*t;

inline char read(){
    if(s==t) t=(s=ibuf)+fread(ibuf,1,SIZE,stdin);
    return s==t?-1:*s++;
}

template <typename T>
inline void read(T &x){
    static char c;bool iosig;
    for(c=read(),iosig=0;!isdigit(c);c=read()){
        if(c==-1) return;
        iosig |= (c=='-');
    }
    for(x=0;isdigit(c);c=read())
        x = (((x<<2)+x)<<1) + (c^48);
    if(iosig) x = -x;
}

const int MAXN = 210000,logn = 20;

int n;
ll num[MAXN]; 
ll dp[MAXN][logn][2];
//点亮了i这个节点和子树的所有节点，下一个点亮到？级祖先的？儿子的最小代价 
ll dis[MAXN][logn];
//从i节点向上j个节点的长度 

#define p(i,j) (((1<<(j-1))<=i)?(i>>j):-1)
//i的j祖先，上设虚拟0节点，其他均为-1
//num[0] = 0,dis[1][1] = 0
#define b(i,j) ((i>>(j-1))^1)
//i的j祖先的另一个儿子
#define lson (i<<1)
#define rson ((i<<1)|1)

void init(){
    read(n);
    for(int i = 1;i<=n;i++)
        read(num[i]);
    dis[1][1] = 0;
    for(int i = 2;i<=n;i++){
        read(dis[i][1]);
        for(int j = 2;~p(i,j);j++)
            dis[i][j] = dis[p(i,1)][j-1] + dis[i][1];
    }
}

void solve(){
    //0 祖先 1 兄弟 
    for(int i = n;i >= 1;--i){
        for(int j = 1;~p(i,j);j++){
            dp[i][j][0] = dp[i][j][1] = 0x3f3f3f3f3f3f3f3f;
            if((i<<1) > n){//一个儿子都没有 
                dp[i][j][0] = dis[i][j] * num[p(i,j)];
                dp[i][j][1] = (dis[i][j] + dis[b(i,j)][1]) * num[b(i,j)];
            }
            else if(((i<<1)|1) > n){//只有左儿子 
            	//注意要加上从根节点到儿子的代价
                dp[i][j][0] = dp[lson][j+1][0] + dis[lson][1] * num[lson];
                dp[i][j][1] = dp[lson][j+1][1] + dis[lson][1] * num[lson];
            }
            else{//有两个儿子
            	//两种转移方式，左->右 or 右->左 ，注意要加上从根节点到儿子的代价
                dp[i][j][0] = min(dp[i][j][0],dp[lson][1][1]+dp[rson][j+1][0] + dis[lson][1] * num[lson]);
                dp[i][j][0] = min(dp[i][j][0],dp[rson][1][1]+dp[lson][j+1][0] + dis[rson][1] * num[rson]);
                dp[i][j][1] = min(dp[i][j][1],dp[lson][1][1]+dp[rson][j+1][1] + dis[lson][1] * num[lson]);
                dp[i][j][1] = min(dp[i][j][1],dp[rson][1][1]+dp[lson][j+1][1] + dis[rson][1] * num[rson]);
            }
        }
    }
    //计算答案
    ll ans = 0x3f3f3f3f3f3f3f3f;
    for(int s = 1;s<=n;s++){
    	//从s点开始，先点亮所有s子树的节点和s的父亲
        ll tmp = dp[s][1][0];
        for(int i = p(s,1),last = s;~i;i = p(i,1),last = p(last,1)){
            //last节点的子树即i节点已经被点亮，现在要点亮i的父亲节点
            //有兄弟，就需要去先点亮兄弟，再点亮i的父亲（last兄弟的祖父）节点
            if(b(last,1) <= n)
            	tmp += dis[b(last,1)][1] * num[b(last,1)] + dp[b(last,1)][2][0];
            else
                tmp +=  dis[i][1] * num[p(i,1)];
        	//加上从i到i的父亲节点的代价
        }
        ans = min(ans,tmp);
    }
    printf("%lld\n",ans);
}

int main(){
    init();
    solve();
    return 0;
}
```
{% endfold %}