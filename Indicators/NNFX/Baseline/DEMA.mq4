//+------------------------------------------------------------------+
//|                                                   DEMA_RLH       |
//|                                    Copyright © 2006, Robert Hill |
//|                                                                  |
//| Based on the formula developed by Patrick Mulloy                 |
//|                                                                  |
//| It can be used in place of EMA or to smooth other indicators.    |
//|                                                                  |
//| DEMA = 2 * EMA - EMA of EMA                                      |
//|                                                                  |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Robert Hill "

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 1
#property  indicator_color1  Red
#property  indicator_width1  2
      
extern int EMA_Period = 14;

//---- buffers
double Dema[];
double Ema[];
double EmaOfEma[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
  
//---- drawing settings
   
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,EMA_Period);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);

//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,Dema) &&
      !SetIndexBuffer(1,EmaOfEma) &&
      !SetIndexBuffer(2,Ema))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("DEMA("+EMA_Period+")");
   SetIndexLabel(0, "DEMA");
   
//---- initialization done
   return(0);
  }

int start()
{
   int i, limit;
   int    counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
  
//   if (AccountCompany() != "Peregrine Financial Group, Inc") return(0);
 
   for(i = limit; i >= 0; i--)
       Ema[i] = iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_CLOSE,i);
   for(i = limit; i >=0; i--)
       EmaOfEma[i] = iMAOnArray(Ema,Bars,EMA_Period,0,MODE_EMA,i);
    
         
//========== COLOR CODING ===========================================               
        
   for(i = limit; i >=0; i--)
       Dema[i] = 2 * Ema[i] - EmaOfEma[i];
       
      return(0);
  }
//+------------------------------------------------------------------+



