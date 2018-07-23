//+------------------------------------------------------------------+
//|                                                Cointegration.mq4 |
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
int SYMBOL_MAIN_SEND = OP_SELL;
int SYMBOL_HEDGE_SEND = OP_BUY;
extern int CONFORT_ZONE = 0; 

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

extern int NEXTOPEN_ORDER_0 = 0;
extern int NEXTOPEN_ORDER_1 = 1000;
extern int NEXTOPEN_ORDER_2 = 1000;
extern int NEXTOPEN_ORDER_3 = 1000;
extern int NEXTOPEN_ORDER_4 = 1000;
extern int NEXTOPEN_ORDER_5 = 1000;
extern int NEXTOPEN_ORDER_6 = 1000;
extern int NEXTOPEN_ORDER_7 = 1000;
extern int NEXTOPEN_ORDER_8 = 1000;
extern int NEXTOPEN_ORDER_9 = 1000;

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

int arr_NEXTOPEN_ORDER[10];
int current_zone = 0;
bool clear_order = false;
 
int OnInit()
  {
  
   StringToUpper(SYMBOL_MAIN);
   StringToUpper(SYMBOL_HEDGE); 
   
   if(iOpen(SYMBOL_MAIN,PERIOD_M1,0) > iOpen(SYMBOL_HEDGE,PERIOD_M1,0)){
      SYMBOL_MAIN_SEND = OP_SELL;
      SYMBOL_HEDGE_SEND = OP_BUY;
   }else{
      SYMBOL_MAIN_SEND = OP_BUY;
      SYMBOL_HEDGE_SEND = OP_SELL;
   }
   
   
   CONFORT_ZONE = PairSeparateTest(365,PERIOD_D1); 
   rebind_ticket();
   
   arr_NEXTOPEN_ORDER[0] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0);
   arr_NEXTOPEN_ORDER[1] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1);
   arr_NEXTOPEN_ORDER[2] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1 + 
                            NEXTOPEN_ORDER_2);
   arr_NEXTOPEN_ORDER[3] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1 + 
                            NEXTOPEN_ORDER_2 + 
                            NEXTOPEN_ORDER_3);
   arr_NEXTOPEN_ORDER[4] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1 + 
                            NEXTOPEN_ORDER_2 + 
                            NEXTOPEN_ORDER_3 + 
                            NEXTOPEN_ORDER_4);
   arr_NEXTOPEN_ORDER[5] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5);
   arr_NEXTOPEN_ORDER[6] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6);
   arr_NEXTOPEN_ORDER[7] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6 + 
                           NEXTOPEN_ORDER_7);
   arr_NEXTOPEN_ORDER[8] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6 + 
                           NEXTOPEN_ORDER_7 + 
                           NEXTOPEN_ORDER_8);
   arr_NEXTOPEN_ORDER[9] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6 + 
                           NEXTOPEN_ORDER_7 + 
                           NEXTOPEN_ORDER_8 + 
                           NEXTOPEN_ORDER_9);
                           
   
   
   
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
   int SYMBOL_MAIN_TICKET = 0;
   int SYMBOL_HEDGE_TICKET = 0; 
   current_zone = PairSeparateTest(1,PERIOD_M1);
   //CONFORT_ZONE = 20000;
   //current_zone = 20001;
   //arr_NEXTOPEN_ORDER[0] = 20000;
   string comment = "Comfort : "+ IntegerToString(CONFORT_ZONE)+" // Current : "+IntegerToString(current_zone); 
   Comment(comment);
   //return; 
        
         if(current_zone > arr_NEXTOPEN_ORDER[0] && current_zone < arr_NEXTOPEN_ORDER[1] && !IS_OPEN_0){
            //BEGIN FIRST ORDER 
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET,0))  SYMBOL_MAIN_TICKET = openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,0)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_0 = true;
            }
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[1]  && current_zone < arr_NEXTOPEN_ORDER[2] && IS_OPEN_0 && !IS_OPEN_1){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 1))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_1,1,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,1)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_1,1,99999999);
             if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_1 = true;
            }
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[2]  && current_zone < arr_NEXTOPEN_ORDER[3] && IS_OPEN_1 && !IS_OPEN_2){
            //NEXT ORDER
             if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 2))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_2,2,99999999);
             if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,2)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_2,2,99999999); 
             if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_2 = true;
             }
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[3] && current_zone < arr_NEXTOPEN_ORDER[4]  && IS_OPEN_2 && !IS_OPEN_3){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 3))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_3,3,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,3)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_3,3,99999999);
             if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_3 = true;
             }
            
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[4]  && current_zone < arr_NEXTOPEN_ORDER[5] && IS_OPEN_3 && !IS_OPEN_4){
            //NEXT ORDER
             if(!isOpenedOrder(SYMBOL_MAIN_TICKET,4))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_4,4,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,4)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_4,4,99999999);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_4 = true;
             }
            
         }
          
         if(current_zone > arr_NEXTOPEN_ORDER[5] && current_zone < arr_NEXTOPEN_ORDER[6]  && IS_OPEN_4 && !IS_OPEN_5){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 5))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_5,5,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,5)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_5,5,99999999);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_5 = true;
             }
         }
          
         if(current_zone > arr_NEXTOPEN_ORDER[6] && current_zone < arr_NEXTOPEN_ORDER[7] && IS_OPEN_5 && !IS_OPEN_6){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 6))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_6,6,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,6)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_6,6,99999999);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_6 = true;
             }
         }
          
         if(current_zone > arr_NEXTOPEN_ORDER[7]  && current_zone < arr_NEXTOPEN_ORDER[8] && IS_OPEN_6 && !IS_OPEN_7){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 7))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_7,7,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,7)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_7,7,99999999);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_7 = true;
             }
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[8]  && current_zone < arr_NEXTOPEN_ORDER[9] && IS_OPEN_7 && !IS_OPEN_8){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 8))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_8,8,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,8)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_8,8,99999999);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_8 = true;
             }
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[9] && IS_OPEN_8 && !IS_OPEN_9){
            //NEXT ORDER
            if(!isOpenedOrder(SYMBOL_MAIN_TICKET, 9))  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_9,9,99999999);
            if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,9)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_9,9,99999999);
            if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
               IS_OPEN_9 = true;
             }
         }
      
    
   SYMBOL_MAIN_TICKET = 0;
   SYMBOL_HEDGE_TICKET = 0;
   completeOrders();  
}
//+------------------------------------------------------------------+

