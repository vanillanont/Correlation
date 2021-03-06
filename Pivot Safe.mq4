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
double pivot = 0; 
double Arr_Open_Price[];
double Arr_isOpened_Price[];
bool isFirstOrderOpen = false;
int OP_TYPE = 0; 
int Arr_CloseTicket[];
double Tp_price_minimum = 0;
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

void OnTick()
{   
   if(TotalOrders() == 0){ 
      isFirstOrderOpen = false;
   } 

   Tp_price_minimum = 0;
   int totalRemainClose = 0;
   for(int i = 0 ; i < ArraySize(Arr_CloseTicket); i++){
      if(Arr_CloseTicket[i] != 0){
         bool isSuccess = Util_CloseOrder(Arr_CloseTicket[i]);
         if(isSuccess){
            Arr_CloseTicket[i] = 0;
         }
         totalRemainClose++;
      } 
   } 
   if(totalRemainClose > 0){
      ArrayFree(Arr_CloseTicket); 
      ArrayFree(Arr_Open_Price);
      ArrayFree(Arr_isOpened_Price);
      isFirstOrderOpen = false;
      OP_TYPE = 0;
      ObjectsDeleteAll();
      SetHLine("PIVOT",pivot,clrGreen); 
   }     
   
   if(Util_IsNewBar(PERIOD_D1))
   {
      //ObjectsDeleteAll();
      pivot = GetPivot(Symbol()); 
      SetHLine("PIVOT",pivot,clrGreen); 
   } 
   double price = (MarketInfo(Symbol(),MODE_BID)+MarketInfo(Symbol(),MODE_ASK))/(double)2;

   int period =  PERIOD_H1;
   int previous_open = Util_PriceNoDigit(iOpen(Symbol(),period,1));
   int previous_close = Util_PriceNoDigit(iClose(Symbol(),period,1));
   int previous_low = Util_PriceNoDigit(iLow(Symbol(),period,1));
   int previous_high = Util_PriceNoDigit(iHigh(Symbol(),period,1));
   
   int previous_second_open = Util_PriceNoDigit(iOpen(Symbol(),period,2));
   int previous_second_close = Util_PriceNoDigit(iClose(Symbol(),period,2));
   int previous_second_low = Util_PriceNoDigit(iLow(Symbol(),period,2));
   int previous_second_high = Util_PriceNoDigit(iHigh(Symbol(),period,2));
   
   int previous_third_open = Util_PriceNoDigit(iOpen(Symbol(),period,3));
   int previous_third_close = Util_PriceNoDigit(iClose(Symbol(),period,3));
   int previous_third_low = Util_PriceNoDigit(iLow(Symbol(),period,3));
   int previous_third_high = Util_PriceNoDigit(iHigh(Symbol(),period,3)); 
   
   int previous_fourth_open = Util_PriceNoDigit(iOpen(Symbol(),period,4));
   int previous_fourth_close = Util_PriceNoDigit(iClose(Symbol(),period,4));
   int previous_fourth_low = Util_PriceNoDigit(iLow(Symbol(),period,4));
   int previous_fourth_high = Util_PriceNoDigit(iHigh(Symbol(),period,4));
   
   int previous_fifth_open = Util_PriceNoDigit(iOpen(Symbol(),period,5));
   int previous_fifth_close = Util_PriceNoDigit(iClose(Symbol(),period,5));
   int previous_fifth_low = Util_PriceNoDigit(iLow(Symbol(),period,5));
   int previous_fifth_high = Util_PriceNoDigit(iHigh(Symbol(),period,5));
   
   if(price < pivot){ 
   // buy
      if(
            previous_fifth_open > previous_fifth_close 
         && previous_fourth_open > previous_fourth_close 
         && previous_third_open > previous_third_close 
         && previous_second_open > previous_second_close 
         && previous_open > previous_close  
         && previous_close > previous_second_low
         && isFirstOrderOpen == false
         ){
             //Util_OpenOrder(Symbol(),OP_BUY,0.01,"GP_"+Symbol()+"_0"); 
             double tp = (double)(Util_PriceNoDigit(Bid)+300)/(double)Util_DivideDigit();
             double sl = (double)(Util_PriceNoDigit(Bid)-300)/(double)Util_DivideDigit();
             Util_OpenOrderWithSLTP(Symbol(),OP_BUY,0.01,tp,sl,"GP_"+Symbol()+"_0");
             isFirstOrderOpen = true;
             OP_TYPE = OP_BUY;
             ArrayResize(Arr_Open_Price,50);
             ArrayResize(Arr_isOpened_Price,50);
             double begin_price = MarketInfo(Symbol(),MODE_ASK);
             int Buy_Step = Util_PriceNoDigit(begin_price);     
             //for(int i = 0; i < 50; i++){ 
             //  Buy_Step -= 100;
             //  Arr_Open_Price[i] = Buy_Step/(double)Util_DivideDigit();  
             //  SetHLine("GRID_"+DoubleToStr(Arr_Open_Price[i]),Arr_Open_Price[i],clrYellow);    
             //}
         }
   }else{ 
   // sell
      if(
            previous_fifth_open < previous_fifth_close 
         && previous_fourth_open < previous_fourth_close 
         && previous_third_open < previous_third_close 
         && previous_second_open < previous_second_close 
         && previous_open < previous_close  
         && previous_close < previous_second_high
         && isFirstOrderOpen == false
         ){
             //Util_OpenOrder(Symbol(),OP_SELL,0.01,"GP_"+Symbol()+"_0"); 
             double tp = (double)(Util_PriceNoDigit(Ask)-300)/(double)Util_DivideDigit();
             double sl = (double)(Util_PriceNoDigit(Ask)+300)/(double)Util_DivideDigit();
             Util_OpenOrderWithSLTP(Symbol(),OP_SELL,0.01,tp,sl,"GP_"+Symbol()+"_0");
             isFirstOrderOpen = true;
             OP_TYPE = OP_SELL;
             ArrayResize(Arr_Open_Price,50);
             ArrayResize(Arr_isOpened_Price,50);
             double begin_price = MarketInfo(Symbol(),MODE_BID);
             int Sell_Step = Util_PriceNoDigit(begin_price); 
             //for(int i = 0; i < 50; i++){ 
               //Sell_Step += 100;
               //Arr_Open_Price[i] = Sell_Step/(double)Util_DivideDigit(); 
               //SetHLine("GRID_"+DoubleToStr(Arr_Open_Price[i]),Arr_Open_Price[i],clrYellow);   
             //}
         }
   }
   
   if(isFirstOrderOpen == true){ 
      double currentPrice = (OP_TYPE == OP_BUY) ? MarketInfo(Symbol(),MODE_ASK) : MarketInfo(Symbol(),MODE_BID);
      for(int i = 0; i < 50; i++){
         double openPrice = Arr_Open_Price[i]; 
         bool isReady = isOrderReady(currentPrice,openPrice);
         bool isOpened = Arr_isOpened_Price[i];
         if(isReady == true && isOpened == false){
            Util_OpenOrder(Symbol(),OP_TYPE,0.01,"GP_"+Symbol()+"_0"); 
            Arr_isOpened_Price[i] = true;
         }
      } 
   }
   
       double profit = 0;
       for (int i = 0; i < OrdersTotal(); i++)
       {
          if (OrderSelect(i, SELECT_BY_POS) == true)
          {   
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){ 
               if(StringFind(OrderComment(),"GP_"+Symbol(),0) >= 0){
                  profit += (OrderProfit() + OrderSwap() + OrderCommission()); 
                  Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                  Tp_price_minimum += 1;
               }
            } 
          }
       } 
       Tp_price_minimum = 0.01*(Tp_price_minimum*100);
       if(profit < Tp_price_minimum){
         ArrayFree(Arr_CloseTicket);
       } 
       Comment("TP At : "+DoubleToStr(Tp_price_minimum)+" profit : "+DoubleToStr(profit));
}


