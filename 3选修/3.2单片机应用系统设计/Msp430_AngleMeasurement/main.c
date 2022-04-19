/*
 * main.c
 *
 *  Created on: 2021��5��18��
 *      Author: CK1201
 */
#include <msp430.h>
#include "stdint.h"
#include "math.h"

#define uchar  unsigned  char
#define uint  unsigned  int

#define CPU_F ((double)1000000)//����1MHz��CPU��ʱ��MCLK��Ĭ��DCO
#define delay_us(x) __delay_cycles((long)(CPU_F*(double)x/1000000.0)) //��ʱ
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
#define SDA_IN  P2DIR &= ~BIT1 //I/O ��Ϊ����,SDA_1
#define SDA_OUT P2DIR |=  BIT1 //I/0 ��Ϊ���
#define SCL_IN  P2DIR &= ~BIT0 //I/O ��Ϊ����,SCL_1
#define SCL_OUT P2DIR |=  BIT0 //I/0 ��Ϊ���
#define SlaveAddress 0xA6

uchar ErrorBit=0;  //A����Ӧ���־ 1���� 0��ȷ
uchar ErrorBit1=0;  //B����Ӧ���־ 1���� 0��ȷ

//typedef unsigned char uchar;
/*IIC*/
//void Init__IIC(void);
//void Start(void);                                             //SCL Ϊ�ߵ�ƽ�ڼ䣬SDA ����һ���½���
//void Stop(void);                                              //SCL �ߵ�ƽ�ڼ䣬SDA ����һ��������
//void Ack(void);                                               //IIC ����Ӧ��//////SCL Ϊ�ߵ�ƽʱ��SDA Ϊ�͵�ƽ
//void NoAck(void);                                             //IIC ������Ӧ��//SDA ά�ָߵ�ƽ��SCL ����һ������
//uchar TestACK(void);                                          //
//void WriteByte(uchar WriteData);                              //дһ���ֽ�
//uchar ReadByte(void);                                         //��һ���ֽ�
//uchar ReadWords_ACC(uchar *acc);                                    //������ȡ
//void Init_ADXL345(void);                                      //���ٶȼ�ADXL345��ʼ��
//uchar Single_Write_ADXL345(uchar REG_Address,uchar REG_data); //

/*IO��*/
void initLED_BEEP(void);                      //��ʼ��LED�ƺͷ�����
void initSystemCLK(void);                     //��ʼ��ϵͳʱ��λ1MHz

void initUART(void);                          //��ʼ������ ���������ж�
void sendString(uint8_t *pbuff, uint8_t num); //ͨ�����ڷ����ַ���
void sendNumber(uint16_t num);                //ͨ�����ڷ������� ���ڵ���

uint8_t RxBuff[20] = {0};   //�Ӵ��ڽ��յ�������
uint8_t CmdBuff = 0x00;     //������
uint8_t cnt = 0;            //����֡������
uint8_t DataN = 0;          //���ݸ���
uint8_t DataBuff[10] = {0}; //����

uint8_t RcvCmdFlag = 0;     //���ڽ��յ���ȷ�����־λ
uint8_t ReadyFlag = 0;      //׼��������־λ
uint8_t ConfirmFlag = 0;    //ȷ����Ϣ��־λ
uint8_t SendAngleFlag = 0;  //���ݷ��Ϳ������1 ���� 0 ֹͣ
uint8_t MissionMode = 0;    //����ģʽ

uint8_t sendStateCnt = 0;   //100ms���һ��״̬ ������
uint8_t State[9] = {0};
uint8_t StateLast[9] = {0};

int16_t Yaw       = 20; //ƫ���� ֻͨ��������ٶȵò���ƫ����
int16_t Roll      = 0; //�����
int16_t Pitch     = 0; //������
int16_t Path      = 20;
int16_t RollLast  = 0; //�����
int16_t PitchLast = 0; //������

uint8_t AngleNum = 32;
int16_t RollArr[32]={-1,0,10,20,30,40,50,60,70,80,70,60,50,45,40,30,20,10,0,-10,-20,-30,-40,-50,-60,-70,-80,-70,-60,-50,-45,0};
uint8_t cntAngle = 0;

int16_t Roll0    = 0; //����ǳ�ֵ
int16_t Pitch0   = 0; //�����ǳ�ֵ
uint8_t RollThr  = 3; //��������½�
uint8_t PitchThr = 3; //���������½�


