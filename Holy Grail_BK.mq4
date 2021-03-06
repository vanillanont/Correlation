//+------------------------------------------------------------------+
//|                                                   Holy Grail.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict 

extern int BarLookUp = 72;
extern int AllowOrders = 1;
double Arr_Resistance[];
double Arr_Support[];
bool Sell_Ready = false;
bool Buy_Ready = false;
bool Sell_Set = false;
bool Buy_Set = false; 
int timeframe = 0;
double lotSize = 0.01;
double multiply = 1;
double AccountBalance_Current = 0;
bool new_bar_H1 = false;
int total_bar_H1 = 0;
bool new_bar_H4 = false;
int total_bar_H4 = 0;
bool new_bar_D1 = false;
int total_bar_D1 = 0;
bool pauseOrder = false;

/////////////////// ENUM ///////////////////
int GREATERTHAN = 0;
int LESSTHAN = 1;
/////////////////// ENUM ///////////////////

int OnInit()
  {   
   AccountBalance_Current = AccountBalance();
   timeframe = PERIOD_CURRENT;   
   ObjectsDeleteAll();  
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
 /*
   lotSize = 0.01;
   multiply = 1;
   if(AccountBalance() < AccountBalance_Current){ 
      multiply += 1; 
      AccountBalance_Current = AccountBalance();
   }else if(AccountBalance() > AccountBalance_Current){
      AccountBalance_Current = AccountBalance();
      multiply = 1;
   }else if(AccountBalance() == AccountBalance_Current){
     
   }else{
      //multiply = 1;
   }
 */
   lotSize = 0.01;
   multiply = 1;
   lotSize = lotSize*multiply; 
   
    for (int i = 0; i < OrdersTotal(); i++)
    {
       if (OrderSelect(i, SELECT_BY_POS) == true)
       { 
         if(OrderType() == OP_SELL){
            if(MathAbs(Util_PriceNoDigit(Ask)-Util_PriceNoDigit(OrderOpenPrice())) > 200 && Ask < OrderOpenPrice()){ 
               double orderTP = OrderTakeProfit();
               double orderSL = ((Util_PriceNoDigit(OrderOpenPrice())-100))/(double)Util_DivideDigit(); 
               if(orderSL != OrderStopLoss()){
                  int ord = OrderModify(OrderTicket(),OrderOpenPrice(),orderSL,orderTP,0,clrBlue);
               }
            }
         }
         
         if(OrderType() == OP_BUY){
            if(MathAbs(Util_PriceNoDigit(Bid)-Util_PriceNoDigit(OrderOpenPrice())) > 200 && Bid > OrderOpenPrice()){
               //double orderTP = ((PriceNoDigit(OrderTakeProfit())+300))/(double)DivideDigit();
               double orderTP = OrderTakeProfit();
               double orderSL = ((Util_PriceNoDigit(OrderOpenPrice())+100))/(double)Util_DivideDigit();
               if(orderSL != OrderStopLoss()){
                  int ord = OrderModify(OrderTicket(),OrderOpenPrice(),orderSL,orderTP,0,clrBlue);
               }
            }
         }
       }
    }
   
   bool newBar = false;
   newBar = Util_IsNewBar(timeframe);
    
   if(newBar){
      ObjectsDeleteAll();  
      pauseOrder = false;
      Buy_Ready = false;
      Buy_Set = false;
      Sell_Ready = false;
      Sell_Set = false;
   }
    
   LoopBars();
   // OPEN / CLOSE 
   if(TotalOrders() < AllowOrders && pauseOrder == false)
   {
      double Buy_Price = Ask;
      double Sell_Price = Bid;
      double previous_open = iOpen(Symbol(),timeframe,1);
      double previous_close = iClose(Symbol(),timeframe,1);
      double previous_low = iLow(Symbol(),timeframe,1);
      double previous_high = iHigh(Symbol(),timeframe,1);
      
      double previous_second_open = iOpen(Symbol(),timeframe,2);
      double previous_second_close = iClose(Symbol(),timeframe,2);
      double previous_second_low = iLow(Symbol(),timeframe,2);
      double previous_second_high = iHigh(Symbol(),timeframe,2);
      
      double previous_third_open = iOpen(Symbol(),timeframe,3);
      double previous_third_close = iClose(Symbol(),timeframe,3);
      double previous_third_low = iLow(Symbol(),timeframe,3);
      double previous_third_high = iHigh(Symbol(),timeframe,3);
      
      if(Buy_Ready == false){
         Buy_Ready = Util_ArrayCondition(Arr_Support,Buy_Price,LESSTHAN); 
      }  
      if(Buy_Ready == true && Buy_Set == false){
         Buy_Set = Util_ArrayCondition(Arr_Support,Buy_Price,GREATERTHAN);
      }
      
      if(Sell_Ready == false){
         Sell_Ready = Util_ArrayCondition(Arr_Resistance,Sell_Price,GREATERTHAN);   
      }
      if(Sell_Ready == true && Sell_Set == false){
         Sell_Set = Util_ArrayCondition(Arr_Resistance,Sell_Price,LESSTHAN);
      } 
      
      
      /*
      Buy_Ready = Util_ArrayCondition(Arr_Support,previous_second_low,LESSTHAN);
      if(Buy_Ready){
         Buy_Set = (Util_ArrayCondition(Arr_Support,previous_second_close,GREATERTHAN) && 
                    Util_isUp(previous_open,previous_close));
         if(Buy_Set == false){
            Buy_Ready = false;
         }           
      }
      Sell_Ready = Util_ArrayCondition(Arr_Resistance,previous_second_high,GREATERTHAN);  
      if(Sell_Ready){
         Sell_Set = (Util_ArrayCondition(Arr_Resistance,previous_second_close,LESSTHAN) && 
                    Util_isDown(previous_open,previous_close));
                    
         if(Sell_Set == false){
            Sell_Ready = false;
         }           
      }
      */
      
      /*
      //if(ArraySize(Arr_Support) >= ArraySize(Arr_Resistance)){
      Bid_Ready = Util_ArrayCondition(Arr_Support,previous_second_low,LESSTHAN);
      //}
      if(Bid_Ready){
         Bid_Set = Util_ArrayCondition(Arr_Support,previous_second_close,GREATERTHAN); 
      }
      //if(ArraySize(Arr_Resistance) >= ArraySize(Arr_Support)){
      Ask_Ready = Util_ArrayCondition(Arr_Resistance,previous_second_high,GREATERTHAN);  
      //}
      if(Ask_Ready){
         Ask_Set = Util_ArrayCondition(Arr_Resistance,previous_second_close,LESSTHAN); 
      }
      */
      
      
      ///////////////////// ready for open order ///////////////////
      
     
      if(Buy_Set){ // READY,SET,[GO] 
         
         double tp = 0;
         double sl = 0; 
            tp = (((Util_PriceNoDigit(Bid)+1000))/(double)Util_DivideDigit()); 
            sl = (((Util_PriceNoDigit(Bid)-1000))/(double)Util_DivideDigit()); 
            Util_OpenOrderWithSLTP(Symbol(),OP_BUY,lotSize,tp,sl,"");
            Buy_Set = false; 
            Buy_Ready = false;
            pauseOrder = true;
      }
      
       if(Sell_Set){ // READY,SET,[GO] 
         double tp = 0;
         double sl = 0;
         
            tp = (((Util_PriceNoDigit(Ask)-1000))/(double)Util_DivideDigit()); 
            sl = (((Util_PriceNoDigit(Ask)+1000))/(double)Util_DivideDigit()); 
            Util_OpenOrderWithSLTP(Symbol(),OP_SELL,lotSize,tp,sl,""); 
            Sell_Set = false; 
            Sell_Ready  = false;
            pauseOrder = true;       
      }
   }
   /////////////////////////////////////////////////////////////   
   // END OPEN / CLOSE
   ArrayFree(Arr_Resistance);
   ArrayFree(Arr_Support);
   
}


