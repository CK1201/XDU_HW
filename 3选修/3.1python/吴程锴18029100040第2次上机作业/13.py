from random import random
import math

rate_A = eval(input("A的胜率(%):"))
rate_B = eval(input("B的胜率(%):"))
times = eval(input("次数:"))
win_A = 0
win_B = 0

for i in range(times):
    rate = random() * 100
    if rate < rate_A:
        win_A = win_A + 1
    else:
        win_B = win_B + 1
print("A获胜次数:{0}     B获胜次数:{1}   A与B获胜比值:{2}".format(win_A,win_B,win_A/win_B))