/*��ʱ��*/
void initTimer(void); //��ʼ��Timer_A0

/*ADXL345*/
uchar acc[6] = {0};        //������ٶ���Ϣ
double exc[3] = {0, 0, 0}; //ƫ������

/*�����ͺ����*/
void getAngle(void); //����������ٶȵõ������ͺ����

/*����ִ�к���*/
void executeCmd(uint8_t cmd); //ִ������
void sendReq(void);           //0x05 ��������ʵ��ƽ̨����ʵ�����󣨿�ʼ���
void confirmType(void);       //0x06 ȷ����Ϣ
void sendPitchRoll(void);     //0x41 ��������ʵ��ƽ̨���ͽǶ�����
void sendState(void);         //0x42 ��������ʵ��ƽ̨����״̬��ÿ 100ms�ж�һ��״̬
void sendSwitch(void);        //0x46 ���ݷ��Ϳ�������
void setPitch0(void);         //0x48 ���궨����궨���������
void setRoll0(void);          //0x49 ���궨����궨��������
void setPitchThr(void);       //0x4B ���������������������
void setRollThr(void);        //0x4C ��������������������
void warn(void);              //0x4D �����źţ�ʹ����������
void switchMission(void);     //0x4E ʵ����������
void switchServer(void);      //0x4F ��������������

