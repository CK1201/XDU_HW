/*
 * main.c
 *
 *  Created on: 2021年5月18日
 *      Author: CK1201
 */
#include <msp430.h>
#include "stdint.h"
#include "math.h"

#define uchar  unsigned  char
#define uint  unsigned  int

#define CPU_F ((double)1000000)//晶振1MHz，CPU主时钟MCLK，默认DCO
#define delay_us(x) __delay_cycles((long)(CPU_F*(double)x/1000000.0)) //延时
#define delay_ms(x) __delay_cycles((long)(CPU_F*(double)x/1000.0))

#define LED1_OFF  P2OUT |=  BIT7
#define LED1_ON   P2OUT &= ~BIT7
#define LED2_OFF  P2OUT |=  BIT5
#define LED2_ON   P2OUT &= ~BIT5
#define LED3_OFF  P2OUT |=  BIT6
#define LED3_ON   P2OUT &= ~BIT6
#define LED4_OFF  P2OUT |=  BIT4
#define LED4_ON   P2OUT &= ~BIT4
#define LED5_OFF  P1OUT |=  BIT3
#define LED5_ON   P1OUT &= ~BIT3
#define LED6_OFF  P2OUT |=  BIT3
#define LED6_ON   P2OUT &= ~BIT3
#define LED7_OFF  P1OUT |=  BIT4
#define LED7_ON   P1OUT &= ~BIT4
#define LED8_OFF  P1OUT |=  BIT5
#define LED8_ON   P1OUT &= ~BIT5
#define LED9_OFF  P1OUT |=  BIT6
#define LED9_ON   P1OUT &= ~BIT6
#define LED10_OFF P1OUT |=  BIT7
#define LED10_ON  P1OUT &= ~BIT7
#define BEEP_ON   P1OUT |=  BIT0
#define BEEP_OFF  P1OUT &= ~BIT0

#define SDA_1   P2OUT |=  BIT1 //SDA = 1
#define SDA_0   P2OUT &= ~BIT1 //SDA = 0
#define SCL_1   P2OUT |=  BIT0 //SCL = 1
#define SCL_0   P2OUT &= ~BIT0 //SCL = 0 P1.0 SCL P1.1 SDA
#define SDA_IN  P2DIR &= ~BIT1 //I/O 口为输入,SDA_1
#define SDA_OUT P2DIR |=  BIT1 //I/0 口为输出
#define SCL_IN  P2DIR &= ~BIT0 //I/O 口为输入,SCL_1
#define SCL_OUT P2DIR |=  BIT0 //I/0 口为输出
#define SlaveAddress 0xA6

uchar ErrorBit=0;  //A检验应答标志 1错误 0正确
uchar ErrorBit1=0;  //B检验应答标志 1错误 0正确

//typedef unsigned char uchar;
/*IIC*/
//void Init__IIC(void);
//void Start(void);                                             //SCL 为高电平期间，SDA 产生一个下降沿
//void Stop(void);                                              //SCL 高电平期间，SDA 产生一个上升沿
//void Ack(void);                                               //IIC 总线应答//////SCL 为高电平时，SDA 为低电平
//void NoAck(void);                                             //IIC 总线无应答//SDA 维持高电平，SCL 产生一个脉冲
//uchar TestACK(void);                                          //
//void WriteByte(uchar WriteData);                              //写一个字节
//uchar ReadByte(void);                                         //读一个字节
//uchar ReadWords_ACC(uchar *acc);                                    //连续读取
//void Init_ADXL345(void);                                      //加速度计ADXL345初始化
//uchar Single_Write_ADXL345(uchar REG_Address,uchar REG_data); //

/*IO口*/
void initLED_BEEP(void);                      //初始化LED灯和蜂鸣器
void initSystemCLK(void);                     //初始化系统时钟位1MHz

void initUART(void);                          //初始化串口 开启接收中断
void sendString(uint8_t *pbuff, uint8_t num); //通过串口发送字符串
void sendNumber(uint16_t num);                //通过串口发送数据 用于调试

uint8_t RxBuff[20] = {0};   //从串口接收到的数据
uint8_t CmdBuff = 0x00;     //命令码
uint8_t cnt = 0;            //数据帧计数器
uint8_t DataN = 0;          //数据个数
uint8_t DataBuff[10] = {0}; //数据

uint8_t RcvCmdFlag = 0;     //串口接收到正确命令标志位
uint8_t ReadyFlag = 0;      //准备就绪标志位
uint8_t ConfirmFlag = 0;    //确认信息标志位
uint8_t SendAngleFlag = 0;  //数据发送开关命令：1 发送 0 停止
uint8_t MissionMode = 0;    //任务模式

