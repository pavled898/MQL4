#property copyright "Market Profile v2.3.6704. © 2009-2010 Plus."
#property link      "plusfx@ya.ru; skype:plusfx"

#property indicator_chart_window

// Ïàðàìåòðû ðàñ÷åòîâ
extern int RangePeriod = PERIOD_D1;				// ÒÔ äèàïàçîíà, äîëæåí áûòü îäíèì èç ñòàíäàðòíûõ
extern int RangeCount = 20;						// êîëè÷åñòâî äèàïàçîíîâ/ãèñòîãðàìì
extern int ModeStep = 10;						// ñòåïåíü ñãëàæèâàíèÿ ãèñòîãðàììû, ôàêòè÷åñêè â 2 ðàçà áîëüøå + 1
int PointStep = 1;								// øàã öåíû
int DataPeriod = 1;								// ïåðèîä äëÿ äàííûõ, ìèíóòêè - ñàìûå òî÷íûå
bool ShowHorizon = true;						// ïîêàçàòü ãîðèçîíò äàííûõ

// Ãèñòîãðàììà
extern color HGColor = C'160,192,224';			// öâåò ãèñòîãðàììû
extern color ModeColor = Blue;					// öâåò ìîä
extern color MaxModeColor = CLR_NONE;			// âûäåëèòü ìàêñèìóì

int HGLineWidth = 1;							// øèðèíà ëèíèé ãèñòîãðàììû
double Zoom = 0;								// ìàñøòàá ãèñòîãðàììû, 0 - àâòîìàñøòàá

int ModeWidth = 1;								// òîëùèíà ìîä
int ModeStyle = STYLE_SOLID;					// ñòèëü ìîä

// Ñëóæåáíûå
extern string Id = "+mp";						// ïðåôèêñ èìåí ëèíèé

int WaitSeconds = 1;							// ìèíèìàëüíîå âðåìÿ, â ñåêóíäàõ, ìåæäó îáíîâëåíèÿìè
int TickMethod = 1;								// ìåòîä èìèòàöèè òèêîâ: 0 - Low >> High, 1 - Open > Low(High) > High(Low) > Close, 2 - HLC, 3 - HL
												// +4 - áåç ó÷åòà îáú¸ìà, +8 - ñ ó÷åòîì îáú¸ìà è äëèíû áàðà.

string onp;

datetime drawHistory[];		// èñòîðèÿ ðèñîâàíèÿ
datetime lastTime = 0;		// ïîñëåäíåå âðåìñÿ çàïóñêà
bool lastOK = false;

double hgPoint;				// ìèíèìàëüíîå èçìåíåíèå öåíû
int modeStep = 0;

bool showHG, showModes, showMaxMode;


#define ERR_HISTORY_WILL_UPDATED 4066


int init()
{
	onp = Id + " " + RangePeriod + " ";

	hgPoint = Point;
	
	bool is5digits = ((Digits == 3) || (Digits == 5)) && (MarketInfo(Symbol(), MODE_PROFITCALCMODE) == 0);
	
	if (PointStep == 0)
	{
		if (is5digits)
			hgPoint = Point * 10.0;
	}
	else
	{
		hgPoint = Point * PointStep;
	}


	modeStep = ModeStep * Point / hgPoint;
	if (is5digits)
		modeStep *= 10;
		

	ArrayResize(drawHistory, 0);
	
	// íàñòðîéêè îòîáðàæåíèÿ	
	showHG = (HGColor != CLR_NONE) && (HGColor != -16777216);
	showModes = (ModeColor != CLR_NONE) && (ModeColor != -16777216);
	showMaxMode = (MaxModeColor != CLR_NONE) && (MaxModeColor != -16777216);
}

