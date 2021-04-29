//+------------------------------------------------------------------+
//|                                         abstractedIndicators.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
//+------------------------------------------------------------------+


bool isLastHeikenAshiBull()
   {
      double HAOpen  = iCustom(NULL,0,"Heiken Ashi", Red,White,Red,White, 2, 1);
      double HAClose = iCustom(NULL,0,"Heiken Ashi", Red,White,Red,White, 3, 1);
      return HAClose > HAOpen;
   }