uint8_t sendStateCnt = 0;   //100ms检查一次状态 计数器
uint8_t State[9] = {0};
uint8_t StateLast[9] = {0};

int16_t Yaw       = 20; //偏航角 只通过三轴加速度得不到偏航角
int16_t Roll      = 0; //横滚角
int16_t Pitch     = 0; //俯仰角
int16_t Path      = 20;
int16_t RollLast  = 0; //横滚角
int16_t PitchLast = 0; //俯仰角

uint8_t AngleNum = 32;
int16_t RollArr[32]={-1,0,10,20,30,40,50,60,70,80,70,60,50,45,40,30,20,10,0,-10,-20,-30,-40,-50,-60,-70,-80,-70,-60,-50,-45,0};
uint8_t cntAngle = 0;

int16_t Roll0    = 0; //横滚角初值
int16_t Pitch0   = 0; //俯仰角初值
uint8_t RollThr  = 3; //横滚角上下界
uint8_t PitchThr = 3; //俯仰角上下界


/*定时器*/
void initTimer(void); //初始化Timer_A0

/*ADXL345*/
uchar acc[6] = {0};        //三轴加速度信息
double exc[3] = {0, 0, 0}; //偏差修正

/*俯仰和横滚角*/
void getAngle(void); //根据三轴加速度得到俯仰和横滚角

/*命令执行函数*/
void executeCmd(uint8_t cmd); //执行命令
void sendReq(void);           //0x05 向物联网实验平台发送实验请求（开始命令）
void confirmType(void);       //0x06 确认信息
void sendPitchRoll(void);     //0x41 向物联网实验平台发送角度数据
void sendState(void);         //0x42 向物联网实验平台发送状态，每 100ms判断一次状态
void sendSwitch(void);        //0x46 数据发送开关命令
void setPitch0(void);         //0x48 零点标定命令：标定俯仰角零点
void setRoll0(void);          //0x49 零点标定命令：标定横滚角零点
void setPitchThr(void);       //0x4B 门限设置命令：俯仰角门限
void setRollThr(void);        //0x4C 门限设置命令：横滚角门限
void warn(void);              //0x4D 报警信号，使蜂鸣器发声
void switchMission(void);     //0x4E 实验任务命令
void switchServer(void);      //0x4F 服务器开关命令

void sendData(uint8_t cmd, uint8_t datan, uint8_t *databuff); //向物联网发送数据


//角度A采集初始化
//*******初始化IIC***********//
void Init__IIC_A(void)
{
   SCL_OUT;                     //P2.3(SCL)为输出 
   SDA_IN;                      //p2.4(SDA)为输入
   SCL_0;                       //SCL初始化为低电平
}

void IIC_A_Start(void) //SCL为高电平期间，SDA产生一个下降沿
{
  SDA_OUT;
  SDA_1;
  delay_us(5);
  SCL_1;
  delay_us(5);
  SDA_0;
  delay_us(5);
  SCL_0;
  delay_us(5);
}

void IIC_A_Stop(void)   //SCL高电平期间，SDA产生一个上升沿
{ 
  SDA_OUT;
  SDA_0;
  delay_us(5);
  SCL_1;
  delay_us(5);
  SDA_1;
  delay_us(5);
  SCL_0;
  delay_us(5);
}

void IIC_A_Ack(void) //IIC总线应答//////SCL为高电平时，SDA为低电平
{
  SDA_OUT;
  SDA_0;
  delay_us(5);
  SCL_1;
  delay_us(5);
  SCL_0;
  delay_us(5);
  SDA_1;
}

void IIC_A_NAck(void) //IIC总线无应答//SDA维持高电平，SCL产生一个脉冲
{
  SDA_OUT;
  SDA_1;
  delay_us(5);
  SCL_1;
  delay_us(5);
  SCL_0;
  delay_us(5);
}


//IIC总线检验应答（SCL高电平期间，读SDA的值）
//返回值：IIC应答的值 0：应答  1：无应答
//先转换端口为读，这样接收器拉低电平的应答才能确定拉低，否则
//电平被拉至高电平，从而造成无应答的情形 
uchar IIC_A_TestACK(void)//检验是否应答
{
  SDA_IN;       //SDA设为输入
  delay_us(5);
  SCL_1;
  delay_us(5);
  //ErrorBit=(P2IN & BIT4)>>1;//读取P2.4端口的值?
  ErrorBit=(P2IN & BIT1);
  delay_us(5);
  SCL_0;
  delay_us(5);
  //SDA_OUT; 
  return(ErrorBit);
}