int start()
{
	datetime currentTime = TimeLocal();

	// âñåãäà îáíîâëÿåìñÿ íà íîâîì áàðå...
	if ((Volume[0] > 1) && lastOK)
	{
		// ...è íå ÷àùå, ÷åì ðàç â íåñêîëüêî ñåêóíä
		if (currentTime - lastTime < WaitSeconds)
			return(0);
	}

	lastTime = currentTime;

	if (ShowHorizon)
	{
		datetime hz = iTime(NULL, DataPeriod, iBars(NULL, DataPeriod) - 1);
		drawVLine(onp + "hz", hz, Red, 1, STYLE_DOT, false);
	}

	double vh[], hLow;
	
	lastOK = true;
	for (int i = 0; i < RangeCount; i++)//1 - ShowLast
	{
		int barFrom, barTo, m1BarFrom, m1BarTo;

		datetime timeFrom = iTime(NULL, RangePeriod, i);

		datetime timeTo = Time[0];
		if (i != 0)
			timeTo = iTime(NULL, RangePeriod, i - 1);


		if (getRange(timeFrom, timeTo, barFrom, barTo, m1BarFrom, m1BarTo, DataPeriod))
		{
			if (!checkDrawHistory(timeFrom) || (i == 0))
			{
				int count = getHGByRates(m1BarFrom, m1BarTo, TickMethod, vh, hLow, hgPoint, DataPeriod);
				
				if (count > 0)
				{
					if (i != 0)
						addDrawHistory(timeFrom);

					// îïðåäåëåíèå ìàñøòàáà
					double zoom = Zoom*0.000001;
					if (zoom <= 0)
					{
						double maxVolume = vh[ArrayMaximum(vh)];
						zoom = (barFrom - barTo + 1) / maxVolume;
					}

					// ðèñóåì
					if (showHG)
					{
						string prefix = onp + "hg " + TimeToStr(timeFrom) + " ";
						drawHG(prefix, vh, hLow, barFrom, HGColor, HGColor, zoom, HGLineWidth, hgPoint);
					}
					
					if (showModes || showMaxMode)
						drawModes(vh, hLow, barFrom, zoom, hgPoint);
				}
			}
		}
		else
		{
			lastOK = false;
		}
	}

	return(0);
}

int deinit()
{
	clearChart(onp);
	return(0);
}

// ïðîâåðÿåò, ðèñîâàëèñü ëè äëÿ äàííîé äàòû óðîâíè
bool checkDrawHistory(datetime time)
{
	int count = ArraySize(drawHistory);
	bool r = false;
	for (int i = 0; i < count; i++)
	{
		if (drawHistory[i] == time)
		{
			r = true;
			break;
		}
	}
	return(r);
}

// äîáàâèòü îòðèñîâàííûé ó÷àñòîê â èñòîðèþ
void addDrawHistory(datetime time)
{
	if (!checkDrawHistory(time))
	{
		int count = ArraySize(drawHistory);
		ArrayResize(drawHistory, count + 1);
		drawHistory[count] = time;
	}
}

// íàðèñîâàòü ìîäû ãèñòîãðàììû
void drawModes(double& vh[], double hLow, int barFrom, double zoom, double point)
{
	int modes[], modeCount, j;
	double price;

	// ïîèñê ìîä
	modeCount = getModesIndexes(vh, modeStep, modes);

	// ìàêñ. ìîäà
	double max = 0;
	if (showMaxMode)
	{
		for (j = 0; j < modeCount; j++)
			if (vh[modes[j]] > max)
				max = vh[modes[j]];
	}

	for (j = 0; j < modeCount; j++)
	{
		double v = zoom*vh[modes[j]];

		// íå ðèñîâàòü êîðîòêèõ ëèíèé (ìåíüøå áàðà ÒÔ), ãëþ÷èò ïðè âûäåëåíèè ãðàíèö
		if (MathAbs(v) > 0)
		{
			price = hLow + modes[j]*point;
	
			datetime timeFrom = getBarTime(barFrom);
			datetime timeTo = getBarTime(barFrom - v);

			color cl = ModeColor;
			if (MathAbs(vh[modes[j]] - max) < point)
				cl = MaxModeColor;

			drawTrend(onp + "mode " + TimeToStr(timeFrom) + " " + DoubleToStr(price, Digits), 
				timeFrom, price, timeTo, price, cl, ModeWidth, ModeStyle, false, false);
		}
	}
}

