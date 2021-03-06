//**************************************************************************//
//***                          T3 Coral MTF TT                             ***
//**************************************************************************//
#property copyright   "" 
#property link        "" 
#property description "T3 – индикатор, относящийся к классу Moving Average.  Он создан Тимом Тиллсоном ещё" 
#property description "в 1998 году. Цель, поставленная при создании - получить MA, которая будет давать меньше"
#property description "шумов и быстрее реагировать на изменения цены. T3 применяется как и обычная MA."
#property description " * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * "
#property description "Почта:  tualatine@mail.ru" 
//#property version  "3.00"
//#property strict
#property indicator_chart_window
#property indicator_buffers 3
//------
#property indicator_color1 Lime  //LightSteelBlue  //
#property indicator_color2 Red  //Magenta  //
#property indicator_color3 Blue  //LightCyan  //Dark  //Red
//------
//#property indicator_width1 3
//#property indicator_width2 3
#property indicator_width3 1
//------
#property indicator_style1 0
#property indicator_style2 0
#property indicator_style3 2
//**************************************************************************//
//***                   Custom indicator ENUM settings                     ***
//**************************************************************************//
enum showCR { LINE, ZIGZAG, ARROW };
//**************************************************************************//
//***                Custom indicator input parameters                     *** 
//**************************************************************************//

extern int                 History  =  1440;  //2864;
extern ENUM_TIMEFRAMES   TimeFrame  =  PERIOD_CURRENT;
extern int                T3Period  =  24;  //14;
extern double                 beta  =  0.2424;  //0.1;  //0.618;
extern ENUM_APPLIED_PRICE  T3Price  =  PRICE_WEIGHTED;  //CLOSE;
extern int                 T3Shift  =  0;
extern bool            Interpolate  =  true;
extern bool                 ShowT3  =  false;
extern showCR            ShowCoral  =  LINE;
extern int                ArrCodUP  =  167,  //233,  //147,  116, 117, 234,   //226
                          ArrCodDN  =  167,  //234,   //181,  233,   //225
                           ArrSize  =  3;
extern int               SIGNALBAR  =  1;
extern bool          AlertsMessage  =  true,   //false,    
                       AlertsSound  =  true,   //false,
                       AlertsEmail  =  false,
                      AlertsMobile  =  false;
extern string            SoundFile  =  "expert.wav";   //"stops.wav"   //"alert2.wav"   //"news.wav"

