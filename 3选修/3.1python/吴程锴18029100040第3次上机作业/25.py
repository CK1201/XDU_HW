import numpy as np
import sklearn.cluster as skc
from sklearn import metrics
import matplotlib.pyplot as plt

mac2id = dict()
onlinetimes = []
f = open(r'学生月上网时间分布-TestData.txt', encoding='utf-8')
for line in f:
    # 读取每条数据中的mac地址，开始上网时间，上网时长
    mac = line.split(',')[2]
    onlinetime = int(line.split(',')[6])
    starttime = int(line.split(',')[4].split(' ')[1].split(':')[0])

    # mac2id是一个字典：key是mac地址，value是对应mac地址的上网时长以及开始上网时间
    if mac not in mac2id:
        mac2id[mac] = len(onlinetimes)
        onlinetimes.append((starttime, onlinetime))
    else:
        onlinetimes[mac2id[mac]] = [(starttime, onlinetime)]
real_X = np.array(onlinetimes).reshape((-1, 2))

# 调用DBSCAN方法训练，labels为每个数据的簇标签
X = real_X[:, 0:1]
db = skc.DBSCAN(eps=0.01, min_samples=20).fit(X)
labels = db.labels_

# 打印数据被记上的标签，计算标签为-1,即噪声数据的比例
print('Labels:')
print(labels)
raito = len(labels[labels[:] == -1]) / len(labels)
print('Noise raito:', format(raito, '.2%'))

# 计算簇的个数并打印，评价聚类效果
n_clusters_ = len(set(labels)) - (1 if -1 in labels else 0)

print('Estimated number of clusters: %d' % n_clusters_)
print("Silhouette Coefficient: %0.3f" % metrics.silhouette_score(X, labels))

# 打印各簇标号以及各簇内数据
for i in range(n_clusters_):
    print('Cluster ', i, ':')
    print(list(X[labels == i].flatten()))

plt.hist(X, 24)
plt.show()