#表示matplotlib的pyplot子库，它提供了和matlab类似的绘图API
import  matplotlib.pyplot as plt
#表示可以调用sklearn中的 linear_model模块进行线性回归。
from sklearn import  linear_model
import numpy as np
#建立datasets_X和datasets_Y用来存储数据中的房屋尺寸和房屋成交价格。
datasets_X =[]
datasets_Y =[]
fr =open('prices.txt','r')
#一次读取整个文件。
lines =fr.readlines()
#逐行进行操作，循环遍历所有数据
for line in lines:
    #去除数据文件中的逗号
    items =line.strip().split(',')
    #将读取的数据转换为int型，并分别写入datasets_X和datasets_Y。
    datasets_X.append(int(items[0]))
    datasets_Y.append(int(items[1]))
#求得datasets_X的长度，即为数据的总数。
length =len(datasets_X)
#将datasets_X转化为数组， 并变为二维，以符合线性回 归拟合函数输入参数要求
datasets_X= np.array(datasets_X).reshape([length,1])
#将datasets_Y转化为数组
datasets_Y=np.array(datasets_Y)

minX =min(datasets_X)
maxX =max(datasets_X)
#以数据datasets_X的最大值和最小值为范围，建立等差数列，方便后续画图。
X=np.arange(minX,maxX).reshape([-1,1])

linear =linear_model.LinearRegression()
linear.fit(datasets_X,datasets_Y)#调用线性回归模块，建立回归方程，拟合数据
#查看回归方程系数
print('Cofficients:',linear.coef_)
#查看回归方程截距
print('intercept',linear.intercept_)

#3.可视化处理
#scatter函数用于绘制数据 点，这里表示用红色绘制数据点；
plt.scatter(datasets_X,datasets_Y,color='red')
#plot函数用来绘制直线，这 里表示用蓝色绘制回归线；
#xlabel和ylabel用来指定横纵坐标的名称
plt.plot(X,linear.predict(X),color='blue')
plt.xlabel('Area')
plt.ylabel('Price')
plt.show()