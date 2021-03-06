//+------------------------------------------------------------------+
//|                                                       TEMA_RLH   |
//|                                    Copyright © 2006, Robert Hill |
//|                                       http://www.metaquotes.net/ |
//|                                                                  |
//| Based on the formula developed by Patrick Mulloy                 |
//|                                                                  |
//| It can be used in place of EMA or to smooth other indicators.    |
//|                                                                  |
//| TEMA = 3 * EMA - 3 * (EMA of EMA) + EMA of EMA of EMA            |
//|                                                                  |
//|  Red is EMA, Green is EMA of EMA, Yellow is DEMA                 |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Robert Hill "
#property  link      "http://www.metaquotes.net/"
#include <MovingAverages.mqh>

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 3
#property  indicator_color1  Red
#property  indicator_color2  Green
#property  indicator_color3  Yellow
#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
      
extern int EMA_Period = 14;

//---- buffers
double Ema[];
double EmaOfEma[];
double Dema[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit(void)
  {
  
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(0,EMA_Period);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,Ema) &&
      !SetIndexBuffer(1,EmaOfEma) &&
      !SetIndexBuffer(2,Dema))
      Print("cannot set indicator buffers!");
//   if(!SetIndexBuffer(0,Tema) )
//      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("DEMA("+EMA_Period+")");
//---- initialization done
   ArraySetAsSeries(Ema,true);
   ArraySetAsSeries(EmaOfEma,true);
   ArraySetAsSeries(Dema,true);
}
int totalBars;

int OnCalculate (const int rates_total,
                 const int prev_calculated,
                 const datetime& time[],
                 const double& open[],
                 const double& high[],
                 const double& low[],
                 const double& close[],
                 const long& tick_volume[],
                 const long& volume[],
                 const int& spread[])
{
   int i, limit;
   int    counted_bars=prev_calculated;
   if(counted_bars>0) counted_bars--;
    totalBars = rates_total;
   limit=totalBars-counted_bars;
  

   for(i = 0; i < limit ; i++)
       Ema[i] = iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_CLOSE,i);
//   for(i = limit; i>0; i--)
//       EmaOfEma[i] = iMAOnArray(Ema,Bars,EMA_Period,0,MODE_EMA,i);
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,EMA_Period,Ema,EmaOfEma);
             
//========== COLOR CODING ===========================================               
        
   for(i = 0; i < limit; i++)
       Dema[i] = 2 * Ema[i] - 3 * EmaOfEma[i];
       
      return(rates_total);
  }
//+------------------------------------------------------------------+



