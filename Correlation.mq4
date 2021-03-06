//+------------------------------------------------------------------+
//|                                                  Correlation.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern string SYMBOL_MAIN = "GBPAUD";  
extern string SYMBOL_HEDGE = "GBPCHF";

enum WAY 
  {
   SAME = 0,        // SAME
   DIFFERENCE = 1,  // DIFFERENCE
  };  
extern WAY SYMBOL_WAY = SAME;
extern int CONFORT_ZONE = 50; // CHECKING FOR OPEN OUTSIDE ZONE
extern double TAKE_PROFIT = 1; 

bool IS_OPEN_0 = false;
bool IS_OPEN_1 = false;
bool IS_OPEN_2 = false;
bool IS_OPEN_3 = false;
bool IS_OPEN_4 = false;
bool IS_OPEN_5 = false;
bool IS_OPEN_6 = false;
bool IS_OPEN_7 = false;
bool IS_OPEN_8 = false;
bool IS_OPEN_9 = false;

extern int CORRELATION_ORDER_0 = 95;
extern int CORRELATION_ORDER_1 = 85;
extern int CORRELATION_ORDER_2 = 80;
extern int CORRELATION_ORDER_3 = 75;
extern int CORRELATION_ORDER_4 = 70;
extern int CORRELATION_ORDER_5 = 65;
extern int CORRELATION_ORDER_6 = 60;
extern int CORRELATION_ORDER_7 = 55;
extern int CORRELATION_ORDER_8 = 50;
extern int CORRELATION_ORDER_9 = 45;

extern double LOT_ORDER_0 = 0.01;
extern double LOT_ORDER_1 = 0.01;
extern double LOT_ORDER_2 = 0.01;
extern double LOT_ORDER_3 = 0.01;
extern double LOT_ORDER_4 = 0.01;
extern double LOT_ORDER_5 = 0.01;
extern double LOT_ORDER_6 = 0.01;
extern double LOT_ORDER_7 = 0.01;
extern double LOT_ORDER_8 = 0.01;
extern double LOT_ORDER_9 = 0.01; 
 