//**************************************************************************//
//***                     Custom indicator buffers                         ***         
//**************************************************************************//
double T3UP[], T3DN[], T3ARRAY[];  double trend[];  
//------
int t3Period;
double e1,e2,e3,e4,e5,e6;
double c1,c2,c3,c4;
double w1,w2,b2,b3;
//------
double ae1[], ae2[], ae3[], ae4[], ae5[], ae6[];
//------
int timeFrame;  string IndicatorFileName;
string  messageUP, messageDN;  int TimeBar=0;
//**************************************************************************//
//***               Custom indicator initialization function               ***
//**************************************************************************//
int init()
{
   IndicatorBuffers(3);   IndicatorDigits(Digits);  if (Digits==3 || Digits==5) IndicatorDigits(Digits-1);
//------ 3 распределенных буфера индикатора 
   SetIndexBuffer(0,T3UP);
   SetIndexBuffer(1,T3DN);
   SetIndexBuffer(2,T3ARRAY);
//------ настройка параметров отрисовки 
   int ARR=DRAW_LINE;   if (ShowCoral==1) ARR=DRAW_ZIGZAG;   if (ShowCoral==2) ARR=DRAW_ARROW; 
   SetIndexStyle(0,ARR,EMPTY,ArrSize);   SetIndexArrow(0,ArrCodUP);  
  	SetIndexStyle(1,ARR,EMPTY,ArrSize);   SetIndexArrow(1,ArrCodDN);   	
   int T3L=DRAW_LINE;   if (!ShowT3) T3L=DRAW_NONE;   
  	SetIndexStyle(2,T3L);     
//------ значение 0 отображаться не будет 
  	SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
  	SetIndexEmptyValue(2,0.0);
//------ установка сдвига линий при отрисовке
   SetIndexShift(0,T3Shift);   
   SetIndexShift(1,T3Shift);   
   SetIndexShift(2,T3Shift);   
//------ пропуск отрисовки первых баров
   SetIndexDrawBegin(0,T3Shift+T3Period);   
   SetIndexDrawBegin(1,T3Shift+T3Period);   
   SetIndexDrawBegin(2,T3Shift+T3Period);    
    	
//------ отображение в DataWindow 
   SetIndexLabel(0,TimeFrameToString(TimeFrame)+"Coral UP");
   SetIndexLabel(1,TimeFrameToString(TimeFrame)+"Coral DN");   
   SetIndexLabel(2,TimeFrameToString(TimeFrame)+"Coral ["+IntegerToString(T3Period)+"*"+DoubleToStr(beta,2)+"]");
   
//------ "короткое имя" для DataWindow и подокна индикатора 
   if (TimeFrame < Period()) TimeFrame=PERIOD_CURRENT; 
   timeFrame = stringToTimeFrame(TimeFrame); 
   IndicatorShortName(TimeFrameToString(TimeFrame)+"T3 Coral MTF TT ["+IntegerToString(T3Period)+"*"+DoubleToStr(beta,2)+"]");
   IndicatorFileName = WindowExpertName();
//**************************************************************************//   
//------
return(0);
}
//**************************************************************************//
//***              Custom indicator deinitialization function              ***
//**************************************************************************//
int deinit() { return(0); }
//**************************************************************************//
//***                 Custom indicator iteration function                  ***
//**************************************************************************//
int start()
{
   int  i, x, y, limit;
   int CountedBars = IndicatorCounted();   
   if (CountedBars < 0) return (-1);       //Стандарт-Вариант!!!         
   if (CountedBars > 0) CountedBars--;
   limit = History; 
   if (History==0) limit = Bars-CountedBars;      
//**************************************************************************//

   ArrayResize(ae1, limit);  ArraySetAsSeries(ae1, true);
   ArrayResize(ae2, limit);  ArraySetAsSeries(ae2, true);
   ArrayResize(ae3, limit);  ArraySetAsSeries(ae3, true);
   ArrayResize(ae4, limit);  ArraySetAsSeries(ae4, true);
   ArrayResize(ae5, limit);  ArraySetAsSeries(ae5, true);
   ArrayResize(ae6, limit);  ArraySetAsSeries(ae6, true);
   ArrayResize(trend, limit);  ArraySetAsSeries(trend, true);
//**************************************************************************//       

   if (AlertsMessage || AlertsEmail || AlertsMobile) {
       messageUP=(IndicatorFileName+" - "+TimeFrameToString(TimeFrame)+Symbol()+", TF["+Period()+"]  >>>  Trend UP  ==  BUY");
       messageDN=(IndicatorFileName+" - "+TimeFrameToString(TimeFrame)+Symbol()+", TF["+Period()+"]  <<<  Trend DN  ==  SELL"); }
//**************************************************************************//

   if (t3Period != T3Period)
    {
     t3Period = T3Period;
       b2 = beta*beta;
       b3 = b2*beta;
       //------
       c1 = -b3;
       c2 = (3*(b2+b3));
       c3 = -3*(2*b2+beta+b3);
       c4 = (1+3*beta+b3+3*b2);
       //------
       w1 = 2 / (2 + 0.5*(MathMax(1,T3Period)-1));
       w2 = 1 - w1; 
    }
//**************************************************************************//
//**************************************************************************//   

   if (timeFrame==Period())
    {
     for (i=limit; i>=0; i--)
      {
       double price = iMA(NULL,0,1,0,MODE_SMA,T3Price,i);   
       e1 = w1*price + w2*ae1[i+1];
       e2 = w1*e1    + w2*ae2[i+1];
       e3 = w1*e2    + w2*ae3[i+1];
       e4 = w1*e3    + w2*ae4[i+1];
       e5 = w1*e4    + w2*ae5[i+1];
       e6 = w1*e5    + w2*ae6[i+1];
       //------
         T3ARRAY[i] = c1*e6 + c2*e5 + c3*e4 + c4*e3;
       //------
         ae1[i] = e1;
         ae2[i] = e2;
         ae3[i] = e3;
         ae4[i] = e4;
         ae5[i] = e5;
         ae6[i] = e6;
      }  
   //**************************************************************************//
     
     for (x=limit-1; x>=0; x--)
      {
       trend[x] = trend[x+1];   
       if (T3ARRAY[x] > T3ARRAY[x+1]) trend[x] = 1;
       if (T3ARRAY[x] < T3ARRAY[x+1]) trend[x] =-1;
     //------
       if (trend[x]>0) { T3UP[x]=T3ARRAY[x];  if (trend[x+1]<0) T3UP[x+1]=T3ARRAY[x+1];  T3DN[x]=0; }     
       if (trend[x]<0) { T3DN[x]=T3ARRAY[x];  if (trend[x+1]>0) T3DN[x+1]=T3ARRAY[x+1];  T3UP[x]=0; }
      }
   //**************************************************************************//
     
     if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound) {
         if (TimeBar!=Time[0] && trend[0+SIGNALBAR]==1 && trend[0+SIGNALBAR]!=trend[0+1+SIGNALBAR]) { 
             if (AlertsMessage) Alert(messageUP);  if (AlertsEmail) SendMail(Symbol(),messageUP);  if (AlertsMobile) SendNotification(messageUP);  if (AlertsSound) PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"  
             TimeBar=Time[0]; } //return(0);
         //------
         else if (TimeBar!=Time[0] && trend[0+SIGNALBAR]==-1 && trend[0+SIGNALBAR]!=trend[0+1+SIGNALBAR]) {
                  if (AlertsMessage) Alert(messageDN);  if (AlertsEmail) SendMail(Symbol(),messageDN);  if (AlertsMobile) SendNotification(messageDN);  if (AlertsSound) PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"                
                  TimeBar=Time[0]; } }  //return(0);   //*конец* Алертов
   //**************************************************************************//
     return(0);  //*конец* if (timeFrame==Period())
    }
