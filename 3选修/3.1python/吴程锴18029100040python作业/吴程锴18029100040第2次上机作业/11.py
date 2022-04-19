#AutoTrace.py
import turtle
turtle.setup(800,600)
turtle.pencolor("red")
turtle.pensize(5)
turtle.speed(5)

data = []
f = open("data.txt","r") #打开文件
for line in f:
    line = line.replace('\n','')
    data.append(list(map(eval,line.split(','))))
f.close()

for i in range(len(data)):
    turtle.pencolor(data[i][3],data[i][4],data[i][5])
    turtle.fd(data[i][0])
    turtle.left(data[i][2]) if data[i][1] == 0 else turtle.right(data[i][2])
turtle.done