void IIC_A_WriteByte(uchar WriteData)//I2C写一个字节
{
  uchar i;
  SDA_OUT;
  for (i=0; i<8; i++)
  {
    //SDA_OUT;
    //if ((WriteData & 0x80) == 0x80)
    if (((WriteData >> 7) & 0x01) == 0x01)  //判断发送位，送数据到数据线上，从高位开始发送bit
    {
      SDA_1;
    }
    else
    {
      SDA_0;
    }
    delay_us(10);
    SCL_1;      //置时钟信号为高电平，使数据有效
    delay_us(5);
    SCL_0;
    delay_us(10);
    WriteData = WriteData << 1;
  }
  //SDA_IN;
  delay_us(5);
}

uchar IIC_A_ReadByte()//I2C读一个字节
{
  SDA_IN;     //置数据线为输入方向
  uchar i;
  uchar byte = 0;
  for (i=0; i<8; i++)
  {
    SCL_1;       //置时钟为高电平，使数据线数据有效
    delay_us(5);
    byte=byte<<1;
    //SDA_IN;
    if (P2IN & BIT1) byte=(byte|0x01);  //将数据存入byte
    delay_us(10);
    SCL_0;
    delay_us(10);
  }
  return(byte);
}

uchar IIC_A_Single_Write_ADXL345(uchar REG_Address,uchar REG_data)//单个写入数据 
{
  IIC_A_Start();
  IIC_A_WriteByte(0xA6);                   //发送设备地址+写信号，(ADXL345)12管脚接地，I2C地址为0x53,转化为0xA6写入,0xA7读取
  if(IIC_A_TestACK()!=0)                //检验应答
    return 1;                             //若应答错误，则退出函数，返回错误
  IIC_A_WriteByte(REG_Address);               //内部寄存器地址
  if(IIC_A_TestACK()!=0)     
    return 1;            
  IIC_A_WriteByte(REG_data);                  //内部寄存器数据
  if(IIC_A_TestACK()!=0)     
    return 1;   
  IIC_A_Stop();
  return 0;
}

uchar IIC_A_ReadWords_ACC()//连续读取
{
  uchar i;
  IIC_A_Start();
  IIC_A_WriteByte(0xA6);       //发送设备地址+写信号
  if(IIC_A_TestACK()!=0)     
    return 1; 
  IIC_A_WriteByte(0x32);       //数据寄存器，从0x32处开始读取数据
  if(IIC_A_TestACK()!=0)     
    return 1; 
  IIC_A_Start();                //再次启动IIC总线
  IIC_A_WriteByte(0xA7);         //读取
  if(IIC_A_TestACK()!=0)     
    return 1; 
  for (i=0; i<6; i++)//读取6个字节
  {
     acc[i]  = IIC_A_ReadByte();  
     if(i==5)
     {
       IIC_A_NAck();//最后一个数据，发送不应答
     }
     else
     {
       IIC_A_Ack();//应答
     }
  }
  IIC_A_Stop();//发送停止
  return 0;
}

//***************加速度计ADXL345初始化×××××××××××××××××××//
void IIC_A_Init_ADXL345()
{	 
   IIC_A_Single_Write_ADXL345(0x31,0x0B);   //测量范围,正负16g，13位模式
   IIC_A_Single_Write_ADXL345(0x2C,0x08);   //速率设定为12.5 参考pdf13页
   IIC_A_Single_Write_ADXL345(0x2D,0x08);   //选择电源模式   参考pdf24页
   IIC_A_Single_Write_ADXL345(0x2E,0x80);   //使能 DATA_READY 中断
   IIC_A_Single_Write_ADXL345(0x1E,0x00);   //X 偏移量 根据测试传感器的状态写入pdf29页p
   IIC_A_Single_Write_ADXL345(0x1F,0x00);   //Y 偏移量 根据测试传感器的状态写入pdf29页
   IIC_A_Single_Write_ADXL345(0x20,0x05);   //Z 偏移量 根据测试传感器的状态写入pdf29页
}








/**************/
int main(void){
    WDTCTL = WDTPW | WDTHOLD;   // stop watchdog timer

    initLED_BEEP();
    initSystemCLK();
    initUART();
    initTimer();

    //Init__IIC();
    //Init_ADXL345();
    Init__IIC_A();
    IIC_A_Init_ADXL345();

    __bis_SR_register(GIE);     //打开全局中断

    while(1){
      
//      ReadWords_ACC(acc);
      IIC_A_ReadWords_ACC();
      sendString(acc, 6);
      __delay_cycles(500000);
    }
    return 0;
}