int OnInit()
  {
  
   StringToUpper(SYMBOL_MAIN);
   StringToUpper(SYMBOL_HEDGE);
   
   PairSeparateTest();
   return(INIT_SUCCEEDED); 
   rebind_ticket();
   //return(INIT_SUCCEEDED);
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
   return;
   
   int SYMBOL_MAIN_TICKET = 0;
   int SYMBOL_HEDGE_TICKET = 0;
   double MONTH_DIRECTION = (Cor(SYMBOL_MAIN, SYMBOL_HEDGE, 30, 0, PERIOD_D1)*100);
   double HOUR_DIRECTION = (Cor(SYMBOL_MAIN, SYMBOL_HEDGE, 48, 0, PERIOD_H1)*100);
   string comment = "";
   comment = "Month :"+DoubleToString(MONTH_DIRECTION)+" Hour :"+DoubleToString(HOUR_DIRECTION);
   //Comment(PipCounter("CHFJPY",PERIOD_H1,24));
   Comment(comment);
   //return;
   if(SYMBOL_WAY == SAME){
       
      if(MONTH_DIRECTION > CONFORT_ZONE){ // BIG TIMEFRAME STILL RUNNING IN CONFORT ZONE
         if(HOUR_DIRECTION < CORRELATION_ORDER_0 && HOUR_DIRECTION > CORRELATION_ORDER_1 && !IS_OPEN_0){
            //BEGIN FIRST ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET,0))  SYMBOL_MAIN_TICKET = openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_0,0);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,0)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_0,0);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_0 = true;
            }
         }
         
         if(HOUR_DIRECTION < CORRELATION_ORDER_1 && HOUR_DIRECTION > CORRELATION_ORDER_2 && IS_OPEN_0 && !IS_OPEN_1){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 1))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_1,1);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,1)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_1,1);
             if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_1 = true;
            }
         }
         
         if(HOUR_DIRECTION < CORRELATION_ORDER_2 && HOUR_DIRECTION > CORRELATION_ORDER_3 && IS_OPEN_1 && !IS_OPEN_2){
            //NEXT ORDER
             if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 2))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_2,2);
             if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,2)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_2,2); 
             if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_2 = true;
             }
         }
         
         if(HOUR_DIRECTION < CORRELATION_ORDER_3 && HOUR_DIRECTION > CORRELATION_ORDER_4 && IS_OPEN_2 && !IS_OPEN_3){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 3))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_3,3);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,3)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_3,3);
             if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_3 = true;
             }
            
         }
         
         if(HOUR_DIRECTION < CORRELATION_ORDER_4 && HOUR_DIRECTION > CORRELATION_ORDER_5 && IS_OPEN_3 && !IS_OPEN_4){
            //NEXT ORDER
             if(!isOpenedOrder(SYMBOL_MAIN_TICKET,4))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_4,4);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,4)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_4,4);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_4 = true;
             }
            
         }
          
         if(HOUR_DIRECTION < CORRELATION_ORDER_5 && HOUR_DIRECTION > CORRELATION_ORDER_6 && IS_OPEN_4 && !IS_OPEN_5){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 5))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_5,5);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,5)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_5,5);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_5 = true;
             }
         }
          
         if(HOUR_DIRECTION < CORRELATION_ORDER_6 && HOUR_DIRECTION > CORRELATION_ORDER_7 && IS_OPEN_5 && !IS_OPEN_6){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 6))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_6,6);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,6)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_6,6);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_6 = true;
             }
         }
          
         if(HOUR_DIRECTION < CORRELATION_ORDER_7 && HOUR_DIRECTION > CORRELATION_ORDER_8 && IS_OPEN_6 && !IS_OPEN_7){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 7))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_7,7);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,7)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_7,7);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_7 = true;
             }
         }
         
         if(HOUR_DIRECTION < CORRELATION_ORDER_8 && HOUR_DIRECTION > CORRELATION_ORDER_9 && IS_OPEN_7 && !IS_OPEN_8){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 8))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_8,8);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,8)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_8,8);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_8 = true;
             }
         }
         
         if(HOUR_DIRECTION < CORRELATION_ORDER_9 && IS_OPEN_8 && !IS_OPEN_9){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 9))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_BUY,LOT_ORDER_9,9);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,9)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_9,9);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_9 = true;
             }
         }
      }
   }
   
   if(SYMBOL_WAY == DIFFERENCE){
      CONFORT_ZONE=CONFORT_ZONE-(2*CONFORT_ZONE);
      CORRELATION_ORDER_0 = CORRELATION_ORDER_0-(2*CORRELATION_ORDER_0);
      CORRELATION_ORDER_1 = CORRELATION_ORDER_1-(2*CORRELATION_ORDER_1);
      CORRELATION_ORDER_2 = CORRELATION_ORDER_2-(2*CORRELATION_ORDER_2);
      CORRELATION_ORDER_3 = CORRELATION_ORDER_3-(2*CORRELATION_ORDER_3);
      CORRELATION_ORDER_4 = CORRELATION_ORDER_4-(2*CORRELATION_ORDER_4);
      CORRELATION_ORDER_5 = CORRELATION_ORDER_5-(2*CORRELATION_ORDER_5);
      CORRELATION_ORDER_6 = CORRELATION_ORDER_6-(2*CORRELATION_ORDER_6);
      CORRELATION_ORDER_7 = CORRELATION_ORDER_7-(2*CORRELATION_ORDER_7);
      CORRELATION_ORDER_8 = CORRELATION_ORDER_8-(2*CORRELATION_ORDER_8);
      CORRELATION_ORDER_9 = CORRELATION_ORDER_9-(2*CORRELATION_ORDER_9);
      
      if(MONTH_DIRECTION < CONFORT_ZONE){ // BIG TIMEFRAME STILL RUNNING IN CONFORT ZONE
         if(HOUR_DIRECTION > CORRELATION_ORDER_0 && HOUR_DIRECTION < CORRELATION_ORDER_1 && !IS_OPEN_0){
            //BEGIN FIRST ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET,0))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_0,0);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,0)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_0,0); 
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_0 = true;
             }
         }
         
         if(HOUR_DIRECTION > CORRELATION_ORDER_1 && HOUR_DIRECTION < CORRELATION_ORDER_2 && IS_OPEN_0 && !IS_OPEN_1){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 1))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_1,1);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,1)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_1,1); 
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_1 = true;
             }
         }
         
         if(HOUR_DIRECTION > CORRELATION_ORDER_2 && HOUR_DIRECTION < CORRELATION_ORDER_3 && IS_OPEN_1 && !IS_OPEN_2){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 2))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_2,2);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,2)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_2,2); 
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_2 = true;
             }
         }
         
         if(HOUR_DIRECTION > CORRELATION_ORDER_3 && HOUR_DIRECTION < CORRELATION_ORDER_4 && IS_OPEN_2 && !IS_OPEN_3){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 3))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_3,3);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,3)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_3,3); 
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_3 = true;
             }
         }
         
         if(HOUR_DIRECTION > CORRELATION_ORDER_4 && HOUR_DIRECTION < CORRELATION_ORDER_5 && IS_OPEN_3 && !IS_OPEN_4){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 4))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_4,4);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,4)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_4,4); 
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_4 = true;
             }
         }
          
         if(HOUR_DIRECTION > CORRELATION_ORDER_5 && HOUR_DIRECTION < CORRELATION_ORDER_6 && IS_OPEN_4 && !IS_OPEN_5){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 5))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_5,5);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,5)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_5,5);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_5 = true;
             }
         }
          
         if(HOUR_DIRECTION > CORRELATION_ORDER_6 && HOUR_DIRECTION < CORRELATION_ORDER_7 && IS_OPEN_5 && !IS_OPEN_6){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 6))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_6,6);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,6)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_6,6);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_6 = true;
             }
         }
          
         if(HOUR_DIRECTION > CORRELATION_ORDER_7 && HOUR_DIRECTION < CORRELATION_ORDER_8 && IS_OPEN_6 && !IS_OPEN_7){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 7))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_7,7);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,7)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_7,7);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_7 = true;
             }
         }
         
         if(HOUR_DIRECTION > CORRELATION_ORDER_8 && HOUR_DIRECTION < CORRELATION_ORDER_9 && IS_OPEN_7 && !IS_OPEN_8){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 8))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_8,8);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,8)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_8,8);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_8 = true;
             }
         }
         
         if(HOUR_DIRECTION > CORRELATION_ORDER_9 && IS_OPEN_8 && !IS_OPEN_9){
            //NEXT ORDER 
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 9))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,OP_SELL,LOT_ORDER_9,9);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,9)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,OP_SELL,LOT_ORDER_9,9);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_9 = true;
             }
         }
      } 
   } 
   SYMBOL_MAIN_TICKET = 0;
   SYMBOL_HEDGE_TICKET = 0;
   
   completeOrders();
       
}
//+------------------------------------------------------------------+

