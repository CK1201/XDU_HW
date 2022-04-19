from tvtk.api import tvtk
import numpy as np
from scipy.spatial import ConvexHull
import matplotlib.pyplot as plt
def convexhull(ch3d): #1 定义凸多面体 tvtk 的 Polydata() 对象
    poly = tvtk.PolyData()
    poly.points = ch3d.points
    poly.polys = ch3d.simplices
    #2 定义凸多面体顶点的小球
    sphere = tvtk.SphereSource(radius = 0.02)
    points3d = tvtk.Glyph3D()
    points3d.set_source_connection(sphere.output_port)
    points3d.set_input_data(poly)
    #3 绘制凸多面体的面，设置半透明度
    m1 = tvtk.PolyDataMapper()
    m1.set_input_data(poly)
    a1 = tvtk.Actor(mapper=m1)
    a1.property.opacity = 0.3
    #4 绘制凸多面体的边，设置为红色
    m2 = tvtk.PolyDataMapper()
    m2.set_input_data(poly)
    a2 = tvtk.Actor(mapper=m2)
    a2.property.representation = 'wireframe'
    a2.property.line_width = 2.0
    a2.property.color = (1.0,0,0)
    #5 绘制凸多面体的顶点，设置为绿色
    m3 = tvtk.PolyDataMapper(input_connection=points3d.output_port)
    a3 = tvtk.Actor(mapper = m3)
    a3.property.color = (0.0,1.0,0.0)
    return [a1,a2,a3]
#4. 定义绘制场景用的函数
def ivtk_scene(actors):
    from tvtk.tools import ivtk
    win = ivtk.IVTKWithCrustAndBrowser() #创建 crust 窗口
    win.open()
    win.scene.add_actor(actors)
    dialog = win.control.centralWidget().widget(0).widget(0) #窗口错误修正
    from pyface.qt import QtCore
    dialog.setWindowFlags(QtCore.Qt.WindowFlags(0x00000000))
    dialog.show()
    return win

np.random.seed(42)
points3d=np.random.rand(40,3)
ch3d=ConvexHull(points3d)
actors=convexhull(ch3d)
win=ivtk_scene(actors)
