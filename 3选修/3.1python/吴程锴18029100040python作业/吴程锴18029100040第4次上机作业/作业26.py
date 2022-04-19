# 1 建立工程，导入sklearn 相关工具包
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.datasets import load_iris
# 2 加载数据并进行降维
data = load_iris()
y = data.target
x = data.data
pca = PCA(n_components = 2)
reduced_x = pca.fit_transform(x)
# 3 按类别对降维后的数据进行保存
red_x,red_y = [],[]
blue_x,blue_y = [],[]
green_x,green_y = [],[]
for i in range(len(reduced_x)):
    if y[i] == 0:
        red_x.append(reduced_x[i][0])
        red_y.append(reduced_x[i][1])
    elif y[i] == 1:
        blue_x.append(reduced_x[i][0])
        blue_y.append(reduced_x[i][1])
    else:
        green_x.append(reduced_x[i][0])
        green_y.append(reduced_x[i][1])
# 4 降维后数据可视化
plt.scatter(red_x,red_y, c = 'r',marker = 'x')
plt.scatter(blue_x,blue_y, c = 'b',marker = 'D')
plt.scatter(green_x,green_y, c = 'g',marker = '.')
plt.show()