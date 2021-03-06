//+------------------------------------------------------------------+
//|                                                    VKW Bands.mq4 |
//|                      Copyright © 2008, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+

#property copyright "Alksnis Gatis"
#property link      "2xpoint@gmail.com"
//----
#property indicator_separate_window
#property indicator_buffers  6
#property indicator_color1   clrDodgerBlue
#property indicator_color2   clrSaddleBrown
#property indicator_color3   clrSlateGray
#property indicator_color4   clrDodgerBlue
#property indicator_color5   clrSandyBrown
#property indicator_color6   clrSandyBrown
#property  indicator_style1  STYLE_DOT
#property  indicator_style2  STYLE_DOT
#property  indicator_style3  STYLE_DOT
#property  indicator_width4  2
#property  indicator_width5  2
#property  indicator_width6  2

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};
enum enRsiTypes
{
   rsi_rsi,  // Regular RSI
   rsi_wil,  // Slow RSI
   rsi_rap,  // Rapid RSI
   rsi_har,  // Harris RSI
   rsi_rsx,  // RSX
   rsi_cut   // Cuttlers RSI
};
enum colorOn
{
   clrOnSlope, // Color change on slope change
   clrOnMid,   // Color change on mid level cross
   clrOnlevel  // Color change on levels cross
};

extern ENUM_TIMEFRAMES TimeFrame         = PERIOD_CURRENT;    // Time frame to use
extern int             RangePeriod       = 25;
extern int             BandsSmoothPeriod = 3;
extern ENUM_MA_METHOD  BandsSmoothMode   = MODE_SMA;
extern enRsiTypes      RsiType           = rsi_rsx;          // Rsi calculation method
extern int             RsiPeriod         = 25;               // Rsi Period
extern enPrices        Price             = pr_hatbiased;     // Rsi Price
extern int             StepSize          = 5;
extern bool            ShowArrow0        = TRUE;
extern bool            ShowArrow1        = TRUE;
extern bool            ShowTLine         = TRUE;
extern color           ArrowUpColor      = clrDodgerBlue;
extern color           ArrowDownColor    = clrSandyBrown;
extern colorOn         ColorChangeOn     = clrOnSlope;        // Color change on : 
extern bool            alertsOn          = false;             // Turn alerts on
extern bool            alertsOnCurrent   = false;             // Alerts on current (still opened) bar?
extern bool            alertsMessage     = true;              // Alerts should display a pop-up message
extern bool            alertsSound       = true;              // Alerts should play an alert sound?
extern bool            alertsEmail       = false;             // Alerts should send an email?
extern bool            alertsNotify      = false;             // Alerts should send notification?
extern bool            Interpolate       = true;             // Interpolate in mtf mode
//---- buffers 
double ExtMapBuffer0[],ExtMapBufferda[],ExtMapBufferdb[],slope[];
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double Buffer3[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double miLevel[];
double rsi[];
double smax[];
double smin[];
double trend[];
double count[];

bool fb=false, fs=false;
double a[],t[],fa,fd;
int b;
datetime drop=0;

string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,RangePeriod,BandsSmoothPeriod,BandsSmoothMode,RsiType,RsiPeriod,Price,StepSize,ShowArrow0,ShowArrow1,ShowTLine,ArrowUpColor,ArrowDownColor,ColorChangeOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify,_buff,_ind)

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init(){
//---- indicators 
   IndicatorBuffers(15);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexDrawBegin(0,BandsSmoothPeriod);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexDrawBegin(1,BandsSmoothPeriod);
   SetIndexBuffer(2,Buffer3);
   SetIndexBuffer(3,ExtMapBuffer0);
   SetIndexBuffer(4,ExtMapBufferda);
   SetIndexBuffer(5,ExtMapBufferdb);
   SetIndexBuffer(6,ExtMapBuffer3);
   SetIndexBuffer(7,ExtMapBuffer4);
   SetIndexBuffer(8,miLevel);
   SetIndexBuffer(9, rsi); 
   SetIndexBuffer(10,smin);
   SetIndexBuffer(11,smax);
   SetIndexBuffer(12,trend);
   SetIndexBuffer(13,slope);
   SetIndexBuffer(14,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
//---- 
   IndicatorShortName(timeFrameToString(TimeFrame)+" vkw bands of "+getRsiName((int)RsiType)+" ("+(string)RangePeriod+","+(string)BandsSmoothPeriod+","+(string)RsiPeriod+","+(string)StepSize+")");
   return(0);
}
//+------------------------------------------------------------------+ 
//| Custom indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit(){
//---- 
   ObjectsDeleteAll();
//---- 
   return(0);
}
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(14,0)*TimeFrame/_Period));
               if (slope[limit]==-1) CleanPoint(limit,ExtMapBufferda,ExtMapBufferdb);
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     ExtMapBuffer1[i]  = _mtfCall(0,y);
                     ExtMapBuffer2[i]  = _mtfCall(1,y);
                     Buffer3[i]        = _mtfCall(2,y);
                     ExtMapBuffer0[i]  = _mtfCall(3,y);
                     ExtMapBufferda[i] = EMPTY_VALUE;
                     ExtMapBufferdb[i] = EMPTY_VALUE;
                     slope[i] = _mtfCall(13,y);
                    
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                         {
                           _interpolate(ExtMapBuffer1);  
                           _interpolate(ExtMapBuffer2); 
                           _interpolate(Buffer3);  
                           _interpolate(ExtMapBuffer0);    
                        }                                    
            }
            for(i=limit; i>=0; i--) if (slope[i]==-1) PlotPoint(i,ExtMapBufferda,ExtMapBufferdb,ExtMapBuffer0);
      return(0);
      }
   

