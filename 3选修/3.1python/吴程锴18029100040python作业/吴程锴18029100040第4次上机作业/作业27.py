import matplotlib.pyplot as plt
from sklearn import decomposition
# 加载PCA算法包
from sklearn.datasets import fetch_olivetti_faces
# 加载人脸数据集
from numpy.random import RandomState

# 加载RandomState用于创建随机种子

n_row, n_col = 2, 3
# 设置图像展示时的排列情况，2行三列
n_components = n_row = n_col
# 设置提取的特征的数目
image_shape = (64, 64)
# 设置人脸数据图片的大小
dataset = fetch_olivetti_faces(shuffle=True, random_state=RandomState(0))
faces = dataset.data  # 加载数据，并打乱顺序


# 设置图像的展示方式
def plot_gallery(title, images, n_col=n_col, n_row=n_row):
    plt.figure(figsize=(2. * n_col, 2.26 * n_row))  # 创建图片，并指定大小
    plt.suptitle(title, size=16)  # 设置标题及字号大小
    for i, comp in enumerate(images):
        plt.subplot(n_row, n_col, i + 1)  # 选择画制的子图
        vmax = max(comp.max(), -comp.min())
        plt.imshow(comp.reshape(image_shape), cmap=plt.cm.gray, interpolation='nearest', vmin=-vmax,
                   vmax=vmax)  # 对数值归一化，并以灰度图形式显示
        plt.xticks(())
        plt.yticks(())  # 去除子图的坐标轴标签
    plt.subplots_adjust(0.01, 0.05, 0.99, 0.93, 0.04, 0.)


# 创建特征提取的对象NMF，使用PCA作为对
estimators = [('Eigenfaces - PCA using randomized SVD', decomposition.PCA(n_components=6, whiten=True)),
              ('Non-negative components - NMF', decomposition.NMF(n_components=6, init='nndsvda', tol=5e-3))]
# NMF和PCA实例，将它们放在一个列表中

# 降维后数据点的可视化
for name, estimators in estimators:  # 分别调用PCA和NMF
    estimators.fit(faces)  # 调用PCA或NMF提取特征
    components_ = estimators.components_  # 获取提取特征
    plot_gallery(name, components_[:n_components])
    # 按照固定格式进行排列
plt.show()  # 可视化