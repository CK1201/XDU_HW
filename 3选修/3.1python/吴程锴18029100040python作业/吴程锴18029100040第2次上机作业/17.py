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

con = tvtk.ContourFilter()  #创建等值面对象
con.set_input_data(grid)    #将网格与其绑定
con.generate_values(10,grid.point_data.scalars.range) #指定轮廓数和数据范围 其中轮廓数越大，越丰富多彩  #映射颜色最小红色，最大蓝色

m = tvtk.PolyDataMapper(scalar_range=grid.point_data.scalars.range, #设置映射器的变量范围属性
                        input_connection=con.output_port)
a = tvtk.Actor(mapper=m)
a.property.opacity = 0.5    #设置透明度为0.5

win = ivtk_scene(a)
win.scene.isometric_view()
event_loop()