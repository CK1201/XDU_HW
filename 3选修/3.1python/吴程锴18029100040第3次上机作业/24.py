import numpy as np
from sklearn.cluster import KMeans
#定义数据导入方法
def loadData(filePath):
    fr=open(filePath,'r+')  #读写打开一个文本文件
    lines=fr.readlines()    #一次读取整 个文件（类似于.read())
    retData=[]              #城市各项信息
    retCityName=[]          #城市名称
    for line in lines:
        items=line.strip().split(",")
        retCityName.append(items[0])
        retData.append([items[i] for i in range(1,len(items))])
        #print(retCityName)
    return retData,retCityName


#加载数据，创建K-means算法实例，并进行训练，获得标签
if __name__=='__main__':
    filepath='city.txt'
    data,cityName=loadData(filepath)  #利用loadData方法读取数据
    km=KMeans(n_clusters=3)              #创建实例
    label=km.fit_predict(data)          #调用Kmeans() fit_predict()方法进行计算
    expenses=np.sum(km.cluster_centers_,axis=1)
    #print(expenses)
    CityCluster=[[],[],[]]      #将城市 按label分成设定的簇，将每个簇的城市输出
    for i in range(len(cityName)):
        CityCluster[label[i]].append(cityName[i])
    for i in range(len(CityCluster)):
        print("平均花费:%.2f" %expenses[i])
        print(CityCluster[i])

