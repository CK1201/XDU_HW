Weight=eval(input('体重(kg)='))
Height=eval(input('身高(m)='))
BMI=Weight/Height/Height

def Int(BMI):
    if BMI<18.5:
        return '国际偏瘦'
    elif BMI<25:
        return '国际正常'
    elif BMI<30:
        return '国际偏胖'
    else:
        return '国际肥胖'

def Dom(BMI):
    if BMI<18.5:
        return '国内偏瘦'
    elif BMI<24:
        return '国内正常'
    elif BMI<28:
        return '国内偏胖'
    else:
        return '国内肥胖'

print(Int(BMI)+' '+Dom(BMI))