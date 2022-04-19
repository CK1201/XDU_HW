from numpy import sqrt, sin, mgrid
from traits.api import HasTraits, Instance
from traitsui.api import View, Item
from tvtk.pyface.scene_editor import SceneEditor
from mayavi.tools.mlab_scene_model import MlabSceneModel
from mayavi.core.ui.mayavi_scene import MayaviScene

class ActorViewer(HasTraits):
    # 场景模型
    scene = Instance(MlabSceneModel, ())
    # 建立视图
    view = View(Item(name='scene',
                    editor=SceneEditor(scene_class=MayaviScene),
                    show_label=False,
                    resizable=True,
                    height=500,
                    width=500),
                resizable=True)

    def __init__(self, **traits):
        HasTraits.__init__(self, **traits)
        self.generate_data()

    def generate_data(self):
        # 建立数据
        X, Y = mgrid[-2:2:100j, -2:2:100j]
        R = 10*sqrt(X**2 + Y**2)
        Z = sin(R)/R
        # 绘制数据
        self.scene.mlab.surf(X, Y, Z, colormap='cool')

a = ActorViewer()
a.configure_traits()