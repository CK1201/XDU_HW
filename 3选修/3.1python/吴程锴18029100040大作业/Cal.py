from PyQt5.QtWidgets import QApplication, QMessageBox
from PyQt5 import uic

class Stats:

    def __init__(self):
        self.ui = uic.loadUi('Cal.ui')
        self.info = ''

        self.ui.pushButton_C.clicked.connect(self.push_C)
        self.ui.pushButton_CE.clicked.connect(self.push_C)

        self.ui.pushButton_1.clicked.connect(self.push_1)
        self.ui.pushButton_2.clicked.connect(self.push_2)
        self.ui.pushButton_3.clicked.connect(self.push_3)
        self.ui.pushButton_4.clicked.connect(self.push_4)
        self.ui.pushButton_5.clicked.connect(self.push_5)
        self.ui.pushButton_6.clicked.connect(self.push_6)
        self.ui.pushButton_7.clicked.connect(self.push_7)
        self.ui.pushButton_8.clicked.connect(self.push_8)
        self.ui.pushButton_9.clicked.connect(self.push_9)
        self.ui.pushButton_0.clicked.connect(self.push_0)

        self.ui.pushButton_Plus.clicked.connect(self.push_Plus)
        self.ui.pushButton_Reduce.clicked.connect(self.push_Reduce)
        self.ui.pushButton_Multiply.clicked.connect(self.push_Multiply)
        self.ui.pushButton_Divide.clicked.connect(self.push_Divide)
        self.ui.pushButton_Modulus.clicked.connect(self.push_Modulus)

        self.ui.pushButton_div_x.clicked.connect(self.push_div_x)
        self.ui.pushButton_Square.clicked.connect(self.push_Square)
        self.ui.pushButton_Sqrt.clicked.connect(self.push_Sqrt)

        self.ui.pushButton_Del.clicked.connect(self.push_Del)

        self.ui.pushButton_Minus.clicked.connect(self.push_Minus)
        self.ui.pushButton_Point.clicked.connect(self.push_Point)
        self.ui.pushButton_Equal.clicked.connect(self.push_Equal)

###############################################################
        self.ui.pushButton_Cal.clicked.connect(self.push_Cal)

###############################################################
        self.ui.pushButton_C_2.clicked.connect(self.push_C_2)

        self.ui.pushButton_Del_2.clicked.connect(self.push_Del_2)

        self.ui.pushButton_16.clicked.connect(self.push_1_2)
        self.ui.pushButton_17.clicked.connect(self.push_2_2)
        self.ui.pushButton_18.clicked.connect(self.push_3_2)
        self.ui.pushButton_13.clicked.connect(self.push_4_2)
        self.ui.pushButton_14.clicked.connect(self.push_5_2)
        self.ui.pushButton_15.clicked.connect(self.push_6_2)
        self.ui.pushButton_10.clicked.connect(self.push_7_2)
        self.ui.pushButton_11.clicked.connect(self.push_8_2)
        self.ui.pushButton_12.clicked.connect(self.push_9_2)
        self.ui.pushButton_19.clicked.connect(self.push_0_2)

        self.ui.pushButton_Point_2.clicked.connect(self.push_Point_2)
        self.ui.pushButton_Space_2.clicked.connect(self.push_Space_2)

        self.ui.pushButton_SS_2.clicked.connect(self.push_SS_2)
        self.ui.pushButton_SV_2.clicked.connect(self.push_SV_2)
        self.ui.pushButton_TS_2.clicked.connect(self.push_TS_2)
        self.ui.pushButton_TV_2.clicked.connect(self.push_TV_2)
        self.ui.pushButton_CS_2.clicked.connect(self.push_CS_2)
        self.ui.pushButton_CV_2.clicked.connect(self.push_CV_2)

    def push_C(self):
        self.ui.textBrowser_Cal.clear()
        self.info = ''