datetime getBarTime(int shift, int period = 0)
{
	if (period == 0)
		period = Period();

	if (shift >= 0)
		return(iTime(Symbol(), period, shift));
	else
		return(iTime(Symbol(), period, 0) - shift*period*60);
}

/// Î÷èñòèòü ãðàôèê îò ñâîèõ îáúåêòîâ
int clearChart(string prefix)
{
	int obj_total = ObjectsTotal();
	string name;
	
	int count = 0;
	for (int i = obj_total - 1; i >= 0; i--)
	{
		name = ObjectName(i);
		if (StringFind(name, prefix) == 0)
		{
			ObjectDelete(name);
			count++;
		}			
	}
	return(count);
}

void drawVLine(string name, datetime time1, color lineColor = Gray, int width = 1, int style = STYLE_SOLID, bool back = true)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);
		
	ObjectCreate(name, OBJ_VLINE, 0, time1, 0);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
}

void drawTrend(string name, datetime time1, double price1, datetime timeTo, double price2, 
	color lineColor = Gray, int width = 1, int style = STYLE_SOLID, bool back = true, bool ray = true, int window = 0)
{
	if (ObjectFind(name) >= 0)
		ObjectDelete(name);
		
	ObjectCreate(name, OBJ_TREND, window, time1, price1, timeTo, price2);
	ObjectSet(name, OBJPROP_COLOR, lineColor);
	ObjectSet(name, OBJPROP_BACK, back);
	ObjectSet(name, OBJPROP_STYLE, style);
	ObjectSet(name, OBJPROP_WIDTH, width);
	ObjectSet(name, OBJPROP_RAY, ray);
}

// íàðèñîâàòü ãèñòîãðàììó (+öâåò +point)
void drawHG(string prefix, double& h[], double low, int barFrom, color bgColor, color lineColor, double zoom, int width, double point)
{
	double max = h[ArrayMaximum(h)];
	if (max == 0)
		return(0);

	int bgR = (bgColor & 0xFF0000) >> 16;
	int bgG = (bgColor & 0x00FF00) >> 8;
	int bgB = (bgColor & 0x0000FF);

	int lineR = (lineColor & 0xFF0000) >> 16;
	int lineG = (lineColor & 0x00FF00) >> 8;
	int lineB = (lineColor & 0x0000FF);
	
	int dR = lineR - bgR;
	int dG = lineG - bgG;
	int dB = lineB - bgB;

	for (int i = 0; i < ArraySize(h); i++)
	{
		double price = NormalizeDouble(low + i*point, Digits);
		
		int barTo = barFrom - h[i]*zoom;
		
		double fade = h[i] / max;

		int r = MathMax(MathMin(bgR + fade*dR, 255), 0);
		int g = MathMax(MathMin(bgG + fade*dG, 255), 0);
		int b = MathMax(MathMin(bgB + fade*dB, 255), 0);

		color cl = (r << 16) + (g << 8) + b;
		
		datetime timeFrom = getBarTime(barFrom);
		datetime timeTo = getBarTime(barTo);

		if (barFrom != barTo)
			drawTrend(prefix + DoubleToStr(price, Digits), timeFrom, price, timeTo, price, cl, width, STYLE_SOLID, true, false);
	}
}

// ïîëó÷èòü ïàðàìåòðû äèàïàçîíà
bool getRange(datetime timeFrom, datetime timeTo, int& barFrom, int& barTo, 
	int& p1BarFrom, int& p1BarTo, int period)
{
	// äèàïàçîí áàðîâ â òåêóùåì ÒÔ (äëÿ ðèñîâàíèÿ)

	barFrom = iBarShift(NULL, 0, timeFrom);
	datetime time = Time[barFrom];
	int bar = iBarShift(NULL, 0, time);
	time = Time[bar];
	if (time != timeFrom)
		barFrom--;
											
	barTo = iBarShift(NULL, 0, timeTo);
	time = Time[barTo];
	bar = iBarShift(NULL, 0, time);
	time = Time[bar];
	if (time == timeFrom)
		barTo++;

	if (barFrom < barTo)
		return(false);


	// äèàïàçîí áàðîâ ÒÔ period (äëÿ ïîëó÷åíèÿ äàííûõ)

	p1BarFrom = iBarShift(NULL, period, timeFrom);
	time = iTime(NULL, period, p1BarFrom);
	if (time != timeFrom)
		p1BarFrom--;
		
	p1BarTo = iBarShift(NULL, period, timeTo);
	time = iTime(NULL, period, p1BarTo);
	if (timeTo == time)
		p1BarTo++;
		
	if (p1BarFrom < p1BarTo)
		return(false);

	return(true);
}

