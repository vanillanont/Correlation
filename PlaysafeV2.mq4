//+------------------------------------------------------------------+
//|                                              Profit Playsafe.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict
//--- input parameters
extern string Symbol_Focus = "GBPNZD";
extern string Symbols_Main = "GBPUSD,GBPCHF,GBPJPY,GBPCAD,GBPAUD";
extern string Symbols_Hedge = "NZDUSD,NZDCHF,NZDJPY,NZDCAD,AUDNZD";
extern int Total_Allow_Resolve = 4;

string Arr_Symbols_Main[];
string Arr_Symbols_Hedge[];
string Arr_Symbols_Main_Way[];
string Arr_Symbols_Hedge_Way[];
double result[]; 
int Arr_Percent_Pass[];

int Size = 0; 
double Tp_Size = 0;
double Loss_Acceptable = 0; 
int Correct_Percent = 80;
bool Hold = false;
int OrderBuy = 0;
int OrderSell = 0;
bool test = false;

double Arr_Resistance[];
double Arr_Support[];
int totalOrder = 4;

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
      bool allowOpen = true;
      int total = 0;
      for (int i = 0; i <= (OrdersTotal() - 1); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         {
             if(OrderType() == OP_BUY || OrderType() == OP_SELL){
               total++;
             } 
         }
      }
      if(total >= totalOrder){
         allowOpen = false;
      }
    
    ArrayResize(v1,100);
    ArrayResize(v2,100); 
    ArrayFree(Arr_Resistance);
    ArrayFree(Arr_Support);
        
    for(int i = 30; i > 0 ; i--){
    
       val1 = iFractals(NULL, 0, MODE_UPPER, i);
       //----
       if(val1 > 0) {
           v1[i] = High[i]; SetHLine("HIGH_"+i,v1[i],clrBlueViolet); Util_ArrayAddDouble(Arr_Resistance,v1[i]);
       }else
           v1[i] = v1[i+1];
       val2 = iFractals(NULL, 0, MODE_LOWER, i);
       //----
       if(val2 > 0) {
           v2[i] = Low[i];  SetHLine("LOW_"+i,v2[i],clrOrangeRed); Util_ArrayAddDouble(Arr_Support,v2[i]);
       }else
           v2[i] = v2[i+1]; 
    }
    
    string Direction = "";
    if(ArraySize(Arr_Resistance) >= 4 && ArraySize(Arr_Support) >= 4){
       Comment(Arr_Resistance[(ArraySize(Arr_Resistance)-1)] +"-"+ Arr_Resistance[(ArraySize(Arr_Resistance)-2)]+" / "+Arr_Support[(ArraySize(Arr_Support)-1)]+"-"+Arr_Support[(ArraySize(Arr_Support)-2)] );
       if((Arr_Resistance[(ArraySize(Arr_Resistance)-1)] > Arr_Resistance[(ArraySize(Arr_Resistance)-2)]) && 
          (Arr_Resistance[(ArraySize(Arr_Resistance)-2)] > Arr_Resistance[(ArraySize(Arr_Resistance)-3)]) && 
          (Arr_Support[(ArraySize(Arr_Support)-1)] > Arr_Support[(ArraySize(Arr_Support)-2)]) &&
          (Arr_Support[(ArraySize(Arr_Support)-2)] > Arr_Support[(ArraySize(Arr_Support)-3)])
          ){
         Comment("UP");
         Direction = "UP";
       }
       
       
       if((Arr_Resistance[(ArraySize(Arr_Resistance)-1)] < Arr_Resistance[(ArraySize(Arr_Resistance)-2)]) && 
          (Arr_Resistance[(ArraySize(Arr_Resistance)-2)] < Arr_Resistance[(ArraySize(Arr_Resistance)-3)]) && 
          (Arr_Support[(ArraySize(Arr_Support)-1)] < Arr_Support[(ArraySize(Arr_Support)-2)]) &&
          (Arr_Support[(ArraySize(Arr_Support)-2)] < Arr_Support[(ArraySize(Arr_Support)-3)])
         ){
         Comment("DOWN");
         Direction = "DOWN";
       }
    } 
    
    if(isChangeBar()){
      holdOrder = false;
    }
    double lot = AccountBalance()*0.00001;
    if(lot < 0.01){
      lot = 0.01;
    }
    if(Direction == "UP"){
      for(int i = 0; i < ArraySize(Arr_Support); i++){
         //if(Ask == Arr_Support[i]){
            if(NormalizeDouble(Ask+50*Point,Digits) > Arr_Support[i] && NormalizeDouble(Ask-50*Point,Digits) < Arr_Support[i] && holdOrder == false && allowOpen == true){
               //double arr_result[];
               //Nearest(NormalizeDouble(Ask+1000*Point,Digits),OP_BUY,Arr_Resistance,Arr_Support,arr_result);
               double tp = Nearest(NormalizeDouble(Ask+1000*Point,Digits),OP_BUY,Arr_Resistance);
               double sl = Nearest(NormalizeDouble(Ask-700*Point,Digits),OP_BUY,Arr_Support);
               /*
               if(MathAbs(NormalizeDouble(tp*Point,Digits) - NormalizeDouble(Ask+1000*Point,Digits)) < 500){
                  tp = NormalizeDouble(Ask+1000*Point,Digits);
               }
               if(MathAbs(NormalizeDouble(sl*Point,Digits) - NormalizeDouble(Ask-700*Point,Digits)) < 300){
                  sl = NormalizeDouble(Ask-700*Point,Digits);
               }
               */
               Util_OpenOrderWithSLTP(Symbol(),OP_BUY,lot,tp,sl,"");
               //Util_OpenOrderWithSLTP(Symbol(),OP_BUY,lot,arr_result[0],arr_result[1],"");
               //Util_OpenOrderWithSLTP(Symbol(),OP_BUY,lot,"");
               //sl = NormalizeDouble(price-700*_symbol_Point,_symbol_Digits);
               holdOrder = true;
            }  
         }
      }
    
    
   
    
    if(Direction == "DOWN"){
      for(int i = 0; i < ArraySize(Arr_Resistance); i++){
         //if(Bid == Arr_Resistance[i]){
         if(NormalizeDouble(Bid+50*Point,Digits) < Arr_Resistance[i] && NormalizeDouble(Bid-50*Point,Digits) > Arr_Resistance[i] && holdOrder == false && allowOpen == true){
            //double arr_result[];
            //Nearest(NormalizeDouble(Bid+1000*Point,Digits),OP_SELL,Arr_Resistance,Arr_Support,arr_result);
            double tp = Nearest(NormalizeDouble(Bid-1000*Point,Digits),OP_SELL,Arr_Support);
            double sl = Nearest(NormalizeDouble(Bid+700*Point,Digits),OP_SELL,Arr_Resistance);
            /*
            if(MathAbs(NormalizeDouble(tp*Point,Digits) - NormalizeDouble(Bid+1000*Point,Digits)) < 500){
               tp = NormalizeDouble(Bid+1000*Point,Digits);
            }
         
            if(MathAbs(NormalizeDouble(sl*Point,Digits) - NormalizeDouble(Bid-700*Point,Digits)) < 300){
               sl = NormalizeDouble(Bid-700*Point,Digits);
            }
            */
            Util_OpenOrderWithSLTP(Symbol(),OP_BUY,lot,tp,sl,"");
            //Util_OpenOrderWithSLTP(Symbol(),OP_SELL,lot,arr_result[0],arr_result[1],"");
            //Util_OpenOrderWithSLTP(Symbol(),OP_SELL,lot,"");
            holdOrder = true;
         }
      }
         
    } 
    Comment(holdOrder);
    //if(NormalizeDouble(Ask+10*Point,Digits) > Ask && NormalizeDouble(Ask-10*Point,Digits) < Ask){
    //Comment(NormalizeDouble(Ask+10*Point,Digits) + " - "+Ask+" - "+ NormalizeDouble(Ask-10*Point,Digits));
    //}
    
    
    
}

