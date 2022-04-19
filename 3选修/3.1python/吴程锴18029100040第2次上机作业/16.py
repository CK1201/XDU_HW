from PIL import Image
import numpy as np

a = np.asarray(Image.open(r"fivestart.png").convert('L')).astype('float')

depth = 10.
grad = np.gradient(a)  # 梯度值，
grad_x, grad_y = grad
grad_x = grad_x * depth / 100.  # 列梯度值*0.1
grad_y = grad_y * depth / 100.

A = np.sqrt(grad_x ** 2 + grad_y ** 2 + 1.)  # 相当于grad_z=1
uni_x = grad_x / A
uni_y = grad_y / A
uni_z = 1. / A  # 梯度归一化

vec_el = np.pi / 2.2
vec_az = np.pi / 4.

dx = np.cos(vec_el) * np.cos(vec_az)
dy = np.cos(vec_el) * np.sin(vec_az)
dz = np.sin(vec_el)  # 长度为1，投影x,y,z长度

b = 255 * (dx * uni_x + dy * uni_y + dz * uni_z)
b = b.clip(0, 255)

im = Image.fromarray(b.astype('uint8'))
im.save(r"fivestart_Draw.jpg")