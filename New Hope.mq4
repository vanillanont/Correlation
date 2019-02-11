//+------------------------------------------------------------------+
//|                                                      Hedging.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict 


int total_allow_orders = 1;
double lot_size = 0.01;
int Arr_period[];

int OnInit()
{        
   ArrayResize(Arr_period,5);
   Arr_period[0] = PERIOD_M15;
   Arr_period[1] = PERIOD_M30;
   Arr_period[2] = PERIOD_H1;
   Arr_period[3] = PERIOD_H4;
   Arr_period[4] = PERIOD_D1;
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{ 

}

void OnTick()
{     
   
   //for(int i = 0; i < ArraySize(Arr_period); i++){ 
      //int period =  Arr_period[i];
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
       
      int minimum_space = 150;
      if(
            previous_open < previous_close
         && previous_second_open < previous_second_close
         && previous_third_open < previous_third_close
         && previous_close < previous_second_high
      ){
         int space = MathAbs(previous_third_open-previous_high); 
         if(space >= minimum_space){  
            int space_tp = space/2;
            double tp = (double)(Util_PriceNoDigit(Ask)-space_tp)/(double)Util_DivideDigit();
            double sl = (double)(Util_PriceNoDigit(Ask)+space)/(double)Util_DivideDigit();
            if(TotalOrders() < total_allow_orders){
               Util_OpenOrderWithSLTP(Symbol(),OP_SELL,lot_size,tp,sl,""); 
            }
         }
      } 
   //}
   
}
 
int Util_OpenOrderWithSLTP(string _symbol, int cmd, double lot,double tp,double sl,string comment)
{  
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0; 
    double _symbol_Point = MarketInfo(_symbol,MODE_POINT);
    int _symbol_Digits = ((int)MarketInfo(_symbol,MODE_DIGITS)); 
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