void LoopBars(){
   for(int i = BarLookUp; i > 1; i--){
      
      double Resistance = TurningPoint(Symbol(),timeframe,i,OP_BUY);      
      double Support = TurningPoint(Symbol(),timeframe,i,OP_SELL);
      if(Resistance > 0){
         /*if(ArraySize(Arr_Resistance) > 0){
            ArraySort(Arr_Resistance,WHOLE_ARRAY,0,MODE_DESCEND);
            if(Arr_Resistance[0] < Resistance){
               ArrayFree(Arr_Resistance);
               Util_ArrayAddDouble(Arr_Resistance,Resistance);
            }
         }else{
            Util_ArrayAddDouble(Arr_Resistance,Resistance);
         }*/
         Util_ArrayAddDouble(Arr_Resistance,Resistance);
         //SetHLine(LineName,Resistance,clrBlue);
      } 
      if(Support > 0){
         /*if(ArraySize(Arr_Support) > 0){
            ArraySort(Arr_Support,WHOLE_ARRAY,0,MODE_ASCEND);
            if(Arr_Support[0] > Support){
               ArrayFree(Arr_Support);
               Util_ArrayAddDouble(Arr_Support,Support);
            }
         }else{
            Util_ArrayAddDouble(Arr_Support,Support);
         }*/
         Util_ArrayAddDouble(Arr_Support,Support);
       //  LineName = "Support_"+IntegerToString(i);
       //  SetHLine(LineName,Support,clrRed);
      }
   }
   ObjectsDeleteAll();
   string LineName = "";
   for(int i = 0; i < ArraySize(Arr_Resistance);i++){
      LineName = "Resistance_"+IntegerToString(i);
      SetHLine(LineName,Arr_Resistance[i],clrBlue);
   }
   for(int i = 0; i < ArraySize(Arr_Support);i++){
      LineName = "Support_"+IntegerToString(i);
      SetHLine(LineName,Arr_Support[i],clrRed);
   }
}

