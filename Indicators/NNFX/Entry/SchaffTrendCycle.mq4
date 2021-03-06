//+------------------------------------------------------------------+
//                                              SchaffTrendCycle.mq4 |
//|                                  Copyright © 2011, EarnForex.com |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, EarnForex.com"
#property link      "http://www.earnforex.com"

/*
   Schaff Trend Cycle - Cyclical Stoch over Stoch over MACD.
   Falling below 75 is a sell signal.
   Rising above 25 is a buy signal.
   Developed by Doug Schaff.
   Code adapted from the original TradeStation EasyLanguage version.
*/   

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 25
#property indicator_level2 75
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID
#property indicator_color1 DarkOrchid

//---- Input Parameters
extern int MAShort = 23;
extern int MALong = 50;
extern int Cycle = 10;

//---- Global Variables
double Factor = 0.5;
int BarsRequired;

//---- Buffers
double MACD[];
double ST[];
double ST2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorShortName("STC(" + MAShort + ", " + MALong + ", " + Cycle + ")");

   IndicatorBuffers(3);
   SetIndexBuffer(0, ST2);
   SetIndexBuffer(1, ST);
   SetIndexBuffer(2, MACD);

   SetIndexDrawBegin(0, MALong + Cycle * 2);

   BarsRequired = MALong + Cycle * 2;

   return(0);
}

//+------------------------------------------------------------------+
//| Schaff Trend Cycle                                               |
//+------------------------------------------------------------------+
int start()
{
   
   if (Bars <= BarsRequired) return(0);
   
   int counted_bars = IndicatorCounted();
   
   double LLV, HHV;
   int shift, n = 1, i;
   // Static variables are used to flag that we already have calculated curves from the previous indicator run
   static bool st1_pass = false;
   static bool st2_pass = false;
   int st1_count = 0;
   bool check_st1 = false, check_st2 = false;
   
   if (counted_bars < BarsRequired)
   {
      for (i = 1; i <= BarsRequired; i++) ST2[Bars - i] = 0;
      for (i = 1; i <= BarsRequired; i++) ST[Bars - i] = 0;
   }

   if (counted_bars > 0) counted_bars--;

   shift = Bars - counted_bars + BarsRequired - MALong;
   
   if (shift > Bars - 1) shift = Bars - 1;
   
   while (shift >= 0)
   {
      double MA_Short = iMA(NULL, 0, MAShort, 0, MODE_EMA, PRICE_CLOSE, shift);
	   double MA_Long = iMA(NULL, 0, MALong, 0, MODE_EMA, PRICE_CLOSE, shift);
	   MACD[shift] = MA_Short - MA_Long;
	   
      if (n >= Cycle) check_st1 = true;
      else n++;
	
      if (check_st1)  
      {
         // Finding Max and Min on Cycle of MA differrences (MACD)
         for (i = 0; i < Cycle; i++)
         {	
            if (i == 0)
            {
               LLV = MACD[shift + i];
               HHV = MACD[shift + i];
            }
            else
            {
               if (LLV > MACD[shift + i]) LLV = MACD[shift + i];
               if (HHV < MACD[shift + i]) HHV = MACD[shift + i];
            }
         }
         // Calculating first Stochastic
         if (HHV - LLV != 0) ST[shift] = ((MACD[shift] - LLV) / (HHV - LLV)) * 100;
         else {ST[shift] = ST[shift + 1];}
         
         // Smoothing first Stochastic
         if (st1_pass) ST[shift] = Factor * (ST[shift] - ST[shift + 1]) + ST[shift + 1];
         st1_pass = true;
                  
         // Have enough elements of first Stochastic to proceed to second
         if (st1_count >= Cycle) check_st2 = true;
         else st1_count++;
         
         if (check_st2)
         {
            // Finding Max and Min on Cycle of first smoothed Stoch
            for (i = 0; i < Cycle; i++)
            {	
               if (i == 0)
               {
                  LLV = ST[shift + i];
                  HHV = ST[shift + i];
               }
               else
               {
                  if (LLV > ST[shift + i]) LLV = ST[shift + i];
                  if (HHV < ST[shift + i]) HHV = ST[shift + i];
               }
            }
            // Calculating second Stochastic
            if (HHV - LLV != 0) ST2[shift] = ((ST[shift] - LLV) / (HHV - LLV)) * 100;
            else {ST2[shift] = ST2[shift + 1];}
            
            // Smoothing second Stochastic
            if (st2_pass) ST2[shift] = Factor * (ST2[shift] - ST2[shift + 1]) + ST2[shift + 1];
            st2_pass = true;
         }
      }
      shift--;
   }

   return(0);
}
//+----------------------------------------------------