void completeOrders(){ 
  double profit = 0;
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
      if (OrderSelect(i, SELECT_BY_POS) == true)
      {
         if(isFocusedOrder()){
            profit += (OrderProfit() + OrderSwap() + OrderCommission()); 
         }
      }
  }
  
  if(profit > TAKE_PROFIT){
      
     for (int i = 0; i <= (OrdersTotal() - 1); i++)
     {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         {
            if(isFocusedOrder()){
               closeOrder(OrderTicket());
            }
         }
     } 
      IS_OPEN_0 = false;
      IS_OPEN_1 = false;
      IS_OPEN_2 = false;
      IS_OPEN_3 = false;
      IS_OPEN_4 = false;
      IS_OPEN_5 = false;
      IS_OPEN_6 = false;
      IS_OPEN_7 = false;
      IS_OPEN_8 = false;
      IS_OPEN_9 = false;
  }
  
}

bool isFocusedOrder(){
   //OrderSelect needed before call this function
   if(StringFind(OrderComment(),SYMBOL_MAIN,0) >= 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) >= 0){
      return true;
   }else{
      return false;
   }
}
 
void closeOrder(int ticket)
{
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
        
        bool iSuccess = false;
        int i = 0;
        while (!iSuccess)
        {
            if(i == 6){
               iSuccess = true;
            }
            
            iSuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 0, 0);
            i++;
        } 
    }
}


//+------------------------------------------------------------------+
double sDif(string symbol, int shift, int _period, int timeframe)
{
    return (iClose(symbol, timeframe, shift) - iMA(symbol, timeframe, _period, 0, MODE_SMA, PRICE_CLOSE, shift));
}

double pDif(double val)
{
    return (MathPow(val, 2));
}

