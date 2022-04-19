#include "msp430g2553.h"
#include "math.h"

#define CPU_F ((double)1000000)//����1MHz��CPU��ʱ��MCLK��Ĭ��DCO
#define delay_us(x) __delay_cycles((long)(CPU_F*(double)x/1000000.0)) //��ʱ
#define delay_ms(x) __delay_cycles((long)(CPU_F*(double)x/1000.0))
#define uchar  unsigned  char
#define uint  unsigned  int

#define     SlaveAddress    0xA6	             //������ٶȼƵ��豸��ַ

//��������������I2Cģ��ͨ��Э�� angleA����������������//
#define SDA_1       P2OUT |=  BIT1              //SDA = 1
#define SDA_0       P2OUT &=~ BIT1              //SDA = 0
#define SCL_1       P2OUT |=  BIT0              //SCL = 1
#define SCL_0       P2OUT &=~ BIT0              //SCL = 0   P2.3 SCL   P2.4 SDA
 
#define SDA_IN      P2DIR &=~ BIT1              //I/O��Ϊ����,SDA_1,Bit = 0: The port pin is switched to input direction
#define SDA_OUT     P2DIR |=  BIT1              //I/0��Ϊ���,Bit = 1: The port pin is switched to output direction

#define SCL_IN      P2DIR &=~ BIT0              //I/O��Ϊ����,SCL_1
#define SCL_OUT     P2DIR |=  BIT0              //I/0��Ϊ���


//��������������I2Cģ��ͨ��Э�� angleB����������������//
//#define SDA1_1       P2OUT |=  BIT4              //SDA1 = 1
//#define SDA1_0       P2OUT &=~ BIT4              //SDA1 = 0
//#define SCL1_1       P2OUT |=  BIT3              //SCL1 = 1
//#define SCL1_0       P2OUT &=~ BIT3              //SCL1 = 0   P2.0 SCL1   P2.1 SDA1
// 
//#define SDA1_IN      P2DIR &=~ BIT4              //I/O��Ϊ����,SDA1_1,Bit = 0: The port pin is switched to input direction
//#define SDA1_OUT     P2DIR |=  BIT4              //I/0��Ϊ���,Bit = 1: The port pin is switched to output direction
//
//#define SCL1_IN      P2DIR &=~ BIT3              //I/O��Ϊ����,SCL1_1
//#define SCL1_OUT     P2DIR |=  BIT3              //I/0��Ϊ���



uchar ErrorBit=0;  //A����Ӧ���־ 1���� 0��ȷ
uchar ErrorBit1=0;  //B����Ӧ���־ 1���� 0��ȷ
char acc[6];//��ȡA�ǶȲ���ֵ
char acc1[6];//��ȡB�ǶȲ���ֵ

char test[6];

struct angle{
  char pathangleH;//�����
  char pathangleL;
  char pathangleH2;//�����2
  char pathangleL2;
  uint  pathangle;
  char pitchangleH;//������
  char pitchangleL;
  char pitchangleH2;//������2
  char pitchangleL2;
  uint  pitchangle;
  char rollangleH;//�����
  char rollangleL;
  char rollangleH2;//�����2
  char rollangleL2;
  uint  rollangle;
};

int x,y,z,roll,pitch,path;

//�Ƕ�A�ɼ���ʼ��
//*******��ʼ��IIC***********//
void Init__IIC_A(void)
{
   SCL_OUT;                     //P2.3(SCL)Ϊ��� 
   SDA_IN;                      //p2.4(SDA)Ϊ����
   SCL_0;                       //SCL��ʼ��Ϊ�͵�ƽ
}

void IIC_A_Start(void) //SCLΪ�ߵ�ƽ�ڼ䣬SDA����һ���½���
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

void IIC_A_Stop(void)   //SCL�ߵ�ƽ�ڼ䣬SDA����һ��������
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

void IIC_A_Ack(void) //IIC����Ӧ��//////SCLΪ�ߵ�ƽʱ��SDAΪ�͵�ƽ
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

void IIC_A_NAck(void) //IIC������Ӧ��//SDAά�ָߵ�ƽ��SCL����һ������
{
  SDA_OUT;
  SDA_1;
  delay_us(5);
  SCL_1;
  delay_us(5);
  SCL_0;
  delay_us(5);
}


//IIC���߼���Ӧ��SCL�ߵ�ƽ�ڼ䣬��SDA��ֵ��
//����ֵ��IICӦ���ֵ 0��Ӧ��  1����Ӧ��
//��ת���˿�Ϊ�����������������͵�ƽ��Ӧ�����ȷ�����ͣ�����
//��ƽ�������ߵ�ƽ���Ӷ������Ӧ������� 
uchar IIC_A_TestACK(void)//�����Ƿ�Ӧ��
{
  SDA_IN;       //SDA��Ϊ����
  delay_us(5);
  SCL_1;
  delay_us(5);
  //ErrorBit=(P2IN & BIT4)>>1;//��ȡP2.4�˿ڵ�ֵ?
  ErrorBit=(P2IN & BIT1);
  delay_us(5);
  SCL_0;
  delay_us(5);
  //SDA_OUT; 
  return(ErrorBit);
}

