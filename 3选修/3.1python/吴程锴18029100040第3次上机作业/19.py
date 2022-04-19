from mayavi import mlab
from os.path import join
import tarfile

# 读取tar压缩文件
dragon_tar_file = tarfile.open('dragon.tar.gz')
try:
    os.mkdir('dragon_data')
except:
    pass
dragon_tar_file.extractall('dragon_data')
dragon_tar_file.close()
dragon_ply_file = join('dragon_data', 'dragon_recon', 'dragon_vrip.ply')

# 渲染dragon ply文件
mlab.pipeline.surface(mlab.pipeline.open(dragon_ply_file))
mlab.show()

# 删除解压的文件夹
import shutil

shutil.rmtree('dragon_data')