double TurningPoint(string symbol,int period,int shift,int type){
   double price = 0;
   if(shift <= 3){
    return price;
   }
   
   double previous_second_open = iOpen(symbol,period,(shift+2));
   double previous_second_close = iClose(symbol,period,(shift+2));
   double previous_open = iOpen(symbol,period,(shift+1));
   double previous_close = iClose(symbol,period,(shift+1));
   double current_open = iOpen(symbol,period,shift);
   double current_close = iClose(symbol,period,shift);
   double next_open = iOpen(symbol,period,(shift-1));
   double next_close = iClose(symbol,period,(shift-1));
   double next_second_open = iOpen(symbol,period,(shift-2));
   double next_second_close = iClose(symbol,period,(shift-2));
   
   if(type == OP_BUY){
      if(
         previous_second_open < previous_second_close &&
         previous_open < previous_close &&
         current_open > current_close &&
         //next_open > next_close
         (next_open > next_close || (next_open < next_close && next_close < current_open))
      ){
         price = current_open;
         for(int i = 1; i < shift; i++){
            if(iClose(symbol,period,i) > current_open){
               price = 0;
               break;
            }
         }
      }        
   }
   if(type == OP_SELL){
      if(
         previous_second_open > previous_second_close &&
         previous_open > previous_close &&
         current_open < current_close &&
         //next_open < next_close
         (next_open < next_close || (next_open > next_close && next_close > current_open))
      ){
         price = current_open;
         for(int i = 1; i < shift; i++){
            if(iClose(symbol,period,i) < current_open){
               price = 0;
               break;
            }
         }
      }
   }
   return price;
}




  bool SetHLine(string name,double price,color clr){ 
       
      if( ObjectFind(name) < 0){
         HLineCreate(0,name,0,price,clr); return true;
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
   /*
   new_bar_H1 = false;
   new_bar_H4 = false;
   new_bar_D1 = false;
   if(iBars(Symbol(),PERIOD_H1) > total_bar_H1){
      total_bar_H1 = iBars(Symbol(),PERIOD_H1);
      new_bar_H1 = true;
   }
   if(iBars(Symbol(),PERIOD_H4) > total_bar_H4){
      total_bar_H4 = iBars(Symbol(),PERIOD_H4);
      new_bar_H4 = true;
   } 
   if(iBars(Symbol(),PERIOD_D1) > total_bar_D1){
      total_bar_D1 = iBars(Symbol(),PERIOD_D1);
      new_bar_D1 = true;
   }
   
   if(period == PERIOD_H1){
      return new_bar_H1;
   }
   if(period == PERIOD_H4){
      return new_bar_H4;
   }
   if(period == PERIOD_D1){
      return new_bar_D1;
   }
   return false;
   */
}    
  
bool Util_ArrayCondition(double & arr[],double value,int condition,string comment = ""){
   bool result = false; 
   if(condition == GREATERTHAN){
      for(int i = 0; i < ArraySize(arr); i++){
         if(value > arr[i]){ 
            result = true; 
            break;
         }
      } 
   } 
   if(condition == LESSTHAN){
      for(int i = 0; i < ArraySize(arr); i++){
         if(value < arr[i]){
            //Print("LESSTHAN "+value +" / "+ arr[i]);
            result = true;
            break;
         }
      }
   }
   return result;   
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

bool Util_isUp(double open,double close){
   bool result = false;
   if(open < close){
      result = true;
   }
   return result;
}

bool Util_isDown(double open,double close){
   bool result = false;
   if(open > close){
      result = true;
   }
   return result;
}

int Util_PriceNoDigit(double price){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   return (int)(price*StrToDouble(multiple));   
}

double Util_DivideDigit(){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   return StrToDouble(multiple);
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
