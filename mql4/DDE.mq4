//+------------------------------------------------------------------+
//|                                                          DDE.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define major   1
#define minor   0

#import "user32.dll"
int SendMessageW(int hWnd,int Msg,int wParam,int lParam);
int FindWindowW(int lpClassName,string lpWindowName);

#import "kernel32.dll"
int GlobalAddAtomW(string str);
int GlobalDeleteAtom(int atom);
int GlobalGetAtomNameW(int atom,int &buf[],int size);
#import

#define FormClass NULL
#define WND_NAME  "MT4.DDE.2"

#define WM_USER         0x0400
#define WM_CHECKITEM    0x0401
#define WM_ADDITEM      0x0402
#define WM_SETITEM      0x0403

int            min_rates_total;
bool           calculoNovosCandles = false;

//--- declaring constants
#define RESET 0


//--- input parameters
input datetime dataInicio=D'2020.10.01 00:00:00';
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//--- indicator buffers mapping

   min_rates_total=8;


   if(!CheckItem("Cotacao","Barra")) 
   AddItem("Cotacao","Barra");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
   //---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(RESET);
   
   //---- declaration of local variables 
   int limit,bar;

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
   ArraySetAsSeries(volume,true);
   ArraySetAsSeries(spread,true);
   
//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
      calculoNovosCandles = false;
     }
   else
     { 
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
      calculoNovosCandles = true;
     } 
//----
   
   //---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
   {
   
      if(!calculoNovosCandles && time[bar]>=dataInicio)
      {
         string jsonBar = "{\"date\": \"" + TimeToString(time[bar],TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\", " +
               " \"open\": \""+ DoubleToString(open[bar], _Digits)+ "\", "+
               " \"high\": \""+ DoubleToString(high[bar], _Digits)+ "\", "+
               " \"low\": \""+ DoubleToString(low[bar], _Digits)+ "\", "+ 
               " \"close\": \""+ DoubleToString(close[bar], _Digits)+ "\", "+ 
               " \"volume\": \""+ IntegerToString(tick_volume[bar])+ "\"}";
               
         SetItem("Cotacao","Barra", jsonBar);
         Print(jsonBar);

      
      }
   
   
      if(calculoNovosCandles)
      {
         string jsonBar = "{\"date\": \"" + TimeToString(time[bar],TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\", " +
               " \"open\": \""+ DoubleToString(open[bar], _Digits)+ "\", "+
               " \"high\": \""+ DoubleToString(high[bar], _Digits)+ "\", "+
               " \"low\": \""+ DoubleToString(low[bar], _Digits)+ "\", "+ 
               " \"close\": \""+ DoubleToString(close[bar], _Digits)+ "\", "+ 
               " \"volume\": \""+ IntegerToString(tick_volume[bar])+ "\"}";
               
         SetItem("Cotacao","Barra", jsonBar);
         Print(jsonBar);
      }
      
      
   }
   
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

bool CheckItem(string topic,string item)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0) 
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item=GlobalAddAtomW(topic+"!"+item);
   if(_item==0) 
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_CHECKITEM,_item,0);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[CheckItem] "+str);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AddItem(string topic,string item)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0) 
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item=GlobalAddAtomW(topic+"!"+item);
   if(_item==0) 
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_ADDITEM,_item,0);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[AddItem] "+str);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetItem(string topic,string item,string val)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0) 
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item= GlobalAddAtomW(topic+"!"+item);
   if(_item == 0)
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int _val= GlobalAddAtomW(val);
   if(_val == 0)
     {
      Alert("Cannot create "+val+" atom!");
      GlobalDeleteAtom(_item);
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_SETITEM,_item,_val);
   GlobalDeleteAtom(_val);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[SetItem] "+str);
     }

   return(false);
  }
//-----------------------------------------------------------------------------

int LOWORD(int val)
  {
   return((val>>16)  &0xFFFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HIWORD(int val)
  {
   return(val  &0xFFFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MakeStr(int &buf[],int cnt)
  {
   string str="";
   int ch=-1;

   for(int i=0; i<cnt; i++) 
     {
      if(i%4 == 0) ch = buf[i/4] & 0xFF;
      if(i%4 == 1) ch = (buf[i/4] >> 8) & 0xFF;
      if(i%4 == 2) ch = (buf[i/4] >> 16) & 0xFF;
      if(i%4 == 3) ch = (buf[i/4] >> 24) & 0xFF;

      str=str+CharToString((uchar)ch);
     }

   return(str);
  }
//+------------------------------------------------------------------+