void completeOrders(){ 
  double profit = 0;
  bool opening_order = false;
  
   //////////////// recheck open order ///////////////
   int order_0 = 0;
   int order_1 = 0;
   int order_2 = 0;
   int order_3 = 0;
   int order_4 = 0;
   int order_5 = 0;
   int order_6 = 0;
   int order_7 = 0;
   int order_8 = 0;
   int order_9 = 0;
   
   string order_symbol_0 = "";
   string order_symbol_1 = "";
   string order_symbol_2 = "";
   string order_symbol_3 = "";
   string order_symbol_4 = "";
   string order_symbol_5 = "";
   string order_symbol_6 = "";
   string order_symbol_7 = "";
   string order_symbol_8 = "";
   string order_symbol_9 = "";
   //////////////// recheck open order ///////////////
   
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
      if (OrderSelect(i, SELECT_BY_POS) == true)
      {
         if(isFocusedOrder()){
            if(clear_order == true){
               closeOrder(OrderTicket());
               if(isFocusedOrder()){
                  opening_order = true;
               } 
               
               if(opening_order == true){
                   clear_order = true;
               }else{
                           
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
                  
                  clear_order = false;
               }  
            }else{ 
               profit += (OrderProfit() + OrderSwap() + OrderCommission());  
             
               if(StringFind(OrderComment(),"_0_",0) >= 0){
                    order_symbol_0 = OrderSymbol();
                    order_0++;
               }
               if(StringFind(OrderComment(),"_1_",0) >= 0){
                    order_symbol_1 = OrderSymbol();
                    order_1++;
               }
               if(StringFind(OrderComment(),"_2_",0) >= 0){
                    order_symbol_2 = OrderSymbol();
                    order_2++;
               }
               if(StringFind(OrderComment(),"_3_",0) >= 0){
                    order_symbol_3 = OrderSymbol();
                    order_3++;
               }
               if(StringFind(OrderComment(),"_4_",0) >= 0){
                    order_symbol_4 = OrderSymbol();
                    order_4++;
               }
               if(StringFind(OrderComment(),"_5_",0) >= 0){
                    order_symbol_5 = OrderSymbol();
                    order_5++;
               }
               if(StringFind(OrderComment(),"_6_",0) >= 0){
                    order_symbol_6 = OrderSymbol();
                    order_6++;
               }
               if(StringFind(OrderComment(),"_7_",0) >= 0){
                    order_symbol_7 = OrderSymbol();
                    order_7++;
               }
               if(StringFind(OrderComment(),"_8_",0) >= 0){
                    order_symbol_8 = OrderSymbol();
                    order_8++;
               }
               if(StringFind(OrderComment(),"_9_",0) >= 0){
                    order_symbol_9 = OrderSymbol();
                    order_9++;
               }
            
            } 
         }
      }
  } 
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
   if(clear_order == false){ 
        if(order_0 == 1){
       // Alert("x");
            if(order_symbol_0 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_0,0,CONFORT_ZONE); 
            }
            IS_OPEN_0 = true;
        }
        
        if(order_1 == 1){
            if(order_symbol_1 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_1,1,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_1,1,99999999); 
            }
            IS_OPEN_1 = true;
        }
        
        if(order_2 == 1){
            if(order_symbol_2 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_2,2,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_2,2,99999999); 
            }
            IS_OPEN_2 = true;
        }
        
        if(order_3 == 1){
            if(order_symbol_3 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_3,3,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_3,3,99999999); 
            }
            IS_OPEN_3 = true;
        }
        
        if(order_4 == 1){
            if(order_symbol_4 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_4,4,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_4,4,99999999); 
            }
            IS_OPEN_4 = true;
        }
        
        if(order_5 == 1){
            if(order_symbol_5 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_5,5,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_5,5,99999999); 
            }
            IS_OPEN_5 = true;
        }
        
        if(order_6 == 1){
            if(order_symbol_6 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_6,6,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_6,6,99999999); 
            }
            IS_OPEN_6 = true;
        }
        if(order_7 == 1){
            if(order_symbol_7 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_7,7,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_7,7,99999999); 
            }
            IS_OPEN_7 = true;
        }
        if(order_8 == 1){
            if(order_symbol_8 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_8,8,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_8,8,99999999); 
            }
            IS_OPEN_8 = true;
        }
        if(order_9 == 1){
            if(order_symbol_9 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_9,9,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_9,9,99999999); 
            }
            IS_OPEN_9 = true;
        }
   }
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
  
     if(clear_order == false){
        if(profit > TAKE_PROFIT){
           clear_order = true;
           for (int i = 0; i <= (OrdersTotal() - 1); i++)
           {
               if (OrderSelect(i, SELECT_BY_POS) == true)
               {
                  if(isFocusedOrder()){
                     closeOrder(OrderTicket());
                  }
               }
           }  
           CONFORT_ZONE = PairSeparateTest(365,PERIOD_D1); 
        } 
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


int openOrder(string _symbol, int cmd, double lot, int group_id,int begin_order)
{

    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;

    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 3, 0.0, 0.0, SYMBOL_MAIN+"_"+SYMBOL_HEDGE+"_"+IntegerToString(group_id)+"_"+IntegerToString(begin_order)+"_", group_id, 0, clrGreen); 
        
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
               
                  // change comfort zone to first open order /////////
                  string result[];
                  StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                  CONFORT_ZONE = (int)result[3];
                   ///////// ///////// ///////// ///////// /////////
                   
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

bool isOpenedOrder(int ticket_number,int group_id){
   bool opened = false;
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) == true)
    { 
      if(isFocusedOrder()){ 
         if(StringFind(OrderComment(),IntegerToString(ticket_number),0) >= 0 && StringFind(OrderComment(),"_"+IntegerToString(group_id)+"_",0) >= 0){
           opened = true; 
           break;
         }
      }
    }
  }
  return opened;
}

 

