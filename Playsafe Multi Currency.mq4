//+------------------------------------------------------------------+
//|                                        Profit Multi Currency.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict
//--- input parameters 
extern string Symbols_01 = "GBPUSD,GBPCHF,GBPJPY,GBPCAD,GBPAUD,GBPNZD";
extern string Symbols_02 = ",NZDUSD,NZDCHF,NZDJPY,NZDCAD,AUDNZD";
extern string Symbols_03 = ",EURUSD,EURJPY,EURCHF,EURCAD";
extern string Symbols_04 = ",USDJPY,USDCHF,USDCAD";
extern string Symbols_05 = ",CHFJPY,CADCHF";
extern string Symbols_06 = ",CADJPY";
extern int Total_Allow_Resolve = 20;
  
int Arr_Percent_Pass[];


// new 
string Arr_Symbols[]; 
double Arr_Percent_Buy[];
double Arr_Percent_Sell[];
double Arr_Percent[]; 
double Arr_Percent_Buy_Day[];
double Arr_Percent_Sell_Day[];
double Arr_Percent_Day[];
bool Arr_Is_Run[];
// new 

int Size = 0; 
double Tp_Size = 0;
double Loss_Acceptable = 0; 
int Correct_Percent = 100;
bool Hold = false;
int OrderBuy = 0;
int OrderSell = 0;
bool test = false; 
string Symbols_All = "";


void InitSymbols(){ 
   // new
   Symbols_All += Symbols_01;
   Symbols_All += Symbols_02;
   Symbols_All += Symbols_03;
   Symbols_All += Symbols_04;
   Symbols_All += Symbols_05; 
   Symbols_All += Symbols_06;  
   Util_Split(Symbols_All,",",Arr_Symbols);
   Size = ArraySize(Arr_Symbols);  
   ArrayResize(Arr_Percent_Buy,Size);
   ArrayResize(Arr_Percent_Sell,Size);  
   ArrayResize(Arr_Percent_Buy_Day,Size);
   ArrayResize(Arr_Percent_Sell_Day,Size); 
   ArrayResize(Arr_Is_Run,Size);   
   ArrayResize(Arr_Percent,2);
   ArrayResize(Arr_Percent_Day,2);
      
   
   for(int i = 0 ;i < Size ;i++){
      Arr_Is_Run[i] = true;
   }
   
   // new 
    
}

