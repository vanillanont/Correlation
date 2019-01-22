//+------------------------------------------------------------------+
//|                                                  Golden Gate.mq4 |
//|                                          Bo Bazooka,Vanillanont. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Bo Bazooka,Vanillanont."
#property link      "https://www.metatrader4.com/"
#property version   "1.00"
#property strict 

extern double Center_price = 1250.00;
extern double Buy_price = 0.01;
extern int Buy_Distance = 1000;
extern int Buy_Order_Maximum = 10;
extern double Sell_price = 0.01; 
extern int Sell_Distance = 1000;
extern int Sell_Order_Maximum = 10;
extern double Tp_price_minimum = 10.00; // USD;
int AcceptOpen = 5;
int Latest_Buy_Order = 0;
int Latest_Sell_Order = 0;
double Arr_Buy_Price[];
double Arr_Sell_Price[];
bool Arr_Buy_Open[];
bool Arr_Sell_Open[];
int Arr_CloseTicket[];
double topLossBuy = 0;
double topLossSell = 0;
   int OnInit()
   {     
    ArrayResize(Arr_Buy_Price,Buy_Order_Maximum);
    ArrayResize(Arr_Sell_Price,Sell_Order_Maximum);
    ArrayResize(Arr_Buy_Open,Buy_Order_Maximum);
    ArrayResize(Arr_Sell_Open,Sell_Order_Maximum);
    int Buy_Step = Util_PriceNoDigit(Center_price);
    for(int i = 0; i < Buy_Order_Maximum; i++){
      Buy_Step -= Buy_Distance;
      Arr_Buy_Price[i] = Buy_Step/(double)Util_DivideDigit(); 
    }
    int Sell_Step = Util_PriceNoDigit(Center_price);
    for(int i = 0; i < Sell_Order_Maximum;i++){
      Sell_Step += Sell_Distance;
      Arr_Sell_Price[i] = Sell_Step/(double)Util_DivideDigit();  
    } 
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
   
   void Rebind()
   {    
       Latest_Sell_Order = -1;
       Latest_Buy_Order = -1;
       for(int i = 0; i < ArraySize(Arr_Buy_Open); i++){
         Arr_Buy_Open[i] = false;
       }
       for(int i = 0; i < ArraySize(Arr_Sell_Open); i++){
         Arr_Sell_Open[i] = false;
       }
       double lossBuy = 0;
       double lossSell =0;
       for (int i = 0; i < OrdersTotal(); i++)
       {
          if (OrderSelect(i, SELECT_BY_POS) == true)
          {  
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){ 
               if(StringFind(OrderComment(),"GG_",0) >= 0){
                  string result[];
                  Util_Split(OrderComment(),"_",result);
                  if(result[1] == "S"){
                     lossSell += OrderProfit()+OrderCommission()+OrderSwap();
                     if(ArraySize(Arr_Sell_Open) >= (int)result[2]){
                        Arr_Sell_Open[((int)result[2]-1)] = true;
                     } 
                     if((int)result[2] > Latest_Sell_Order){
                        Latest_Sell_Order = (int)result[2];
                     }
                  }
                   if(result[1] == "B"){
                      lossBuy += OrderProfit()+OrderCommission()+OrderSwap();
                      if(ArraySize(Arr_Buy_Open) >= (int)result[2]){
                        Arr_Buy_Open[((int)result[2]-1)] = true;
                      }
                      if((int)result[2] > Latest_Buy_Order){
                        Latest_Buy_Order = (int)result[2]; 
                     }
                  }
               }
            }
          }
       }
       if(lossBuy < topLossBuy){
         topLossBuy = lossBuy;
       }
       if(lossSell < topLossSell){
         topLossSell = lossSell;
       }
       Comment("Top Loss Buy : "+ topLossBuy+" / Top Loss Sell : "+topLossSell);
   }
   
   void OnTick()
   {  
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
      }    
      Rebind();
      
      if(Util_IsNewBar(PERIOD_CURRENT)){
         for(int i = 0; i < ArraySize(Arr_Sell_Price); i++){
            string LineName = "BuyPoint_"+IntegerToString(i+1);
            SetHLine(LineName,Arr_Sell_Price[i],clrRed); 
         }
         for(int i = 0; i < ArraySize(Arr_Buy_Price); i++){
            string LineName = "SellPoint_"+IntegerToString(i+1);
            SetHLine(LineName,Arr_Buy_Price[i],clrBlue); 
         }
      }
      
      double price = (MathAbs(Ask+Bid)/2);
      if(price > Center_price){ // Sell
         for(int i = 0; i < ArraySize(Arr_Sell_Price); i++){ 
            bool isReady = isOrderReady(Bid,Arr_Sell_Price[i],"d");  
            if(isReady && Arr_Sell_Open[i] == false){
               Util_OpenOrder(Symbol(),OP_SELL,Sell_price,"GG_S_"+IntegerToString(i+1));
               break;
            } 
            //int current_index = (i+1);
            //if(isReady && current_index > Latest_Sell_Order){
            //   Util_OpenOrder(Symbol(),OP_SELL,Sell_price,"GG_S_"+IntegerToString(i+1));
            //   break;
            //}
         }
      }
      if(price < Center_price){ // Buy
         for(int i = 0; i < ArraySize(Arr_Buy_Price); i++){ 
            bool isReady = isOrderReady(Ask,Arr_Buy_Price[i]);
            if(isReady && Arr_Buy_Open[i] == false){
               Util_OpenOrder(Symbol(),OP_BUY,Buy_price,"GG_B_"+IntegerToString(i+1));
               break;
            }
            //int current_index = (i+1);
            //if(isReady && current_index > Latest_Buy_Order){
            //   Util_OpenOrder(Symbol(),OP_BUY,Buy_price,"GG_B_"+IntegerToString(i+1));
            //   break;
            //}
         }
      }  
      prepareClose();    
   }
   
   void prepareClose(){
     string CloseAt = ichimokuCheck();
     if(CloseAt != ""){
      Print(CloseAt); 
     }
       if(CloseAt == "BUY"){
          for (int i = 0; i < OrdersTotal(); i++)
          {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {  
               if(OrderType() == OP_SELL){ 
                  if(StringFind(OrderComment(),"GG_",0) >= 0){
                     double orderProfit = (OrderProfit() + OrderSwap() + OrderCommission()); 
                     if(orderProfit > Tp_price_minimum){ 
                        Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                     }
                  }
               }
             }
          }         
       }
       
       if(CloseAt == "SELL"){
          for (int i = 0; i < OrdersTotal(); i++)
          {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {  
               if(OrderType() == OP_BUY){ 
                  if(StringFind(OrderComment(),"GG_",0) >= 0){
                     double orderProfit = (OrderProfit() + OrderSwap() + OrderCommission()); 
                     if(orderProfit > Tp_price_minimum){ 
                        Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                     }
                  }
               }
             }
          }         
       }
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
   
     void Util_ArrayAddString(string & arr[],string value){ 
      ArrayResize(arr,(ArraySize(arr)+1));
      arr[(ArraySize(arr)-1)] = value; 
   } 
     void Util_ArrayAddInt(int & arr[],int value){ 
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



bool Util_CloseOrder(int ticket)
{
        bool iSuccess = false;
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
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
    }
    int fnError = GetLastError();
    if(fnError > 0){
      Print("Error function closeOrder: ",fnError," Ticket: ",ticket);
      ResetLastError();
    }
    return iSuccess;
}

void Util_Split(string text,string split,string & results[]){
   StringSplit(text,StringGetCharacter(split,0),results);
   int fnError = GetLastError();
   if(fnError > 0){ 
     // Print("Error function Split: ",fnError," - ",text);  
     // ResetLastError();
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

string ichimokuCheck(){
   string result = "";
   double PRICE = (Ask+Bid)/2;
   double TENKANSEN = iIchimoku(Symbol(),PERIOD_D1,5,5,5,MODE_TENKANSEN,0);
   double KIJUNSEN = iIchimoku(Symbol(),PERIOD_D1,5,5,5,MODE_KIJUNSEN,0);
   double SENKOUSPANA = iIchimoku(Symbol(),PERIOD_D1,5,5,5,MODE_SENKOUSPANA,0);
   double SENKOUSPANB = iIchimoku(Symbol(),PERIOD_D1,5,5,5,MODE_SENKOUSPANB,0);
   double CHIKOUSPAN = iIchimoku(Symbol(),PERIOD_D1,5,5,5,MODE_CHIKOUSPAN,0);
   
   /*
   if(PRICE < TENKANSEN &&
      PRICE < KIJUNSEN &&
      PRICE < SENKOUSPANA &&
      PRICE < SENKOUSPANB &&
      PRICE < CHIKOUSPAN){
         result = "SELL";
      } 
      
   if(PRICE > TENKANSEN &&
      PRICE > KIJUNSEN &&
      PRICE > SENKOUSPANA &&
      PRICE > SENKOUSPANB &&
      PRICE > CHIKOUSPAN){
         result = "BUY";
      }
     */
        
   if(PRICE < TENKANSEN &&
      PRICE < KIJUNSEN &&
      PRICE < SENKOUSPANB
      ){
         result = "SELL";
      } 
      
   if(PRICE > TENKANSEN &&
      PRICE > KIJUNSEN &&
      PRICE > SENKOUSPANB 
      ){
         result = "BUY";
      }
   return result;
}

