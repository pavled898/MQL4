//+------------------------------------------------------------------+

//|                                                 BB 2Bands MR.mq4 |

//|                                                    Mohsen Hassan |

//|                             https://www.MontrealTradingGroup.com |

//+------------------------------------------------------------------+

#property copyright "Mohsen Hassan"

#property link      "https://www.MontrealTradingGroup.com"

#property version   "1.00"

#property strict

#property show_inputs

#include  <CustomFunctions.mqh>



int magicNB = 55555;

input int bbPeriod = 70;



input int bandStdEntry = 1;

input int bandStdProfitExit = 0.4;

input int bandStdLossExit = 2;

int rsiPeriod = 30;

input double riskPerTrade = 0.02;

input int rsiLowerLevel = 30;

input int rsiUpperLevel = 70;



int openOrderID;

//+------------------------------------------------------------------+

//| Expert initialization function                                   |

//+------------------------------------------------------------------+

int OnInit()

  {

   Alert("");

   Alert("Starting Strategy BB 2Bans MR");



   return(INIT_SUCCEEDED);

  }

//+------------------------------------------------------------------+

//| Expert deinitialization function                                 |

//+------------------------------------------------------------------+

void OnDeinit(const int reason)

  {

   Alert("Stopping Strategy BB 2Bans MR");

  }

//+------------------------------------------------------------------+

//| Expert tick function                                             |

//+------------------------------------------------------------------+

void OnTick()

  {

  

   double bbLowerEntry = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_LOWER,0);

   double bbUpperEntry = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,MODE_UPPER,0);

   double bbMid = iBands(NULL,0,bbPeriod,bandStdEntry,0,PRICE_CLOSE,0,0);

   

   double bbLowerProfitExit = iBands(NULL,0,bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_LOWER,0);

   double bbUpperProfitExit = iBands(NULL,0,bbPeriod,bandStdProfitExit,0,PRICE_CLOSE,MODE_UPPER,0);

   

   double bbLowerLossExit = iBands(NULL,0,bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_LOWER,0);

   double bbUpperLossExit = iBands(NULL,0,bbPeriod,bandStdLossExit,0,PRICE_CLOSE,MODE_UPPER,0);

   

   double rsiValue = iRSI(NULL,0,rsiPeriod,PRICE_CLOSE,0);
    double minStop = MarketInfo(Symbol(), MODE_STOPLEVEL);

   

   if(!CheckIfOpenOrdersByMagicNB(magicNB))//if no open orders try to enter new position

   {

      if(Ask < bbLowerEntry && Open[0] > bbLowerEntry && rsiValue < rsiLowerLevel)//buying

      {

         Print("Price is bellow bbLower and rsiValue is lower than " + rsiLowerLevel+ " , Sending buy order");

         double stopLossPrice = NormalizeDouble(bbLowerLossExit,Digits);

         double takeProfitPrice = NormalizeDouble(bbUpperProfitExit,Digits);;

         Print("Entry Price = " + Ask);
         Print("Bid Price = " + Bid);


         Print("Stop Loss Price = " + stopLossPrice);

         Print("Take Profit Price = " + takeProfitPrice);

         

         double lotSize = OptimalLotSize(riskPerTrade,Ask,stopLossPrice);
         
         Print("LotSize " + lotSize);

         

         openOrderID = OrderSend(NULL,OP_BUY,lotSize,Ask,3,stopLossPrice,takeProfitPrice,NULL,magicNB);

         if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());

      }

      else if(Bid > bbUpperEntry && Open[0] < bbUpperEntry && rsiValue > rsiUpperLevel)//shorting

      {

         Print("Price is above bbUpper and rsiValue is above " + rsiUpperLevel + " Sending short order");

         double stopLossPrice = NormalizeDouble(bbUpperLossExit,Digits);

         double takeProfitPrice = NormalizeDouble(bbLowerProfitExit,Digits);

         Print("Entry Price = " + Bid);
         Print("Bid Price = " + Bid);

         Print("Stop Loss Price = " + stopLossPrice);

         Print("Take Profit Price = " + takeProfitPrice);

   	  

   	  double lotSize = OptimalLotSize(riskPerTrade,Bid,stopLossPrice);
   	  
   	  Print("LotSize " + lotSize);



   	  openOrderID = OrderSend(NULL,OP_SELL,lotSize,Bid,3,stopLossPrice,takeProfitPrice,NULL,magicNB);

   	  if(openOrderID < 0) Alert("order rejected. Order error: " + GetLastError());

      }

   }

   else //else if you already have a position, update orders if need too.

   {

      if(OrderSelect(openOrderID,SELECT_BY_TICKET)==true)

      {

            int orderType = OrderType();// Short = 1, Long = 0



            double optimalTakeProfit;

            

            if(orderType == 0)//long position

            {

               optimalTakeProfit = NormalizeDouble(bbUpperProfitExit,Digits);

               

            }

            else //if short

            {

               optimalTakeProfit = NormalizeDouble(bbLowerProfitExit,Digits);

            }



            double TP = OrderTakeProfit();

            double TPdistance = MathAbs(TP - optimalTakeProfit);

            if(TP != optimalTakeProfit && TPdistance > 0.0001)

            {

               bool Ans = OrderModify(openOrderID,OrderOpenPrice(),OrderStopLoss(),optimalTakeProfit,0);

            

               if (Ans==true)                     

               {

                  Print("Order modified: ",openOrderID);

                  return;                           

               }else

               {

                  Print("Unable to modify order: ",openOrderID);

               }   

            }

         }

      }

   }

   

   



//+------------------------------------------------------------------+