double Nearest(double price,int order_type,double & arr_Price[]){
   double result = 0;
   if(order_type == OP_BUY){
      double nearest = 9999999;
      for(int i = 0; i < ArraySize(arr_Price); i++){
         double space = MathAbs(price-arr_Price[i]); 
         if(space < nearest){
            nearest = space;
            result = arr_Price[i];
         }
      }
   }
   
   if(order_type == OP_SELL){
      double nearest = 9999999;
      for(int i = 0; i < ArraySize(arr_Price); i++){
         double space = MathAbs(price-arr_Price[i]); 
         if(space < nearest){
            nearest = space;
            result = arr_Price[i];
         }
      }
   }
   return result; 
}

//double NearestSL(double price,int order_type,double & arr_Price[]){
//}

void Nearest(double price,int order_type,double & arr_resistance[],double & arr_support[],double & arr_result[]){
   ArrayResize(arr_result,2);
   if(order_type == OP_BUY){
      double nearest = 9999999;
      for(int i = 0; i < ArraySize(arr_support); i++){
         double space = MathAbs(price-arr_support[i]); 
         if(space < nearest){
            nearest = space;
            arr_result[1] = arr_support[i];
         }
      }
      nearest = 9999999;
      for(int i = 0; i < ArraySize(arr_resistance); i++){
         double space = MathAbs(price-arr_resistance[i]); 
         if(space < nearest){
            nearest = space;
            arr_result[0] = arr_resistance[i];
         }
      }
       
      
   }
   
   if(order_type == OP_SELL){
       double nearest = 9999999;
         for(int i = 0; i < ArraySize(arr_support); i++){
            double space = MathAbs(price-arr_support[i]); 
            if(space < nearest){
               nearest = space;
               arr_result[0] = arr_support[i];
            }
         }
         nearest = 9999999;
         for(int i = 0; i < ArraySize(arr_resistance); i++){
            double space = MathAbs(price-arr_resistance[i]); 
            if(space < nearest){
               nearest = space;
               arr_result[1] = arr_resistance[i];
            }
         }
   } 
   
   Print("TP:"+arr_result[0]+" - SL:"+arr_result[1] );
}

