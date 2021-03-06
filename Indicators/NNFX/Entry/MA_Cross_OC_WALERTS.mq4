//+------------------------------------------------------------------+
//|                                         EMA-Crossover_Signal.mq4 |
//|         Copyright © 2005, Jason Robinson (jnrtrading)            |
//|                   http://www.jnrtading.co.uk                     |
//+------------------------------------------------------------------+

/*
  +------------------------------------------------------------------+
  | Allows you to enter two ema periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the emas   |
  | from the chart. (emas are initially set at 5 and 6)              |
  +------------------------------------------------------------------+
*/   
#property copyright "Remodified with Alerts by FVT365";

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Orange

double CrossUp[];
double CrossDown[];
double trend[];
extern int FasterMode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
extern int FasterMA =   14;
extern int SlowerMode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
extern int SlowerMA =   14;

// === Section 1: paste this code directly BELOW the final 'extern' statement =================== //
                                                                                                                                                //
extern int     AlertCandle         = 1;                                                                                                         //
extern bool    ShowChartAlerts     = true;                                                                                                     //
extern string  AlertEmailSubject   = "";                                                                                                        //
                                                                                                                                                //
datetime       LastAlertTime       = -999999;                                                                                                   //
                                                                                                                                                //
string         AlertTextCrossUp    = "PUT!!";          //---- type your desired text between the quotes                         //
string         AlertTextCrossDown  = "CALL!!";        //---- type your desired text between the quotes                         //
                                                                                                                                                //
// =============================================================================================== //
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_ARROW, EMPTY,1);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY,1);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
   SetIndexBuffer(2, trend);
//----
   return(0);
   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit, i, counter;
   double fasterMAnow, slowerMAnow;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for (i=limit; i>=0; i--) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(Open[counter]-Close[counter]);
      }
      Range=AvgRange/10;
       
      fasterMAnow = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i);
      slowerMAnow = iMA(NULL, 0, SlowerMA, 0, SlowerMode, PRICE_OPEN, i);
      trend[i] = trend[i+1];
      
      if (fasterMAnow > slowerMAnow) trend[i] = 1;
      if (fasterMAnow < slowerMAnow) trend[i] =-1;
      CrossUp[i] = EMPTY_VALUE;
      CrossDown[i] = EMPTY_VALUE;
      if (trend[i] !=trend[i+1])
         if (trend[i] == 1)
               CrossUp[i] = Low[i] - Range*0.5;
         else  CrossDown[i] = High[i] + Range*0.5;
         
        
   }
   // =============================================================================================== //

// === Section 2: paste this code just BEFORE the final 'return(0)' statement in the start() module === //
                                                                                                                                                //
  ProcessAlerts();                                                                                                                              //
                                                                                                                                                //
// ================================================================================= //
   return(0);
}
// === Section 3: paste this code at the end of the indicator =========================== //
                                                                                                                                                //
//+------------------------------------------------------------------+                                                                          //
int ProcessAlerts()   {                                                                                                                         //
//+------------------------------------------------------------------+                                                                          //
  if (AlertCandle >= 0  &&  Time[0] > LastAlertTime)   {                                                                                        //
                                                                                                                                                //
    // === Alert processing for crossover UP (indicator line crosses ABOVE signal line) ===                                                     //
    if (CrossUp[AlertCandle] > CrossDown[AlertCandle]  &&  CrossUp[AlertCandle+1] <= CrossDown[AlertCandle+1])  {                   //
      string AlertText = Symbol() + "," + TFToStr(Period()) + ": " + AlertTextCrossUp;                                                          //
      if (ShowChartAlerts)          Alert(AlertText);                                                                                           //
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);                                                                      //
      LastAlertTime = Time[0];                                                                                                                  //
    }                                                                                                                                           //
                                                                                                                                                //
    // === Alert processing for crossover DOWN (indicator line crosses BELOW signal line) ===                                                   //
    if (CrossUp[AlertCandle] < CrossDown[AlertCandle]  &&  CrossUp[AlertCandle+1] >= CrossDown[AlertCandle+1])  {                   //
      AlertText = Symbol() + "," + TFToStr(Period()) + ": " + AlertTextCrossDown;                                                               //
      if (ShowChartAlerts)          Alert(AlertText);                                                                                           //
      if (AlertEmailSubject > "")   SendMail(AlertEmailSubject,AlertText);                                                                      //
      LastAlertTime = Time[0];                                                                                                                  //
    }                                                                                                                                           //                                                                                                                                                //
                                                                                                                                                //
  }                                                                                                                                             //
  return(0);                                                                                                                                    //
}                                                                                                                                               //
                                                                                                                                                //
//+------------------------------------------------------------------+                                                                          //
string TFToStr(int tf)   {                                                                                                                      //
//+------------------------------------------------------------------+                                                                          //
  if (tf == 0)        tf = Period();                                                                                                            //
  if (tf >= 43200)    return("MN");                                                                                                             //
  if (tf >= 10080)    return("W1");                                                                                                             //
  if (tf >=  1440)    return("D1");                                                                                                             //
  if (tf >=   240)    return("H4");                                                                                                             //
  if (tf >=    60)    return("H1");                                                                                                             //
  if (tf >=    30)    return("M30");                                                                                                            //
  if (tf >=    15)    return("M15");                                                                                                            //
  if (tf >=     5)    return("M5");                                                                                                             //
  if (tf >=     1)    return("M1");                                                                                                             //
  return("");                                                                                                                                   //
}                                                                                                                                               //
// ======================================================================================= //