void sendData(uint8_t cmd, uint8_t datan, uint8_t *databuff){
    uint8_t DataFrame[5 + 20];
//    uint8_t DataFrame[5 + datan];
    DataFrame[0] = 0xE5;
    DataFrame[1] = cmd;
    DataFrame[2] = datan;
    uint8_t FCS = 0;
    FCS = FCS + cmd + datan;
    uint8_t i = 0;
    for(i = 0; i < datan; i++){
        DataFrame[3 + i] = databuff[i];
        FCS += DataFrame[3 + i];
    }
    DataFrame[3 + datan] = FCS;
    DataFrame[4 + datan] = 0xE6;

    sendString(DataFrame,5 + datan);
}


#pragma vector = USCIAB0RX_VECTOR
__interrupt void UART_Receive_ISR(void){
    if(IFG2 & UCA0RXIFG){   //检测是否是USCI_A0的接收中断，因为USCI_A0和USCI_B0的接收中断共享一个向量，即USCI_A0和USCI_B0产生了中断都能进入该中断函数
        IFG2 &= ~UCA0RXIFG; //清除接收中断标志位
        RxBuff[cnt] = UCA0RXBUF;
        uint8_t flag11 = 0;
        if(RxBuff[cnt] == 0xE6){
          flag11 = 1;
            //收到到帧尾 检查并保存数据
            if(RxBuff[0] == 0xE5){
              
                uint8_t FCS = 0;
                CmdBuff = RxBuff[1];
                DataN = RxBuff[2];
                FCS = FCS + CmdBuff + DataN;
                uint8_t i = 0;
                for(i = 0; i < DataN; i++){
                    DataBuff[i] = RxBuff[i + 3];
                    FCS += DataBuff[i];
                }
                //校验
                if(FCS == RxBuff[3 + DataN]){
                    RcvCmdFlag = 1;
                }else{
                    RcvCmdFlag = 0;
                }
            }
            //cnt = 0;
        }
        cnt++;
        if(flag11){
          cnt = 0;
        }
        cnt %= 20;
    }
}

void initTimer(void){
    /*使用Timer_A1比较模式*/
    TA1CTL |= TASSEL_2; //选择SMCLK作为时钟
    TA1CTL |= MC_1;     //向上计数
    TA1CCR0 = 1000-1;   //记1000个数 1/1MHz*1000=1ms
    /*定时器中断*/
    TA1CTL |= TAIE;    //开启中断
    TA1CTL &= ~TAIFG;  //清除中断标志位
}

#pragma vector = TIMER1_A1_VECTOR //溢出中断TA1
__interrupt void Time_Tick(void){
    switch(TA1IV){
    /*中断处理，中断标志位会自动清理*/
    case 0x02: //TACCR1 CCIFG 捕捉/比较1
        break;
    case 0x04: //TACCR2 CCIFG 捕捉/比较2
        break;
    case 0x0A: //TAIFG溢出中断 1ms执行一次
        TA1CTL &= ~TAIFG;  //清除中断标志位
        if(RcvCmdFlag){
            RcvCmdFlag = 0;
            if(CmdBuff == 0x01){
                executeCmd(0x01);    //第一次收到准备就绪
            }else if(ReadyFlag && CmdBuff == 0x06){
                executeCmd(0x06);    //第一次收到确认
            }else if(ReadyFlag && ConfirmFlag){
                executeCmd(CmdBuff); //收到准备就绪和确认后执行串口其他命令
            }
        }
        /*收到准备就绪和确认*/
        if(ReadyFlag && ConfirmFlag){
            /*100ms检查一次状态 发送一次数据*/
            sendStateCnt++;
            if(sendStateCnt >= 100){
                sendStateCnt = 0;
                /*如果数据发送开关为1则发送数据*/
                if(SendAngleFlag){
                    executeCmd(0x41);
                }
                /*检查一次状态*/
                executeCmd(0x42);
            }
        }
        break;
    default:
        break;
    }
}

void sendReq(void){
    uint8_t code[9] = {'X', 'D', '1', '0', '4', '0', '0', '5', '5'}; //学生ID
    sendData(0x05, 9, code);
}

void confirmType(void){ //确认信息
    if(DataBuff[0] == 0x04){
        ConfirmFlag = 1;
    }else{
        ConfirmFlag = 0;
    }
}

