//+------------------------------------------------------------------+
//|                                           ichimoku-kinko-hyo.mq4 |
//|        ©2011 Best-metatrader-indicators.com. All rights reserved |
//|                        http://www.best-metatrader-indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011 Best-metatrader-indicators.com."
#property link      "http://www.best-metatrader-indicators.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Tomato

// ---- inputs
// ERperiod    It should be >0. If not it will be autoset to default value
// histogram   [true] - histogram style on; [false] - histogram style off
extern int       ERperiod     =10;              // Efficiency ratio period
extern bool      histogram    =false;           // Histogram switch
extern int       shift        =0;               // Sets offset

// ---- buffers
double KVBfr[];

// ---- global variables
double   noise;

string Copyright="\xA9 WWW.BEST-METATRADER-INDICATORS.COM";  
string MPrefix="FI";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
   
   // ---- checking inputs
   if(ERperiod<=0)
      {
       ERperiod=10;
       Alert("ERperiod readjusted");
      }                        
   
   // ---- drawing settings
   if(!histogram) SetIndexStyle(0,DRAW_LINE);
   else           SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexLabel(0,"KVolatility");
   SetIndexShift(0,shift);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   short_name="KVolatility(";
   IndicatorShortName(short_name+ERperiod+")");

   // ---- mapping
   SetIndexBuffer(0,KVBfr);

   // ---- done
   DL("001", Copyright, 5, 20,Gold,"Arial",10,0); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ClearObjects(); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   // ---- optimization
   if(Bars<ERperiod+2) return(0);
   
   int counted_bars=IndicatorCounted(),
       limit, maxbar,
       i;
   
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   
   limit=Bars-counted_bars-1;
   maxbar=Bars-1-ERperiod;
   if(limit>maxbar) limit=maxbar;

   // ---- main cycle
   for(i=limit; i>=0; i--)
      {
       noise=Volatility(i);
       if(noise==EMPTY_VALUE) continue;
       KVBfr[i]=noise;
      }
   
   // ----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom Volatility function                                       |
//+------------------------------------------------------------------+
double Volatility(int initialbar)
   {
    if(initialbar>Bars-ERperiod-1) return(EMPTY_VALUE);
    int j;
    double v=0.0;
    for(j=0; j<ERperiod; j++)
      v+=MathAbs(Close[initialbar+j]-Close[initialbar+1+j]);
    return(v);
   }
//+------------------------------------------------------------------+
//| DL function                                                      |
//+------------------------------------------------------------------+
 void DL(string label, string text, int x, int y, color clr, string FontName = "Arial",int FontSize = 12, int typeCorner = 1)
 
{
   string labelIndicator = MPrefix + label;   
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
  }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, y);
   ObjectSetText(labelIndicator, text, FontSize, FontName, clr);
  
}  

//+------------------------------------------------------------------+
//| ClearObjects function                                            |
//+------------------------------------------------------------------+
void ClearObjects() 
{ 
  for(int i=0;i<ObjectsTotal();i++) 
  if(StringFind(ObjectName(i),MPrefix)==0) { ObjectDelete(ObjectName(i)); i--; } 
}
//+------------------------------------------------------------------+