double Cor(string base, string hedge, int _period, int shift, int timeframe = 0)
{
    double u1 = 0, l1 = 0, s1 = 0;
    for (int i = (_period + shift) - 1; i >= shift; i--)
    {
        u1 += sDif(base, i, _period, timeframe) * sDif(hedge, i, _period, timeframe);
        l1 += pDif(sDif(base, i, _period, timeframe));
        s1 += pDif(sDif(hedge, i, _period, timeframe));
    }
    double dMathSqrt = MathSqrt(l1 * s1);
    if (dMathSqrt > 0)
    {
        return (u1 / dMathSqrt);
    }
    else
    {
        return dMathSqrt;
    }
}


int openOrder(string _symbol, int cmd, double lot, int group_id)
{

    //return order ticket

    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;

    while (iSuccess < 0)
    {
        iSuccess = OrderSend(_symbol, cmd, lot, price, 3, 0.0, 0.0, SYMBOL_MAIN+"_"+SYMBOL_HEDGE+"_"+IntegerToString(group_id)+"_", group_id, 0, clrGreen);
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
    return 0;
}



void rebind_ticket()
{ 
     for (int i = 0; i <= (OrdersTotal() - 1); i++)
     {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         { 
            if(isFocusedOrder()){
               int ticket = OrderTicket();
               int magic_number = OrderMagicNumber();
               if(magic_number == 0){
                  IS_OPEN_0 = true;
               }
               if(magic_number == 1){
                  IS_OPEN_1 = true;
               }
               if(magic_number == 2){
                  IS_OPEN_2 = true;
               }
               if(magic_number == 3){
                  IS_OPEN_3 = true;
               }
               if(magic_number == 4){
                  IS_OPEN_4 = true;
               }
               if(magic_number == 5){
                  IS_OPEN_5 = true;
               }
               if(magic_number == 6){
                  IS_OPEN_6 = true;
               }
               if(magic_number == 7){
                  IS_OPEN_7 = true;
               }
               if(magic_number == 8){
                  IS_OPEN_8 = true;
               }
               if(magic_number == 9){
                  IS_OPEN_9 = true;
               } 
            }
         }
     }
}

bool isOpenedOrder(string symbol,int group_id){
   bool opened = false;
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) == true)
    { 
      if(isFocusedOrder()){ 
         if(StringFind(OrderComment(),symbol,0) >= 0 && StringFind(OrderComment(),"_"+IntegerToString(group_id)+"_",0) >= 0){
           opened = true; 
           break;
         }
      }
    }
  }
  return opened;
}


double PipCounter(string _symbol,int timeframe,int candle_number){ 
    double low = 0;
    double high = 0;  
    double total = 0;
    int pips = 0;
    string multiple = "1";
    
    int digits = MarketInfo(_symbol,MODE_DIGITS);
    for(int i = 0;i<digits; i++){
       multiple += "0"; 
    }
    
    for(int i = 0; i<candle_number;i++){
      low  += iLow(_symbol,timeframe,i);
      high += iHigh(_symbol,timeframe,i);     
    }
    total =MathAbs( MathAbs(low) - MathAbs(high));
    pips = total*StrToDouble(multiple);  
    return pips;
}

void PairSeparateTest(){
      int period = PERIOD_H1;
      int candle_number = 100;
      double price_COMPARE = 0;
      double price_AVERAGE = 0;
      for(int i = 0; i < candle_number ; i++){
         double price_SYMBOL_MAIN = iOpen(SYMBOL_MAIN,period,i);
         double price_SYMBOL_HEDGE = iOpen(SYMBOL_HEDGE,period,i);
         price_COMPARE += MathAbs(price_SYMBOL_MAIN - price_SYMBOL_HEDGE);
      }  
      int digits = MarketInfo(SYMBOL_MAIN,MODE_DIGITS);
      if(MarketInfo(SYMBOL_MAIN,MODE_DIGITS) > MarketInfo(SYMBOL_HEDGE,MODE_DIGITS)){
         digits = MarketInfo(SYMBOL_HEDGE,MODE_DIGITS);
      } 
      string multiple = "1";
      for(int i = 0;i<digits; i++){
         multiple += "0"; 
      }
      price_AVERAGE = ((price_COMPARE/candle_number)*StrToDouble(multiple));  
      Comment(price_AVERAGE);
}