//----
   if(drop==0)drop=TimeCurrent()+60;
   if(drop<=TimeCurrent()){
      bool qwe=false;
      for(i=0;i<=30;i++){
         if(ObjectFind("ui"+i)  >0)  {ObjectDelete("ui"+i);  } 
         if(ObjectFind("uw"+i)  >0)  {ObjectDelete("uw"+i);  } 
         if(ObjectFind("txtu"+i)>0)  {ObjectDelete("txtu"+i);} 
         if(ObjectFind("tu"+i)  >0)  {ObjectDelete("tu"+i);  } 
         if(ObjectFind("di"+i)  >0)  {ObjectDelete("di"+i);  } 
         if(ObjectFind("dw"+i)  >0)  {ObjectDelete("dw"+i);  } 
         if(ObjectFind("txtd"+i)>0)  {ObjectDelete("txtd"+i);} 
         if(ObjectFind("td"+i)  >0)  {ObjectDelete("td"+i);  }
      }
      drop=TimeCurrent()+60;
   }
   int limit1,cnt,n_max,n_min;
   if (counted_bars==0){
      limit=Bars-RangePeriod;
      limit1=limit-BandsSmoothPeriod;
   }
   if (counted_bars>0){
      limit=Bars-counted_bars;
      limit1=limit;
   }
   limit--;
   limit1--;
   if (slope[limit]==-1) CleanPoint(limit,ExtMapBufferda,ExtMapBufferdb);
   for(cnt=limit; cnt>=0;cnt--){
      double price = getPrice(Price,Open,Close,High,Low,cnt);
      rsi[cnt]  = iRsi(RsiType,price,RsiPeriod,cnt);
   	smax[cnt] = rsi[cnt]+2*StepSize;
	   smin[cnt] = rsi[cnt]-2*StepSize;
      if (cnt>(Bars-2)) continue;

	   trend[cnt] = trend[cnt+1];
	   if (rsi[cnt]>smax[cnt+1]) trend[cnt] = 1; 
	   if (rsi[cnt]<smin[cnt+1]) trend[cnt] =-1;
	   if (trend[cnt]>0 && smin[cnt]<smin[cnt+1]) smin[cnt] = smin[cnt+1];
	   if (trend[cnt]<0 && smax[cnt]>smax[cnt+1]) smax[cnt] = smax[cnt+1];
	   if (trend[cnt]>0) ExtMapBuffer0[cnt] = smin[cnt]+StepSize;
	   if (trend[cnt]<0) ExtMapBuffer0[cnt] = smax[cnt]-StepSize;
   }
   for(cnt=limit; cnt>=0;cnt--){
      n_max=ArrayMaximum(ExtMapBuffer0,RangePeriod,cnt);
      n_min=ArrayMinimum(ExtMapBuffer0,RangePeriod,cnt);
      ExtMapBuffer3[cnt]=ExtMapBuffer0[n_max];
      ExtMapBuffer4[cnt]=ExtMapBuffer0[n_min];
      miLevel[cnt] = (ExtMapBuffer3[cnt]+ExtMapBuffer4[cnt])*0.5;
   }
   for(cnt=limit1; cnt>=0;cnt--){
      ExtMapBuffer1[cnt]  = iMAOnArray(ExtMapBuffer3,0,BandsSmoothPeriod,0,BandsSmoothMode,cnt);
      ExtMapBuffer2[cnt]  = iMAOnArray(ExtMapBuffer4,0,BandsSmoothPeriod,0,BandsSmoothMode,cnt);
      Buffer3[cnt]        = iMAOnArray(miLevel,0,BandsSmoothPeriod,0,BandsSmoothMode,cnt);
      ExtMapBufferda[cnt] = EMPTY_VALUE;
      ExtMapBufferdb[cnt] = EMPTY_VALUE;
      if (i<Bars-1)
      {   
        slope[cnt] = slope[cnt+1];
        switch (ColorChangeOn)
        {
           case clrOnSlope: 
              if (ExtMapBuffer0[cnt]>ExtMapBuffer0[cnt+1]) slope[cnt] =  1;
              if (ExtMapBuffer0[cnt]<ExtMapBuffer0[cnt+1]) slope[cnt] = -1;
           break;
           case clrOnMid: 
              if (ExtMapBuffer0[cnt]>Buffer3[cnt])         slope[cnt] =  1;
              if (ExtMapBuffer0[cnt]<Buffer3[cnt])         slope[cnt] = -1;
           break;
           default : 
              if (ExtMapBuffer0[cnt]>ExtMapBuffer1[cnt])    slope[cnt] =  1;
              if (ExtMapBuffer0[cnt]<ExtMapBuffer2[cnt])    slope[cnt] = -1;
           break;
        }    
        if (slope[cnt]==-1) PlotPoint(cnt,ExtMapBufferda,ExtMapBufferdb,ExtMapBuffer0);
      }
   }
   i=Bars-RangePeriod;
   while(i>=0){
      if(ExtMapBuffer0[i]>=ExtMapBuffer1[i])fs=true;
      if(fs==true&&ExtMapBuffer0[i]+0.1<ExtMapBuffer1[i]){
         if(ShowArrow1)
           SetArrow(242,ArrowDownColor,"ui"+i,1,Time[i],ExtMapBuffer1[i]+5,2);
         if(ShowArrow0)
           SetArrow(242,ArrowDownColor,"uw"+i,0,Time[i],High[i]+15*Point ,2);
         fa=FindNearFractal(Symbol(),0,MODE_UPPER,i);
         //SetText(Symbol(), "txtu"+b, "BUYSTOP "+DoubleToStr(High[b],Digits), Yellow, Time[b]+3*3600, High[b], 8, 0, 1);
         if(ShowTLine)
           SetTLine(ArrowDownColor, "tu"+b, Time[b]-5*3600, High[b], Time[b]+15*3600, High[b], false, 0, 2, 0);
         fs=false;
      }
      if(ExtMapBuffer0[i]<=ExtMapBuffer2[i])fb=true;
      if(fb==true&&ExtMapBuffer0[i]-0.1>ExtMapBuffer2[i]){
         if(ShowArrow1)
           SetArrow(241,ArrowUpColor,"di"+i,1,Time[i],ExtMapBuffer0[i],2);
         if(ShowArrow0)
           SetArrow(241,ArrowUpColor,"dw"+i,0,Time[i],Low[i]-2*Point  ,2);
         fd=FindNearFractal(Symbol(),0,MODE_LOWER,i);
         //SetText(Symbol(), "txtd"+b, "SELLSTOP "+DoubleToStr(Low[b],Digits), Yellow, Time[b]+3*3600, Low[b], 8, 0, -1);
         if(ShowTLine)
           SetTLine(ArrowUpColor, "td"+b, Time[b]-5*3600, Low[b], Time[b]+15*3600, Low[b], false, 0, 2, 0);
         fb=false;
      }
      
      i--;
      WindowRedraw();
      
   }
   manageAlerts();
   return(0);
}

