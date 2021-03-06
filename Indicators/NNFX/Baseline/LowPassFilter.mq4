//+------------------------------------------------------------------+
//|                                             LowPassFilter_v1.mq4 |
//|                           Copyright © 2007, TrendLaboratory Ltd. |
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                   E-mail: igorad2003@yahoo.co.uk |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
//---- indicator settings
#property indicator_chart_window 
#property indicator_buffers 3 
#property indicator_color1 Yellow 
#property indicator_color2 LightBlue 
#property indicator_color3 Tomato 
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2 
//---- indicator parameters
extern int     Price          = 0;  //Price mode : 0-Close,1-Open,2-High,3-Low,4-Median,5-Typical,6-Weighted
extern int     Order          = 3;  //Filter Order: 1-EMA,2-2nd Order,3-3rd Order
extern int     FilterPeriod   =14;  //Filter Period 
extern int     PreSmooth      = 1;  //Pre-smoothing period
extern int     PreSmoothMode  = 0;  //Pre-smoothing MA Mode: 0-SMA,1-EMA,2-SMMA,3-LWMA
extern double  PctFilter      = 0;  //Dynamic filter in decimal(multiplier for StdDev)
//---- indicator buffers
double     Filter[];
double     UpTrend[];
double     DnTrend[];
double     Smoother[];
double     trend[];
double     Del[];
double     AvgDel[];

int        draw_begin;
bool       UpTrendAlert=false, DownTrendAlert=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- indicator buffers mapping
   IndicatorBuffers(7);
   SetIndexBuffer(0,Filter);
   SetIndexBuffer(1,UpTrend);
   SetIndexBuffer(2,DnTrend);
   SetIndexBuffer(3,Smoother);
   SetIndexBuffer(4,trend);  
   SetIndexBuffer(5,Del);
   SetIndexBuffer(6,AvgDel);
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   draw_begin = FilterPeriod + PreSmooth;
   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("LowPassFilter("+Order+","+FilterPeriod+")");
   SetIndexLabel(0,"LowPassFilter");
   SetIndexLabel(1,"UpTrend");
   SetIndexLabel(2,"DnTrend");
//---- initialization done
   return(0);
}
//+------------------------------------------------------------------+
//| LowPassFilter_v1                                                 |
//+------------------------------------------------------------------+
int start()
{
   int limit, i, shift;
   int counted_bars=IndicatorCounted();
   double a, b, c, pi = 3.1415926535;
   
   if(counted_bars<1)
   for(i=1;i<=draw_begin;i++) 
   {
   Filter[Bars-i]=0; 
   UpTrend[Bars-i]=0; 
   DnTrend[Bars-i]=0;
   }
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   for(shift=limit; shift>=0; shift--)
   Smoother[shift] = iMA(NULL,0,PreSmooth,0,PreSmoothMode,Price,shift);
   
   for(shift=limit; shift>=0; shift--)
   {
      if(Order == 1) Filter[shift] = iMAOnArray(Smoother,0,FilterPeriod,0,1,shift);
      else
		if(Order == 2) 
		{
		a = MathExp(-MathSqrt(2)*pi/FilterPeriod);
		b = 2*a*MathCos(MathSqrt(2)*pi/FilterPeriod);
    	Filter[shift] = b*Filter[shift+1] - a*a*Filter[shift+2] + (1 - b + a*a)*Smoother[shift];
		}
		else
		if(Order == 3) 
		{
		a = MathExp(-pi/FilterPeriod);
		b = 2*a*MathCos(MathSqrt(3)*pi/FilterPeriod);
    	c = MathExp(-2*pi/FilterPeriod); //a * a;
    	Filter[shift] = (b+c)*Filter[shift+1] - (c+b*c)*Filter[shift+2] + c*c*Filter[shift+3] + (1-b+c)*(1-c)*Smoother[shift];
		}
  
   int Length = FilterPeriod;
      
      if (PctFilter>0)
      {
      Del[shift] = MathAbs(Filter[shift] - Filter[shift+1]);
   
      double sumdel=0;
      for (int j=0;j<=Length-1;j++) sumdel = sumdel+Del[shift+j];
      AvgDel[shift] = sumdel/Length;
    
      double sumpow = 0;
      for (j=0;j<=Length-1;j++) sumpow+=MathPow(Del[j+shift]-AvgDel[j+shift],2);
      double StdDev = MathSqrt(sumpow/Length); 
     
      double filter = PctFilter * StdDev;
     
      if(MathAbs(Filter[shift]-Filter[shift+1]) < filter ) Filter[shift]=Filter[shift+1];
      }
      else
      filter=0;
   
      
   }         
//----------   
//---- done
   return(0);
}