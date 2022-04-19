import turtle

def koch(size,n):
    if n==0:
        turtle.fd(size)
    else:
        for angle in [0,60,-120,60]:
            turtle.left(angle)
            koch(size/3,n-1)

turtle.setup(400,350,200,200)
size=200
n=3
turtle.penup()
turtle.fd(-size/2)
turtle.seth(-90)
turtle.fd(-size/2+50)
turtle.seth(0)
turtle.pensize(2)
turtle.pendown()
turtle.pencolor("red")

koch(size,n)
turtle.seth(-120)
koch(size,n)
turtle.seth(-240)
koch(size,n)
turtle.exitonclick()