void IIC_A_WriteByte(uchar WriteData)//I2Cдһ���ֽ�
{
  uchar i;
  SDA_OUT;
  for (i=0; i<8; i++)
  {
    //SDA_OUT;
    //if ((WriteData & 0x80) == 0x80)
    if (((WriteData >> 7) & 0x01) == 0x01)  //�жϷ���λ�������ݵ��������ϣ��Ӹ�λ��ʼ����bit
    {
      SDA_1;
    }
    else
    {
      SDA_0;
    }
    delay_us(10);
    SCL_1;      //��ʱ���ź�Ϊ�ߵ�ƽ��ʹ������Ч
    delay_us(5);
    SCL_0;
    delay_us(10);
    WriteData = WriteData << 1;
  }
  //SDA_IN;
  delay_us(5);
}

uchar IIC_A_ReadByte()//I2C��һ���ֽ�
{
  SDA_IN;     //��������Ϊ���뷽��
  uchar i;
  uchar byte = 0;
  for (i=0; i<8; i++)
  {
    SCL_1;       //��ʱ��Ϊ�ߵ�ƽ��ʹ������������Ч
    delay_us(5);
    byte=byte<<1;
    //SDA_IN;
    if (P2IN & BIT1) byte=(byte|0x01);  //�����ݴ���byte
    delay_us(10);
    SCL_0;
    delay_us(10);
  }
  return(byte);
}

uchar IIC_A_Single_Write_ADXL345(uchar REG_Address,uchar REG_data)//����д������ 
{
  IIC_A_Start();
  IIC_A_WriteByte(0xA6);                   //�����豸��ַ+д�źţ�(ADXL345)12�ܽŽӵأ�I2C��ַΪ0x53,ת��Ϊ0xA6д��,0xA7��ȡ
  if(IIC_A_TestACK()!=0)                //����Ӧ��
    return 1;                             //��Ӧ��������˳����������ش���
  IIC_A_WriteByte(REG_Address);               //�ڲ��Ĵ�����ַ
  if(IIC_A_TestACK()!=0)     
    return 1;            
  IIC_A_WriteByte(REG_data);                  //�ڲ��Ĵ�������
  if(IIC_A_TestACK()!=0)     
    return 1;   
  IIC_A_Stop();
  return 0;
}

uchar IIC_A_ReadWords_ACC()//������ȡ
{
  uchar i;
  IIC_A_Start();
  IIC_A_WriteByte(0xA6);       //�����豸��ַ+д�ź�
  if(IIC_A_TestACK()!=0)     
    return 1; 
  IIC_A_WriteByte(0x32);       //���ݼĴ�������0x32����ʼ��ȡ����
  if(IIC_A_TestACK()!=0)     
    return 1; 
  IIC_A_Start();                //�ٴ�����IIC����
  IIC_A_WriteByte(0xA7);         //��ȡ
  if(IIC_A_TestACK()!=0)     
    return 1; 
  for (i=0; i<6; i++)//��ȡ6���ֽ�
  {
     acc[i]  = IIC_A_ReadByte();  
     if(i==5)
     {
       IIC_A_NAck();//���һ�����ݣ����Ͳ�Ӧ��
     }
     else
     {
       IIC_A_Ack();//Ӧ��
     }
  }
  IIC_A_Stop();//����ֹͣ
  return 0;
}

//***************���ٶȼ�ADXL345��ʼ����������������������������������������//
void IIC_A_Init_ADXL345()
{	 
   IIC_A_Single_Write_ADXL345(0x31,0x0B);   //������Χ,����16g��13λģʽ
   IIC_A_Single_Write_ADXL345(0x2C,0x08);   //�����趨Ϊ12.5 �ο�pdf13ҳ
   IIC_A_Single_Write_ADXL345(0x2D,0x08);   //ѡ���Դģʽ   �ο�pdf24ҳ
   IIC_A_Single_Write_ADXL345(0x2E,0x80);   //ʹ�� DATA_READY �ж�
   IIC_A_Single_Write_ADXL345(0x1E,0x00);   //X ƫ���� ���ݲ��Դ�������״̬д��pdf29ҳp
   IIC_A_Single_Write_ADXL345(0x1F,0x00);   //Y ƫ���� ���ݲ��Դ�������״̬д��pdf29ҳ
   IIC_A_Single_Write_ADXL345(0x20,0x05);   //Z ƫ���� ���ݲ��Դ�������״̬д��pdf29ҳ
}










//���ݴ���
void dataprocess(struct angle *angleX,char acc[6])
{
  //int x,y,z,roll,pitch,path;
  //int roll2,pitch2,path2;
  //int roll3,pitch3,path3;
  float X,Y,Za;
  x=(acc[1]<<8)+acc[0];//ȡ��x,y,z��ֵ��16λ
  y=(acc[3]<<8)+acc[2];
  z=(acc[5]<<8)+acc[4];
  X=(float)x*3.9;//ÿ�����LSBΪ3.9mg
  Y=(float)y*3.9;
  Za=(float)z*3.9;

  
  //��ˮƽ����н�
  pitch=(int)((atan2(X,sqrt(pow(Y,2)+pow(Za,2)))*180)/3.14159265);//X��Ƕ�ֵ��������
  roll=(int)((atan2(Y,sqrt(pow(X,2)+pow(Za,2)))*180)/3.14159265);//Y��Ƕ�ֵ�������
  path=(int)((atan2(Za,sqrt(pow(X,2)+pow(Y,2)))*180)/3.1415926);//Z��Ƕ�ֵ������
  
  
  
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
