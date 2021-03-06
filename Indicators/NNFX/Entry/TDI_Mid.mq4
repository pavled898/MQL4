//+------------------------------------------------------------------+
//|                                                      TDI_Mid.mq4 |
//|                                Copyright © 2018 by Dack Phillips |
//|                                       http://dackral.duckdns.org |
//+------------------------------------------------------------------+
#property copyright "2018 by Dack Phillips"
#property link      "http://dackral.duckdns.org"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                  Traders Dynamic Index Mid Trend Line            |
//|                                                                  |
//|  Yellow line = Market Base Line                                  |  
//|                                                                  |   
//|   Overall = Yellow line trends up and down generally between the |
//|             lines 32 & 68. Watch for Yellow line to bounces off  |
//|             these lines for market reversal. Trade long when     |
//|             price is above the Yellow line, and trade short when |
//|             price is below.                                      |        
//|                                                                  |
//|  IMPORTANT: The default settings are well tested and proven.     |
//|             But, you can change the settings to fit your         |
//|             trading style.                                       |
//+------------------------------------------------------------------+
#property description "Shows trend direction."
#property description "Yellow line - Market Base line."

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_level1 32
#property indicator_level2 50
#property indicator_level3 68
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1
#property indicator_color1 clrNONE
#property indicator_type1  DRAW_NONE
#property indicator_color2 clrNONE
#property indicator_type2  DRAW_LINE
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
#property indicator_color3 clrYellow
#property indicator_label3 "Market Base Line"
#property indicator_type3  DRAW_LINE
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID
#property indicator_color4 clrNONE
#property indicator_type4  DRAW_LINE
#property indicator_width4 1
#property indicator_style4 STYLE_SOLID
#property indicator_color5 clrNONE
#property indicator_type5  DRAW_LINE
#property indicator_width5 2
#property indicator_style5 STYLE_SOLID
#property indicator_color6 clrNONE
#property indicator_type6  DRAW_LINE
#property indicator_width6 2
#property indicator_style6 STYLE_SOLID
#property indicator_color7 clrNONE
#property indicator_type7  DRAW_LINE
#property indicator_width7 1

input int RSI_Period = 13; //RSI_Period: 8-25
input ENUM_APPLIED_PRICE RSI_Price = PRICE_CLOSE;
input int Volatility_Band = 34; //Volatility_Band: 20-40
input double StdDev = 1.6185; //Standard Deviations: 1-3
input int RSI_Price_Line = 2;      
input ENUM_MA_METHOD RSI_Price_Type = MODE_SMA;
input int Trade_Signal_Line = 7;   
input ENUM_MA_METHOD Trade_Signal_Type = MODE_SMA;
//input bool UseAlerts = false;

//Global Variables
double RSIBuf[], UpZone[], MdZone[], DnZone[], MaBuf[], MbBuf[], RSI7[];
int AlertPlayedonBar = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorShortName("TDI Mid");
   
   //Set maximum and minimum for subwindow 
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
   
   //Set descriptions of horizontal levels
   IndicatorSetString(INDICATOR_LEVELTEXT,0,"Start Trend");
   IndicatorSetString(INDICATOR_LEVELTEXT,1,"Normal");
   IndicatorSetString(INDICATOR_LEVELTEXT,2,"End Trend");

   //Export the information to iCustom   
   SetIndexBuffer(0, RSIBuf); //Not shown
   SetIndexBuffer(1, UpZone); //Not shown
   SetIndexBuffer(2, MdZone); //Yellow
   SetIndexBuffer(3, DnZone); //Not shown
   SetIndexBuffer(4, MaBuf);  //Not shown
   SetIndexBuffer(5, MbBuf);  //Not shown
   SetIndexBuffer(6, RSI7);   //Not shown
   
   return(0);
}

//+------------------------------------------------------------------+
//| Traders Dynamic Index                                            |
//+------------------------------------------------------------------+
int start()
{
   double MA, RSI[];
   ArrayResize(RSI, Volatility_Band);
   
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
   
   for (int i = limit; i >= 0; i--)
   {
      RSIBuf[i] = iRSI(NULL, 0, RSI_Period, RSI_Price, i);
      MA = 0;
      for (int x = i; x < i + Volatility_Band; x++) 
      {
         if (x > Bars - 1) break;
         RSI[x - i] = RSIBuf[x];
         MA += RSIBuf[x] / Volatility_Band;
      }
      double SD = StdDev * StDev(RSI, Volatility_Band);
      UpZone[i] = MA + SD;
      DnZone[i] = MA - SD;
      MdZone[i] = (UpZone[i] + DnZone[i]) / 2;
      RSI7[i] = iRSI(NULL, 0, 7, RSI_Price, i);
   }
   for (i = limit - 1; i >= 0; i--)  
   {
      MaBuf[i] = iMAOnArray(RSIBuf, 0, RSI_Price_Line, 0, RSI_Price_Type, i);
      MbBuf[i] = iMAOnArray(RSIBuf, 0, Trade_Signal_Line, 0, Trade_Signal_Type, i);
   }
   /*if ((MbBuf[0] > MdZone[0]) && (MbBuf[1] <= MdZone[1]) && (UseAlerts == true) && (AlertPlayedonBar != Bars))
   {
      Alert("Bullish cross");
      PlaySound("alert.wav");
      AlertPlayedonBar = Bars;
   }
   if ((MbBuf[0] < MdZone[0]) && (MbBuf[1] >= MdZone[1]) && (UseAlerts == true) && (AlertPlayedonBar != Bars))
   {
      Alert("Bearish cross");
      PlaySound("alert.wav");
      AlertPlayedonBar = Bars;
   }*/
   return 0;
}
  
//+------------------------------------------------------------------+
//| Standard Deviation function - needed to calculate volatility     | 
//|                               bands.                             |
//+------------------------------------------------------------------+
double StDev(double& Data[], int Per)
{
	return MathSqrt(Variance(Data, Per));
}

//+------------------------------------------------------------------+
//| Variance function - needed to calculate volatility bands.        |
//+------------------------------------------------------------------+
double Variance(double& Data[], int Per)
{
	double sum = 0, ssum = 0;
	for (int i = 0; i < Per; i++)
	{
		sum += Data[i];
		ssum += MathPow(Data[i], 2);
	}
	return (ssum * Per - sum * sum) / (Per * (Per - 1));
}