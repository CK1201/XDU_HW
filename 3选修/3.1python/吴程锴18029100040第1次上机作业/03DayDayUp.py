ability=1
change=0.01
for day in range(365):
    if day%7==6 | day%7==0:
        ability=ability*(1-change)
    else:
        ability=ability*(1+change)
print('一年后结果：',ability)


def dayUp(df):
    dayup=1
    for i in range(365):
        if i%7 in [6,0]:
            dayup=dayup*(1-0.01)
        else:
            dayup=dayup*(1+df)
    return dayup

dayfactor=0.01
while(dayUp(dayfactor)<ability):
    dayfactor+=0.001

print('每天要努力：',dayfactor)