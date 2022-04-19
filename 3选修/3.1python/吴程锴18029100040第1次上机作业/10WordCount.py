import jieba
with open("hamlet.txt", "r") as f:  # 打开文件
    data1 = f.read()  # 读取文件
    #print(data1)
with open("threekingdoms.txt", "r",encoding='utf-8') as f:  # 打开文件
    data2 = f.read()  # 读取文件
    #print(data2)
#
words=data1.split()
counts={}
for word in words:
    counts[word]=counts.get(word,0)+1
items=list(counts.items())
items.sort(key=lambda x:x[1],reverse=True)
for i in range(10):
    word,count=items[i]
    print("{0:<10}{1:>5}".format(word,count))
#
excludes={'将军','却说','荆州','二人','不可','不能','如此'}
words=jieba.lcut(data2)
counts={}
for word in words:
    if len(word)==1:
        continue
    elif word=='诸葛亮' or word=="孔明曰":
        rword="孔明"
    elif word=='关公' or word=='云长':
        rword = "关羽"
    elif word=='玄德曰' or word=='玄德':
        rword = "刘备"
    elif word=='孟德' or word=='丞相':
        rword = "曹操"
    else:
        rword=word
    counts[word] = counts.get(rword, 0) + 1
for word in excludes:
    del(counts[word])
items=list(counts.items())
items.sort(key=lambda x:x[1],reverse=True)
for i in range(5):
    word,count=items[i]
    print("{0:<10}{1:>5}".format(word,count))