###############数字按钮
    def push_1(self):
        self.ui.textBrowser_Cal.insertPlainText('1')
        self.info = self.info+'1'
    def push_2(self):
        self.ui.textBrowser_Cal.insertPlainText('2')
        self.info = self.info + '2'
    def push_3(self):
        self.ui.textBrowser_Cal.insertPlainText('3')
        self.info = self.info + '3'
    def push_4(self):
        self.ui.textBrowser_Cal.insertPlainText('4')
        self.info = self.info + '4'
    def push_5(self):
        self.ui.textBrowser_Cal.insertPlainText('5')
        self.info = self.info + '5'
    def push_6(self):
        self.ui.textBrowser_Cal.insertPlainText('6')
        self.info = self.info + '6'
    def push_7(self):
        self.ui.textBrowser_Cal.insertPlainText('7')
        self.info = self.info + '7'
    def push_8(self):
        self.ui.textBrowser_Cal.insertPlainText('8')
        self.info = self.info + '8'
    def push_9(self):
        self.ui.textBrowser_Cal.insertPlainText('9')
        self.info = self.info + '9'
    def push_0(self):
        self.ui.textBrowser_Cal.insertPlainText('0')
        self.info = self.info + '0'


###############加减乘除 取余
    def push_Plus(self):
        self.ui.textBrowser_Cal.insertPlainText('+')
        self.info = self.info + '+'
    def push_Reduce(self):
        self.ui.textBrowser_Cal.insertPlainText('-')
        self.info = self.info + '-'
    def push_Multiply(self):
        self.ui.textBrowser_Cal.insertPlainText('×')
        self.info = self.info + '*'
    def push_Divide(self):
        self.ui.textBrowser_Cal.insertPlainText('÷')
        self.info = self.info + '/'
    def push_Modulus(self):
        self.ui.textBrowser_Cal.insertPlainText('%')
        self.info = self.info + '%'

###############倒数 平方 开根号
    def push_div_x(self):
        self.info = eval(self.info)
        self.info = str(1.0 / self.info)
        self.ui.textBrowser_Cal.insertPlainText('\n')
        self.ui.textBrowser_Cal.insertPlainText(self.info)
        self.ui.textBrowser_Cal.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
    def push_Square(self):
        self.info = eval(self.info)
        self.info = str(self.info ** 2)
        self.ui.textBrowser_Cal.insertPlainText('\n')
        self.ui.textBrowser_Cal.insertPlainText(self.info)
        self.ui.textBrowser_Cal.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
    def push_Sqrt(self):
        self.info = eval(self.info)
        self.info = str(self.info ** 0.5)
        self.ui.textBrowser_Cal.insertPlainText('\n')
        self.ui.textBrowser_Cal.insertPlainText(self.info)
        self.ui.textBrowser_Cal.moveCursor(self.ui.textBrowser_Cal.textCursor().End)



    def push_Del(self):
        if (len(self.info)>0):
            self.ui.textBrowser_Cal.insertPlainText('\n')
            self.info = self.info[:-1]
            self.ui.textBrowser_Cal.insertPlainText(self.info)

    def push_Minus(self):
        self.info = str(-eval(self.info))
        self.ui.textBrowser_Cal.insertPlainText('\n')
        self.ui.textBrowser_Cal.insertPlainText(self.info)
        self.ui.textBrowser_Cal.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
    def push_Point(self):
        self.ui.textBrowser_Cal.insertPlainText('.')
        self.info = self.info + '.'

    def push_Equal(self):
        self.info = str(eval(self.info))
        self.ui.textBrowser_Cal.insertPlainText('\n')
        self.ui.textBrowser_Cal.insertPlainText(self.info)
        self.ui.textBrowser_Cal.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
        self.ui.textBrowser_Cal.ensureCursorVisible()

    def push_Cal(self):
        info = self.ui.plainTextEdit.toPlainText()
        info = str(eval(info))
        self.ui.textBrowser_Sci.insertPlainText(info)
        self.ui.textBrowser_Sci.insertPlainText('\n')