bool holdOrder = false;
int barNo = 0;
bool isChangeBar(){
   if(barNo != iBars(Symbol(),0)){
      barNo = iBars(Symbol(),0);
      return true;
   }
   return false;
}

void Util_ArrayAddDouble(double & arr[],double value){ 
   ArrayResize(arr,(ArraySize(arr)+1));
   arr[(ArraySize(arr)-1)] = value; 
}

double v1[];
double v2[];
double val1;
double val2;
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
      
  }
//+------------------------------------------------------------------+


void InitSymbols(){ 
   Util_Split(Symbols_Main,",",Arr_Symbols_Main);
   Util_Split(Symbols_Hedge,",",Arr_Symbols_Hedge);
   Size = ArraySize(Arr_Symbols_Main);  
   ArrayResize(Arr_Symbols_Main_Way,Size);
   ArrayResize(Arr_Symbols_Hedge_Way,Size);
   ArrayResize(result,2); 
 
}
 
void Rebind(){
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
}



 
void OpenCondition(int period,int fast,int slow,int signal,double & results[])
{ 
   string MainCurrency = StringSubstr(Symbol_Focus,0,3); 
   string HedgeCurrency = StringSubstr(Symbol_Focus,3,3);  
   double buyPercent = 0;
   double sellPercent = 0;
   
   //////////////// for test ///////////////
   if(test == true){ 
      double TEST_MACD_MAIN = iMACD(Symbol_Focus,PERIOD_H1,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double TEST_MACD_SIGNAL = iMACD(Symbol_Focus,PERIOD_H1,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      
       string way = TEST_MACD_MAIN > TEST_MACD_SIGNAL ? "BUY" : "SELL";
         if(way == "BUY"){   
            buyPercent += 50;
            if(TEST_MACD_SIGNAL > 0){
               buyPercent += 50;
            }else{
               buyPercent += 25;
            }
         }else{
            sellPercent += 50;
            if(TEST_MACD_SIGNAL < 0){
               sellPercent += 50;
            }else{
               sellPercent += 25;
            }
         } 
         results[0] = buyPercent;
         results[1] = sellPercent;
         return;
   }
   /////////////// for test ///////////////  
   
   for(int i = 0; i < Size;i++)
   { 
      string test1 = Arr_Symbols_Main[i];
      string test2 = Arr_Symbols_Hedge[i];
      double MAIN_MACD_MAIN = iMACD(Arr_Symbols_Main[i],period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double MAIN_MACD_SIGNAL = iMACD(Arr_Symbols_Main[i],period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      double HEDGE_MACD_MAIN = iMACD(Arr_Symbols_Hedge[i],period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double HEDGE_MACD_SIGNAL = iMACD(Arr_Symbols_Hedge[i],period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      if(MainCurrency == StringSubstr(Arr_Symbols_Main[i],0,3)){
         Arr_Symbols_Main_Way[i] = MAIN_MACD_MAIN > MAIN_MACD_SIGNAL ? "BUY" : "SELL";
         if(Arr_Symbols_Main_Way[i] == "BUY"){
            buyPercent += ((double)0.5/(double)Size)*100;
            if(MAIN_MACD_SIGNAL > 0){
               buyPercent += ((double)0.5/(double)Size)*100;
            }else{
               buyPercent += ((double)0.25/(double)Size)*100;
            }
         }else{
            sellPercent += ((double)0.5/(double)Size)*100;
            if(MAIN_MACD_SIGNAL < 0){
               sellPercent += ((double)0.5/(double)Size)*100;
            }else{
               sellPercent += ((double)0.25/(double)Size)*100;
            }
         }
      }else{ 
         Arr_Symbols_Main_Way[i] = MAIN_MACD_MAIN > MAIN_MACD_SIGNAL ? "SELL" : "BUY";
         if(Arr_Symbols_Main_Way[i] == "BUY"){
            sellPercent += ((double)0.5/(double)Size)*100;
            if(MAIN_MACD_SIGNAL > 0){
               sellPercent += ((double)0.5/(double)Size)*100;
            }else{
               sellPercent += ((double)0.25/(double)Size)*100;
            }
         }else{
            buyPercent += ((double)0.5/(double)Size)*100;
            if(MAIN_MACD_SIGNAL < 0){
               buyPercent += ((double)0.5/(double)Size)*100;
            }else{
               buyPercent += ((double)0.25/(double)Size)*100;
            }
         }
      }
      if(HedgeCurrency == StringSubstr(Arr_Symbols_Hedge[i],0,3)){  
         Arr_Symbols_Hedge_Way[i] = HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL ? "BUY" : "SELL";
         if(Arr_Symbols_Hedge_Way[i] == "BUY"){
            sellPercent += ((double)0.5/(double)Size)*100;
            if(HEDGE_MACD_SIGNAL > 0){
               sellPercent += ((double)0.5/(double)Size)*100;
            }else{
               sellPercent += ((double)0.25/(double)Size)*100;
            }
         }else{
            buyPercent += ((double)0.5/(double)Size)*100;
            if(HEDGE_MACD_SIGNAL < 0){
               buyPercent += ((double)0.5/(double)Size)*100;
            }else{
               buyPercent += ((double)0.25/(double)Size)*100;
            }
         }
      }else{
         Arr_Symbols_Hedge_Way[i] = HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL ? "SELL" : "BUY"; 
         if(Arr_Symbols_Hedge_Way[i] == "BUY"){
            buyPercent += ((double)0.5/(double)Size)*100;
            if(HEDGE_MACD_SIGNAL > 0){
               buyPercent += ((double)0.5/(double)Size)*100;
            }else{
               buyPercent += ((double)0.25/(double)Size)*100;
            }
         }else{
            sellPercent += ((double)0.5/(double)Size)*100;
            if(HEDGE_MACD_SIGNAL < 0){
               sellPercent += ((double)0.5/(double)Size)*100;
            }else{
               sellPercent += ((double)0.25/(double)Size)*100;
            }
         }
      }
   } 
      results[0] = buyPercent/(double)2;
      results[1] = sellPercent/(double)2;
}


void Change_TPSL(){ 
   int n = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    {
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
         if(OrderSymbol() == Symbol_Focus){
         bool isFiftyPercent = false;
         bool isEightyPercent = false; 
          bool isSuccess = false;
            if(StringFind(OrderComment(),"PS_",0) == 0){ 
               double ChangePriceFifty = (OrderOpenPrice()+OrderTakeProfit())/(double)2;
               double ChangeSLFifty = (OrderOpenPrice()+OrderStopLoss())/(double)2;
             
               if(OrderType() == OP_BUY){    
                  if(Arr_Percent_Pass[n] < 50){ 
                     if(MarketInfo(Symbol_Focus,MODE_ASK) >= ChangePriceFifty){
                        //isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLFifty,OrderTakeProfit(),0,clrNONE);
                        Arr_Percent_Pass[n] = 50;                     
                     } 
                  } 
                  if(Arr_Percent_Pass[n] >= 50 && Arr_Percent_Pass[n] < 80 ){  
                     double ChangePriceEighty = MathAbs(((OrderOpenPrice()-OrderTakeProfit())*0.80)+OrderOpenPrice());
                     double ChangeSLEighty = MathAbs(((OrderOpenPrice()-OrderTakeProfit())*0.15)+OrderOpenPrice());
                     if(MarketInfo(Symbol_Focus,MODE_ASK) >= ChangePriceEighty){
                        isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLEighty,OrderTakeProfit(),0,clrNONE);
                        Arr_Percent_Pass[n] = 80;                     
                     } 
                  }
                  
               }
               if(OrderType() == OP_SELL){  
                  if(Arr_Percent_Pass[n] < 50){ 
                     if(MarketInfo(Symbol_Focus,MODE_BID) <= ChangePriceFifty){ 
                        isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLFifty,OrderTakeProfit(),0,clrNONE);
                        Arr_Percent_Pass[n] = 50;                     
                     }
                  }
                  
                  if(Arr_Percent_Pass[n] >= 50 && Arr_Percent_Pass[n] < 80 ){  
                     double ChangePriceEighty = MathAbs(((OrderOpenPrice()-OrderTakeProfit())*0.80)-OrderOpenPrice());
                     double ChangeSLEighty = MathAbs(((OrderOpenPrice()-OrderTakeProfit())*0.15)-OrderOpenPrice()); 
                     if(MarketInfo(Symbol_Focus,MODE_ASK) <= ChangePriceEighty){
                        //isSuccess = OrderModify(OrderTicket(),OrderOpenPrice(),ChangeSLEighty,OrderTakeProfit(),0,clrNONE);
                        Arr_Percent_Pass[n] = 80;         
                     } 
                  }
               } 
               n++;
            }
         }
       } 
    }
}
 
 
 
 
void GenInterface()
{  
   int y = 40; 
   string lbl_Buy_Percent  =  "lbl_Buy_Percent"; 
   string lbl_Sell_Percent  =  "lbl_Sell_Percent";  

   if(ObjectFind(lbl_Buy_Percent) < 0){  
    Util_LabelCreate(0,lbl_Buy_Percent,0,20,20,CORNER_LEFT_UPPER,"BUY : "+DoubleToString(result[0],2),"Arial",9,clrBlue,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
   Util_LabelCreate(0,lbl_Sell_Percent,0,20,40,CORNER_LEFT_UPPER,"SELL : "+DoubleToString(result[1],2),"Arial",9,clrRed,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
   
   }else{ 
      ObjectSetString(0,lbl_Buy_Percent,OBJPROP_TEXT,"BUY : "+DoubleToString(result[0],2));
      ObjectSetString(0,lbl_Sell_Percent,OBJPROP_TEXT,"SELL : "+DoubleToString(result[1],2)); 
   }
   
   
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
      sl = NormalizeDouble(price-700*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price+1000*_symbol_Point,_symbol_Digits);
    }else{
      sl = NormalizeDouble(price+700*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price-1000*_symbol_Point,_symbol_Digits);
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
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
  
bool HLineMove(const long   chart_ID=0,   // chart's ID
               const string name="HLine", // line name
               double       price=0)      // line price
  {
//--- if the line price is not set, move it to the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move a horizontal line
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
  
  bool SetHLine(string name,double price,color clr){ 
       
      if( ObjectFind(name) < 0){
         HLineCreate(0,name,0,price,clr); return true;
      }else{
         HLineMove(0,name,price); return true;
      } 
      return false;
  }
  
  void GetBar(int &arr_bar[]){
   
      for(int i = 0; i<=2; i++){
          datetime t = iTime(Symbol(),PERIOD_W1,i);
           if (t>0)
           {
              int shift = iBarShift(Symbol(),PERIOD_H4,t);
              ArrayResize(arr_bar,ArraySize(arr_bar)+1);
              arr_bar[i] = shift;
              ObjectCreate("Line "+DoubleToStr(i,0),OBJ_VLINE,0,t,0);
              ObjectSet("Line "+DoubleToStr(i,0),OBJPROP_STYLE,STYLE_SOLID);
              ObjectSet("Line "+DoubleToStr(i,0),OBJPROP_COLOR,clrRed);
              ObjectSet("Line "+DoubleToStr(i,0),OBJPROP_WIDTH,1);
              ObjectSet("Line "+DoubleToStr(i,0),OBJPROP_BACK,true); 
           }  
      }
      
      for(int i = 0; i < ArraySize(arr_bar);i++){
         int length = 0;
         if(i == 0){
            length = arr_bar[i];
         }else{
            length = 30;
         } 
              ObjectCreate("Linex "+DoubleToStr(i,0),OBJ_VLINE,0,length,0);
              ObjectSet("Linex "+DoubleToStr(i,0),OBJPROP_STYLE,STYLE_SOLID);
              ObjectSet("Linex "+DoubleToStr(i,0),OBJPROP_COLOR,clrWhite);
              ObjectSet("Linex "+DoubleToStr(i,0),OBJPROP_WIDTH,1);
              ObjectSet("Linex "+DoubleToStr(i,0),OBJPROP_BACK,true); 
         //Alert(iHighest(Symbol(),PERIOD_H4,MODE_CLOSE,length,arr_bar[i]));
      }
      
  }
  
  
  void LatestHigh(){
  
  }
  
  
  void LatestLow(){
   for(int i = 0; i < 30; i++){
      
   }
  }