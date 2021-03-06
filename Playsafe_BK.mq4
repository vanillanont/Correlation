//+------------------------------------------------------------------+
//|                                            Profit PlaysafeV2.mq4 |
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
    int Order_ID = 0;
    double Lot_Size = 0; 
    double PercentBuy = 0;
    double PercentSell = 0;
    if(Util_IsNewBar(PERIOD_M15)){
      Hold = false;
    } 
    
    for (int i = 0; i < OrdersTotal(); i++)
    {
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
         if(OrderSymbol() == Symbol_Focus){
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
            }
         }
       } 
    }
     
    result[0] = 0;
    result[1] = 0;
    OpenCondition(PERIOD_H1,10,34,9,result); 
    if((OrderBuy+OrderSell) < Total_Allow_Resolve)
    { 
         /*
       double Arr_Result_Check[];
       ArrayResize(Arr_Result_Check,2);
       Arr_Result_Check[0] = 0;
       Arr_Result_Check[1] = 0;
       OpenCondition(PERIOD_M5,10,34,9,Arr_Result_Check);
           */        
       if(result[0] >= Correct_Percent && result[0] > PercentBuy){
         //buy
         //if(Arr_Result_Check[0] > 50){
            Lot_Size = (result[0]/(AccountBalance()*(double)10));
            Lot_Size = Lot_Size < 0.01 ? 0.01 : Lot_Size;
            Order_ID = Util_OpenOrderWithSLTP(Symbol_Focus,OP_BUY,Lot_Size,"PS_"+DoubleToString(result[0],0));
            if(Order_ID > 0){
               Hold = true;
         //   }
         } 
       }
       if(result[1] >= Correct_Percent && result[1] > PercentSell){
         //sell
         //if(Arr_Result_Check[1] > 50){
            Lot_Size = (result[1]/(AccountBalance()*(double)10));
            Lot_Size = Lot_Size < 0.01 ? 0.01 : Lot_Size;
            Order_ID = Util_OpenOrderWithSLTP(Symbol_Focus,OP_SELL,Lot_Size,"PS_"+DoubleToString(result[1],0));
            if(Order_ID > 0){
               Hold = true;
            }
         //}
       }
    }
    Change_TPSL(); 
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