int OnInit()
  {                    
   InitSymbols();
   Rebind();       
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  { 
   ObjectsDeleteAll();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{    

    Rebind();   
    if(Util_IsNewBar(PERIOD_M15)){
      Hold = false;
    } 
    
   // new 
      for(int i = 0; i < Size; i++){
          
         string Symbols = Arr_Symbols[i];
         double PercentBuy = 0;
         double PercentSell = 0;
         int TotalOrder = 0;
         
            int Order_ID = 0;
            double Lot_Size = 0;
            Arr_Percent[0] = 0;
            Arr_Percent[1] = 0;
            //Arr_Percent_Buy[
            OpenCondition(Symbols,PERIOD_H1,10,34,9,Arr_Percent); 
            Arr_Percent_Buy[i] = Arr_Percent[0];
            Arr_Percent_Sell[i] = Arr_Percent[1];  
            OpenCondition(Symbols,PERIOD_D1,10,34,9,Arr_Percent_Day); 
            Arr_Percent_Buy_Day[i] = Arr_Percent_Day[0];
            Arr_Percent_Sell_Day[i] = Arr_Percent_Day[1];  
          for (int n = 0; n < OrdersTotal(); n++)
          {
             if (OrderSelect(n, SELECT_BY_POS) == true)
             {   
               if(OrderSymbol() == Symbols){
                  if(StringFind(OrderComment(),"PS_",0) == 0){
                     string arr_Percent[]; 
                     Util_Split(OrderComment(),"_",arr_Percent);
      
                     if(OrderType() == OP_BUY){   
                       if(((double)arr_Percent[1]) > PercentBuy){
                          PercentBuy = ((double)OrderComment());
                       } 
                     }
                     
                     if(OrderType() == OP_SELL){ 
                        if(((double)arr_Percent[1]) > PercentSell){
                           PercentSell = ((double)OrderComment());
                        }
                     } 
                     TotalOrder++;
                  }
               }
             } 
          } 
            
           if(TotalOrder < Total_Allow_Resolve && isPlayTime() && Arr_Is_Run[i] == true)
           {
            if(Arr_Percent[0] >= Correct_Percent && Arr_Percent[0] > PercentBuy && Arr_Percent_Day[0] > 70){
               //buy
               //if(Arr_Result_Check[0] > 50){
                  Lot_Size = (AccountBalance()*0.00001)*5;//(Arr_Percent[0]/(AccountBalance()*(double)10));
                  Lot_Size = Lot_Size < 0.01 ? 0.01 : Lot_Size;
                  Order_ID = Util_OpenOrderWithSLTP(Symbols,OP_BUY,Lot_Size,"PS_"+DoubleToString(Arr_Percent[0],0));
                  if(Order_ID > 0){
                     Hold = true;
                  }
               //} 
             }
             if(Arr_Percent[1] >= Correct_Percent && Arr_Percent[1] > PercentSell && Arr_Percent_Day[1] > 70){
               //sell
               //if(Arr_Result_Check[1] > 50){
                  Lot_Size = (AccountBalance()*0.00001)*5;//(Arr_Percent[0]/(AccountBalance()*(double)10));
                  //Lot_Size = (Arr_Percent[1]/(AccountBalance()*(double)10));
                  Lot_Size = Lot_Size < 0.01 ? 0.01 : Lot_Size;
                  Order_ID = Util_OpenOrderWithSLTP(Symbols,OP_SELL,Lot_Size,"PS_"+DoubleToString(Arr_Percent[1],0));
                  if(Order_ID > 0){
                     Hold = true;
                  }
               //}
             }  
          }
      }
   // new  
    if(isPlayTime() == false){
        for (int i = 0; i < OrdersTotal(); i++)
        {
          if (OrderSelect(i, SELECT_BY_POS) == true)
          {     
            if(StringFind(OrderComment(),"PS_",0) == 0){ 
               double profit = (OrderProfit() + OrderSwap() + OrderCommission()); 
               if(profit > 0){
                  Util_CloseOrder(OrderTicket());
               }
            }
          }
        }      
    }
   // Change_TPSL();  
    GenInterface();
    
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- 
      if(id==CHARTEVENT_OBJECT_CLICK) { 
         long z=ObjectGetInteger(0,sparam,OBJPROP_ZORDER); 
         for(int i = 0; i < Size; i++){ 
            string lbl_Is_Run = "lbl_Is_Run_"+IntegerToString(i);  
            if(sparam == lbl_Is_Run){
               Arr_Is_Run[i] = (Arr_Is_Run[i] == true) ? false : true; 
            }   
         }
      } 
  }
//+------------------------------------------------------------------+


 
void Rebind(){
/*
    OrderBuy = 0;
    OrderSell = 0;
    int total = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    { 
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
          if(StringFind(OrderComment(),"PS_",0) == 0){
             if(OrderSymbol() == Symbol_Focus){
                if(OrderType() == OP_BUY){ 
                  OrderBuy++;
                }
                if(OrderType() == OP_SELL){ 
                  OrderSell++;
                } 
             }
             total++;
          }
       } 
    } 
    ArrayResize(Arr_Percent_Pass,total);
    */
}
 
void OpenCondition_BK(string symbol,int period,int fast,int slow,int signal,double & results[])
{  
         double buyPercent = 0;
         double sellPercent = 0; 
         int divider = 0; 
         for(int n = 0; n < Size; n++){
            
            string test2 = Arr_Symbols[n];
            if(symbol != test2){ 
             
               string Symbols_Main_Way = "";
               string Symbols_Hedge_Way = "";
               double MAIN_MACD_MAIN = 0;
               double MAIN_MACD_SIGNAL = 0;
               double HEDGE_MACD_MAIN = 0;
               double HEDGE_MACD_SIGNAL = 0;
                
               string MainCurrency = StringSubstr(test2,0,3); 
               string HedgeCurrency = StringSubstr(test2,3,3);  
               if(StringFind(symbol,MainCurrency,0) == 0)
               { 
                  MAIN_MACD_MAIN = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
                  MAIN_MACD_SIGNAL = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0); 
                  
                  Symbols_Main_Way = MAIN_MACD_MAIN > MAIN_MACD_SIGNAL ? "BUY" : "SELL";
                  if(Symbols_Main_Way == "BUY"){
                     buyPercent += 50;
                     if(MAIN_MACD_SIGNAL > 0){
                        buyPercent += 50;
                     }else{
                        buyPercent += 25;
                     }
                  }else{
                     sellPercent += 50;
                     if(MAIN_MACD_SIGNAL < 0){
                        sellPercent += 50;
                     }else{
                        sellPercent += 25;
                     }
                  }
                  divider++;
               }
               if(StringFind(symbol,MainCurrency,0) == 3)
               { 
                  MAIN_MACD_MAIN = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
                  MAIN_MACD_SIGNAL = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
                  
                  Symbols_Main_Way = MAIN_MACD_MAIN > MAIN_MACD_SIGNAL ? "SELL" : "BUY";
                  if(Symbols_Main_Way == "BUY"){
                     sellPercent += 50;
                     if(MAIN_MACD_SIGNAL > 0){
                        sellPercent += 50;
                     }else{
                        sellPercent += 25;
                     }
                  }else{
                     buyPercent += 50;
                     if(MAIN_MACD_SIGNAL < 0){
                        buyPercent += 50;
                     }else{
                        buyPercent += 25;
                     }
                  }
                  divider++;
               }
               if(StringFind(symbol,HedgeCurrency,0) == 0)
               { 
                  HEDGE_MACD_MAIN = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
                  HEDGE_MACD_SIGNAL = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
                   
                  Symbols_Hedge_Way = HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL ? "BUY" : "SELL";
                  if(Symbols_Hedge_Way == "BUY"){
                     sellPercent += 50;
                     if(HEDGE_MACD_SIGNAL > 0){
                        sellPercent += 50;
                     }else{
                        sellPercent += 25;
                     }
                  }else{
                     buyPercent += 50;
                     if(HEDGE_MACD_SIGNAL < 0){
                        buyPercent += 50;
                     }else{
                        buyPercent += 25;
                     }
                  }
                  divider++;
               }
               if(StringFind(symbol,HedgeCurrency,0) == 3)
               {   
                  HEDGE_MACD_MAIN = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
                  HEDGE_MACD_SIGNAL = iMACD(test2,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0); 
                  
                  Symbols_Hedge_Way = HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL ? "SELL" : "BUY"; 
                  if(Symbols_Hedge_Way == "BUY"){
                     buyPercent += 50;
                     if(HEDGE_MACD_SIGNAL > 0){
                        buyPercent += 50;
                     }else{
                        buyPercent += 25;
                     }
                  }else{
                     sellPercent += 50;
                     if(HEDGE_MACD_SIGNAL < 0){
                        sellPercent += 50;
                     }else{
                        sellPercent += 25;
                     }
                  }
                  divider++;
               }
                
            } 
         } 
   buyPercent = buyPercent/(double)divider;
   sellPercent = sellPercent/(double)divider;
   results[0] = buyPercent;
   results[1] = sellPercent;
}



void OpenCondition(string symbol,int period,int fast,int slow,int signal,double & results[])
{  
         double buyPercent = 0;
         double sellPercent = 0; 
         int divider = 0; 
         for(int n = 0; n < Size; n++){
            
            string test2 = Arr_Symbols[n];
            if(symbol != test2){ 
             
               string Symbols_Main_Way = "";
               string Symbols_Hedge_Way = "";
               double MAIN_MACD_MAIN = 0;
               double MAIN_MACD_SIGNAL = 0;
               double HEDGE_MACD_MAIN = 0;
               double HEDGE_MACD_SIGNAL = 0;
                
               string MainCurrency = StringSubstr(test2,0,3); 
               string HedgeCurrency = StringSubstr(test2,3,3);  
               if(StringFind(symbol,MainCurrency,0) == 0)
               { 
                  MAIN_MACD_MAIN = (MarketInfo(test2,MODE_ASK)+MarketInfo(symbol,MODE_BID)) / 2; 
                  MAIN_MACD_SIGNAL = iOpen(test2,period,0);
                  Symbols_Main_Way = MAIN_MACD_MAIN > MAIN_MACD_SIGNAL ? "BUY" : "SELL";
                  if(Symbols_Main_Way == "BUY"){
                     buyPercent += 100; 
                  }else{
                     sellPercent += 100; 
                  }
                  divider++;
               }
               if(StringFind(symbol,MainCurrency,0) == 3)
               {  
                  MAIN_MACD_MAIN = (MarketInfo(test2,MODE_ASK)+MarketInfo(symbol,MODE_BID)) / 2; 
                  MAIN_MACD_SIGNAL = iOpen(test2,period,0);
                  Symbols_Main_Way = MAIN_MACD_MAIN > MAIN_MACD_SIGNAL ? "SELL" : "BUY";
                  if(Symbols_Main_Way == "BUY"){
                     sellPercent += 100; 
                  }else{
                     buyPercent += 100; 
                  }
                  divider++; 
               }
               if(StringFind(symbol,HedgeCurrency,0) == 0)
               { 
                  HEDGE_MACD_MAIN = (MarketInfo(test2,MODE_ASK)+MarketInfo(symbol,MODE_BID)) / 2; 
                  HEDGE_MACD_SIGNAL = iOpen(test2,period,0); 
                  Symbols_Hedge_Way = HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL ? "BUY" : "SELL";
                  if(Symbols_Hedge_Way == "BUY"){
                     sellPercent += 100; 
                  }else{
                     buyPercent += 100;
                  }
                  divider++;
               }
               if(StringFind(symbol,HedgeCurrency,0) == 3)
               {    
                  HEDGE_MACD_MAIN = (MarketInfo(test2,MODE_ASK)+MarketInfo(symbol,MODE_BID)) / 2; 
                  HEDGE_MACD_SIGNAL = iOpen(test2,period,0); 
                  Symbols_Hedge_Way = HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL ? "SELL" : "BUY"; 
                  if(Symbols_Hedge_Way == "BUY"){
                     buyPercent += 100;
                  }else{
                     sellPercent += 100;
                  }
                  divider++;
               }
                
            } 
         } 
   buyPercent = buyPercent/(double)divider;
   sellPercent = sellPercent/(double)divider;
   results[0] = buyPercent;
   results[1] = sellPercent;
}




void Change_TPSL(){ 

   int n = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {    
         bool isFiftyPercent = false;
         bool isEightyPercent = false; 
          bool isSuccess = false;
            if(StringFind(OrderComment(),"PS_",0) == 0){ 
                double ChangePriceFifty = 0;
                double ChangeSLFifty = 0;
                double ChangePriceEighty = 0;
                double ChangeSLEighty = 0;
                     
                double _symbol_Point = MarketInfo(OrderSymbol(),MODE_POINT);
                int _symbol_Digits = ((int)MarketInfo(OrderSymbol(),MODE_DIGITS));
                if(OrderType() == OP_BUY){ 
                  ChangePriceFifty = NormalizeDouble(OrderOpenPrice()+500*_symbol_Point,_symbol_Digits);
                  ChangeSLFifty = NormalizeDouble(OrderOpenPrice()+50*_symbol_Point,_symbol_Digits);
                  
                  ChangePriceEighty =  NormalizeDouble(OrderOpenPrice()+900*_symbol_Point,_symbol_Digits);
                  ChangeSLEighty = NormalizeDouble(OrderOpenPrice()+50*_symbol_Point,_symbol_Digits);
                }else{
                  ChangePriceFifty = NormalizeDouble(OrderOpenPrice()-500*_symbol_Point,_symbol_Digits);
                  ChangeSLFifty = NormalizeDouble(OrderOpenPrice()-50*_symbol_Point,_symbol_Digits);
                  
                  ChangePriceEighty =  NormalizeDouble(OrderOpenPrice()-900*_symbol_Point,_symbol_Digits);
                  ChangeSLEighty = NormalizeDouble(OrderOpenPrice()-50*_symbol_Point,_symbol_Digits);
                }  
               if(OrderType() == OP_BUY){     
                  if(MarketInfo(OrderSymbol(),MODE_ASK) >= ChangePriceFifty && MarketInfo(OrderSymbol(),MODE_ASK) < ChangePriceEighty){
                     //isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLFifty,OrderTakeProfit(),0,clrNONE);                  
                  }     
                  if(MarketInfo(OrderSymbol(),MODE_ASK) >= ChangePriceFifty && MarketInfo(OrderSymbol(),MODE_ASK) >= ChangePriceEighty){
                     isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLEighty,OrderTakeProfit(),0,clrNONE);                   
                  }                    
               }
               
               if(OrderType() == OP_SELL){  
                  if(MarketInfo(OrderSymbol(),MODE_BID) <= ChangePriceFifty && MarketInfo(OrderSymbol(),MODE_BID) > ChangePriceEighty){ 
                     //isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLFifty,OrderTakeProfit(),0,clrNONE); 
                  } 
                  if(MarketInfo(OrderSymbol(),MODE_BID) <= ChangePriceFifty && MarketInfo(OrderSymbol(),MODE_BID) <= ChangePriceEighty){
                     isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLEighty,OrderTakeProfit(),0,clrNONE);        
                  } 
               } 
               
               n++;
           }
       } 
    }
    
}
 
 
 
 
void GenInterface()
{  

   int y = 40;  
   
    for(int i = 0; i< Size; i++){
      string Symbols = Arr_Symbols[i];
      double Buy_Percent = Arr_Percent_Buy[i];
      double Sell_Percent = Arr_Percent_Sell[i];
      double Buy_Percent_Day = Arr_Percent_Buy_Day[i];
      double Sell_Percent_Day = Arr_Percent_Sell_Day[i];
    
      string lbl_Symbols_ = "lbl_Symbols_"+IntegerToString(i);
      string lbl_Buy_Percent = "lbl_Buy_Percent_"+IntegerToString(i);
      string lbl_Sell_Percent = "lbl_Sell_Percent_"+IntegerToString(i);
      string lbl_Is_Run = "lbl_Is_Run_"+IntegerToString(i);
      string lbl_Buy_Percent_Day = "lbl_Buy_Percent_Day_"+IntegerToString(i);
      string lbl_Sell_Percent_Day = "lbl_Sell_Percent_Day_"+IntegerToString(i);
      
      string Is_Run_Text = "Y";
      if(Arr_Is_Run[i] == false){
         Is_Run_Text = "N";
      } 
       if(ObjectFind(lbl_Symbols_) < 0){   
         Util_LabelCreate(0,lbl_Symbols_,0,20,y,CORNER_LEFT_UPPER,Symbols,"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_Buy_Percent,0,90,y,CORNER_LEFT_UPPER,DoubleToString(Buy_Percent,2),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_Sell_Percent,0,140,y,CORNER_LEFT_UPPER,DoubleToString(Sell_Percent,2),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_Buy_Percent_Day,0,220,y,CORNER_LEFT_UPPER,DoubleToString(Buy_Percent_Day,2),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_Sell_Percent_Day,0,270,y,CORNER_LEFT_UPPER,DoubleToString(Sell_Percent_Day,2),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_Is_Run,0,190,y,CORNER_LEFT_UPPER,Is_Run_Text,"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
       }else{ 
         ObjectSetString(0,lbl_Buy_Percent,OBJPROP_TEXT,DoubleToString(Buy_Percent,2));
         ObjectSetString(0,lbl_Sell_Percent,OBJPROP_TEXT,DoubleToString(Sell_Percent,2));
         ObjectSetString(0,lbl_Buy_Percent_Day,OBJPROP_TEXT,DoubleToString(Buy_Percent_Day,2));
         ObjectSetString(0,lbl_Sell_Percent_Day,OBJPROP_TEXT,DoubleToString(Sell_Percent_Day,2));
         ObjectSetString(0,lbl_Is_Run,OBJPROP_TEXT,Is_Run_Text);
         
         if(Buy_Percent >= Correct_Percent){
            ObjectSetInteger(0,lbl_Buy_Percent,OBJPROP_COLOR,clrBlue);
         }else{
            ObjectSetInteger(0,lbl_Buy_Percent,OBJPROP_COLOR,clrWhite); 
         }
         
         if(Sell_Percent >= Correct_Percent){
            ObjectSetInteger(0,lbl_Sell_Percent,OBJPROP_COLOR,clrRed);
         }else{
            ObjectSetInteger(0,lbl_Sell_Percent,OBJPROP_COLOR,clrWhite); 
         } 
         
         if(Buy_Percent_Day >= 70){
            ObjectSetInteger(0,lbl_Buy_Percent_Day,OBJPROP_COLOR,clrBlue);
         }else{
            ObjectSetInteger(0,lbl_Buy_Percent_Day,OBJPROP_COLOR,clrWhite); 
         }
         
         if(Sell_Percent_Day >= 70){
            ObjectSetInteger(0,lbl_Sell_Percent_Day,OBJPROP_COLOR,clrRed);
         }else{
            ObjectSetInteger(0,lbl_Sell_Percent_Day,OBJPROP_COLOR,clrWhite); 
         }
         
       }  
      y += 21;
    }
  
   
}



bool isPlayTime(){
   bool isPlay = false;
   MqlDateTime dt;
   TimeCurrent(dt); 
   int time = dt.hour; 
   if(DayOfWeek() == 1) // Monday
   {
      if(time > 0){
         isPlay = true;
      }
   } 
   
   if(DayOfWeek() == 2 || DayOfWeek() == 3 || DayOfWeek() == 4) // Monday
   { 
      isPlay = true; 
   } 
   
   if(DayOfWeek() == 5) // Friday
   {   
      if(time < 22){
         isPlay = true;
      } 
   }
   return isPlay;
}
    
     
//////// UTILITIES ///////////
 

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


int Util_OpenOrderWithSLTP(string _symbol, int cmd, double lot,string comment)
{ 
    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;
    double sl = 0;
    double tp = 0;
    double _symbol_Point = MarketInfo(_symbol,MODE_POINT);
    int _symbol_Digits = ((int)MarketInfo(_symbol,MODE_DIGITS));
    if(cmd == OP_BUY){ 
      sl = NormalizeDouble(price-100*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price+100*_symbol_Point,_symbol_Digits);
    }else{
      sl = NormalizeDouble(price+100*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price-100*_symbol_Point,_symbol_Digits);
    } 
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
   
void Util_Split(string text,string split,string & results[]){
   StringSplit(text,StringGetCharacter(split,0),results);
   int fnError = GetLastError();
   if(fnError > 0){ 
     // Print("Error function Split: ",fnError," - ",text);  
     // ResetLastError();
   }
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


bool Util_LabelCreate(const long         chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
      //--- set label coordinates
      
         ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
         ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
         ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
      //--- set the chart's corner, relative to which point coordinates are defined
         ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
      //--- set the text
         ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
      //--- set text font
         ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
      //--- set font size
         ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
      //--- set the slope angle of the text
         ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
      //--- set anchor type
         ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
      //--- set color
         ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
      //--- display in the foreground (false) or background (true)
         ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
      //--- enable (true) or disable (false) the mode of moving the label by mouse
         ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
         ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
      //--- hide (true) or display (false) graphical object name in the object list
         ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
      //--- set the priority for receiving the event of a mouse click in the chart
         ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
      //--- successful execution
   return(true);
  }
  
//////////////////////////////