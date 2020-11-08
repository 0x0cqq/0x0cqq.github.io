---
##-- draftstate --##
draft: false
##-- page info --##
title: "第一次开发事故报告"
date: 2020-11-08T23:51:30+08:00
categories:
- 开发
tags:
- 后端
series:
##-- page setting --##
# slug: ""
# type: ""
pinned: false
libraries:
- mathjax 
##-- toc setting --##
hideToc: false
enableToc: true
enableTocContent: true
---

谨以此份报告记录我第一次（稍微有一点算）正经的开发和第一次开发事故的过程和反省，留作以后（也许有的）开发生活中回看，算是开发的初心和初念吧。

<!--more-->

## 事故经过

### 开发目的

2020年11月1日18时43分，游导找到刚加入开发组的我，交给我一份任务：

>打算做一个男生节小游戏，女生们每人录一段“男生节快乐”，打乱后，同学们猜一个顺序，公众号告诉他猜对了几个人， 然后首次猜对的同学获得奖励🤔

### 开发过程

当日21时33分，提交答案功能初步上线，智能返回一个数字：“答对个数”。

当日21时58分，加入了查看本次成绩和最好成绩，按照用户id（至少是我当时认为的用户id）阻止频繁提交的功能。

当日22时16分，加入了查看最好成绩的提交时间的功能。

其间，还将抽签功能的代码分开到了另一个文件 `drawing.py` 中，把提交答案功能分开到了 `check_name.py`

此时主要代码如下：

`check_name.py`

```python
def check_list(answer_list, user_list):  # 计算匹配个数，返回 -1 代表长度不一致
    match_cnt = 0
    try:
        assert len(answer_list) == len(user_list)
        for i in range(len(answer_list)):
            if answer_list[i] == user_list[i]:
                match_cnt += 1
    except:
        match_cnt = -1
    return match_cnt

def check_name(username, line):
    grade = check_list(ans, line[1:])
    response = ""
    if grade == -1:
        response = "没有提交有效答案！"
    else:
        now_time = time()
        result = (time(), username, grade)
        if result_rank.__contains__(username) and now_time - last_time[username] < 5:
            response = "您提交的太过频繁，请稍后再试。"
        else:
            last_time[username] = now_time
            result_list.append((now_time, result))
            if not result_rank.__contains__(username) or result_rank[username][2] < result[2]:
                result_rank[username] = result
            response = "提交成功！您本次的成绩是" + str(grade) + "分。"

    if result_rank.__contains__(username):
        response = response + "您目前的最好成绩是" + \
            str(result_rank[username][2]) + "分，"
        response = response + "提交于" + \
            get_usual_time(result_rank[username][0]) + "。"
    else:
        response = response + "您目前还没有有效成绩。"
    return response
```

`rylzb.py`

```python
        if msgType == 'text':
            msgText = xml.find('Content').text
            line = msgText.split()
            if line[0] == '抽签': # 抽签功能
                return reply_text(toUser, fromUser, drawing(line))
            elif line[0] == '提交答案': # 提交答案功能
                return reply_text(toUser, fromUser, check_name(toUser,line))
            else:
                return reply_text(toUser, fromUser, '你在说什么，我听不懂。')
```

2020年11月8日公众号方面的工作准备完毕，于是把 `check_name.py` 中的 `answer_list` 替换成女生的人名名单。

同时增加功能：增加答案不合法类型，如果答案不仅是汉字或答案出现重复，都会返回不合法信息。

当日20时20分，公众号发布推送，随后用户数据开始出现。

20时27分44秒，公众号接到第一条提交答案请求。

20时36分，通过用户反馈和后台log发现程序对于用户“最好成绩”反馈有问题，进一步发现程序对于用户id的识别有问题

20时37分，在微信群中通知程序出现了bug。此时并未将程序下线。

20时37-40分，对代码进行修改，将所有用户相关的内容（最好成绩，同一用户提交时间限制）注释掉，只保留了判断正确个数的功能。

20时41分55秒左右，对原来的程序进行替换。

20时49分左右，试图查找错误，（我认为，但事实上没有）换用 `toUser` 变量用作用户 id。没有起效，用户ID仍然全部相同。（因为事实上不同的是 `fromUser` ，而我以为我用的是 `fromUser`，但事实上不是）

20时55分左右，在总共第200次提交的时候，有用户已经正确猜出了14个名字，游戏结束。游戏仅仅进行了28分钟，并且获得答案的方式是通过（部分）试验的方式。

20时50分-21时10分左右，对于分数反馈进行模糊化处理，代码如下：

```python
message = ""
if 0 <= grade and grade <= 2 :
    message = "0~2"
elif 2 < grade and grade <= 4:
    message = "3~4"
elif 4 < grade and grade <= 6:
    message = "5~6"     
elif 6 < grade and grade <= 8:
    message = "7~8"
elif 8 < grade and grade <= 10:    
    message = "9~10"     
elif 10 < grade and grade <= 13:  
    message = "11~13"
else:
    message = "14"     
response = "提交成功！正确" + str(message) + "个。"
```

21时11分左右，对原来的程序进行替换，

21时13分左右，发现 `toUser` 是用户id，对代码进行更改，增添了最佳成绩和提交间隔限制。并替换程序。

## 事故原因

### 直接原因

1. 错误使用了微信提供的数据 `fromUser` 和 `toUser` ，导致对用户的识别失效；从而导致不能有效阻止通过短时间试错法得到正确答案；
2. 没有加入更严格的答案反馈系统，在一开始就不返回真正分数，只返回区间；从而导致试错成本太低。

### 深层原因

1. 在写代码的时候就没有做好写很强判断的准备，导致程序有些先天不足；
2. 对上线后的可能情况思想准备不足，在遇到大量请求的时候脑子有些不太转；
3. 发现bug之后，没有及时撤下出错的程序，而是挂着修改，导致后面想改的时候反而有所顾忌；
4. 测试的时候，只有我一个人测试；没有多人测试（事实上有，但我没有关注具体输出），也就没有发现userid大家都一样的问题。

## 经验总结

1. “我向来是不惮以最坏的恶意，来推测用户的，然而我还不料......”
2. 写的时候就把功能写丰富一点，它可以用不到，但不能没有；
3. 应该测试到所有的功能，找多人，多次测试；
4. 应该挑人少的时候上线功能；
5. 不能指望着上线了之后再去补 bug ，务必要保证代码没错再交上去；
6. 发现 bug，立刻下线：用户暂时用不了不要紧，用户搞出点大新闻可就麻烦了；
7. 发现 bug 之后，要冷静一点，冷静的修改和测试；
8. 发现 bug 之后，要积极的与用户沟通，不能自己闷改。

## 最后

云服务器也不便宜，在上面瞎搞的机会要好好珍惜啊。之后大概不太会有人一年出快好几百块钱送你服务器玩吧。

每一次开发的机会都要重视啊。开发的时候，面对的不仅是自己，面对的不仅是 OJ 的 Judger，而是许许多多活生生的人，要慎重呐。

