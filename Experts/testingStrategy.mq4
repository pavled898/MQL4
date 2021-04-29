//+------------------------------------------------------------------+
//|                                           barLevelEventsTest.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <CustomFunctions.mqh>
#include <abstractedIndicators.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
datetime lastActionTime = 0;
double lotSize;
double riskPerTrade = 0.02;
bool chasingContinuation = false;
int openOrderID;
int magicNB = 55555;
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  
//---
     if(lastActionTime != Time[0])
     {
         double baseline = iMA(NULL, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
         double atr = iATR(NULL, PERIOD_CURRENT, 14, 1);
         
         bool exitBuy = !isLastHeikenAshiBull();
         bool exitSell = !exitBuy;
         bool c1Buy;
         bool c1Sell;
         bool c2Buy;
         bool c2Sell;
         bool volumeBuy;
         bool volumeSell;
         bool baselineTooFar = MathAbs(baseline - Close[1]) > atr;
         
         bool enterBuy = c1Buy && c2Buy && volumeBuy && !baselineTooFar;
         bool continueBuy;
         bool enterSell;
         bool continueSell;
         
         bool orderExists = CheckIfOpenOrdersByMagicNB(magicNB);
       
         if(orderExists) {                                                                         //POSITION OPENED
            if(OrderSelect(openOrderID,SELECT_BY_TICKET)==true) 
            {
               int orderType = OrderType();                                                        // 0 - LONG, 1 - SHORT
               
               if(orderType == 0)
              {
                  if(exitBuy || Close[1] < baseline)
                  {
                     OrderClose(openOrderID, lotSize, Bid, 10);
                     chasingContinuation = Close[1] > baseline;
                  };
              }
               else
              {
                  if(exitSell || Close[1] > baseline) 
                  {
                     OrderClose(openOrderID, lotSize, Ask, 10);
                     chasingContinuation = Close[1] < baseline;
                  };
              }
            };
         };
         if(!orderExists) {                                                                 //NO OPEN POSITION
            if( enterBuy ) {                                 //GO LONG
               lotSize = OptimalLotSize(riskPerTrade,Ask,Ask - atr*1.5);
               double stopLoss = NormalizeDouble(Ask - atr*1.5, Digits);
               Print("ATR ", +atr);
               Print("StopLoss " + stopLoss);
               Print("Ask " + Ask);
               Print("baseline: " + baseline);
               Print("STOPLEVEL ", +MarketInfo(Symbol(),MODE_STOPLEVEL));
               openOrderID = OrderSend(NULL,OP_BUY,lotSize,Ask,10,stopLoss, 0,NULL,magicNB);
            } 
            else if ( enterSell )                              //GO SHORT
            {
               lotSize = OptimalLotSize(riskPerTrade,Bid,Bid + atr*1.5);
               double stopLoss = NormalizeDouble(Bid + atr*1.5, Digits);
               Print("ATR ", +atr);
               Print("StopLoss " + stopLoss);
               Print("Bid " + Bid);
               Print("baseline: " + baseline);
               Print("STOPLEVEL ", +MarketInfo(Symbol(),MODE_STOPLEVEL));
               openOrderID = OrderSend(NULL,OP_SELL,lotSize,Bid,10,stopLoss, 0,NULL,magicNB);
            } 
         } 
         lastActionTime = Time[0];
     }
  }
//+------------------------------------------------------------------+