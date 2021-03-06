//+------------------------------------------------------------------+
//|                                                      Hedging.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict 
 
extern int BarLookUp = 5; // Bar Lookup
extern double Ratio = 2; // Candle Ratio (Times)
extern int MinimumPipRatio = 500; // Minimum pips to calculate ratio
double Arr_Ratio_High[];
double Arr_Ratio_Low[];
double Arr_High[];
double Arr_Low[];
double Arr_Ratio_Candle_High[];
double Arr_Ratio_Candle_Low[];
int AcceptOpen = 5;
int MaximumOrder = 1;
int OnInit()
  {      
   ObjectsDeleteAll();
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
   if(Util_IsNewBar(PERIOD_CURRENT))
   {
      ObjectsDeleteAll();
      MainLoop();
   }
    
   if(TotalOrders() >= MaximumOrder){
      return;
   }
   
   double current_open = iOpen(Symbol(),PERIOD_CURRENT,0);
   double price = (Ask+Bid)/(double)2; 
      
   for(int i = 1; i < BarLookUp;i++){
     if(Arr_Ratio_High[i] >= Ratio){
         if(current_open < Arr_High[i]){ 
            if(isOrderReady(price,Arr_High[i]) && EMADirection() == "SELL"){
               double tp = (Util_PriceNoDigit(Arr_Ratio_Candle_High[i])+(MinimumPipRatio*0.1))/Util_DivideDigit();
               double sl = (Util_PriceNoDigit(price)+(MathAbs(Util_PriceNoDigit(Arr_High[i])-Util_PriceNoDigit(Arr_Ratio_Candle_High[i]))-(MinimumPipRatio*0.2)))/Util_DivideDigit();
               //double sl = (Util_PriceNoDigit(Arr_Ratio_Candle_High[i])-(MinimumPipRatio*0.2))/Util_DivideDigit();
               Util_OpenOrderWithSLTP(Symbol(),OP_SELL,0.01,tp,sl,"HG_S");
               break;
            }
         }
      }
      
     if(Arr_Ratio_Low[i] >= Ratio){
         if(current_open > Arr_Low[i]){ 
            if(isOrderReady(price,Arr_Low[i]  && EMADirection() == "BUY")){
               double tp = (Util_PriceNoDigit(Arr_Ratio_Candle_Low[i])-(MinimumPipRatio*0.1))/Util_DivideDigit();
               double sl = (Util_PriceNoDigit(price)-(MathAbs(Util_PriceNoDigit(Arr_Ratio_Candle_Low[i])-Util_PriceNoDigit(Arr_Low[i]))-(MinimumPipRatio*0.2)))/Util_DivideDigit();
               //double sl = (Util_PriceNoDigit(Arr_Ratio_Candle_High[i])-(MinimumPipRatio*0.2))/Util_DivideDigit();
               Util_OpenOrderWithSLTP(Symbol(),OP_BUY,0.01,tp,sl,"HG_S");
               break;
            }
         }
      }
   } 
}


string EMADirection(){
    double price = (Ask+Bid)/(double)2;
    double ema = iMA(Symbol(),PERIOD_CURRENT,14,0,MODE_EMA,PRICE_CLOSE,0);
    if(price > ema){
      return "BUY";
    }else{
      return "SELL";
    }
}



int TotalOrders(){
   
    int order_total = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    { 
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
          if(OrderType() == OP_BUY){ 
            order_total++;
          }
          if(OrderType() == OP_SELL){ 
            order_total++;
          } 
       } 
    }   
 
   return order_total;
}

bool isOrderReady(double priceCurrent,double priceOpen){
   bool isReady = false;
   
   int intPriceCurrent = Util_PriceNoDigit(priceCurrent);
   int intPriceOpenFrom = Util_PriceNoDigit(priceOpen)+AcceptOpen;
   int intPriceOpenTo = Util_PriceNoDigit(priceOpen)-AcceptOpen; 
   if(intPriceCurrent < intPriceOpenFrom && intPriceCurrent > intPriceOpenTo){
      isReady = true; 
   }
   return isReady;
}