void sendPitchRoll(void){
    uint8_t angle[6] = {0};
    if(MissionMode != 0){
      Pitch = RollArr[cntAngle];
      cntAngle++;
      cntAngle %= AngleNum;
      if(Pitch != PitchLast){
        PitchLast = Pitch;
        /*Yaw*/
        angle[0] = Yaw >> 8;
        angle[1] = Yaw &  0xff;
        /*Pitch*/
        angle[2] = Pitch >> 8;
        angle[3] = Pitch &  0xff;
        /*Roll*/
        angle[4] = RollLast >> 8;
        angle[5] = RollLast &  0xff;
        /*发送角度*/
        //sendData(0x41, 6, angle);
      }
    }else{
      if(MissionMode != 0){
        Roll = RollArr[cntAngle];
        cntAngle++;
        cntAngle %= AngleNum;
        if(Roll != RollLast){
          RollLast = Roll;
          /*Yaw*/
          angle[0] = Yaw >> 8;
          angle[1] = Yaw &  0xff;
          /*Pitch*/
          angle[2] = PitchLast >> 8;
          angle[3] = PitchLast &  0xff;
          /*Roll*/
          angle[4] = Roll >> 8;
          angle[5] = Roll &  0xff;
          /*发送角度*/
          //sendData(0x41, 6, angle);
        }
      }
    }
    //Roll = RollArr[cntAngle];
    //Pitch = RollArr[cntAngle];
    //cntAngle++;
    //cntAngle %= AngleNum;
    
    
    
    getAngle();
    angle[0] = Yaw >> 8;
    angle[1] = Yaw &  0xff;
    /*Pitch*/
    angle[2] = Pitch >> 8;
    angle[3] = Pitch &  0xff;
    /*Roll*/
    angle[4] = Roll >> 8;
    angle[5] = Roll &  0xff;
    /*发送角度*/
    sendData(0x41, 6, angle);
    
}

void sendState(void){
    getAngle();
    int i;
    uint8_t isSame = 1;
    for(i = 0; i < 6; i++){
        if(StateLast[i] != State[i]){
            isSame = 0;
            break;
        }
    }
    if(isSame){
        return;
    }
    uint16_t state16 = 0;
    for(i = 8; i >= 0; i--){
        state16 <<= 1;
        state16 += State[i];
        StateLast[i] = State[i];
    }
    uint8_t state[2] = {0};
    state[1] = state16 >> 8;
    //state[0] = state16 & 0xff;
    state[0] = state16;
    sendData(0x42, 2, state);
}

void sendSwitch(void){
    SendAngleFlag = DataBuff[0];
}

void setPitch0(void){
    getAngle();
    Pitch0 = Pitch;
}

void setRoll0(void){
    getAngle();
    Roll0 = Roll;
}

void setPitchThr(void){
    PitchThr = DataBuff[0];
}

void setRollThr(void){
    RollThr = DataBuff[0];
}

void warn(void){
    switch(DataBuff[0]){
    case 1: //发出一短声
        BEEP_ON;
        __delay_cycles(500000);
        BEEP_OFF;
        break;
    case 2: //发出一长声
        BEEP_ON;
        __delay_cycles(1000000);
        BEEP_OFF;
        break;
    case 3: //发出一长一短声
        BEEP_ON;
        __delay_cycles(1000000);
        BEEP_OFF;
        __delay_cycles(500000);
        BEEP_ON;
        __delay_cycles(500000);
        BEEP_OFF;
        break;
    default:
        break;
    }
}

void switchMission(void){
    MissionMode = DataBuff[0];
    switch(MissionMode){
    case 1:
        LED7_ON;
        LED8_OFF;
        State[4] = 1;
        State[5] = 0;
        break;
    case 2:
        LED8_ON;
        LED7_OFF;
        State[4] = 0;
        State[5] = 1;
        break;
    case 0:
        LED7_OFF;
        LED8_OFF;
        State[4] = 0;
        State[5] = 0;
        break;
    default:
        LED7_OFF;
        LED8_OFF;
        State[4] = 0;
        State[5] = 0;
        break;
    }
}

void switchServer(void){
    if(DataBuff[0] == 1){
        LED10_ON;
    }else{
        LED10_OFF;
    }
}

void executeCmd(uint8_t cmd){
    switch(cmd){
    case 0x00: //什么也不干
        break;
    case 0x01: //物联网实验平台发送“准备就绪”命令
        ReadyFlag = 1;
        sendReq(); //向物联网实验平台发送实验请求（开始命令）
        break;
//    case 0x05:
//        CmdBuff = 0x00;
//        break;
    case 0x06: //确认信息
        confirmType();
        break;
    case 0x41: //向物联网实验平台发送角度数据
        getAngle();
        sendPitchRoll();
        break;
    case 0x42: //向物联网实验平台发送状态，每 100ms判断一次状态，如果位 D0~D5 的值发生了变化，则发送给实验平台。
        /**
         * 状态 State 为字型变量，从 D0 开始分别表示俯仰角和横滚角的上下
         * 门限，实验 1,2 的指示灯、实验步骤指示灯、平台操作的 1 个指示灯。共 9位。
         */
        sendState();
        break;
    case 0x46: //数据发送开关命令：1 发送 0 停止
        sendSwitch();
        //uint8_t str1[1] = {0x46};
        //sendString(str1, 1);
        break;
    case 0x48: //零点标定命令：标定俯仰角零点
        setPitch0();
        break;
    case 0x49: //零点标定命令：标定横滚角零点
        setRoll0();
        break;
    case 0x4B: //门限设置命令：俯仰角门限
        setPitchThr();
        break;
    case 0x4C: //门限设置命令：横滚角门限
        setRollThr();
        break;
    case 0x4D: //报警信号，使蜂鸣器发声
        warn();
        break;
    case 0x4E: //实验任务命令:1,2 表示开始实验任务1,2；0 表示该实验结束
        switchMission();
        break;
    case 0x4F: //服务器开关命令：Switch 的 D0 位的“1”表示平台开关 1 的 ON 状态，“0”表示 OFF状态
        switchServer();
        break;
    default:
        break;
    }
    CmdBuff = 0x00;
}




void getAngle(void){
    double AccX = 0, AccY = 0, AccZ = 0; //
    int AccXtemp = 0, AccYtemp = 0, AccZtemp = 0; //
//    uint8_t MeanTimes = 10;    //取10次数据的平均值

    //ReadWords_ACC(acc);
    IIC_A_ReadWords_ACC();

    /*X轴加速度*/
    AccXtemp = (acc[1] << 8) + acc[0];  //合成数据
//        AccXtemp = AccXtemp - exc[0];         //偏移校准
    AccX += AccXtemp;

    /*Y轴加速度*/
    AccYtemp = (acc[3] << 8) + acc[2];  //合成数据
//        AccYtemp = AccYtemp - exc[1];        //偏移校准
    AccY += AccYtemp;

    /*Z轴加速度*/
    AccZtemp = (acc[5] << 8) + acc[4];    //合成数据
//        AccZtemp = AccZtemp - exc[2];        //偏移校准
    AccZ += AccZtemp;
    /*取平均*/
//    AccX = AccX / MeanTimes;
//    AccY = AccY / MeanTimes;
//    AccZ = AccZ / MeanTimes;
    float X,Y,Za;

    X=(float)AccX*3.9;//每个输出LSB为3.9mg
    Y=(float)AccY*3.9;
    Za=(float)AccZ*3.9;

    Pitch=(int16_t)((atan2(X,sqrt(pow(Y,2)+pow(Za,2)))*180)/3.14159265-Pitch0);//X轴角度值（俯仰）
    Roll=(int16_t)((atan2(Y,sqrt(pow(X,2)+pow(Za,2)))*180)/3.14159265-Roll0);//Y轴角度值（横滚）
    Path=(int16_t)((atan2(Za,sqrt(pow(X,2)+pow(Y,2)))*180)/3.1415926);//Z轴角度值（航向）

//    Pitch = (int16_t)(atan2(AccY , AccZ) / 3.1416 * 180) - Pitch0;
//    Roll  = (int16_t)(atan2(AccX , AccZ) / 3.1416 * 180) - Roll0;

    if(Pitch > PitchThr){
//        Pitch = PitchThr;
        State[0] = 1; //上限
        State[1] = 0; //下限
        LED4_ON;
        LED3_OFF;
    }else{
        State[0] = 0;
        LED4_OFF;
    }

    if(Pitch < -PitchThr){
//        Pitch = -PitchThr;
        State[0] = 0; //上限
        State[1] = 1;
        LED3_ON;
        LED4_OFF;
    }else{
        State[1] = 0;
        LED3_OFF;
    }

    if(Roll > RollThr){
//        Roll = RollThr;
        State[2] = 1;
        State[3] = 0;
        LED6_ON;
        LED5_OFF;
    }else{
        State[2] = 0;
        LED6_OFF;
    }

    if(Roll < -RollThr){
//        Roll = -RollThr;
        State[2] = 0;
        State[3] = 1;
        LED5_ON;
        LED6_OFF;
    }else{
        State[3] = 0;
        LED5_OFF;
    }
}