######################################################################################################
    def push_C_2(self):
        self.ui.textBrowser_Cal_2.clear()
        self.info = ''

    def push_1_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('1')
        self.info = self.info+'1'
    def push_2_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('2')
        self.info = self.info + '2'
    def push_3_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('3')
        self.info = self.info + '3'
    def push_4_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('4')
        self.info = self.info + '4'
    def push_5_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('5')
        self.info = self.info + '5'
    def push_6_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('6')
        self.info = self.info + '6'
    def push_7_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('7')
        self.info = self.info + '7'
    def push_8_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('8')
        self.info = self.info + '8'
    def push_9_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('9')
        self.info = self.info + '9'
    def push_0_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('0')
        self.info = self.info + '0'

    def push_Del_2(self):
        if (len(self.info)>0):
            self.ui.textBrowser_Cal_2.insertPlainText('\n')
            self.info = self.info[:-1]
            self.ui.textBrowser_Cal_2.insertPlainText(self.info)

    def push_Point_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText('.')
        self.info = self.info + '.'

    def push_Space_2(self):
        self.ui.textBrowser_Cal_2.insertPlainText(' ')
        self.info = self.info + ' '

    def push_SS_2 (self):
        str1 = self.info
        str1 = str1.split()
        num1 = eval(str1[0])
        num2 = eval(str1[1])
        SS=num1*num2
        self.info = str(SS)
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.ui.textBrowser_Cal_2.insertPlainText(self.info)
        self.ui.textBrowser_Cal_2.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
        self.ui.textBrowser_Cal_2.ensureCursorVisible()
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.info = ''
    def push_SV_2(self):
        str1 = self.info
        str1 = str1.split()
        num1 = eval(str1[0])
        num2 = eval(str1[1])
        num3=eval(str1[2])
        SV = num1 * num2*num3
        self.info = str(SV)
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.ui.textBrowser_Cal_2.insertPlainText(self.info)
        self.ui.textBrowser_Cal_2.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
        self.ui.textBrowser_Cal_2.ensureCursorVisible()
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.info = ''
    def push_TS_2(self):
        str1 = self.info
        str1 = str1.split()
        num1 = eval(str1[0])
        num2 = eval(str1[1])
        TS = num1 * num2/2
        self.info = str(TS)
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.ui.textBrowser_Cal_2.insertPlainText(self.info)
        self.ui.textBrowser_Cal_2.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
        self.ui.textBrowser_Cal_2.ensureCursorVisible()
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.info = ''
    def push_TV_2(self):
        str1 = self.info
        str1 = str1.split()
        num1 = eval(str1[0])
        num2 = eval(str1[1])
        num3 = eval(str1[2])
        TV = num1 * num2 /2 * num3 / 3
        self.info = str(TV)

        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.ui.textBrowser_Cal_2.insertPlainText(self.info)
        self.ui.textBrowser_Cal_2.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
        self.ui.textBrowser_Cal_2.ensureCursorVisible()
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.info = ''
    def push_CS_2(self):
        r = eval(self.info)
        CS = 3.14 * r * r
        self.info = str(CS)
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.ui.textBrowser_Cal_2.insertPlainText(self.info)
        self.ui.textBrowser_Cal_2.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
        self.ui.textBrowser_Cal_2.ensureCursorVisible()
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.info = ''
    def push_CV_2(self):
        r=eval(self.info)
        CV=4/3*3.14*r*r*r
        self.info = str(CV)
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.ui.textBrowser_Cal_2.insertPlainText(self.info)
        self.ui.textBrowser_Cal_2.moveCursor(self.ui.textBrowser_Cal.textCursor().End)
        self.ui.textBrowser_Cal_2.ensureCursorVisible()
        self.ui.textBrowser_Cal_2.insertPlainText('\n')
        self.info = ''




app = QApplication([])
stats = Stats()
stats.ui.show()
app.exec_()