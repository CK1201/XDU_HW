#include "msp430g2553.h"
#include "math.h"

#define CPU_F ((double)1000000)//晶振1MHz，CPU主时钟MCLK，默认DCO
#define delay_us(x) __delay_cycles((long)(CPU_F*(double)x/1000000.0)) //延时
#define delay_ms(x) __delay_cycles((long)(CPU_F*(double)x/1000.0))
#define uchar  unsigned  char
#define uint  unsigned  int

#define     SlaveAddress    0xA6	             //定义加速度计的设备地址

//×××××××I2C模拟通信协议 angleA××××××××//
#define SDA_1       P2OUT |=  BIT1              //SDA = 1
#define SDA_0       P2OUT &=~ BIT1              //SDA = 0
#define SCL_1       P2OUT |=  BIT0              //SCL = 1
#define SCL_0       P2OUT &=~ BIT0              //SCL = 0   P2.3 SCL   P2.4 SDA
 
#define SDA_IN      P2DIR &=~ BIT1              //I/O口为输入,SDA_1,Bit = 0: The port pin is switched to input direction
#define SDA_OUT     P2DIR |=  BIT1              //I/0口为输出,Bit = 1: The port pin is switched to output direction

#define SCL_IN      P2DIR &=~ BIT0              //I/O口为输入,SCL_1
#define SCL_OUT     P2DIR |=  BIT0              //I/0口为输出


//×××××××I2C模拟通信协议 angleB××××××××//
//#define SDA1_1       P2OUT |=  BIT4              //SDA1 = 1
//#define SDA1_0       P2OUT &=~ BIT4              //SDA1 = 0
//#define SCL1_1       P2OUT |=  BIT3              //SCL1 = 1
//#define SCL1_0       P2OUT &=~ BIT3              //SCL1 = 0   P2.0 SCL1   P2.1 SDA1
// 
//#define SDA1_IN      P2DIR &=~ BIT4              //I/O口为输入,SDA1_1,Bit = 0: The port pin is switched to input direction
//#define SDA1_OUT     P2DIR |=  BIT4              //I/0口为输出,Bit = 1: The port pin is switched to output direction
//
//#define SCL1_IN      P2DIR &=~ BIT3              //I/O口为输入,SCL1_1
//#define SCL1_OUT     P2DIR |=  BIT3              //I/0口为输出



uchar ErrorBit=0;  //A检验应答标志 1错误 0正确
uchar ErrorBit1=0;  //B检验应答标志 1错误 0正确
char acc[6];//存取A角度测量值
char acc1[6];//存取B角度测量值

char test[6];

struct angle{
  char pathangleH;//航向角
  char pathangleL;
  char pathangleH2;//航向角2
  char pathangleL2;
  uint  pathangle;
  char pitchangleH;//俯仰角
  char pitchangleL;
  char pitchangleH2;//俯仰角2
  char pitchangleL2;
  uint  pitchangle;
  char rollangleH;//横滚角
  char rollangleL;
  char rollangleH2;//横滚角2
  char rollangleL2;
  uint  rollangle;
};

int x,y,z,roll,pitch,path;

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










//数据处理
void dataprocess(struct angle *angleX,char acc[6])
{
  //int x,y,z,roll,pitch,path;
  //int roll2,pitch2,path2;
  //int roll3,pitch3,path3;
  float X,Y,Za;
  x=(acc[1]<<8)+acc[0];//取出x,y,z的值，16位
  y=(acc[3]<<8)+acc[2];
  z=(acc[5]<<8)+acc[4];
  X=(float)x*3.9;//每个输出LSB为3.9mg
  Y=(float)y*3.9;
  Za=(float)z*3.9;

  
  //与水平方向夹角
  pitch=(int)((atan2(X,sqrt(pow(Y,2)+pow(Za,2)))*180)/3.14159265);//X轴角度值（俯仰）
  roll=(int)((atan2(Y,sqrt(pow(X,2)+pow(Za,2)))*180)/3.14159265);//Y轴角度值（横滚）
  path=(int)((atan2(Za,sqrt(pow(X,2)+pow(Y,2)))*180)/3.1415926);//Z轴角度值（航向）
  
  
  
  angleX->pathangle=path;
  angleX->pitchangle=pitch;
  angleX->rollangle=roll;
  
  
  angleX->pathangleH2=path>>8;
  angleX->pathangleL2=path;
  angleX->pitchangleH2=pitch>>8;
  angleX->pitchangleL2=pitch;
  angleX->rollangleH2=roll>>8;
  angleX->rollangleL2=roll;
  
}