void MainLoop(){
   ArrayFree(Arr_Ratio_High);
   ArrayFree(Arr_Ratio_Low);
   ArrayFree(Arr_High);
   ArrayFree(Arr_Low);
   ArrayFree(Arr_Ratio_Candle_High);
   ArrayFree(Arr_Ratio_Candle_Low);
   ArrayResize(Arr_Ratio_High,BarLookUp);
   ArrayResize(Arr_Ratio_Low,BarLookUp);
   ArrayResize(Arr_High,BarLookUp);
   ArrayResize(Arr_Low,BarLookUp);
   ArrayResize(Arr_Ratio_Candle_High,BarLookUp);
   ArrayResize(Arr_Ratio_Candle_Low,BarLookUp);
   
   for(int i = 0; i < BarLookUp; i++)
   {
      //Arr_Ratio_High[i] = RatioCal(PERIOD_CURRENT,i,MODE_HIGH);
      //Arr_Ratio_Low[i] = RatioCal(PERIOD_CURRENT,i,MODE_LOW);
      RatioCal(PERIOD_CURRENT,i,MODE_HIGH);
      RatioCal(PERIOD_CURRENT,i,MODE_LOW);
      if(Arr_Ratio_High[i] >= Ratio){ 
         string name = "arrowSell_"+IntegerToString(i);
         Util_ArrowSellCreate(0,name,0,iTime(Symbol(),PERIOD_CURRENT,i),iHigh(Symbol(),PERIOD_CURRENT,i)); 
      } 
      if(Arr_Ratio_Low[i] >= Ratio){ 
         string name = "arrowBuy_"+IntegerToString(i);
         Util_ArrowBuyCreate(0,name,0,iTime(Symbol(),PERIOD_CURRENT,i),iLow(Symbol(),PERIOD_CURRENT,i)); 
      }
         
   }
}

   /*
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
   if(MinimumPipRatio < MathAbs(highest-lowest)){ 
      if(MODE == MODE_HIGH)
      {
         check = (open > close ? open : close); 
         wick = MathAbs(highest-check); 
      }   
      if(MODE == MODE_LOW)
      {
         check = (open > close ? close : open);
         wick = MathAbs(lowest-check); 
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
*/

   /*
double RatioCal(int period,int shift,int MODE)
{  
   //bool result = false;
   int highest = Util_PriceNoDigit(iHigh(Symbol(),period,shift));
   int lowest  = Util_PriceNoDigit(iLow(Symbol(),period,shift));
   int open = Util_PriceNoDigit(iOpen(Symbol(),period,shift));
   int close = Util_PriceNoDigit(iClose(Symbol(),period,shift));  
   int candle = MathAbs(open-close); 
   int wickHigh = 0;
   int checkHigh = 0;
   int wickLow = 0;
   int checkLow = 0;
   double ratio = 0; 
   if(MinimumPipRatio < MathAbs(highest-lowest)){ 
   
      checkHigh = (open > close ? open : close); 
      wickHigh = MathAbs(highest-checkHigh); 
       
      checkLow = (open > close ? close : open);
      wickLow = MathAbs(lowest-checkLow);
      
      if(MODE == MODE_HIGH){
         if(candle > 0){
            ratio = ((double)wickHigh/(double)candle);  
         }else{
            ratio = 0;
         }
         
         if(wickLow > wickHigh){
            ratio = 0;
         }
      }
      
      if(MODE == MODE_LOW){ 
         if(candle > 0){
            ratio = ((double)wickLow/(double)candle);  
         }else{
            ratio = 0;
         } 
         
         if(wickHigh > wickLow){
            ratio = 0;
         }
      } 
   }else{
      ratio = 0;
   }
   return ratio; 
   //if(ratio > Ratio){ result = true; }
   //return result;
}
*/


void RatioCal(int period,int shift,int MODE)
{  
   //bool result = false;
   int highest = Util_PriceNoDigit(iHigh(Symbol(),period,shift));
   int lowest  = Util_PriceNoDigit(iLow(Symbol(),period,shift));
   int open = Util_PriceNoDigit(iOpen(Symbol(),period,shift));
   int close = Util_PriceNoDigit(iClose(Symbol(),period,shift));  
   int candle = MathAbs(open-close); 
   int wickHigh = 0;
   int checkHigh = 0;
   int wickLow = 0;
   int checkLow = 0;
   double ratio = 0; 
   if(MinimumPipRatio < MathAbs(highest-lowest)){ 
   
      checkHigh = (open > close ? open : close); 
      wickHigh = MathAbs(highest-checkHigh); 
       
      checkLow = (open > close ? close : open);
      wickLow = MathAbs(lowest-checkLow);
      
      if(MODE == MODE_HIGH){
         if(candle > 0){
            ratio = ((double)wickHigh/(double)candle);  
         }else{
            ratio = 0;
         }
         
         if(wickLow > wickHigh){
            ratio = 0;
         }
      }
      
      if(MODE == MODE_LOW){ 
         if(candle > 0){
            ratio = ((double)wickLow/(double)candle);  
         }else{
            ratio = 0;
         } 
         
         if(wickHigh > wickLow){
            ratio = 0;
         }
      } 
   }else{
      ratio = 0;
   }  
   
   if(MODE == MODE_HIGH){
      Arr_Ratio_High[shift] = ratio;
      Arr_High[shift] = (highest)/(double)Util_DivideDigit();
      Arr_Ratio_Candle_High[shift] = (checkHigh)/(double)Util_DivideDigit();
   }
   if(MODE == MODE_LOW){ 
      Arr_Ratio_Low[shift] = ratio;
      Arr_Low[shift] = (lowest)/(double)Util_DivideDigit();
      Arr_Ratio_Candle_Low[shift] = (checkLow)/(double)Util_DivideDigit();
   } 
   
}

double Util_DivideDigit(){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   return StrToDouble(multiple);
}


int Util_PriceNoDigit(double price){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   
   return (int)(price*StrToDouble(multiple));   
}


int Util_OpenOrderWithSLTP(string _symbol, int cmd, double lot,double tp,double sl,string comment)
{ 
    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0; 
    double _symbol_Point = MarketInfo(_symbol,MODE_POINT);
    int _symbol_Digits = ((int)MarketInfo(_symbol,MODE_DIGITS));
    double Arr_SLTP[]; 
    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 5, sl, tp, comment, 0, 0, clrGreen);  
        if (iSuccess >= 0)
        {
            return iSuccess;
        }

        if (count == 5)
        {
            return 0;
        }
        count++;
    }
    int fnError = GetLastError();
    if(fnError > 0){
      Print("Error function OpenOrder: ",fnError);
      ResetLastError();
    }
    return 0;
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

bool Util_IsNewBar(int period)
{  

   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(Symbol(),period,SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
   {
      lastbar = curbar;
      return true;
   }
   return false;
}    

   