//void Init__IIC(void){
//    P1SEL &= ~BIT0;
//    P1SEL &= ~BIT1; //选择 P1.1(SDA) P1.0(SCL)为 I/O 端口
//    SCL_OUT; //P1.0(SCL)为输出
//    SDA_IN; //p1.1(SDA)为输入
//    SCL_0;
//}
//
////×××××开始××××××//
//void Start(void){ //SCL 为高电平期间，SDA 产生一个下降沿
//    SDA_OUT;
//    SDA_1;
//    __delay_cycles(5);
//    SCL_1;
//    __delay_cycles(5);
//    SDA_0;
//    __delay_cycles(5);
//    SCL_0;
//    __delay_cycles(5);
//}
////×××××停止×××××//
//void Stop(void){ //SCL 高电平期间，SDA 产生一个上升沿
//    SDA_OUT;
//    SCL_0;
//    __delay_cycles(5);
//    SDA_0;
//    __delay_cycles(5);
//    SCL_1;
//    __delay_cycles(5);
//    SDA_1;
//    __delay_cycles(5);
//}
////×××××应答信号×××××//
//void Ack(void){ //IIC总线应答  SCL为高电平时，SDA为低电平
//    SDA_OUT;
//    SDA_0;
//    __delay_cycles(5);
//    SCL_1;
//    __delay_cycles(5);
//    SCL_0;
//    __delay_cycles(5);
//    SDA_1;
//}
//
//void NoAck(void){ //IIC总线无应答 SDA 维持高电平，SCL 产生一个脉冲
//    SDA_OUT;
//    SDA_1;
//    __delay_cycles(5);
//    SCL_1;
//    __delay_cycles(5);
//    SCL_0;
//    __delay_cycles(5);
//}
//
//#define delay_ms(x) __delay_cycles((long)(CPU_F*(double)x/1000.0))
////IIC 总线检验应答（SCL 高电平期间，读 SDA 的值）
////返回值：IIC 应答的值 0：应答 1：无应答
////先转换端口为读，这样接收器拉底电平的应答才能确定拉底，否则
////电平被拉至高电平，从而造成无应答的情形
//uchar TestACK(void){
//    SDA_IN; //SDA 设为输入
//    __delay_cycles(5);
//    SCL_1;
//    __delay_cycles(5);
//    uchar ErrorBit = (P1IN & BIT1)>>1;
//    __delay_cycles(5);
//    SCL_0;
//    __delay_cycles(5);
//    //SDA_OUT;
//    return(ErrorBit);
//}
////×××××××写一个字节×××××××//
//void WriteByte(uchar WriteData){
//    uchar i;
//    SDA_OUT;
//    for (i = 0; i < 8; i++){
//        SDA_OUT;
//        if (((WriteData >> 7) & 0x01) == 0x01){ //判断发送位，送数据到数据线上，从高位开始发送 bit
//            SDA_1;
//        }else{
//            SDA_0;
//        }
//        __delay_cycles(10);
//        SCL_1; //置时钟信号为高电平，使数据有效
//        __delay_cycles(5);
//        SCL_0;
//        __delay_cycles(10);
//        WriteData = WriteData << 1;
//    }
//    SDA_IN;
//    __delay_cycles(5);
//}
////××××××××××读一个字节××××××××××//
//uchar ReadByte(void){
//    SDA_IN; //置数据线为输入方向
//    uint8_t i;
//    uint8_t q0 ;
//    uchar byte = 0;
//    for (i = 0; i < 8; i++){
//        SCL_1; //置时钟为高电平，使数据线数据有效
//        __delay_cycles(5);
//        byte = byte << 1;
//        SDA_IN;
//        q0 = (P1IN & BIT1);
//        if (q0 == BIT1 ) byte = (byte | 0x01); //将数据存入 byte
//        __delay_cycles(10);
//        SCL_0;
//        __delay_cycles(10);
//    }
//    return(byte);
//}
//
//uchar Single_Write_ADXL345(uchar REG_Address,uchar REG_data){
//    Start();
//    WriteByte(SlaveAddress); //发送设备地址+写信号
//    if(TestACK()!=0)         //检验应答
//        return 1;            //若应答错误，则推出函数，返回错误
//    WriteByte(REG_Address);  //内部寄存器地址
//    if(TestACK()!=0)
//        return 1;
//    WriteByte(REG_data);     //内部寄存器数据
//    if(TestACK()!=0)
//        return 1;
//    Stop();
//    return 0;
//}
////×××××××××连续读取××××××××××//
//uchar ReadWords_ACC(uchar *acc){
//    Start();
//    WriteByte(SlaveAddress);     //发送设备地址+写信号
//    if(TestACK() != 0)
//        return 1;
//    WriteByte(0x32);
//    if(TestACK() != 0)
//        return 1;
//    /**/
//    Start();                     //再次启动 IIC 总线
//    WriteByte(SlaveAddress + 1); //读取
//    if(TestACK() != 0)
//        return 1;
//    uint8_t i;
////    uchar acc[6] = {0}; //三轴加速度信息
//    for (i = 0; i < 6; i++){
//        acc[i] = ReadByte();
//        if(i==5){
//            NoAck();
//        }else{
//            Ack();
//        }
//    }
//    Stop();
//    return 0;
//}
////***************加速度计ADXL345初始化×××××××××××××××××××//
//void Init_ADXL345(void){
//    Single_Write_ADXL345(0x31, 0x0B); //测量范围,正负 16g，13 位模式
//    Single_Write_ADXL345(0x2C, 0x08); //速率设定为 12.5 参考 pdf13 页
//    Single_Write_ADXL345(0x2D, 0x08); //选择电源模式 参考 pdf24 页
//    Single_Write_ADXL345(0x2E, 0x80); //使能 DATA_READY 中断
//    Single_Write_ADXL345(0x1E, 0x00); //X 偏移量 根据测试传感器的状态写入 pdf29 页
//    Single_Write_ADXL345(0x1F, 0x00); //Y 偏移量 根据测试传感器的状态写入 pdf29 页
//    Single_Write_ADXL345(0x20, 0x05); //Z 偏移量 根据测试传感器的状态写入 pdf29 页
//}

