//+------------------------------------------------------------------+
//|                                                   Holy Grail.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict 
 
extern int BarLookUp = 200; // Bar Lookup
extern double Ratio = 2; // Candle Ratio (Times)
extern int MinimumPipRatio = 150; // Minimum pips to calculate ratio
double Arr_Ratio_High[];
double Arr_Ratio_Low[];
int OnInit()
  {      
   ObjectsDeleteAll();
   MainLoop();
   //RatioCal(PERIOD_CURRENT,145,MODE_LOW);
   return(INIT_SUCCEEDED);
  }
   
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  { 
    
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{  
   
}


void MainLoop(){
   ArrayFree(Arr_Ratio_High);
   ArrayFree(Arr_Ratio_Low);
   ArrayResize(Arr_Ratio_High,BarLookUp);
   ArrayResize(Arr_Ratio_Low,BarLookUp);
   for(int i = 0; i < BarLookUp; i++)
   {
      Arr_Ratio_High[i] = RatioCal(PERIOD_CURRENT,i,MODE_HIGH);
      Arr_Ratio_Low[i] = RatioCal(PERIOD_CURRENT,i,MODE_LOW);
      
      if(Arr_Ratio_High[i] >= Ratio){ 
         string name = "arrowSell_"+IntegerToString(i);
         Util_ArrowSellCreate(0,name,0,iTime(Symbol(),PERIOD_CURRENT,i),iHigh(Symbol(),PERIOD_CURRENT,i)); 
      } 
      if(Arr_Ratio_Low[i] >= Ratio){ 
         string name = "arrowBuy_"+IntegerToString(i);
         Util_ArrowBuyCreate(0,name,0,iTime(Symbol(),PERIOD_CURRENT,i),iLow(Symbol(),PERIOD_CURRENT,i)); 
      } 
      
      
      
      
   }
   //Alert(Arr_Ratio_High[4]);
}

   
double RatioCal(int period,int shift,int MODE)
{  
   //bool result = false;
   int highest = Util_PriceNoDigit(iHigh(Symbol(),period,shift));
   int lowest  = Util_PriceNoDigit(iLow(Symbol(),period,shift));
   int open = Util_PriceNoDigit(iOpen(Symbol(),period,shift));
   int close = Util_PriceNoDigit(iClose(Symbol(),period,shift));  
   int candle = MathAbs(open-close); 
   int wick = 0;
   int check = 0;
   double ratio = 0;
   //Alert(MathAbs(highest-lowest));
   if(MinimumPipRatio < MathAbs(highest-lowest)){ 
      if(MODE == MODE_HIGH)
      {
         check = (open > close ? open : close); 
         wick = MathAbs(highest-check);
        // Alert(wick);
      }   
      if(MODE == MODE_LOW)
      {
         check = (open > close ? close : open);
         wick = MathAbs(lowest-check);
        // Alert(wick);
      }
      if(candle > 0){
         ratio = ((double)wick/(double)candle);  
      }else{
         ratio = 0;
      }
   }else{
      ratio = 0;
   }
   return ratio; 
   //if(ratio > Ratio){ result = true; }
   //return result;
}



int Util_PriceNoDigit(double price){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   
   return (int)(price*StrToDouble(multiple));   
}

bool Util_ArrowSellCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="ArrowSell",  // sign name
                     const int             sub_window=0,      // subwindow index
                     datetime              time=0,            // anchor point time
                     double                price=0,           // anchor point price
                     const color           clr=C'225,68,29',  // sign color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // line style (when highlighted)
                     const int             width=1,           // line size (when highlighted)
                     const bool            back=false,        // in the background
                     const bool            selection=false,   // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   Util_ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create the sign
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_SELL,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Sell\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- set a sign color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set a line style (when highlighted)
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a line size (when highlighted)
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the sign by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
  bool Util_ArrowBuyCreate(const long            chart_ID=0,        // chart's ID
                    const string          name="ArrowBuy",   // sign name
                    const int             sub_window=0,      // subwindow index
                    datetime              time=0,            // anchor point time
                    double                price=0,           // anchor point price
                    const color           clr=C'3,95,172',   // sign color
                    const ENUM_LINE_STYLE style=STYLE_SOLID, // line style (when highlighted)
                    const int             width=1,           // line size (when highlighted)
                    const bool            back=false,        // in the background
                    const bool            selection=false,   // highlight to move
                    const bool            hidden=true,       // hidden in the object list
                    const long            z_order=0)         // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   Util_ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create the sign
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_BUY,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Buy\" sign! Error code = ",GetLastError());
      return(false);
     }
//--- set a sign color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set a line style (when highlighted)
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set a line size (when highlighted)
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the sign by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }

  
  void Util_ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }

