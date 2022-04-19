import zipfile
import numpy as np
from mayavi import mlab

# 读取压缩文件
hgt = zipfile.ZipFile('5.1.6 N36W113.hgt.zip').read('N36W113.hgt')
data = np.fromstring(hgt, '>i2')
data.shape = (3601, 3601)
data = data.astype(np.float32)
data = data[:1000, 900:1900]
data[data == -32768] = data[data > 0].min()

# 渲染地形hgt的数据data
mlab.figure(size=(400, 320), bgcolor=(0.16, 0.28, 0.46))
mlab.surf(data, colormap='gist_earth', warp_scale=0.2,
          vmin=1200, vmax=1610)

# 清空内存
del data
# 创建交互式的可视化窗口
mlab.view(-5.9, 83, 570, [5.3, 20, 238])
mlab.show()