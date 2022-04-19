from tvtk.api import tvtk
from Tvtkfunc import ivtk_scene,event_loop

def read_data():    #导入数据
    plot3d = tvtk.MultiBlockPLOT3DReader(
        xyz_file_name="comxyz.bin", #网格文件
        q_file_name="combq.bin", #开启动力学结果文件
        scalar_function_number = 100, #设置标量数据数量
        vector_function_number=200, #设置矢量数据数量
    )   #读入Plot3D数据
    plot3d.update() #让plot3D计算器输出数据
    return plot3d


plot3d = read_data()
grid = plot3d.output.get_block(0)   #获取读入的数据集对象

#对数据集中的数据进行随机选取，每50个点选择一个点,是对数据进行降采样
mask = tvtk.MaskPoints(random_mode=True,on_ratio=50)
mask.set_input_data(grid)   #将grid和mask相连
#创建表示箭头的PolyData数据集
glyph_source = tvtk.ArrowSource()
#在Mask采样后的PolyData数据集每个点上放置一个箭头
#箭头的方向（速度方向），长度<箭头越大，表示标量越大>和颜色<也表示标量大小，红色小，蓝色大>（两个都表示密度）由于点对应的矢量和标量数据决定

#将上面的降采样数据与箭头符号化相关联
glyph = tvtk.Glyph3D(input_connection=mask.output_port,
                     scale_factor=4)    #scale_factor符号的共同放缩系数
glyph.set_source_connection(glyph_source.output_port)

m = tvtk.PolyDataMapper(scalar_range=grid.point_data.scalars.range, #设置映射器的变量范围属性
                        input_connection=glyph.output_port)
a = tvtk.Actor(mapper=m)
a.property.opacity = 0.5    #设置透明度为0.5

win = ivtk_scene(a)
win.scene.isometric_view()
event_loop()