void sendData(uint8_t cmd, uint8_t datan, uint8_t *databuff); //����������������


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

    __bis_SR_register(GIE);     //��ȫ���ж�

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
    if(IFG2 & UCA0RXIFG){   //����Ƿ���USCI_A0�Ľ����жϣ���ΪUSCI_A0��USCI_B0�Ľ����жϹ���һ����������USCI_A0��USCI_B0�������ж϶��ܽ�����жϺ���
        IFG2 &= ~UCA0RXIFG; //��������жϱ�־λ
        RxBuff[cnt] = UCA0RXBUF;
        uint8_t flag11 = 0;
        if(RxBuff[cnt] == 0xE6){
          flag11 = 1;
            //�յ���֡β ��鲢��������
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
                //У��
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
    /*ʹ��Timer_A1�Ƚ�ģʽ*/
    TA1CTL |= TASSEL_2; //ѡ��SMCLK��Ϊʱ��
    TA1CTL |= MC_1;     //���ϼ���
    TA1CCR0 = 1000-1;   //��1000���� 1/1MHz*1000=1ms
    /*��ʱ���ж�*/
    TA1CTL |= TAIE;    //�����ж�
    TA1CTL &= ~TAIFG;  //����жϱ�־λ
}

#pragma vector = TIMER1_A1_VECTOR //����ж�TA1
__interrupt void Time_Tick(void){
    switch(TA1IV){
    /*�жϴ����жϱ�־λ���Զ�����*/
    case 0x02: //TACCR1 CCIFG ��׽/�Ƚ�1
        break;
    case 0x04: //TACCR2 CCIFG ��׽/�Ƚ�2
        break;
    case 0x0A: //TAIFG����ж� 1msִ��һ��
        TA1CTL &= ~TAIFG;  //����жϱ�־λ
        if(RcvCmdFlag){
            RcvCmdFlag = 0;
            if(CmdBuff == 0x01){
                executeCmd(0x01);    //��һ���յ�׼������
            }else if(ReadyFlag && CmdBuff == 0x06){
                executeCmd(0x06);    //��һ���յ�ȷ��
            }else if(ReadyFlag && ConfirmFlag){
                executeCmd(CmdBuff); //�յ�׼��������ȷ�Ϻ�ִ�д�����������
            }
        }
        /*�յ�׼��������ȷ��*/
        if(ReadyFlag && ConfirmFlag){
            /*100ms���һ��״̬ ����һ������*/
            sendStateCnt++;
            if(sendStateCnt >= 100){
                sendStateCnt = 0;
                /*������ݷ��Ϳ���Ϊ1��������*/
                if(SendAngleFlag){
                    executeCmd(0x41);
                }
                /*���һ��״̬*/
                executeCmd(0x42);
            }
        }
        break;
    default:
        break;
    }
}

void sendReq(void){
    uint8_t code[9] = {'X', 'D', '1', '0', '4', '0', '0', '5', '5'}; //ѧ��ID
    sendData(0x05, 9, code);
}

void confirmType(void){ //ȷ����Ϣ
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
        /*���ͽǶ�*/
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
          /*���ͽǶ�*/
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
    /*���ͽǶ�*/
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
    case 1: //����һ����
        BEEP_ON;
        __delay_cycles(500000);
        BEEP_OFF;
        break;
    case 2: //����һ����
        BEEP_ON;
        __delay_cycles(1000000);
        BEEP_OFF;
        break;
    case 3: //����һ��һ����
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
    case 0x00: //ʲôҲ����
        break;
    case 0x01: //������ʵ��ƽ̨���͡�׼������������
        ReadyFlag = 1;
        sendReq(); //��������ʵ��ƽ̨����ʵ�����󣨿�ʼ���
        break;
//    case 0x05:
//        CmdBuff = 0x00;
//        break;
    case 0x06: //ȷ����Ϣ
        confirmType();
        break;
    case 0x41: //��������ʵ��ƽ̨���ͽǶ�����
        getAngle();
        sendPitchRoll();
        break;
    case 0x42: //��������ʵ��ƽ̨����״̬��ÿ 100ms�ж�һ��״̬�����λ D0~D5 ��ֵ�����˱仯�����͸�ʵ��ƽ̨��
        /**
         * ״̬ State Ϊ���ͱ������� D0 ��ʼ�ֱ��ʾ�����Ǻͺ���ǵ�����
         * ���ޣ�ʵ�� 1,2 ��ָʾ�ơ�ʵ�鲽��ָʾ�ơ�ƽ̨������ 1 ��ָʾ�ơ��� 9λ��
         */
        sendState();
        break;
    case 0x46: //���ݷ��Ϳ������1 ���� 0 ֹͣ
        sendSwitch();
        //uint8_t str1[1] = {0x46};
        //sendString(str1, 1);
        break;
    case 0x48: //���궨����궨���������
        setPitch0();
        break;
    case 0x49: //���궨����궨��������
        setRoll0();
        break;
    case 0x4B: //���������������������
        setPitchThr();
        break;
    case 0x4C: //��������������������
        setRollThr();
        break;
    case 0x4D: //�����źţ�ʹ����������
        warn();
        break;
    case 0x4E: //ʵ����������:1,2 ��ʾ��ʼʵ������1,2��0 ��ʾ��ʵ�����
        switchMission();
        break;
    case 0x4F: //�������������Switch �� D0 λ�ġ�1����ʾƽ̨���� 1 �� ON ״̬����0����ʾ OFF״̬
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
//    uint8_t MeanTimes = 10;    //ȡ10�����ݵ�ƽ��ֵ

    //ReadWords_ACC(acc);
    IIC_A_ReadWords_ACC();

    /*X����ٶ�*/
    AccXtemp = (acc[1] << 8) + acc[0];  //�ϳ�����
//        AccXtemp = AccXtemp - exc[0];         //ƫ��У׼
    AccX += AccXtemp;

    /*Y����ٶ�*/
    AccYtemp = (acc[3] << 8) + acc[2];  //�ϳ�����
//        AccYtemp = AccYtemp - exc[1];        //ƫ��У׼
    AccY += AccYtemp;

    /*Z����ٶ�*/
    AccZtemp = (acc[5] << 8) + acc[4];    //�ϳ�����
//        AccZtemp = AccZtemp - exc[2];        //ƫ��У׼
    AccZ += AccZtemp;
    /*ȡƽ��*/
//    AccX = AccX / MeanTimes;
//    AccY = AccY / MeanTimes;
//    AccZ = AccZ / MeanTimes;
    float X,Y,Za;

    X=(float)AccX*3.9;//ÿ�����LSBΪ3.9mg
    Y=(float)AccY*3.9;
    Za=(float)AccZ*3.9;

    Pitch=(int16_t)((atan2(X,sqrt(pow(Y,2)+pow(Za,2)))*180)/3.14159265-Pitch0);//X��Ƕ�ֵ��������
    Roll=(int16_t)((atan2(Y,sqrt(pow(X,2)+pow(Za,2)))*180)/3.14159265-Roll0);//Y��Ƕ�ֵ�������
    Path=(int16_t)((atan2(Za,sqrt(pow(X,2)+pow(Y,2)))*180)/3.1415926);//Z��Ƕ�ֵ������

//    Pitch = (int16_t)(atan2(AccY , AccZ) / 3.1416 * 180) - Pitch0;
//    Roll  = (int16_t)(atan2(AccX , AccZ) / 3.1416 * 180) - Roll0;

    if(Pitch > PitchThr){
//        Pitch = PitchThr;
        State[0] = 1; //����
        State[1] = 0; //����
        LED4_ON;
        LED3_OFF;
    }else{
        State[0] = 0;
        LED4_OFF;
    }

    if(Pitch < -PitchThr){
//        Pitch = -PitchThr;
        State[0] = 0; //����
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
//    P1SEL &= ~BIT1; //ѡ�� P1.1(SDA) P1.0(SCL)Ϊ I/O �˿�
//    SCL_OUT; //P1.0(SCL)Ϊ���
//    SDA_IN; //p1.1(SDA)Ϊ����
//    SCL_0;
//}
//
////������������ʼ������������//
//void Start(void){ //SCL Ϊ�ߵ�ƽ�ڼ䣬SDA ����һ���½���
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
////����������ֹͣ����������//
//void Stop(void){ //SCL �ߵ�ƽ�ڼ䣬SDA ����һ��������
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
////����������Ӧ���źš���������//
//void Ack(void){ //IIC����Ӧ��  SCLΪ�ߵ�ƽʱ��SDAΪ�͵�ƽ
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
//void NoAck(void){ //IIC������Ӧ�� SDA ά�ָߵ�ƽ��SCL ����һ������
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
////IIC ���߼���Ӧ��SCL �ߵ�ƽ�ڼ䣬�� SDA ��ֵ��
////����ֵ��IIC Ӧ���ֵ 0��Ӧ�� 1����Ӧ��
////��ת���˿�Ϊ�����������������׵�ƽ��Ӧ�����ȷ�����ף�����
////��ƽ�������ߵ�ƽ���Ӷ������Ӧ�������
//uchar TestACK(void){
//    SDA_IN; //SDA ��Ϊ����
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
////��������������дһ���ֽڡ�������������//
//void WriteByte(uchar WriteData){
//    uchar i;
//    SDA_OUT;
//    for (i = 0; i < 8; i++){
//        SDA_OUT;
//        if (((WriteData >> 7) & 0x01) == 0x01){ //�жϷ���λ�������ݵ��������ϣ��Ӹ�λ��ʼ���� bit
//            SDA_1;
//        }else{
//            SDA_0;
//        }
//        __delay_cycles(10);
//        SCL_1; //��ʱ���ź�Ϊ�ߵ�ƽ��ʹ������Ч
//        __delay_cycles(5);
//        SCL_0;
//        __delay_cycles(10);
//        WriteData = WriteData << 1;
//    }
//    SDA_IN;
//    __delay_cycles(5);
//}
////����������������������һ���ֽڡ�������������������//
//uchar ReadByte(void){
//    SDA_IN; //��������Ϊ���뷽��
//    uint8_t i;
//    uint8_t q0 ;
//    uchar byte = 0;
//    for (i = 0; i < 8; i++){
//        SCL_1; //��ʱ��Ϊ�ߵ�ƽ��ʹ������������Ч
//        __delay_cycles(5);
//        byte = byte << 1;
//        SDA_IN;
//        q0 = (P1IN & BIT1);
//        if (q0 == BIT1 ) byte = (byte | 0x01); //�����ݴ��� byte
//        __delay_cycles(10);
//        SCL_0;
//        __delay_cycles(10);
//    }
//    return(byte);
//}
//
//uchar Single_Write_ADXL345(uchar REG_Address,uchar REG_data){
//    Start();
//    WriteByte(SlaveAddress); //�����豸��ַ+д�ź�
//    if(TestACK()!=0)         //����Ӧ��
//        return 1;            //��Ӧ��������Ƴ����������ش���
//    WriteByte(REG_Address);  //�ڲ��Ĵ�����ַ
//    if(TestACK()!=0)
//        return 1;
//    WriteByte(REG_data);     //�ڲ��Ĵ�������
//    if(TestACK()!=0)
//        return 1;
//    Stop();
//    return 0;
//}
////������������������������ȡ��������������������//
//uchar ReadWords_ACC(uchar *acc){
//    Start();
//    WriteByte(SlaveAddress);     //�����豸��ַ+д�ź�
//    if(TestACK() != 0)
//        return 1;
//    WriteByte(0x32);
//    if(TestACK() != 0)
//        return 1;
//    /**/
//    Start();                     //�ٴ����� IIC ����
//    WriteByte(SlaveAddress + 1); //��ȡ
//    if(TestACK() != 0)
//        return 1;
//    uint8_t i;
////    uchar acc[6] = {0}; //������ٶ���Ϣ
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
////***************���ٶȼ�ADXL345��ʼ����������������������������������������//
//void Init_ADXL345(void){
//    Single_Write_ADXL345(0x31, 0x0B); //������Χ,���� 16g��13 λģʽ
//    Single_Write_ADXL345(0x2C, 0x08); //�����趨Ϊ 12.5 �ο� pdf13 ҳ
//    Single_Write_ADXL345(0x2D, 0x08); //ѡ���Դģʽ �ο� pdf24 ҳ
//    Single_Write_ADXL345(0x2E, 0x80); //ʹ�� DATA_READY �ж�
//    Single_Write_ADXL345(0x1E, 0x00); //X ƫ���� ���ݲ��Դ�������״̬д�� pdf29 ҳ
//    Single_Write_ADXL345(0x1F, 0x00); //Y ƫ���� ���ݲ��Դ�������״̬д�� pdf29 ҳ
//    Single_Write_ADXL345(0x20, 0x05); //Z ƫ���� ���ݲ��Դ�������״̬д�� pdf29 ҳ
//}

void initLED_BEEP(void){
    /*LED��BEEP*/
    P1DIR |= BIT0 + BIT3 + BIT4 + BIT5 + BIT6 + BIT7; //BEEP��LED5��7��8��9��10���ģʽ
    P2DIR |= BIT3 + BIT4 + BIT5 + BIT6 + BIT7; //LED6��4��2��3��1���ģʽ
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
    /*P2.2 CSƬѡ*/
    P2DIR |= BIT2;
    //P2OUT &= ~BIT2;
    P2OUT |= BIT2;
}

void initSystemCLK(void){
    /*����DCOΪ1MHz��SMCLK��ԴΪDCOΪ1MHz*/
    DCOCTL = CALDCO_1MHZ;
    BCSCTL1 = CALBC1_1MHZ;
    /*����SMCLK*/
    BCSCTL2 &= ~SELS;               //ѡ��DCOCLKΪSMCLK����Դ
    BCSCTL2 &= ~(DIVS0|DIVS1);      //SMCLK�ķ���ϵ����Ϊ1
}

void initUART(void){
    /*���ô���*/
    UCA0CTL1 |= UCSWRST;            //��λ

    UCA0CTL0 &= ~UCPEN;             //��żУ�鱻��ֹ
    UCA0CTL0 &= ~UCPAR;             //����У��
    UCA0CTL0 &= ~UCMSB;             //�ȷ���0λ
    UCA0CTL0 &= ~UC7BIT;            //8 λ����
    UCA0CTL0 &= ~UCSPB;             //1 ��ֹͣλ
    UCA0CTL0 &= ~(UCMODE0|UCMODE1); //UART ģʽ
    UCA0CTL0 &= ~UCSYNC;            //�첽ģʽUART

    UCA0CTL1 |= (UCSSEL0|UCSSEL1);  //ѡ�� BRCLKʱ��ԴΪSMCLK

    /*���ò�����N=fBRCLK/Baud_rate*/
    //�� 15-4 UCOS16=0 1MHz 9600
    UCA0BR0 = 0x68;  //�Ͱ�λ1000000/9600=104.16667
    UCA0BR1 = 0x00;  //�߰�λ
    UCA0MCTL = 1<<1; //UCBRSx=0

    /*����UCA0RXD��UCA0TXD*/
    P1SEL |= BIT1 + BIT2;
    P1SEL2 |= BIT1 + BIT2;

    /*�����λλ��ʹ��UART*/
    UCA0CTL1 &= ~UCSWRST;

    /*�����ж� ������������λλ��*/
    IE2 |= UCA0RXIE;    //�������ڽ����ж�15.4.12
    IFG2 &= ~UCA0RXIFG; //��������жϱ�־λ15.4.13
}

void sendString(uint8_t *pbuff, uint8_t num){
    uint8_t cnt = 0;
    for(cnt = 0; cnt < num; cnt++){
        while(UCA0STAT & UCBUSY); //ֱ����һ���ַ��������
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