//**************************************************************************//
//***                          T3 Coral MTF TT                             ***
//**************************************************************************//

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,IndicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   
   for (i=limit; i>=0; i--)
    {
     y = iBarShift(NULL,timeFrame,Time[i]);
     T3UP[i] = iCustom(NULL, timeFrame, IndicatorFileName, History, TimeFrame, T3Period, beta, T3Price, T3Shift, 0, y);
     T3DN[i] = iCustom(NULL, timeFrame, IndicatorFileName, History, TimeFrame, T3Period, beta, T3Price, T3Shift, 1, y);
     T3ARRAY[i] = iCustom(NULL, timeFrame, IndicatorFileName, History, TimeFrame, T3Period, beta, T3Price, T3Shift, 2, y);
    //**************************************************************************//

     if (!Interpolate || y==iBarShift(NULL,TimeFrame,Time[i-1])) continue;
       datetime time = iTime(NULL,TimeFrame,y);
         for (int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
           for (int k = 1; k < n; k++)
             T3ARRAY[i+k] = T3ARRAY[i] + (T3ARRAY[i+n]-T3ARRAY[i])*k/n; 
             T3UP[i+k] = T3UP[i] + (T3UP[i+n]-T3UP[i])*k/n;   
             T3DN[i+k] = T3DN[i] + (T3DN[i+n]-T3DN[i])*k/n;   
    //**************************************************************************//
    } //*конец цикла* for (i=limit; i>=0; i--)
   //**************************************************************************//
  
   for (x=limit-1; x>=0; x--)
    {
     trend[x] = trend[x+1];   
     if (T3ARRAY[x] > T3ARRAY[x+1]) trend[x] = 1;
     if (T3ARRAY[x] < T3ARRAY[x+1]) trend[x] =-1;
   //------
     if (trend[x]>0) { T3UP[x]=T3ARRAY[x];  if (trend[x+1]<0) T3UP[x+1]=T3ARRAY[x+1];  T3DN[x]=0; }
     if (trend[x]<0) { T3DN[x]=T3ARRAY[x];  if (trend[x+1]>0) T3DN[x+1]=T3ARRAY[x+1];  T3UP[x]=0; }
    }
   //**************************************************************************//
     
     if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound) {
         if (TimeBar!=Time[0] && trend[0+SIGNALBAR]==1 && trend[0+SIGNALBAR]!=trend[0+1+SIGNALBAR]) { 
             if (AlertsMessage) Alert(messageUP);  if (AlertsEmail) SendMail(Symbol(),messageUP);  if (AlertsMobile) SendNotification(messageUP);  if (AlertsSound) PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"  
             TimeBar=Time[0]; } //return(0);
         //------
         else if (TimeBar!=Time[0] && trend[0+SIGNALBAR]==-1 && trend[0+SIGNALBAR]!=trend[0+1+SIGNALBAR]) {
                  if (AlertsMessage) Alert(messageDN);  if (AlertsEmail) SendMail(Symbol(),messageDN);  if (AlertsMobile) SendNotification(messageDN);  if (AlertsSound) PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"                
                  TimeBar=Time[0]; } }  //return(0);   //*конец* Алертов
   //**************************************************************************//    