void initLED_BEEP(void){
    /*LED和BEEP*/
    P1DIR |= BIT0 + BIT3 + BIT4 + BIT5 + BIT6 + BIT7; //BEEP、LED5、7、8、9、10输出模式
    P2DIR |= BIT3 + BIT4 + BIT5 + BIT6 + BIT7; //LED6、4、2、3、1输出模式
    LED1_OFF;
    LED2_OFF;
    LED3_OFF;
    LED4_OFF;
    LED5_OFF;
    LED6_OFF;
    LED7_OFF;
    LED8_OFF;
    LED9_OFF;
    LED10_OFF;
    BEEP_OFF;
    /*P2.2 CS片选*/
    P2DIR |= BIT2;
    //P2OUT &= ~BIT2;
    P2OUT |= BIT2;
}

void initSystemCLK(void){
    /*配置DCO为1MHz即SMCLK来源为DCO为1MHz*/
    DCOCTL = CALDCO_1MHZ;
    BCSCTL1 = CALBC1_1MHZ;
    /*配置SMCLK*/
    BCSCTL2 &= ~SELS;               //选择DCOCLK为SMCLK的来源
    BCSCTL2 &= ~(DIVS0|DIVS1);      //SMCLK的分配系数设为1
}

void initUART(void){
    /*配置串口*/
    UCA0CTL1 |= UCSWRST;            //复位

    UCA0CTL0 &= ~UCPEN;             //奇偶校验被禁止
    UCA0CTL0 &= ~UCPAR;             //奇数校验
    UCA0CTL0 &= ~UCMSB;             //先发第0位
    UCA0CTL0 &= ~UC7BIT;            //8 位数据
    UCA0CTL0 &= ~UCSPB;             //1 个停止位
    UCA0CTL0 &= ~(UCMODE0|UCMODE1); //UART 模式
    UCA0CTL0 &= ~UCSYNC;            //异步模式UART

    UCA0CTL1 |= (UCSSEL0|UCSSEL1);  //选择 BRCLK时钟源为SMCLK

    /*设置波特率N=fBRCLK/Baud_rate*/
    //表 15-4 UCOS16=0 1MHz 9600
    UCA0BR0 = 0x68;  //低八位1000000/9600=104.16667
    UCA0BR1 = 0x00;  //高八位
    UCA0MCTL = 1<<1; //UCBRSx=0

    /*复用UCA0RXD和UCA0TXD*/
    P1SEL |= BIT1 + BIT2;
    P1SEL2 |= BIT1 + BIT2;

    /*清除复位位，使能UART*/
    UCA0CTL1 &= ~UCSWRST;

    /*接收中断 必须放在清除复位位后*/
    IE2 |= UCA0RXIE;    //开启串口接收中断15.4.12
    IFG2 &= ~UCA0RXIFG; //清除接收中断标志位15.4.13
}

void sendString(uint8_t *pbuff, uint8_t num){
    uint8_t cnt = 0;
    for(cnt = 0; cnt < num; cnt++){
        while(UCA0STAT & UCBUSY); //直到上一个字符发送完成
        UCA0TXBUF = *(pbuff+cnt);
    }
}

void sendNumber(uint16_t num){
    uint8_t buff[6] = {0, 0, 0, 0, 0, '\n'};
    uint8_t cnt = 0;
    for(cnt = 5; cnt > 0; cnt--){
        buff[cnt-1] = (uint8_t)(num % 10 + '0');
        num /= 10;
    }
    sendString(buff, 6);
}