bool isOrderReady(double priceCurrent,double priceOpen,string cmt = ""){
   bool isReady = false;
   
   int intPriceCurrent = Util_PriceNoDigit(priceCurrent);
   int intPriceOpenFrom = Util_PriceNoDigit(priceOpen)+AcceptOpen;
   int intPriceOpenTo = Util_PriceNoDigit(priceOpen)-AcceptOpen; 
   if(intPriceCurrent < intPriceOpenFrom && intPriceCurrent > intPriceOpenTo){
      isReady = true; 
   }
   return isReady;
}
 

  

bool Util_CloseOrder(int ticket)
{
        bool iSuccess = false;
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
      // if(OrderMagicNumber() == magicNumber){ 
           int mode = 0;
           if (OrderType() == OP_SELL)
           {
               mode = MODE_ASK;
           }
           else
           {
               mode = MODE_BID;
           }
           ;
           int i = 0;
           while (!iSuccess)
           {
              // if(i == 6){
              //    iSuccess = true;
              // }
               
               iSuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 10, clrRed);
               i++;
           } 
           Sleep(300);
      //  }
    }
    int fnError = GetLastError();
    if(fnError > 0){
      Print("Error function closeOrder: ",fnError," Ticket: ",ticket);
      ResetLastError();
    }
    return iSuccess;
}

  
double GetPivot(string symbol,int period = PERIOD_D1,int shift = 1){
   return (iHigh(symbol,period,shift)+iLow(symbol,period,shift))/(double)2;
}


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


 
int Util_OpenOrder(string _symbol, int cmd, double lot,string comment)
{

    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;

    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 10, 0.0, 0.0, comment, 0, 0, clrGreen);  
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




  bool SetHLine(string name,double price,color clr){ 
       
      if( ObjectFind(name) < 0){
         HLineCreate(0,name,0,price,clr,0,1,true); return true;
      }else{
         HLineMove(0,name,price,clr); return true;
      } 
      return false;
  } 
   bool HLineMove(const long   chart_ID=0,   // chart's ID
                  const string name="HLine", // line name
                  double       price=0,      // line price
                  color        clr = clrWhite)     // color 
     { 
      if(!price)
         price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
      ResetLastError(); 
      if(!ObjectMove(chart_ID,name,0,0,price))
        {
         Print(__FUNCTION__,
               ": failed to move the horizontal line! Error code = ",GetLastError());
         return(false);
        } 
        ObjectSet(name, OBJPROP_COLOR, clr);    
      return(true);
     } 
   bool HLineCreate(const long            chart_ID=0,        // chart's ID
                    const string          name="HLine",      // line name
                    const int             sub_window=0,      // subwindow index
                    double                price=0,           // line price
                    const color           clr=clrRed,        // line color
                    const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                    const int             width=1,           // line width
                    const bool            back=false,        // in the background
                    const bool            selection=true,    // highlight to move
                    const bool            hidden=true,       // hidden in the object list
                    const long            z_order=0)         // priority for mouse click
     { 
      if(!price)
         price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
      ResetLastError(); 
      if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
        {
         Print(__FUNCTION__,
               ": failed to create a horizontal line! Error code = ",GetLastError());
         return(false);
        } 
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
      ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
      ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
      ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
      ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
      return(true);
     } 
   void Util_ArrayAddDouble(double & arr[],double value){ 
      ArrayResize(arr,(ArraySize(arr)+1));
      arr[(ArraySize(arr)-1)] = value; 
   } 
   
     void Util_ArrayAddString(string & arr[],string value){ 
      ArrayResize(arr,(ArraySize(arr)+1));
      arr[(ArraySize(arr)-1)] = value; 
   } 
     void Util_ArrayAddInt(int & arr[],int value){ 
      ArrayResize(arr,(ArraySize(arr)+1));
      arr[(ArraySize(arr)-1)] = value; 
   } 
   
   
   
int Util_OpenOrderWithSLTP(string _symbol, int cmd, double lot,double tp,double sl,string comment)
{ 
    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;
    //double sl = 0;
    //double tp = 0;
    double _symbol_Point = MarketInfo(_symbol,MODE_POINT);
    int _symbol_Digits = ((int)MarketInfo(_symbol,MODE_DIGITS));
    /*if(cmd == OP_BUY){ 
      sl = NormalizeDouble(price-700*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price+1000*_symbol_Point,_symbol_Digits);
    }else{
      sl = NormalizeDouble(price+700*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price-1000*_symbol_Point,_symbol_Digits);
    }*/
    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 10, sl, tp, comment, 0, 0, clrGreen);  
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