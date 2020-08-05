---
title: 「FJOI2015」火星商店问题-线段树分治+可持久化Trie
urlname: FJOI2015-shop
date: 2019-04-02 21:50:00
tags:
- 数据结构
- 线段树
- 线段树分治
- 可持久化线段树
- Trie
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

有 $n$ 个商店，每个商店都有一个特殊商品，每个人在任何时间都可以买。第一天可能没有进货，有若干次询问，而之后的每天，都有**一次**进货和若干次询问，每次进货都是某个商店进了某个编号的货，每次询问都是询问在编号为 $l$ 到 $r$ 的商店中，在 $d$ 天内进的货的编号异或 $x$ 的最大值。 

<!--more-->

## 链接

[Luogu P4585](https://www.luogu.org/problemnew/show/P4585)

## 题解

我们考虑如果没有天数限制，就是类似 「SCOI2016」美味 这样的题，我们用一个可持久化 Trie 就可以解决了。现在有时间的限制，我们用线段树套可持久化线段树貌似就可以了（，但是这个不优美qwq

那让我们学习一下线段树分治。

我们回想线段树的工作原理，本质上是将一个区间划分成 $O(\log n)$ 个区间，对于这种贡献可以累加的题目，我们就可以分治询问的时间区间到线段树的节点上，然后在线段树上跑一些什么dfs之类的就可以解决这个问题（当然，贡献不独立也是可以做的，就是需要所有的 $d$ 都相同或者能够以物品的时间来确定一个查询的贡献来自于那些物品，也就是查询的贡献来自与查询无关的地方）。

我们考虑对时间分治，线段树的下标是时间，然后每次都把询问分散到 $O(\log n)$ 个区间上，最后对答案取 $\max$ 即可。

那么我们现在总共有 $O(n \log n)$ 个询问在 $O(n)$ 个节点里面，我们考虑来处理新加进来的物品。

我们把商品对于出现的位置排序，然后我们按照时间每次都把所有询问划分到两边去，每个线段树的节点都新建一个可持久化 Trie，我们可以证明这个东西的复杂度只有 $O(n \log^2 n)$ ，因为每个物品最多出现 $O(\log n)$ 次，每次插入都是 $O(\log n)$ 的。我们再单独建立一个可持久化 Trie 处理特殊物品即可。每个线段树节点建立 Trie 的时候需要离散化保证时间复杂度正确性。

时间复杂度： $O(n \log^2 n)$ ，空间复杂度 $O(n \log n)$ 。

## 代码

```cpp
#include <bits/stdc++.h>
using namespace std;
const int MAXN = 110000,logn = 19;

int c[MAXN*logn*2][2],sum[MAXN*logn*2],totp;
struct Query{int id,l,r,x;};
struct Node{int tim,p,v;};
bool cmp(Node a,Node b){return a.p < b.p;}

vector<Query> Q[MAXN<<2];// query
vector<Node> N[MAXN<<2];// node / number

int query(int lc,int rc,int v){
  int ans = 0;
  for(int i = logn-1;i>=0;--i){
    ans <<= 1;int t = (v>>i) & 1;
    if(sum[c[rc][t^1]] - sum[c[lc][t^1]] > 0)
      lc = c[lc][t^1],rc = c[rc][t^1],ans ^= 1;
    else  lc = c[lc][t],rc = c[rc][t];
  }
  return ans;
}

void modify(int &x,int pre,int v){
  int now = x = ++totp;
  for(int i = logn-1;i>=0;--i){
    int t = (v>>i) & 1;
    c[now][t] = ++totp,c[now][t^1] = c[pre][t^1];
    sum[now] = sum[pre]+1;
    now = c[now][t],pre = c[pre][t];
  }
  sum[now] = sum[pre] + 1;
}

#define mid ((l+r)/2)
#define lson (x<<1)
#define rson (x<<1|1)
void addq(int x,int l,int r,int ql,int qr,Query q){
  if(qr < l || ql > r || ql > qr) return;
  if(ql <= l && r <= qr) Q[x].push_back(q);
  else{
    if(ql <= mid) addq(lson,l,mid,ql,qr,q);
    if(qr >= mid+1) addq(rson,mid+1,r,ql,qr,q);
  }
}

int rt[MAXN],tmp[MAXN],ans[MAXN];

void solve(int x,int l,int r){
  if(N[x].size() == 0) return;
  tmp[0] = totp = 0;// 清空 Trie
  tmp[++tmp[0]] = 0,rt[1] = 0;
  for(int i = 0;i < (int)(N[x].size());i++){
    tmp[++tmp[0]] = N[x][i].p;
    rt[tmp[0]] = 0,modify(rt[tmp[0]],rt[tmp[0]-1],N[x][i].v);
    if(l == r) continue;
    if(N[x][i].tim <= mid) N[lson].push_back(N[x][i]);
    else                   N[rson].push_back(N[x][i]);
  }
  for(int i = 0;i < (int)(Q[x].size());i++){
    int L = upper_bound(tmp+1,tmp+tmp[0]+1,Q[x][i].l-1) - tmp - 1;
    int R = upper_bound(tmp+1,tmp+tmp[0]+1,Q[x][i].r) - tmp - 1;
    ans[Q[x][i].id] = max(ans[Q[x][i].id],query(rt[L],rt[R],Q[x][i].x));
  }
  if(l == r) return;
  solve(lson,l,mid),solve(rson,mid+1,r);
}

int n,m,tott,totq;
int val[MAXN];

int main(){
  scanf("%d %d",&n,&m);
  for(int i = 1;i<=n;i++) scanf("%d",&val[i]);
  totp = 0;
  for(int i = 1;i<=n;i++) rt[i] = 0,modify(rt[i],rt[i-1],val[i]);
  int op,L,R,x,d,s,v;
  for(int i = 1;i<=m;i++){
    scanf("%d",&op);
    if(op == 0){
      scanf("%d %d",&s,&v);
      tott++;
      N[1].push_back((Node){tott,s,v});
    }
    else if(op == 1){
      scanf("%d %d %d %d",&L,&R,&x,&d);
      ++totq;
      addq(1,1,m,tott-d+1,tott,(Query){totq,L,R,x});
      ans[totq] = query(rt[L-1],rt[R],x);
    }
  }
  sort(N[1].begin(),N[1].end(),cmp);
  solve(1,1,m);
  for(int i = 1;i<=totq;i++) printf("%d\n",ans[i]);
  return 0;
}
```