/// Ïîëó÷èòü ãèñòîãðàììó ðàñïðåäåëåíèÿ öåí
///		m1BarFrom, m1BarTo - ãðàíèöû äèàïàçîíà, çàäàííûå íîìåðàìè áàðîâ ìèíóòîê
/// Âîçâðàùàåò:
///		ðåçóëüòàò - êîëè÷åñòâî öåí â ãèñòîãðàììå, 0 - îøèáêà
///		vh - ãèñòîãðàììà
///		hLow - íèæíÿÿ ãðàíèöà ãèñòîãðàììû
///		point - øàã öåíû
///		dataPeriod - òàéìôðåéì äàííûõint
int getHGByRates(int m1BarFrom, int m1BarTo, int tickMethod, double& vh[], double& hLow, double point, int dataPeriod)
{
	double rates[][6];
	double hHigh;

	// ïðåäïîëîæèòåëüíîå (è ìàêñèìàëüíîå) êîëè÷åñòâî ìèíóòîê
	int rCount = getRates(m1BarFrom, m1BarTo, rates, hLow, hHigh, dataPeriod);
	//Print("rCount: " + rCount);
	
	if (rCount != 0)
	{
		hLow = NormalizeDouble(MathRound(hLow / point) * point, Digits);
		hHigh = NormalizeDouble(MathRound(hHigh / point) * point, Digits);
		
		//Print("hLow: " + hLow);
		//Print("hHigh: " + hHigh);

		// èíèöèàëèçèðóåì ìàññèâ ãèñòîãðàììû
		int hCount = hHigh/point - hLow/point + 1;
		//Print("hCount: " + hCount);
		ArrayResize(vh, hCount);
		ArrayInitialize(vh, 0);

		int iCount = m1BarFrom - m1BarTo + 1;
		int hc = mql_GetHGByRates(rates, rCount, iCount, m1BarTo, tickMethod, point, hLow, hCount, vh);
		//Print("hc: " + hc);

		if (hc == hCount)
			return(hc);
		else
			return(0);
	}
	else
	{
		//Print("Error: no rates");
		return(0);
	}
}

