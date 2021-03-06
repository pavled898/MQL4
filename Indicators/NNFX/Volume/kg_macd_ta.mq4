//+------------------------------------------------------------------+
//|                                                    KG_MACD_TA.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 Green
#property indicator_color3 Red

double g_ibuf_76[];
double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];
double g_ibuf_92[];
double g_period_96 = 4.0;
double g_period_104 = 32.0;
int g_ma_method_112 = MODE_LWMA;
int g_applied_price_116 = PRICE_TYPICAL;
int g_period_120 = 1;
string gs_124;
string gs_132;

int init() {
   IndicatorBuffers(5);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   IndicatorDigits(Digits + 2);
   SetIndexDrawBegin(0, 38);
   SetIndexDrawBegin(1, 38);
   SetIndexDrawBegin(2, 38);
   SetIndexBuffer(0, g_ibuf_76);
   SetIndexBuffer(1, g_ibuf_80);
   SetIndexBuffer(2, g_ibuf_84);
   SetIndexBuffer(3, g_ibuf_88);
   SetIndexBuffer(4, g_ibuf_92);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   return (0);
}

int start() {
   double ld_8;
   double ld_16;
   int li_4 = IndicatorCounted();
   if (li_4 > 0) li_4--;
   int li_0 = Bars - li_4;
   for (int li_56 = 0; li_56 < li_0; li_56++) g_ibuf_88[li_56] = iMA(NULL, 0, g_period_96, 0, g_ma_method_112, g_applied_price_116, li_56) - iMA(NULL, 0, g_period_104, 0, g_ma_method_112, g_applied_price_116, li_56);
   for (li_56 = 0; li_56 < li_0; li_56++) g_ibuf_92[li_56] = iMAOnArray(g_ibuf_88, Bars, g_period_120, 0, MODE_LWMA, li_56);
   bool li_60 = TRUE;
   for (li_56 = li_0 - 1; li_56 >= 0; li_56--) {
      ld_16 = g_ibuf_92[li_56];
      ld_8 = g_ibuf_92[li_56 + 1];
      if (ld_16 > ld_8) li_60 = TRUE;
      if (ld_16 < ld_8) li_60 = FALSE;
      if (!li_60) {
         g_ibuf_84[li_56] = ld_16;
         g_ibuf_80[li_56] = 0.0;
      } else {
         g_ibuf_80[li_56] = ld_16;
         g_ibuf_84[li_56] = 0.0;
      }
      g_ibuf_76[li_56] = ld_16;
      if (ld_16 > ld_8) gs_124 = "LONG";
      if (ld_16 < ld_8) gs_124 = "SHORT";
      if (ld_16 == ld_8) gs_124 = "FLAT";
      if (ld_16 > 0.0) gs_132 = "UP TREND";
      if (ld_16 < 0.0) gs_132 = "DOWN TREND";
      if (ld_16 == 0.0) gs_132 = "NEUTRAL";
      IndicatorShortName("KG MACD      [ Status: " + gs_124 + " ]    " + gs_132 + "   ");
   }
   return (0);
}