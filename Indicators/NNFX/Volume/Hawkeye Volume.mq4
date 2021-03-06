//+------------------------------------------------------------------+
//|                                               Hawkeye Volume.mq4 |
//|                                Copyright © 2009, Hawkeye Traders |
//|                                    http://www.HawkeyeTraders.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Hawkeye Traders"
#property link      "http://www.HawkeyeTraders.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 White
#property indicator_color4 MediumVioletRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
//---- indicator buffers
double GreenBuffer[];
double RedBuffer[];
double WhiteBuffer[];
double VioletBuffer[];

#include <HawkVars.mqh>

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- line shifts when drawing
   SetIndexShift(0, 0);
   SetIndexShift(1, 0);
   SetIndexShift(2, 0);
   SetIndexShift(3, 0);
//---- first positions skipped when drawing
   SetIndexDrawBegin(0, 0);
   SetIndexDrawBegin(1, 0);
   SetIndexDrawBegin(2, 0);
   SetIndexDrawBegin(3, 0);
//---- 3 indicator buffers mapping
   SetIndexBuffer(0, GreenBuffer);
   SetIndexBuffer(1, RedBuffer);
   SetIndexBuffer(2, WhiteBuffer);
   SetIndexBuffer(3, VioletBuffer);
//---- index labels
   SetIndexLabel(0,"Hawkeye Volume");
   SetIndexLabel(1,"Hawkeye Volume");
   SetIndexLabel(2,"Hawkeye Volume");
   SetIndexLabel(3,"Hawkeye Volume");
//---- index style
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_HISTOGRAM);
//---- initialization done
   //

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
//| H9_HISHL                                                         |
//+------------------------------------------------------------------+
int start()
  {
//---- main loop

   int limit;
   int counted_bars=IndicatorCounted();

   //---- check for possible errors
   if( counted_bars < 0 ) return(-1);

   //---- the last counted bar will be recounted
   //if( counted_bars > 0 ) counted_bars--;
   limit = Bars-counted_bars;

   int hawkvol;

   for(int i=Bars; i > 0; i--)
     {
         H9_AddPriceData(Open[i], High[i], Low[i], Close[i], Volume[i], Time[i], Period(), Period(), 2, Point, Bars-i);


         hawkvol = H9_HV();
      
         if ( hawkvol == 1 ) GreenBuffer[i] = Volume[i];
         if ( hawkvol == -1 ) RedBuffer[i] = Volume[i];
         if ( hawkvol == 0 ) WhiteBuffer[i] = Volume[i];               
     }

     VioletBuffer[0] = Volume[i];
     if ( limit == 2 ) VioletBuffer[1] = NULL;
     
//---- done
   return(0);
  }
  
  	//H9_HV
int  H9_HV()
	{ 
		int returnVal = 0; 

				double dummy;
				dummy = h9i_average_range(10);
				dummy = h9i_average_range(15);
				dummy = h9i_average_vol(10);
				dummy = h9i_average_vol(15);
				dummy = h9i_average_truerange(5);
				dummy = h9i_average_truerange(15);
				dummy = h9i_average_hlc(5);
				dummy = h9i_average_high(10);
				dummy = h9i_average_low(10);
				returnVal = h9i_hvr();

				returnVal = h9i_hv();

		return returnVal; 
	} 

#include <Hawk.mqh>
#include <HawkSupport.mqh>
#include <Hawk_H9_HS.mqh>
#include <HawkData.mqh>


	//H9_AddPriceData
void H9_AddPriceData( double OpenPrice, double HighPrice, double LowPrice, double ClosePrice, int Vol, int Date, int BarType, int BarInterval, int BarStatus, double MinMoveFrac, int BarNumber) 
	{ 
			h9i_public_vars(Date, BarType, BarInterval, BarStatus, MinMoveFrac, BarNumber);

			h9i_add_price(OpenPrice, HighPrice, LowPrice, ClosePrice, Vol);
	} 


//+------------------------------------------------------------------+