int PairSeparateTest(int candle_number,int period){ 
      double price_COMPARE = 0;
      int price_AVERAGE = 0;
      for(int i = 0; i < candle_number ; i++){
         double price_SYMBOL_MAIN = iOpen(SYMBOL_MAIN,period,i);
         double price_SYMBOL_HEDGE = iOpen(SYMBOL_HEDGE,period,i);
         price_COMPARE += MathAbs(price_SYMBOL_MAIN - price_SYMBOL_HEDGE);
      }  
      int digits =  (int)MarketInfo(SYMBOL_MAIN,MODE_DIGITS);
      if(MarketInfo(SYMBOL_MAIN,MODE_DIGITS) > MarketInfo(SYMBOL_HEDGE,MODE_DIGITS)){
         digits = (int)MarketInfo(SYMBOL_HEDGE,MODE_DIGITS);
      } 
      string multiple = "1";
      for(int i = 0;i<digits; i++){
         multiple += "0"; 
      }
      if(candle_number == 0){
         price_AVERAGE = (int)(price_COMPARE*StrToDouble(multiple));   
      }else{ 
         price_AVERAGE = (int)((price_COMPARE/candle_number)*StrToDouble(multiple));  
      }
      return price_AVERAGE;
} 


void recheck_order(){
  
   
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) == true)
    { 
     
    }
  }
  
   
}
 