Temperature=input()
Unit=Temperature[-1]
Num=eval(Temperature[0:-1])
if Unit=='C':
    T=str(Num*1.8+32)
    T=T+'F'
elif Unit=='F':
    T=str((Num-32)/1.8)
    T = T+'C'
else:
    print('输入格式错误')
print(T)