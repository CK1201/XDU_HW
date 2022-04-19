#import numpy as np
#print('方差=',np.var(a))
#print('中位数=',np.median(a))
#print('平均值=',np.mean(a))

a=[5,1,2,3,4,3]

def var(data):
    datamean=mean(data)
    size = len(data)
    sig=0;
    for i in range(size):
        sig=sig+pow(data[i]-datamean,2)
    return sig/size

def median(data):
    data.sort()
    size=len(data)
    if size%2==0:
        index1=int(size/2-1)
        index2 = index1+1
        return (data[index1]+data[index2])/2
    else:
        index = int((size-1) / 2)
        return data[index]


def mean(data):
    datasum=sum(data)
    size=len(data)
    return datasum/size

print('方差=',var(a))
print('中位数=',median(a))
print('平均值=',mean(a))