//+----------------------------------------------------------------------------+
//|  Àâòîð    : Êèì Èãîðü Â. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Âåðñèÿ   : 12.10.2007                                                     |
//|  Îïèñàíèå : Óñòàíîâêà çíà÷êà íà ãðàôèêå, îáúåêòà OBJ_ARROW.                |
//+----------------------------------------------------------------------------+
//|  Ïàðàìåòðû:                                                                |
//|    cd - êîä çíà÷êà                                                         |
//|    cl - öâåò çíà÷êà                                                        |
//|    nm - íàèìåíîâàíèå               ("" - âðåìÿ îòêðûòèÿ òåêóùåãî áàðà)     |
//|    t1 - âðåìÿ îòêðûòèÿ áàðà        (0  - òåêóùèé áàð)                      |
//|    p1 - öåíîâîé óðîâåíü            (0  - Bid)                              |
//|    sz - ðàçìåð çíà÷êà              (0  - ïî óìîë÷àíèþ)                     |
//|    w  - îêíî îòðèñîâêè             (0  - îñíîâíîå îêíî)                    |
//+----------------------------------------------------------------------------+
void SetArrow(int cd, color cl, string nm="", int w=0, datetime t1=0, double p1=0, int sz=0) {
  if (nm=="") nm=DoubleToStr(Time[0], 0);
  if (t1<=0) t1=Time[0];
  if (p1<=0) p1=Bid;
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_ARROW, w, 0,0);
  ObjectSet(nm, OBJPROP_TIME1    , t1);
  ObjectSet(nm, OBJPROP_PRICE1   , p1);
  ObjectSet(nm, OBJPROP_ARROWCODE, cd);
  ObjectSet(nm, OBJPROP_COLOR    , cl);
  ObjectSet(nm, OBJPROP_WIDTH    , sz);
}/*
void SetText(string sy, string nm, string tx, color cl, datetime t1=0, double p1=0, int fs=9, int w=0, int pos=1){
   
   int d=MarketInfo(sy, MODE_DIGITS);
   
   if (nm=="") nm=DoubleToStr(Time[0], 0);
   if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_TEXT, w, 0,0);
   if (d==0) if (StringFind(sy, "JPY")<0) d=4; else d=2;
   if (pos!=1) pos=-1;
   
   p1=NormalizeDouble(p1, d);
   
   ObjectSetText(nm, tx, fs);
   ObjectSet(nm, OBJPROP_COLOR,    cl);
   ObjectSet(nm, OBJPROP_TIME1 ,   t1);
   if(pos==1  && sy=="EURUSD")ObjectSet(nm,OBJPROP_PRICE1,p1+0.0015);
   if(pos==-1 && sy=="EURUSD")ObjectSet(nm,OBJPROP_PRICE1,p1-0.0002);
   if(pos==1  && sy=="GBPUSD")ObjectSet(nm,OBJPROP_PRICE1,p1+0.0035);
   if(pos==-1 && sy=="GBPUSD")ObjectSet(nm,OBJPROP_PRICE1,p1-0.0002);
   if(pos==1  && sy=="USDCHF")ObjectSet(nm,OBJPROP_PRICE1,p1+0.0015);
   if(pos==-1 && sy=="USDCHF")ObjectSet(nm,OBJPROP_PRICE1,p1-0.0002);
   if(pos==1  && sy=="USDJPY")ObjectSet(nm,OBJPROP_PRICE1,p1+0.15);
   if(pos==-1 && sy=="USDJPY")ObjectSet(nm,OBJPROP_PRICE1,p1-0.02);
   if(pos==1  && sy=="EURJPY")ObjectSet(nm,OBJPROP_PRICE1,p1+0.30);
   if(pos==-1 && sy=="EURJPY")ObjectSet(nm,OBJPROP_PRICE1,p1-0.02);
   if(pos==1  && sy=="GBPJPY")ObjectSet(nm,OBJPROP_PRICE1,p1+0.45);
   if(pos==-1 && sy=="GBPJPY")ObjectSet(nm,OBJPROP_PRICE1,p1-0.02);
   ObjectSet(nm, OBJPROP_FONTSIZE, fs);
   ObjectSet(nm, OBJPROP_BACK, false);
}
*/
//+----------------------------------------------------------------------------+
//|  Àâòîð    : Êèì Èãîðü Â. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Âåðñèÿ   : 12.10.2007                                                     |
//|  Îïèñàíèå : Óñòàíîâêà òåêñòîâîé ìåòêè, îáúåêò OBJ_LABEL.                   |
//+----------------------------------------------------------------------------+
//|  Ïàðàìåòðû:                                                                |
//|    nm - íàèìåíîâàíèå îáúåêòà                                               |
//|    tx - òåêñò                                                              |
//|    cl - öâåò ìåòêè                                                         |
//|    xd - êîîðäèíàòà X â ïèêñåëàõ                                            |
//|    yd - êîîðäèíàòà Y â ïèêñåëàõ                                            |
//|    cr - íîìåð óãëà ïðèâÿçêè        (0 - ëåâûé âåðõíèé,                     |
//|                                     1 - ïðàâûé âåðõíèé,                    |
//|                                     2 - ëåâûé íèæíèé,                      |
//|                                     3 - ïðàâûé íèæíèé )                    |
//|    fs - ðàçìåð øðèôòà              (9 - ïî óìîë÷àíèþ  )                    |
//|    w  - îêíî îòðèñîâêè             (0 - îñíîâíîå îêíî)                     |
//+----------------------------------------------------------------------------+
/*void SetLabel(string nm, string tx, color cl, int xd, int yd, int cr=0, int fs=9, int w=0){
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_LABEL, w, 0,0);
  ObjectSetText(nm, tx, fs);
  ObjectSet(nm, OBJPROP_COLOR    , cl);
  ObjectSet(nm, OBJPROP_XDISTANCE, xd);
  ObjectSet(nm, OBJPROP_YDISTANCE, yd);
  ObjectSet(nm, OBJPROP_CORNER   , cr);
  ObjectSet(nm, OBJPROP_FONTSIZE , fs);
}*/
//+----------------------------------------------------------------------------+
//|  Àâòîð    : Êèì Èãîðü Â. aka KimIV,  http://www.kimiv.ru                   |
//+----------------------------------------------------------------------------+
//|  Âåðñèÿ   : 12.10.2007                                                     |
//|  Îïèñàíèå : Óñòàíîâêà îáúåêòà OBJ_TREND òðåíäîâàÿ ëèíèÿ                    |
//+----------------------------------------------------------------------------+
//|  Ïàðàìåòðû:                                                                |
//|    cl - öâåò ëèíèè                                                         |
//|    nm - íàèìåíîâàíèå               (  ""  - âðåìÿ îòêðûòèÿ òåêóùåãî áàðà)  |
//|    t1 - âðåìÿ îòêðûòèÿ áàðà        (  0   - Time[10]                       |
//|    p1 - öåíîâîé óðîâåíü            (  0   - Low[10])                       |
//|    t2 - âðåìÿ îòêðûòèÿ áàðà        (  0   - òåêóùèé áàð)                   |
//|    p2 - öåíîâîé óðîâåíü            (  0   - Bid)                           |
//|    ry - ëó÷                        (False - ïî óìîë÷àíèþ)                  |
//|    st - ñòèëü ëèíèè                (  0   - ïðîñòàÿ ëèíèÿ)                 |
//|    wd - øèðèíà ëèíèè               (  1   - ïî óìîë÷àíèþ)                  |
//|    w  - îêíî îòðèñîâêè             (  0   - îñíîâíîå îêíî)                 |
//+----------------------------------------------------------------------------+
void SetTLine(color cl, string nm="", datetime t1=0, double p1=0, 
              datetime t2=0, double p2=0, bool ry=False, int st=0, int wd=1, int w=0) {
  if (nm=="") nm=DoubleToStr(Time[0], 0);
  if (t1<=0) t1=Time[10];
  if (p1<=0) p1=Low[10];
  if (t2<=0) t2=Time[0];
  if (p2<=0) p2=Bid;
  if (ObjectFind(nm)<0) ObjectCreate(nm, OBJ_TREND, w, 0,0, 0,0);
  ObjectSet(nm, OBJPROP_TIME1 , t1);
  ObjectSet(nm, OBJPROP_PRICE1, p1);
  ObjectSet(nm, OBJPROP_TIME2 , t2);
  ObjectSet(nm, OBJPROP_PRICE2, p2);
  ObjectSet(nm, OBJPROP_COLOR , cl);
  ObjectSet(nm, OBJPROP_RAY   , ry);
  ObjectSet(nm, OBJPROP_STYLE , st);
  ObjectSet(nm, OBJPROP_WIDTH , wd);
}
//+----------------------------------------------------------------------------+
//| Àâòîð    : Êèì Èãîðü Â. aka KimIV,  http://www.kimiv.ru                    |
//+----------------------------------------------------------------------------+
//| Âåðñèÿ   : 07.10.2006                                                      |
//| Îïèñàíèå : Ïîèñê áëèæàéøåãî ôðàêòàëà.                                      |
//+----------------------------------------------------------------------------+
//| Ïàðàìåòðû:                                                                 |
//|   sy    - íàèìåíîâàíèå èíñòðóìåíòà                (NULL - òåêóùèé ñèìâîë)  |
//|   tf    - òàéìôðåéì                               (0    - òåêóùèé ÒÔ)      |
//|   mode  - òèï ôðàêòàëà                            (MODE_LOWER|MODE_UPPER)  |
//|   start - áàð ñ êîòîðîãî íåáõîäèìî íà÷èíàòü ïîèñê (2    - ïî óìîë÷àíèþ)    |
//+----------------------------------------------------------------------------+
double FindNearFractal(string sy="0", int tf=0, int mode=MODE_LOWER, int start = 2) {
  if (sy=="" || sy=="0") sy=Symbol();
  double f=0;
  int d=MarketInfo(sy, MODE_DIGITS), s;
  if (d==0) if (StringFind(sy, "JPY")<0) d=4; else d=2;
 
  for (s=start; s<start+50; s++) {
    f=iFractals(sy, tf, mode, s);
    if (f!=0){b=s; return(NormalizeDouble(f, d));}
  }
  Print("FindNearFractal(): Ôðàêòàë íå íàéäåí");
  return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//
//

string rsiMethodNames[] = {"RSI","Slow RSI","Rapid RSI","Harris RSI","RSX","Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames)-1;
      method=MathMax(MathMin(method,max),0); return(rsiMethodNames[method]);
}

//
//
//
//
//

#define rsiInstances 1
double workRsi[][rsiInstances*13];
#define _price  0
#define _change 1
#define _changa 2
#define _rsival 1
#define _rsval  1

double iRsi(int rsiMode, double price, double period, int i, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=Bars) ArrayResize(workRsi,Bars);
      int z = instanceNo*13; 
      int r = Bars-i-1;
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
   switch (rsiMode)
   {
      case rsi_rsi:
         {
         double alpha = 1.0/MathMax(period,1); 
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
         }
         
      //
      //
      //
      //
      //
      
      case rsi_wil :
         {         
            double up = 0;
            double dn = 0;
            for(k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               double diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if (r<1)
                  workRsi[r][z+_rsival] = 50;
            else               
               if(up + dn == 0)
                     workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(50            -workRsi[r-1][z+_rsival]);
               else  workRsi[r][z+_rsival] = workRsi[r-1][z+_rsival]+(1/MathMax(period,1))*(100*up/(up+dn)-workRsi[r-1][z+_rsival]);
            return(workRsi[r][z+_rsival]);      
         }
      
      //
      //
      //
      //
      //

      case rsi_rap :
         {
            up = 0;
            dn = 0;
            for(k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               diff = workRsi[r-k][z+_price]- workRsi[r-k-1][z+_price];
               if(diff>0)
                     up += diff;
               else  dn -= diff;
            }
            if(up + dn == 0)
                  return(50);
            else  return(100 * up / (up + dn));      
         }            

      //
      //
      //
      //
      //

      
      case rsi_har :
         {
            double avgUp=0,avgDn=0; up=0; dn=0;
            for(k=0; k<(int)period && (r-k-1)>=0; k++)
            {
               diff = workRsi[r-k][instanceNo+_price]- workRsi[r-k-1][instanceNo+_price];
               if(diff>0)
                     { avgUp += diff; up++; }
               else  { avgDn -= diff; dn++; }
            }
            if (up!=0) avgUp /= up;
            if (dn!=0) avgDn /= dn;
            double rs = 1;
               if (avgDn!=0) rs = avgUp/avgDn;
               return(100-100/(1.0+rs));
         }               

      //
      //
      //
      //
      //
      
      case rsi_rsx :  
         {   
            double Kg = (3.0)/(2.0+period), Hg = 1.0-Kg;
            if (r<period) { for (k=1; k<13; k++) workRsi[r][k+z] = 0; return(50); }  

            //
            //
            //
            //
            //
      
            double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
            double moa = MathAbs(mom);
            for (k=0; k<3; k++)
            {
               int kk = k*2;
               workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
               workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
               workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
               workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
            }
            if (moa != 0)
                 return(MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00)); 
            else return(50);
         }            
            
      //
      //
      //
      //
      //
      
      case rsi_cut :
         {
            double sump = 0;
            double sumn = 0;
            for (k=0; k<(int)period && r-k-1>=0; k++)
            {
               diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0) sump += diff;
                  if (diff < 0) sumn -= diff;
            }
            if (sumn > 0)
                  return(100.0-100.0/(1.0+sump/sumn));
            else  return(50);
         }            
   } 
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=_priceInstancesSize; int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*MathAbs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         //
         //
         
         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (slope[whichBar] != slope[whichBar+1])
      {
         switch (ColorChangeOn)
         {
            case clrOnSlope: 
               if (slope[whichBar]== 1) doAlert(whichBar,"slope changed to up");
               if (slope[whichBar]==-1) doAlert(whichBar,"slope changed to down");
               break;
            case clrOnMid: 
               if (slope[whichBar]== 1) doAlert(whichBar,"middle crossed up");
               if (slope[whichBar]==-1) doAlert(whichBar,"middle crossed down");
               break;
            default : 
               if (slope[whichBar]== 1) doAlert(whichBar,"upper level crossed up");
               if (slope[whichBar]==-1) doAlert(whichBar,"lower level crossed down");
         }    
      }
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(timeFrameToString(_Period)+" "+Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)+" vkw bands  "+doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" vkw bands ",message);
          if (alertsNotify)  SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}


   