//**************************************************************************//
//------
return(0);   //*КОНЕЦ ВСЕХ РАСЧЁТОВ*
}
//**************************************************************************//
//***                          T3 Coral MTF TT                             ***
//**************************************************************************//
int stringToTimeFrame(string tfs)
{
   int tf=0;
   tfs = StringTrimLeft(StringTrimRight(TimeFrame));  //StringUpperCase(tfs)));
   //------
     if (tfs=="M1"  || tfs=="1")      tf=PERIOD_M1;
     if (tfs=="M5"  || tfs=="5")      tf=PERIOD_M5;
     if (tfs=="M15" || tfs=="15")     tf=PERIOD_M15;
     if (tfs=="M30" || tfs=="30")     tf=PERIOD_M30;
     if (tfs=="H1"  || tfs=="60")     tf=PERIOD_H1;
     if (tfs=="H4"  || tfs=="240")    tf=PERIOD_H4;
     if (tfs=="D1"  || tfs=="1440")   tf=PERIOD_D1;
     if (tfs=="W1"  || tfs=="10080")  tf=PERIOD_W1;
     if (tfs=="MN"  || tfs=="43200")  tf=PERIOD_MN1;
     if (tf<Period()) tf=Period();
//------
return(tf);
}
//**************************************************************************//
//***                          T3 Coral MTF TT                             ***
//**************************************************************************//
string TimeFrameToString(int tf)
{
   string tfs="";
//------
   if (tf!=Period())
//------
   switch(tf) {
      case PERIOD_M1:  tfs="M1_"  ; break;
      case PERIOD_M5:  tfs="M5_"  ; break;
      case PERIOD_M15: tfs="M15_" ; break;
      case PERIOD_M30: tfs="M30_" ; break;
      case PERIOD_H1:  tfs="H1_"  ; break;
      case PERIOD_H4:  tfs="H4_"  ; break;
      case PERIOD_D1:  tfs="D1_"  ; break;
      case PERIOD_W1:  tfs="W1_"  ; break;
      case PERIOD_MN1: tfs="MN1_" ; }
//------
return(tfs);
}
//**************************************************************************//
//***                          T3 Coral MTF TT                             ***
//**************************************************************************//
//string StringUpperCase(string str)     // НЕ удалять - может пригодиться!!??
//{
//   string  s = str;
//   int     lenght = StringLen(str) - 1;
//   int     CHAR;
//   //------
//   while (lenght >= 0)
//    {
//     CHAR = StringGetChar(s, lenght);
//     //------
//     if ((CHAR > 96 && CHAR < 123) || (CHAR > 223 && CHAR < 256))
//              s = StringSetChar(s, lenght, CHAR - 32);
//     else 
//     if (CHAR > -33 && CHAR < 0)
//              s = StringSetChar(s, lenght, CHAR + 224);
//     lenght--;
//    }
////------
//return(s);
//}
//**************************************************************************//
//***                          T3 Coral MTF TT                             ***
//**************************************************************************//