/// Ïîëó÷èòü ãèñòîãðàììó ðàñïðåäåëåíèÿ öåí ñðåäñòâàìè MQL (àíàëîã vlib_GetHGByRates
int mql_GetHGByRates(double& rates[][6], int rcount, int icount, int ishift, int tickMethod, double point, 
	double hLow, int hCount, double& vh[])
{
	int pri;	// èíäåêñ öåíû
	double dv;	// îáúåì íà òèê

	int hLowI = MathRound(hLow / point);
	//Print(rcount);

	for (int j = 0; j < icount; j++)
	{
		//int i = rcount - 1 - j - ishift;
		int i = j + ishift;

		double o = rates[i][1];
		int oi = MathRound(o/point);

		double h = rates[i][3];
		int hi = MathRound(h/point);

		double l = rates[i][2];
		int li = MathRound(l/point);

		double c = rates[i][4];
		int ci = MathRound(c/point);

		double v = rates[i][5];

		//Print("oi: " + oi);
		//Print("hLowI: " + hLowI);
		//Print("oi-hLowI: " + (oi-hLowI));
		//Print("rate: " + v);

		int rangeMin = hLowI;
		int rangeMax = hLowI + hCount - 1;

		if (tickMethod == 0)						// ðàâíàÿ âåðîÿòíîñòü âñåõ öåí áàðà
		{
			dv = v / (hi - li + 1.0);
			for (pri = li; pri <= hi; pri++)
				vh[pri - hLowI] += dv;
		}
		else if (tickMethod == 1)					// èìèòàöèÿ òèêîâ
		{
			if (c >= o)		// áû÷üÿ ñâå÷à
			{
				dv = v / (oi - li + hi - li + hi - ci + 1.0);

				for (pri = oi; pri >= li; pri--)		// open --> low
					vh[pri - hLowI] += dv;

				for (pri = li + 1; pri <= hi; pri++)	// low+1 ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= ci; pri--)	// high-1 --> close
					vh[pri - hLowI] += dv;
			}
			else			// ìåäâåæüÿ ñâå÷à
			{
				dv = v / (hi - oi + hi - li + ci - li + 1.0);

				for (pri = oi; pri <= hi; pri++)		// open ++> high
					vh[pri - hLowI] += dv;
				
				for (pri = hi - 1; pri >= li; pri--)	// high-1 --> low
					vh[pri - hLowI] += dv;
				
				for (pri = li + 1; pri <= ci; pri++)	// low+1 ++> close
					vh[pri - hLowI] += dv;
			}
		}
		else if (tickMethod == 2)					// òîëüêî öåíû áàðà
		{
			dv = v / 4.0;
			vh[oi - hLowI] += dv;
			vh[hi - hLowI] += dv;
			vh[li - hLowI] += dv;
			vh[ci - hLowI] += dv;
		}
		else if (tickMethod == 3)					// òîëüêî õàé è ëîó
		{
			dv = v / 2.0;
			vh[hi - hLowI] += dv;
			vh[li - hLowI] += dv;
		}
	}
	
	return(hCount);
}

/// Ïîëó÷èòü ìîäû íà îñíîâå ãèñòîãðàììû è ñãëàæåííîé ãèñòîãðàììû (áûñòðûé ìåòîä, áåç ñãëàæèâàíèÿ)
int getModesIndexes(double& vh[], int modeStep, int& modes[]) //, int& maxModeIndex
{
	int modeCount = 0;
	ArrayResize(modes, modeCount);

	int count = ArraySize(vh);
	
	// èùåì ìàêñèìóìû ïî ó÷àñòêàì
	for (int i = modeStep; i < count - modeStep; i++)
	{
		int maxFrom = i-modeStep;
		int maxRange = 2*modeStep + 1;
		int maxTo = maxFrom + maxRange - 1;

		int k = ArrayMaximum(vh, maxRange, maxFrom);
		
		if (k == i)
		{
			for (int j = i - modeStep; j <= i + modeStep; j++)
			{
				if (vh[j] == vh[k])
				{
					modeCount++;
					ArrayResize(modes, modeCount);
					modes[modeCount-1] = j;
				}
			}
		}
		
	}

	return(modeCount);
}


/// Ïîëó÷èòü ìèíóòêè äëÿ çàäàííîãî äèàïàçîíà (óêàçûâàåòñÿ â íîìåðàõ áàðîâ ìèíóòîê)
int getRates(int barFrom, int barTo, double& rates[][6], double& ilowest, double& ihighest, int period)
{
	// ïðåäïîëîæèòåëüíîå (è ìàêñèìàëüíîå) êîëè÷åñòâî ìèíóòîê
	int iCount = barFrom - barTo + 1;
	
	int count = ArrayCopyRates(rates, NULL, period);
	if (GetLastError() == ERR_HISTORY_WILL_UPDATED)
	{
		return(0);
	}
	else
	{
		if (count >= barFrom - 1)
		{
			ilowest = iLow(NULL, period, iLowest(NULL, period, MODE_LOW, iCount, barTo));
			ihighest = iHigh(NULL, period, iHighest(NULL, period, MODE_HIGH, iCount, barTo));
			//Print("ilowest:" + ilowest);
			//Print("ihighest:" + ihighest);
			return(count);
		}
		else
		{
			return(0);
		}
	}
}


