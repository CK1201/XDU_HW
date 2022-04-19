from random import random
pi1=0
for k in range(0,99):
    pi1=pi1+(4/(8*k+1)-2/(8*k+4)-1/(8*k+5)-1/(8*k+6))/pow(16,k)
print(pi1)

#MC
hits=0
all=99999
for i in range(all):
    x, y = random(), random()
    dist= pow(x ** 2 + y ** 2, 0.5)

    if dist<= 1.0:
        hits = hits + 1
pi2=hits/all
print(pi2*4)