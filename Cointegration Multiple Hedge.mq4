//+------------------------------------------------------------------+
//|                                 Cointegration Multiple Hedge.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "2.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

string Symbols = ""; 

extern string symbols01 =  "EURNZD-GBPNZD-EURGBP-MAIN,EURGBP-GBPNZD-EURNZD-MAIN,EURGBP-EURNZD-GBPNZD-MAIN"; //"GBPNZD-EURNZD-EURGBP,EURNZD-EURAUD-AUDNZD,EURAUD-EURCAD-AUDCAD,EURCAD-EURUSD-USDCAD,EURUSD-NZDUSD-NZDUSD";
extern string symbols02 = ",AUDUSD-AUDCAD-USDCAD-MAIN,AUDUSD-USDCAD-AUDCAD-MAIN,AUDCAD-USDCAD-AUDUSD-MAIN";//",AUDNZD-AUDCAD-NZDCAD,AUDCAD-AUDUSD-USDCAD,AUDUSD-AUDCHF-USDCHF,AUDCHF-NZDCHF-AUDNZD";
extern string symbols03 = ",EURNZD-GBPNZD-EURGBP-HEDGE,EURGBP-GBPNZD-EURNZD-HEDGE,EURGBP-EURNZD-GBPNZD-HEDGE";//",GBPJPY-EURJPY-EURGBP,EURJPY-CHFJPY-EURCHF,CHFJPY-USDJPY-USDCHF,USDJPY-CADJPY-USDCAD,CADJPY-AUDJPY-AUDCAD,AUDJPY-NZDJPY-AUDNZD";
extern string symbols04 = ",AUDUSD-AUDCAD-USDCAD-HEDGE,AUDUSD-USDCAD-AUDCAD-HEDGE,AUDCAD-USDCAD-AUDUSD-HEDGE";//",GBPNZD-GBPAUD-GBPAUD,GBPAUD-GBPCAD-AUDCAD,GBPCAD-GBPCHF-CADCHF,GBPCHF-EURCHF-EURGBP,EURCHF-EURGBP-GBPCHF";
/*
extern string symbols01 =  "GBPUSD-GBPCHF-USDCHF-MAIN,USDCHF-GBPCHF-GBPUSD-MAIN,USDCHF-GBPUSD-GBPCHF-MAIN"; //"GBPNZD-EURNZD-EURGBP,EURNZD-EURAUD-AUDNZD,EURAUD-EURCAD-AUDCAD,EURCAD-EURUSD-USDCAD,EURUSD-NZDUSD-NZDUSD";
extern string symbols02 = ",AUDUSD-AUDCAD-USDCAD-MAIN,AUDUSD-USDCAD-AUDCAD-MAIN,AUDCAD-USDCAD-AUDUSD-MAIN";//",AUDNZD-AUDCAD-NZDCAD,AUDCAD-AUDUSD-USDCAD,AUDUSD-AUDCHF-USDCHF,AUDCHF-NZDCHF-AUDNZD";
extern string symbols03 = ",GBPUSD-GBPCHF-USDCHF-HEDGE,USDCHF-GBPCHF-GBPUSD-HEDGE,USDCHF-GBPUSD-GBPCHF-HEDGE";//",GBPJPY-EURJPY-EURGBP,EURJPY-CHFJPY-EURCHF,CHFJPY-USDJPY-USDCHF,USDJPY-CADJPY-USDCAD,CADJPY-AUDJPY-AUDCAD,AUDJPY-NZDJPY-AUDNZD";
extern string symbols04 = ",AUDUSD-AUDCAD-USDCAD-HEDGE,AUDUSD-USDCAD-AUDCAD-HEDGE,AUDCAD-USDCAD-AUDUSD-HEDGE";//",GBPNZD-GBPAUD-GBPAUD,GBPAUD-GBPCAD-AUDCAD,GBPCAD-GBPCHF-CADCHF,GBPCHF-EURCHF-EURGBP,EURCHF-EURGBP-GBPCHF";
*/


string arr_Group_MAIN[];
string arr_Group_HEDGE[];
string arr_Group_REVERSE[];
string arr_Group_TYPE[];
double arr_Group_Profit[];  
int arr_Group_MAIN_Direction[];
int arr_Group_HEDGE_Direction[];
int arr_Comfort_Zone[];
int arr_Current_Zone[]; 
int arr_ticket_pending_close[];
int arr_ticket_pending_close_hedge[];
double arr_max_profit[];
string arr_order_status[];
string arr_order_status_hedge[]; 
string arr_button_symbol[];
string arr_allow_symbol[];
double arr_tpLot[];
 
input string Lots = "1,1,1,1,1,1,1,1,1,1";
input string Spaces = "1000,1000,1000,1000,1000,1000,1000,1000,1000,1000";
string arr_LotSizeGroup[];
string arr_TPGroup[];
string arr_SpaceGroup[];
double arr_acceptable_profit[];

extern int TOTAL_PAIR_ALLOW = 100; 
string CLOSE_AT_COMFORT_ZONE = "N";
extern double TP_Multiply = 2;
extern string CAL_COMFORT_ZONE = "N";
//string GROUP_HEDGE_COMMENT = "H";

datetime arr_current_open_datetime[];
int arr_current_open[];
int arr_first_open[];
int arr_hedge_open[];
 
int SYMBOL_MAIN_SEND = OP_SELL;
int SYMBOL_HEDGE_SEND = OP_BUY; 
    
string OPENING_MAIN = "";
string OPENING_HEDGE = "";
int OPENING_MAIN_DIREC = 0;
int OPENING_HEDGE_direc = 0;
string OPENING_ZONE_NUMBER = "";
double OPENING_lot = 0;
int OPENING_comfort = 0;
 
int size = 0; 
int lot_Count = 0;
double lot_size = 0;
int OnInit()
{ 

   
  Init();  
  setup_money_management();
  rebind_ticket();
  ClearInterface(); 
  int fnError = GetLastError();
  if(fnError > 0){
   Print("Error function OnInit: ",fnError);
   ResetLastError();
  }       
  return(INIT_SUCCEEDED);  
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ClearInterface();
   ObjectsDeleteAll();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{  
   Tick();
}
//+------------------------------------------------------------------+

bool isFocusedOrder(string SYMBOL_MAIN,string SYMBOL_HEDGE,string TYPE){
   //OrderSelect needed before call this function
   if(StringFind(OrderComment(),SYMBOL_MAIN,0) >= 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) >= 0){
      if(StringFind(OrderComment(),TYPE,0) >= 0){
         return true;
      }else{
         return false;
      } 
   }else{
      return false;
   }
}

/*
bool isFocusedOrderHedge(string SYMBOL_MAIN,string SYMBOL_HEDGE){
   //OrderSelect needed before call this function
   if(StringFind(OrderComment(),SYMBOL_MAIN,0) >= 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) >= 0){
      if(StringFind(OrderComment(),GROUP_HEDGE_COMMENT,0) >= 0){
         return true;
      }else{
         return false;
      } 
   }else{
      return false;
   }
}
*/
 
 bool isNotFocusedOrder(string SYMBOL_MAIN,string SYMBOL_HEDGE){
     //OrderSelect needed before call this function
     if(StringFind(OrderComment(),SYMBOL_MAIN,0) < 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) < 0){
         return true;
     }else{
         return false;
     }
 }

bool closeOrder(int ticket)
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
 

int openOrder(string _symbol,string _symbol_hedge, int cmd, double lot, int group_id,int begin_order,int current,string additional_comment)
{

    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;

    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 10, 0.0, 0.0, _symbol+"_"+_symbol_hedge+"_"+IntegerToString(group_id)+"_"+IntegerToString(current)+"_"+additional_comment, group_id, 0, clrGreen); 
        
        //iSuccess = OrderSend(_symbol, cmd, lot, price, 10, 0.0, 0.0, _symbol+"_"+_symbol_hedge+"_"+IntegerToString(group_id)+"_"+IntegerToString(begin_order)+"_"+IntegerToString(current)+additional_comment, group_id, 0, clrGreen); 
        
        Print("GetLastError = ",GetLastError()," / symbol:",_symbol," / ",_symbol_hedge,"lot:",lot);
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
      Print("Error function openOrder: ",fnError);
      ResetLastError();
    }
    return 0;
}
 
  
int PairSeparateTestCustom(string SYMBOL_MAIN,string SYMBOL_HEDGE,int candle_number,int period){ 

      double price_COMPARE = 0;
      int price_AVERAGE = 0;
      int price_MAXIMUM = 0;
      int price_MINIMUM = 0;
      for(int i = 0; i < candle_number ; i++){
         double price_SYMBOL_MAIN =  0;//iOpen(SYMBOL_MAIN,period,i);//((MarketInfo(SYMBOL_MAIN, MODE_ASK)+MarketInfo(SYMBOL_MAIN, MODE_BID))/2); //iOpen(SYMBOL_MAIN,period,i);
         double price_SYMBOL_HEDGE = 0;//iOpen(SYMBOL_HEDGE,period,i);//((MarketInfo(SYMBOL_HEDGE, MODE_ASK)+MarketInfo(SYMBOL_HEDGE, MODE_BID))/2); //iOpen(SYMBOL_HEDGE,period,i);
         
         price_SYMBOL_MAIN =  iOpen(SYMBOL_MAIN,period,i);
         price_SYMBOL_HEDGE = iOpen(SYMBOL_HEDGE,period,i);
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
      int fnError = GetLastError();
      if(fnError > 0){ 
          Print("Error function PairSeparateTestCustom: ",fnError," / ",SYMBOL_MAIN,"-",SYMBOL_HEDGE); 
          ResetLastError(); 
      }
      return price_AVERAGE;
} 
 
 
 
int PairSeparateTestCustomRealtime(string SYMBOL_MAIN,string SYMBOL_HEDGE){ 
      double price_COMPARE = 0;
      int price_AVERAGE = 0;
      int price_MAXIMUM = 0;
      int price_MINIMUM = 0; 
      double price_SYMBOL_MAIN =  ((MarketInfo(SYMBOL_MAIN, MODE_ASK)+MarketInfo(SYMBOL_MAIN, MODE_BID))/2); //iOpen(SYMBOL_MAIN,period,i);
      double price_SYMBOL_HEDGE = ((MarketInfo(SYMBOL_HEDGE, MODE_ASK)+MarketInfo(SYMBOL_HEDGE, MODE_BID))/2); //iOpen(SYMBOL_HEDGE,period,i);
      price_COMPARE += MathAbs(price_SYMBOL_MAIN - price_SYMBOL_HEDGE);
      
      int digits =  (int)MarketInfo(SYMBOL_MAIN,MODE_DIGITS);
      if(MarketInfo(SYMBOL_MAIN,MODE_DIGITS) > MarketInfo(SYMBOL_HEDGE,MODE_DIGITS)){
         digits = (int)MarketInfo(SYMBOL_HEDGE,MODE_DIGITS);
      } 
      string multiple = "1";
      for(int i = 0;i<digits; i++){
         multiple += "0"; 
      } 
      price_AVERAGE = (int)(price_COMPARE*StrToDouble(multiple));   
      int fnError = GetLastError();
      if(fnError > 0){
         Print("Error function PairSeparateTestCustomRealtime: ",fnError); 
         ResetLastError(); 
      }
      return price_AVERAGE;
} 


 
 
int PairSeparateTestCustomShift(string SYMBOL_MAIN,string SYMBOL_HEDGE,int timeframe,int shift){ 
      double price_COMPARE = 0;
      int price_AVERAGE = 0;
      int price_MAXIMUM = 0;
      int price_MINIMUM = 0; 
      double price_SYMBOL_MAIN =  iOpen(SYMBOL_MAIN,timeframe,shift); //((MarketInfo(SYMBOL_MAIN, MODE_ASK)+MarketInfo(SYMBOL_MAIN, MODE_BID))/2); //iOpen(SYMBOL_MAIN,period,i);
      double price_SYMBOL_HEDGE = iOpen(SYMBOL_HEDGE,timeframe,shift); //((MarketInfo(SYMBOL_HEDGE, MODE_ASK)+MarketInfo(SYMBOL_HEDGE, MODE_BID))/2); //iOpen(SYMBOL_HEDGE,period,i);
      price_COMPARE += MathAbs(price_SYMBOL_MAIN - price_SYMBOL_HEDGE);
      
      int digits =  (int)MarketInfo(SYMBOL_MAIN,MODE_DIGITS);
      if(MarketInfo(SYMBOL_MAIN,MODE_DIGITS) > MarketInfo(SYMBOL_HEDGE,MODE_DIGITS)){
         digits = (int)MarketInfo(SYMBOL_HEDGE,MODE_DIGITS);
      } 
      string multiple = "1";
      for(int i = 0;i<digits; i++){
         multiple += "0"; 
      } 
      price_AVERAGE = (int)(price_COMPARE*StrToDouble(multiple));   
      int fnError = GetLastError();
      if(fnError > 0){
         Print("Error function PairSeparateTestCustomShift: ",fnError); 
         ResetLastError(); 
      }
      return price_AVERAGE;
} 
  
    
  
    

void setup_money_management()
{    
    //double lot_size = (AccountBalance() * 0.0001);
    //int pair_size = ArraySize(arr_Group_MAIN);
    //lot_size = lot_size / pair_size;
    //double lot_size = (AccountBalance() * 0.00001);
    lot_size = ((AccountBalance()/3) * 0.0001);
    if (lot_size < 0.01)
    {
        lot_size = 0.01;
    }    
    double tp_size = lot_size * 100;
      
    Split(Lots,",",arr_LotSizeGroup);
    Split(Spaces,",",arr_SpaceGroup);
    
    Split(Lots,",",arr_TPGroup);
    lot_Count = ArraySize(arr_LotSizeGroup);
          
    for(int i = 0; i < lot_Count; i++){ 
      string lotGrp = (string)((double)arr_LotSizeGroup[i] * lot_size);
      string lotTP = (string)((double)arr_TPGroup[i] * tp_size);
      lotTP = (string)(((double)lotTP)*TP_Multiply);
      arr_LotSizeGroup[i] = lotGrp;
      arr_TPGroup[i]      = lotTP;
    }    
   int fnError = GetLastError(); 
   if(fnError > 0){
      Print("Error function setup_money_management: ",fnError); 
      ResetLastError();        
   }
}
 
void Split(string text,string split,string & result[]){
   StringSplit(text,StringGetCharacter(split,0),result);
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function Split: ",fnError);  
      ResetLastError();
   }
}

void Init(){
   Symbols += symbols01;
   Symbols += symbols02;
   Symbols += symbols03;
   Symbols += symbols04;
   string arr_Group[];
   Split(Symbols,",",arr_Group);
   size = ArraySize(arr_Group);
   ArrayResize(arr_Group_MAIN,size);
   ArrayResize(arr_Group_HEDGE,size);  
   ArrayResize(arr_Group_REVERSE,size);  
   ArrayResize(arr_Group_TYPE,size);   
   ArrayResize(arr_Comfort_Zone,size);      
   ArrayResize(arr_Group_MAIN_Direction,size);
   ArrayResize(arr_Group_HEDGE_Direction,size);  
   ArrayResize(arr_Group_Profit,size);   
   ArrayResize(arr_Current_Zone,size); 
   ArrayResize(arr_max_profit,size); 
   ArrayResize(arr_order_status,size);
   ArrayResize(arr_order_status_hedge,size); 
   ArrayResize(arr_acceptable_profit,size);
   ArrayResize(arr_button_symbol,size);
   ArrayResize(arr_allow_symbol,size); 
   ArrayResize(arr_hedge_open,size);
   
   for(int i = 0; i < size; i++){
      string arr[];
      Split(arr_Group[i],"-",arr);
      string main = arr[0];
      string hedge = arr[1];
      string reverse = arr[2];
      string type = arr[3];
      StringToUpper(main);
      StringToUpper(hedge); 
      arr_Group_MAIN[i]  = main;
      arr_Group_HEDGE[i] = hedge;
      arr_Group_REVERSE[i] = reverse;
      arr_Group_TYPE[i] = type;
      if(CAL_COMFORT_ZONE == "N"){
         arr_Comfort_Zone[i] = 0;
      }else{
         arr_Comfort_Zone[i] = PairSeparateTestCustom(main,hedge,365,PERIOD_D1);
      }
      arr_hedge_open[i] = -99;
      if(iOpen(main,PERIOD_M1,1) > iOpen(hedge,PERIOD_M1,1)){
         arr_Group_MAIN_Direction[i] = OP_SELL;
         arr_Group_HEDGE_Direction[i] = OP_BUY;
      }else{
         arr_Group_MAIN_Direction[i] = OP_BUY;
         arr_Group_HEDGE_Direction[i] = OP_SELL;
      } 
      arr_max_profit[i] = 0;
      arr_order_status[i] = "";
      arr_order_status_hedge[i] = "";
      arr_acceptable_profit[i] = 0;
      arr_allow_symbol[i] = "Y";
      Sleep(300);
   }   
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function Init: ",fnError);  
      ResetLastError(); 
   } 
} 

void ReloadPairSpace(){  
   for(int i = 0; i < size; i++){ 
      string main = arr_Group_MAIN[i];
      string hedge = arr_Group_HEDGE[i]; 
      int comfortZone = 0;//PairSeparateTestCustom(main,hedge,365,PERIOD_D1);
      //arr_Comfort_Zone[i] = comfortZone;
       if(CAL_COMFORT_ZONE == "N"){
         comfortZone = 0;
      }else{
         comfortZone = PairSeparateTestCustom(main,hedge,365,PERIOD_D1);
      }
      arr_Comfort_Zone[i] = comfortZone;
      
       if(iOpen(main,PERIOD_M1,0) > iOpen(hedge,PERIOD_M1,0)){
         arr_Group_MAIN_Direction[i] = OP_SELL;
         arr_Group_HEDGE_Direction[i] = OP_BUY;
      }else{
         arr_Group_MAIN_Direction[i] = OP_BUY;
         arr_Group_HEDGE_Direction[i] = OP_SELL;
      }
      
   }
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function ReloadPairSpace: ",fnError);  
      ResetLastError();
   }
}

 

void rebind_ticket(){      
     ArrayFree(arr_first_open);
     ArrayFree(arr_current_open);
     ArrayFree(arr_current_open_datetime);      
     ArrayResize(arr_first_open,size);
     ArrayResize(arr_current_open,size);
     ArrayResize(arr_current_open_datetime,size);
     for(int i = 0; i < size; i++){  
        arr_first_open[i] = -99;
        arr_current_open[i] = -99;
        arr_current_open_datetime[i] = NULL;//D'2000.01.01 00:00';
     }
     
     for (int i = 0; i <= (OrdersTotal() - 1); i++)
     {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         { 
            int number = OrderMagicNumber();
            string comment = OrderComment();
            for(int n = 0; n < size; n++){
               string symbol_main = arr_Group_MAIN[n];
               string symbol_hedge = arr_Group_HEDGE[n];
               string type = arr_Group_TYPE[n];
               if(isFocusedOrder(symbol_main,symbol_hedge,type)){
                  int first_open = arr_first_open[n];
                  int current_open = arr_current_open[n];
                  if(arr_first_open[n] == -99){
                     arr_first_open[n] = number;
                  }
                  if(number < arr_first_open[n]){
                     arr_first_open[n] = number;
                  }
                  
                  if(number > arr_current_open[n]){
                     arr_current_open[n] = number;
                     arr_current_open_datetime[n] = OrderOpenTime();
                  }        
               }  
            }
         }
     }
     int fnError = GetLastError();
     if(fnError > 0){
      Print("Error function rebind_ticket: ",fnError);   
      ResetLastError(); 
     }
}





void ClearOrder(){
   int CloseOrderPendig = ArraySize(arr_ticket_pending_close);
   if(CloseOrderPendig > 0){
      for(int i = 0; i < CloseOrderPendig; i++){
         int ticket = arr_ticket_pending_close[i];
         if(ticket > 0){
            bool isClosed = closeOrder(ticket);
            if(isClosed){
               arr_ticket_pending_close[i] = 0;
            } 
         }
      }
      int j = 0;
      for(int i = 0; i < CloseOrderPendig; i++){
         int ticket = arr_ticket_pending_close[i];
         if(ticket > 0){
            j++;
         }
      }
      if(j == 0){
         ArrayFree(arr_ticket_pending_close);
      }
      
      return;
   }  

  for(int n = 0; n < size;n++){
     arr_Group_Profit[n] = 0; 
  }
  ArrayResize(arr_tpLot,size);
  for (int i = 0; i <= (ArraySize(arr_tpLot) - 1); i++){
      arr_tpLot[i] = -99; 
  }
     
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
     if (OrderSelect(i, SELECT_BY_POS) == true)
     {
            string comment = OrderComment();
            for(int n = 0; n < ArraySize(arr_Group_MAIN);n++){
               string symbol_main = arr_Group_MAIN[n];
               string symbol_hedge = arr_Group_HEDGE[n];
               string type = arr_Group_TYPE[n];
               if(isFocusedOrder(symbol_main,symbol_hedge,type)){  
                    arr_Group_Profit[n] += (OrderProfit() + OrderSwap() + OrderCommission());   
                    double toOrd =  (OrderLots()*100)*TP_Multiply;
                    if(arr_tpLot[n] < toOrd){
                       arr_tpLot[n] = toOrd;
                       
                       
                    }
               } 
            }
     }
  }
  
   
   
     for(int n = 0; n < ArraySize(arr_Group_MAIN);n++){
        double profit = arr_Group_Profit[n];
        int current_open = arr_current_open[n];
        if(current_open != -99){  
           double tp_At = (double)arr_TPGroup[current_open];
           tp_At = arr_tpLot[n];
           string symbol_main = arr_Group_MAIN[n];
           string symbol_hedge = arr_Group_HEDGE[n];  
           string type = arr_Group_TYPE[n];  
           if(profit >= tp_At){ 
              
               //if(profit >= arr_max_profit[n]){ 
               if(profit > arr_acceptable_profit[n])
               {
                  arr_max_profit[n] = profit;
                  arr_order_status[n] = "PENDING";
               }else{ 
                  arr_order_status[n] = "CLOSE";
               }
               if(arr_order_status[n] == "CLOSE"){
                   for (int i = 0; i <= (OrdersTotal() - 1); i++)
                   {
                        if (OrderSelect(i, SELECT_BY_POS) == true)
                        {
                           if(isFocusedOrder(symbol_main,symbol_hedge,type))
                           {
                               int newSize = ArraySize(arr_ticket_pending_close)+1;
                               ArrayResize(arr_ticket_pending_close,newSize);
                               arr_ticket_pending_close[newSize-1] = OrderTicket(); 
                           }
                        }
                   } 
                   arr_order_status[n] = ""; 
                   arr_max_profit[n] = 0;
               } 
            }else{ //if(profit >= tp_At){   
               if(arr_order_status[n] == "PENDING"){
                    //double acceptable_profit = arr_acceptable_profit[n];//(tp_At*0.5);
                    double acceptable_profit = (tp_At*0.5);
                    if(profit >= acceptable_profit){
                       arr_order_status[n] = "CLOSE"; 
                       for (int i = 0; i <= (OrdersTotal() - 1); i++)
                       {
                           if (OrderSelect(i, SELECT_BY_POS) == true)
                           {
                              if(isFocusedOrder(symbol_main,symbol_hedge,type))
                              {
                                  int newSize = ArraySize(arr_ticket_pending_close)+1;
                                  ArrayResize(arr_ticket_pending_close,newSize);
                                  arr_ticket_pending_close[newSize-1] = OrderTicket(); 
                              }
                           }
                       } 
                    }
                    arr_order_status[n] = "";  
                    arr_max_profit[n] = 0;
                }
            } 
            arr_acceptable_profit[n] = profit-(profit*0.03);
        }
        
      }
   

  
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function ClearOrder: ",fnError);  
      ResetLastError();
   }
}



// interface


void ClearInterface(){

   ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrBlack);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrWhite);
   ChartSetInteger(0,CHART_COLOR_GRID,clrBlack);
   ChartSetInteger(0,CHART_COLOR_VOLUME,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrBlack);
   ChartSetInteger(0,CHART_COLOR_BID,clrBlack);
   ChartSetInteger(0,CHART_COLOR_ASK,clrBlack);
   //ChartSetInteger(0,CHART_COLOR_LAST,clrBlack);
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function ClearInterface: ",fnError);  
      ResetLastError();
   }

}


void GenInterface()
{
 
   int y = 40;
   
   string id_header_sym_main =  "lbl_symbol_main";
   string id_header_sym_hedge =  "lbl_symbol_hedge";
   string id_header_Comfort_Zone =  "id_header_Comfort_Zone";
   string id_Current_Zone_head =  "id_Current_Zone_head";
   string id_tp_head =  "id_tp_head";
   string id_current_price_head =  "id_current_price_head";

   
   if(ObjectFind(id_header_sym_main) < 0){
      LabelCreate(0,id_header_sym_main,0,20,20,CORNER_LEFT_UPPER,"Main","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
      LabelCreate(0,id_header_sym_hedge,0,100,20,CORNER_LEFT_UPPER,"Hedge","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      LabelCreate(0,id_header_Comfort_Zone,0,200,20,CORNER_LEFT_UPPER,"COMFORT_ZONE","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      LabelCreate(0,id_Current_Zone_head,0,340,20,CORNER_LEFT_UPPER,"CURRENT_ZONE","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
      
      LabelCreate(0,id_tp_head,0,480,20,CORNER_LEFT_UPPER,"TP_PRICE","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      LabelCreate(0,id_current_price_head,0,580,20,CORNER_LEFT_UPPER,"CURRENT_PRICE","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
   }
   
   for(int i = 0; i< size; i++){
      string symbol = arr_Group_MAIN[i];
      string symbol_hedge = arr_Group_HEDGE[i];
      string SYMBOL_CHECK = arr_Group_REVERSE[i]; 
      string type = arr_Group_TYPE[i];
      string id_symbol_main = "lbl_symbol_main_"+IntegerToString(i);  
      string id_symbol_hedge = "lbl_symbol_hedge_"+IntegerToString(i);  
      string id_Comfort_Zone = "lbl_comfort_zone_"+IntegerToString(i); 
      string id_Current_Zone = "lbl_current_zone_"+IntegerToString(i); 
      string id_tp = "lbl_tp_"+IntegerToString(i); 
      string id_current_price = "lbl_current_price_"+IntegerToString(i); 
      string id_button_allow = "lbl_button_allow_"+IntegerToString(i);
      string id_total_order = "lbl_total_order"+IntegerToString(i); 
      string id_check_condition = "lbl_check_condition"+IntegerToString(i); 
      arr_button_symbol[i] = id_button_allow;
      double tp_At = 0;
      double total_Order = countOrders(symbol,symbol_hedge,type); 
      int current_open = arr_current_open[i];
      if(current_open != -99){
         tp_At = (double)arr_TPGroup[current_open];
         tp_At = arr_tpLot[i];
      }
      
      
      if(ObjectFind(id_symbol_main) < 0){
         color colType = clrWhite;
         if(type == "MAIN"){
            colType = clrBlue;
         }
         if(type == "HEDGE"){
            colType = clrRed;
         }
         LabelCreate(0,id_symbol_main,0,20,y,CORNER_LEFT_UPPER,symbol,"Arial",9,colType,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
         LabelCreate(0,id_symbol_hedge,0,100,y,CORNER_LEFT_UPPER,symbol_hedge,"Arial",9,colType,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         LabelCreate(0,id_total_order,0,170,y,CORNER_LEFT_UPPER,DoubleToString(total_Order,2),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         
         LabelCreate(0,id_Comfort_Zone,0,200,y,CORNER_LEFT_UPPER,IntegerToString(arr_Comfort_Zone[i]),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         LabelCreate(0,id_Current_Zone,0,340,y,CORNER_LEFT_UPPER,IntegerToString(arr_Current_Zone[i]),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         
         LabelCreate(0,id_tp,0,480,y,CORNER_LEFT_UPPER,DoubleToString(tp_At,2),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         LabelCreate(0,id_current_price,0,580,y,CORNER_LEFT_UPPER,DoubleToString(arr_Group_Profit[i],2),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         LabelCreate(0,id_check_condition,0,640,y,CORNER_LEFT_UPPER,CheckOpenCondition(symbol,symbol_hedge,SYMBOL_CHECK,type,PERIOD_M15,10,34,9),"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         
         
         LabelCreate(0,id_button_allow,0,5,y,CORNER_LEFT_UPPER,arr_allow_symbol[i],"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0);
        
         
      }else{
         ObjectSetString(0,id_Comfort_Zone,OBJPROP_TEXT,IntegerToString(arr_Comfort_Zone[i]));
         ObjectSetString(0,id_Current_Zone,OBJPROP_TEXT,IntegerToString(arr_Current_Zone[i]));
         if(arr_Current_Zone[i] < arr_Comfort_Zone[i]){
            ObjectSetInteger(0,id_Current_Zone,OBJPROP_COLOR,clrBlue);
         }else{
            ObjectSetInteger(0,id_Current_Zone,OBJPROP_COLOR,clrRed);
         } 
         ObjectSetString(0,id_tp,OBJPROP_TEXT,DoubleToString(tp_At,2));
         ObjectSetString(0,id_current_price,OBJPROP_TEXT,DoubleToString(arr_Group_Profit[i],2));
         ObjectSetString(0,id_button_allow,OBJPROP_TEXT,arr_allow_symbol[i]);
         ObjectSetString(0,id_total_order,OBJPROP_TEXT,DoubleToString(total_Order,2)); 
      }
      y += 15;
   }
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function GenInterface: ",fnError);  
      ResetLastError(); 
   }
}




bool LabelCreate(const long              chart_ID=0,               // chart's ID
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
  
  
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
   if(id==CHARTEVENT_OBJECT_CLICK) {
      long z=ObjectGetInteger(0,sparam,OBJPROP_ZORDER);
       
      for(int i = 0; i < size; i++){
         if(arr_button_symbol[i] == sparam){
           if( arr_allow_symbol[i] == "Y"){
              arr_allow_symbol[i] = "N";
           }else{
              arr_allow_symbol[i] = "Y";
           }
         }
      }
     /* if (sparam == buttonID) // Close button has been pressed
    {
       // toggleFeedButton(isStopFeed);
    }*/
      //printf("I am %s, my z-order is %i",sparam,z);
      }
  }
  
  
void Tick(){

   setup_money_management();   
   ReloadPairSpace(); 
   rebind_ticket();
   int totalOpen = 0;
   for(int i = 0; i < ArraySize(arr_first_open); i++){
      int firstOpen = arr_first_open[i];
      if(firstOpen >= 0){
         totalOpen++;
      }
   }
   
   for(int i = 0; i< size; i++){
      string SYMBOL_MAIN = arr_Group_MAIN[i];
      string SYMBOL_HEDGE = arr_Group_HEDGE[i];
      string SYMBOL_CHECK = arr_Group_REVERSE[i]; 
      string type = arr_Group_TYPE[i]; 
      int current_zone = PairSeparateTestCustom(SYMBOL_MAIN,SYMBOL_HEDGE,1,PERIOD_M1);
      int hedge_open =  arr_hedge_open[i];
      //Alert(current_zone+" "+SYMBOL_MAIN+"-"+SYMBOL_HEDGE);
      //int current_zone = PairSeparateTestCustomRealtime(SYMBOL_MAIN,SYMBOL_HEDGE);
      arr_Current_Zone[i] = current_zone;
      int current_open = arr_current_open[i];
      int current_open_shift = 0;
      if(arr_current_open_datetime[i] != NULL){
         current_open_shift = iBarShift(SYMBOL_MAIN,PERIOD_M1,arr_current_open_datetime[i]);
      }
      //datetime shiftDate = OrderOpenTime();
      //int shft = iBarShift(OrderSymbol(),PERIOD_M1,shiftDate);
      int first_open = arr_first_open[i];
      int comfort = arr_Comfort_Zone[i];
      string allow_symbol =  arr_allow_symbol[i];
      int DIRECTION_MAIN = arr_Group_MAIN_Direction[i];
      int DIRECTION_HEDGE = arr_Group_HEDGE_Direction[i]; 
      if(type == "HEDGE"){
         if(DIRECTION_MAIN == OP_BUY){
            DIRECTION_MAIN = OP_SELL;
         }else{
            DIRECTION_MAIN = OP_BUY;
         }
         
         if(DIRECTION_HEDGE == OP_BUY){
            DIRECTION_HEDGE = OP_SELL;
         }else{
            DIRECTION_HEDGE = OP_BUY;
         }
      }
      
      int arr_NEXTOPEN_ORDER[];
      ArrayResize(arr_NEXTOPEN_ORDER,lot_Count);
      int zone = 0;
      for(int n = 0; n < (ArraySize(arr_NEXTOPEN_ORDER)); n++)
      {
         zone += ((int)arr_SpaceGroup[n]);
         int nextComfort = comfort + zone;//((n+1)*SPACE);
         arr_NEXTOPEN_ORDER[n] = nextComfort;       
      }
      
      ///////////////////////////////////// 
      /*
      if(current_open >= 0 && hedge_open != 1){ 
         int arr_hedge_open_item[2]; 
         arr_hedge_open_item[0] = -99;
         arr_hedge_open_item[1] = -99; 
         GroupHedge(SYMBOL_MAIN,SYMBOL_HEDGE,SYMBOL_CHECK,arr_hedge_open_item,DIRECTION_MAIN,DIRECTION_HEDGE); 
         openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,arr_hedge_open_item[0],(double)arr_LotSizeGroup[0],0,comfort,current_zone,GROUP_HEDGE_COMMENT);
         openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,arr_hedge_open_item[1],(double)arr_LotSizeGroup[0],0,comfort,current_zone,GROUP_HEDGE_COMMENT);
         arr_hedge_open[i] = 1;
      }
      */
      ///////////////////////////////////
   
      
      for(int n = 0; n < (ArraySize(arr_NEXTOPEN_ORDER)); n++)
      {
         double LOT = (double)arr_LotSizeGroup[n];
         double LOTFirst = (double)arr_LotSizeGroup[n];
         bool isAllowNewPair = true;
         if(TOTAL_PAIR_ALLOW <= totalOpen){
            isAllowNewPair = false;
         }
         int zone_begin = arr_NEXTOPEN_ORDER[n];
         int zone_end = arr_NEXTOPEN_ORDER[n];
         
         if(n != (ArraySize(arr_NEXTOPEN_ORDER) - 1)){
            zone_end = arr_NEXTOPEN_ORDER[n+1];
         }
         /*      
         if((SYMBOL_MAIN == "EURCAD" && SYMBOL_HEDGE == "EURUSD")){
            current_zone = 40000;  
         }  
         */
         
         int newN = n;
         /*
         for(int m = (ArraySize(arr_NEXTOPEN_ORDER)-1); m > 0; m--){
            if(current_zone < arr_NEXTOPEN_ORDER[m] && arr_NEXTOPEN_ORDER[m] > zone_begin){
               zone_end =  arr_NEXTOPEN_ORDER[m];
               double totalLot = 0;
               for(int o = n; o < m;o++ ){
                  totalLot += (double)arr_LotSizeGroup[o];
               }
               LOT = totalLot;
               newN = m;
            }
         }        
         */
         
         //First
         if(n == 0){
            if(current_zone > zone_begin && current_zone < zone_end && isAllowNewPair && allow_symbol == "Y"){
             //  if(first_open < n && current_open < n){  
                 if(current_open != n){ 
                   bool conditioned = isOpenCondition(SYMBOL_MAIN,SYMBOL_HEDGE,SYMBOL_CHECK,type,PERIOD_M15,10,34,9);
                   if(conditioned && first_open < 0)
                   {
                      openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOTFirst,newN,comfort,current_zone,type);
                      openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOTFirst,newN,comfort,current_zone,type);
                      rebind_ticket();
                      current_open = arr_current_open[i];
                      first_open = arr_first_open[i];
                     
                      OPENING_MAIN = SYMBOL_MAIN;
                      OPENING_HEDGE = SYMBOL_HEDGE;
                      OPENING_MAIN_DIREC = DIRECTION_MAIN;
                      OPENING_HEDGE_direc = DIRECTION_HEDGE;
                      OPENING_ZONE_NUMBER = (string)newN;
                      OPENING_lot = LOTFirst;
                      OPENING_comfort = comfort;
                      totalOpen++;
                   }else{
                     conditioned = isOpenCondition(SYMBOL_MAIN,SYMBOL_HEDGE,SYMBOL_CHECK,type,PERIOD_H1,15,35,9);
                     Print(SYMBOL_MAIN+"/"+SYMBOL_HEDGE+": "+(string)n+" "+(string)conditioned);
                     if(conditioned && first_open >= 0){
                         //LOTFirst = MathAbs(comfort/current_zone) * lot_size; 
                         openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOTFirst,newN,comfort,current_zone,type);
                         openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOTFirst,newN,comfort,current_zone,type);
                         rebind_ticket();
                         current_open = arr_current_open[i];
                         first_open = arr_first_open[i];
                        
                         OPENING_MAIN = SYMBOL_MAIN;
                         OPENING_HEDGE = SYMBOL_HEDGE;
                         OPENING_MAIN_DIREC = DIRECTION_MAIN;
                         OPENING_HEDGE_direc = DIRECTION_HEDGE;
                         OPENING_ZONE_NUMBER = (string)newN;
                         OPENING_lot = LOTFirst;
                         OPENING_comfort = comfort;
                         totalOpen++;
                     }
                   }
                 }
             //  }
            }
         }
         
         if(n > 0 && n < (ArraySize(arr_NEXTOPEN_ORDER) - 1)){
            if(current_zone > zone_begin && current_zone < zone_end && isAllowNewPair && allow_symbol == "Y"){
              // if(first_open < n && current_open < n){
                 if(current_open != n){ 
                   bool isFirstOpen = (totalOpen == 0 ? true : false);
                    bool conditioned = isOpenCondition(SYMBOL_MAIN,SYMBOL_HEDGE,SYMBOL_CHECK,type,PERIOD_M15,10,34,9);
                   //bool Reversed = isReverseZone(SYMBOL_MAIN,SYMBOL_HEDGE,current_zone,comfort,current_open_shift);
                   //if(conditioned || isFirstOpen){
                   if(conditioned && first_open < 0){
                      openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOT,newN,comfort,current_zone,type);
                      openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOT,newN,comfort,current_zone,type);
                      rebind_ticket();
                      current_open = arr_current_open[i];
                      first_open = arr_first_open[i];
                      
                      OPENING_MAIN = SYMBOL_MAIN;
                      OPENING_HEDGE = SYMBOL_HEDGE;
                      OPENING_MAIN_DIREC = DIRECTION_MAIN;
                      OPENING_HEDGE_direc = DIRECTION_HEDGE;
                      OPENING_ZONE_NUMBER = (string)newN;
                      OPENING_lot = LOT;
                      OPENING_comfort = comfort;
                      totalOpen++;
                   }else{
                     conditioned = isOpenCondition(SYMBOL_MAIN,SYMBOL_HEDGE,SYMBOL_CHECK,type,PERIOD_H1,15,35,9);
                     Print(SYMBOL_MAIN+"/"+SYMBOL_HEDGE+": "+(string)n+" "+(string)conditioned);
                     if(conditioned && first_open >= 0){
                         //LOTFirst = MathAbs(comfort/current_zone) * lot_size; 
                         openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOTFirst,newN,comfort,current_zone,type);
                         openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOTFirst,newN,comfort,current_zone,type);
                         rebind_ticket();
                         current_open = arr_current_open[i];
                         first_open = arr_first_open[i];
                        
                         OPENING_MAIN = SYMBOL_MAIN;
                         OPENING_HEDGE = SYMBOL_HEDGE;
                         OPENING_MAIN_DIREC = DIRECTION_MAIN;
                         OPENING_HEDGE_direc = DIRECTION_HEDGE;
                         OPENING_ZONE_NUMBER = (string)newN;
                         OPENING_lot = LOTFirst;
                         OPENING_comfort = comfort;
                         totalOpen++;
                     }
                   }
                 }
              // }                
            }
         }
         
         //Last
         if(n == (ArraySize(arr_NEXTOPEN_ORDER) - 1)){
            if(current_zone > zone_begin && isAllowNewPair && allow_symbol == "Y"){
            //   if(first_open != n && current_open != n){
                 if(current_open != n){ 
                   bool isFirstOpen = (totalOpen == 0 ? true : false);
                   bool conditioned = isOpenCondition(SYMBOL_MAIN,SYMBOL_HEDGE,SYMBOL_CHECK,type,PERIOD_M15,10,34,9);
                 //  bool Reversed = isReverseZone(SYMBOL_MAIN,SYMBOL_HEDGE,current_zone,comfort,current_open_shift);
                   //if(conditioned || isFirstOpen){
                   if(conditioned && first_open < 0){
                      openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOT,newN,comfort,current_zone,type);
                      openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOT,newN,comfort,current_zone,type);
                      rebind_ticket();
                      current_open = arr_current_open[i];
                      first_open = arr_first_open[i];
                      
                      OPENING_MAIN = SYMBOL_MAIN;
                      OPENING_HEDGE = SYMBOL_HEDGE;
                      OPENING_MAIN_DIREC = DIRECTION_MAIN;
                      OPENING_HEDGE_direc = DIRECTION_HEDGE;
                      OPENING_ZONE_NUMBER = (string)newN;
                      OPENING_lot = LOT;
                      OPENING_comfort = comfort;
                      totalOpen++;
                   }else{
                     conditioned = isOpenCondition(SYMBOL_MAIN,SYMBOL_HEDGE,SYMBOL_CHECK,type,PERIOD_H1,15,35,9);
                     Print(SYMBOL_MAIN+"/"+SYMBOL_HEDGE+": "+(string)n+" "+(string)conditioned);
                     if(conditioned && first_open >= 0){
                         //LOTFirst = MathAbs(comfort/current_zone) * lot_size; 
                         openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOTFirst,newN,comfort,current_zone,type);
                         openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOTFirst,newN,comfort,current_zone,type);
                         rebind_ticket();
                         current_open = arr_current_open[i];
                         first_open = arr_first_open[i];
                        
                         OPENING_MAIN = SYMBOL_MAIN;
                         OPENING_HEDGE = SYMBOL_HEDGE;
                         OPENING_MAIN_DIREC = DIRECTION_MAIN;
                         OPENING_HEDGE_direc = DIRECTION_HEDGE;
                         OPENING_ZONE_NUMBER = (string)newN;
                         OPENING_lot = LOTFirst;
                         OPENING_comfort = comfort;
                         totalOpen++;
                     }
                   }
                 }
             //  }            
            }
         }  
      }     
   }
   
     ClearOrder();
	  GenInterface();
	  int fnError = GetLastError();
     if(fnError > 0){
      Print("Error function OnTick: ",fnError);
      ResetLastError();
     }
}



  bool isReverseZone(string _symbolMain,string _symbolHedge,int current_zone,int comfort,int shift)
  {
      if(shift >= 10){
         //shift = 10;
         int space_highest = 0;
         //int arr_space[];
         //ArrayResize(arr_space,shift-1);
         int reverse_space = 0;
         for(int i = 1; i < shift; i++){
            int space = PairSeparateTestCustomShift(_symbolMain,_symbolHedge,PERIOD_M1,i);
            //arr_space[i-1] = space;
            if(space > space_highest){
               space_highest = space;
            }
         }
         space_highest = MathAbs(space_highest - comfort);
         current_zone = MathAbs(current_zone - comfort);
         reverse_space = (int)(space_highest * 0.75);
         if(current_zone <= reverse_space){ 
            return true;
         }
      }
   // symbol main-hedge ใช้เพื่อเข้าฟังชั่นดึง  pairSeparate แท่งก่อนๆ เพื่อเอามาตรวจสอบว่า trend มีการกลับตัวหรือยัง
   // โดยเริ่มต้นดึงจาก candle shift ล่าสุดที่เปิด order จนถึง caldle ปัจจุบัน [ref]: https://docs.mql4.com/series/ibarshift   , https://docs.mql4.com/trading/orderopentime
   // หลังจากตรวจสอบแล้วว่ามีสัญญาณกลับตัว จะรวมไม้เปิด โดยการรวมไม้ ต้องตรวจสอบจาก zone ที่เปิดล่าสุด กับ zone ปัจจุบันที่เปิด และ คำนวนข้อมูลจาก array arr_LotSizeGroup และ  arr_SpaceGroup
   
   
   return false;
  }
  
  
   double countOrders(string MainSymbol,string HedgeSymbol,string type)
   {
      double count = 0;
      for (int i = 0; i <= (OrdersTotal() - 1); i++)
      {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         {
            if(isFocusedOrder(MainSymbol,HedgeSymbol,type)){
               count++;
            }
         }
      }
      count = (count/2);
      return count;
   }
   
   /*
   bool isOpenCondition(string _SymbolMain,int mainDirection,string _SymbolHedge,int hedgeDirection,string _SymbolCheck,string type)
   {
      bool isOK = false;
      
      double MAIN_MACD_MAIN = iMACD(_SymbolMain,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_MAIN,0);
      double MAIN_MACD_SIGNAL = iMACD(_SymbolMain,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isMainOK = false;
      
      double HEDGE_MACD_MAIN = iMACD(_SymbolHedge,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_MAIN,0);
      double HEDGE_MACD_SIGNAL = iMACD(_SymbolHedge,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isHedgeOK = false;
   
      double CHECK_MACD_MAIN = iMACD(_SymbolCheck,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_MAIN,0);
      double CHECK_MACD_SIGNAL = iMACD(_SymbolCheck,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isCheckOK = false;
      
      string checkWith = "";
      int firstOrSec = -1;
      string chk_1 = StringSubstr(_SymbolCheck,0,3); 
      if(StringFind(_SymbolMain,chk_1,0) != -1)
      {
         checkWith = "MAIN";
         firstOrSec = StringFind(_SymbolMain,chk_1,0); 
      }else{ 
         checkWith = "HEDGE";
         firstOrSec = StringFind(_SymbolHedge,chk_1,0);  
      }  
      
      if(type == "MAIN"){
         if(mainDirection < hedgeDirection){
            if(MAIN_MACD_MAIN > MAIN_MACD_SIGNAL){
               isMainOK = true;
            }
            if(HEDGE_MACD_MAIN < HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
            }
            if(checkWith == "MAIN"){ 
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
               if(firstOrSec > 0){
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
            }else{
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               } 
               if(firstOrSec > 0){ 
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){ 
                     isCheckOK = true;
                  }
               }
            }
            
         }else{  
            if(MAIN_MACD_MAIN < MAIN_MACD_SIGNAL){
               isMainOK = true;
            }
            if(HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
            }
            
            if(checkWith == "MAIN"){ 
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
               if(firstOrSec > 0){
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
            }else{
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               } 
               if(firstOrSec > 0){ 
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){ 
                     isCheckOK = true;
                  }
               }
            }
         }
      }
      
      if(type == "HEDGE"){
         if(mainDirection < hedgeDirection){
            if(MAIN_MACD_MAIN > MAIN_MACD_SIGNAL){
               isMainOK = true;
            }
            if(HEDGE_MACD_MAIN < HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
            }    
            
            
            if(checkWith == "MAIN"){ 
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
               if(firstOrSec > 0){
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
            }else{
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               } 
               if(firstOrSec > 0){ 
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){ 
                     isCheckOK = true;
                  }
               }
            }
                    
         }else{
            if(MAIN_MACD_MAIN > MAIN_MACD_SIGNAL){
               isMainOK = true;
            }
            if(HEDGE_MACD_MAIN < HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
            }
            
            
            if(checkWith == "MAIN"){ 
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
               if(firstOrSec > 0){
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               }
            }else{
               if(firstOrSec == 0){
                  if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                     isCheckOK = true;
                  }
               } 
               if(firstOrSec > 0){ 
                  if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){ 
                     isCheckOK = true;
                  }
               }
            }
         }
      }
       
      return isOK;   
   }*/
   
   
   
   
   
   //string CheckOpenCondition(string _SymbolMain,string _SymbolHedge,string _SymbolCheck,string type)
   string CheckOpenCondition(string _SymbolMain,string _SymbolHedge,string _SymbolCheck,string type,int period,int fast,int slow,int signal)
   {
      string isOK = "";
      string symMain = "";
      string symHedge = "";
      if(iOpen(_SymbolMain,PERIOD_CURRENT,0) > iOpen(_SymbolHedge,PERIOD_CURRENT,0))
      {
         symMain = _SymbolMain;
         symHedge = _SymbolHedge;
      }else{
         symMain = _SymbolHedge;
         symHedge = _SymbolMain;
      }
      
      double MAIN_MACD_MAIN = iMACD(symMain,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double MAIN_MACD_SIGNAL = iMACD(symMain,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isMainOK = false;
      
      double HEDGE_MACD_MAIN = iMACD(symHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double HEDGE_MACD_SIGNAL = iMACD(symHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isHedgeOK = false;
   
      double CHECK_MACD_MAIN = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double CHECK_MACD_SIGNAL = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isCheckOK = false;
      
      string checkWith = "";
      int firstOrSec = -1;
      string chk_1 = StringSubstr(_SymbolCheck,0,3); 
      if(StringFind(symMain,chk_1,0) != -1)
      {
         checkWith = "MAIN";
         firstOrSec = StringFind(symMain,chk_1,0); 
      }else{ 
         checkWith = "HEDGE";
         firstOrSec = StringFind(symHedge,chk_1,0);  
      }  
      
      if(type == "MAIN"){
         if(MAIN_MACD_MAIN < MAIN_MACD_SIGNAL){
               isMainOK = true;
         }
         
         if(HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
         }    
          
         if(checkWith == "MAIN"){ 
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
            if(firstOrSec > 0){
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
         }else{
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            } 
            if(firstOrSec > 0){ 
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){ 
                  isCheckOK = true;
               }
            }
         }   
      }
      
      if(type == "HEDGE"){ 
         if(MAIN_MACD_MAIN > MAIN_MACD_SIGNAL){
               isMainOK = true;
         }
         
         if(HEDGE_MACD_MAIN < HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
         }    
          
         if(checkWith == "MAIN"){ 
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
            if(firstOrSec > 0){
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
         }else{
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            } 
            if(firstOrSec > 0){ 
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){ 
                  isCheckOK = true;
               }
            }
         }   
      }
      
    //  if(isMainOK && isHedgeOK && isCheckOK){
          isOK = (symMain+":"+(string)isMainOK+" / "+symHedge+":"+(string)isHedgeOK+" / "+_SymbolCheck+":"+(string)isCheckOK);
      //   isOK = symMain+"";
    //  }
       
      return isOK;   
   }
   
   
   
   bool isOpenCondition(string _SymbolMain,string _SymbolHedge,string _SymbolCheck,string type,int period,int fast,int slow,int signal)
   {
      bool isOK = false;
      string symMain = "";
      string symHedge = "";
      if(iOpen(_SymbolMain,PERIOD_CURRENT,0) > iOpen(_SymbolHedge,PERIOD_CURRENT,0))
      {
         symMain = _SymbolMain;
         symHedge = _SymbolHedge;
      }else{
         symMain = _SymbolHedge;
         symHedge = _SymbolMain;
      }
      
      double MAIN_MACD_MAIN = iMACD(symMain,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double MAIN_MACD_SIGNAL = iMACD(symMain,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isMainOK = false;
      
      double HEDGE_MACD_MAIN = iMACD(symHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double HEDGE_MACD_SIGNAL = iMACD(symHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isHedgeOK = false;
   
      double CHECK_MACD_MAIN = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double CHECK_MACD_SIGNAL = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      bool isCheckOK = false;
      
      string checkWith = "";
      int firstOrSec = -1;
      string chk_1 = StringSubstr(_SymbolCheck,0,3); 
      if(StringFind(symMain,chk_1,0) != -1)
      {
         checkWith = "MAIN";
         firstOrSec = StringFind(symMain,chk_1,0); 
      }else{ 
         checkWith = "HEDGE";
         firstOrSec = StringFind(symHedge,chk_1,0);  
      }  
      
      if(type == "MAIN"){
         if(MAIN_MACD_MAIN < MAIN_MACD_SIGNAL){
               isMainOK = true;
         }
         
         if(HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
         }    
          
         if(checkWith == "MAIN"){ 
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
            if(firstOrSec > 0){
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
         }else{
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            } 
            if(firstOrSec > 0){ 
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){ 
                  isCheckOK = true;
               }
            }
         }   
      }
      
      if(type == "HEDGE"){ 
         if(MAIN_MACD_MAIN > MAIN_MACD_SIGNAL){
               isMainOK = true;
         }
         
         if(HEDGE_MACD_MAIN < HEDGE_MACD_SIGNAL){
               isHedgeOK = true;
         }    
          
         if(checkWith == "MAIN"){ 
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
            if(firstOrSec > 0){
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            }
         }else{
            if(firstOrSec == 0){
               if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
                  isCheckOK = true;
               }
            } 
            if(firstOrSec > 0){ 
               if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){ 
                  isCheckOK = true;
               }
            }
         }   
      }
      
      if(isMainOK && isHedgeOK && isCheckOK){
         // Alert(symMain+":"+isMainOK+" \n "+symHedge+":"+isHedgeOK+" \n "+_SymbolCheck+":"+isCheckOK);
         isOK = true;
      }
       
      return isOK;   
   }
   
   
   
   bool GroupHedge(string _SymbolMain,string _SymbolHedge,string _SymbolCheck,int &arr[],int dMain,int dHedge)
   {  
      string direction_MAIN = "";
      string direction_HEDGE = "";
      /*
      string chk_1 = StringSubstr(_SymbolCheck,0,3);
      string chk_2 = StringSubstr(_SymbolCheck,3,3); 
      if(StringFind(_SymbolMain,chk_1,0) != -1)
      {
        if(StringFind(_SymbolMain,chk_1,0) == 0){
            direction_MAIN = "SAME"; 
         }else{
            direction_MAIN = "DIFFERENCE"; 
         }
      }else{
         if(StringFind(_SymbolHedge,chk_1,0) == 0){
            direction_MAIN = "SAME"; 
         }else{
            direction_MAIN = "DIFFERENCE"; 
         }
      } 
      
      if(StringFind(_SymbolMain,chk_2,0) != -1)
      {
        if(StringFind(_SymbolMain,chk_2,0) == 0){
            direction_HEDGE = "SAME"; 
         }else{
            direction_HEDGE = "DIFFERENCE"; 
         }
      }else{
         if(StringFind(_SymbolHedge,chk_2,0) == 0){
            direction_HEDGE = "SAME"; 
         }else{
            direction_HEDGE = "DIFFERENCE"; 
         }
      }
      */
      /*
      if(dMain == OP_BUY){
         direction_MAIN = OP_SELL;
         direction_HEDGE = OP_BUY;
      }
      
      if(dMain == OP_SELL){
         direction_MAIN = OP_BUY;
         direction_HEDGE = OP_SELL;
      }
      */
   /*
      double MAIN_MACD_MAIN = iMACD(_SymbolMain,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_MAIN,0);
      double MAIN_MACD_SIGNAL = iMACD(_SymbolMain,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_SIGNAL,0);
      
      double HEDGE_MACD_MAIN = iMACD(_SymbolHedge,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_MAIN,0);
      double HEDGE_MACD_SIGNAL = iMACD(_SymbolHedge,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_SIGNAL,0);
   */ 
   /*
      double CHECK_MACD_MAIN = iMACD(_SymbolCheck,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_MAIN,0);
      double CHECK_MACD_SIGNAL = iMACD(_SymbolCheck,PERIOD_H4,10,34,9,PRICE_CLOSE,MODE_SIGNAL,0);
      if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
         if(direction_MAIN == "SAME"){  
            arr[0] = OP_BUY;
         }else{
            arr[0] = OP_SELL;
         }
         
         if(direction_HEDGE == "SAME"){  
            arr[1] = OP_BUY;
         }else{
            arr[1] = OP_SELL;
         }
      }else{
        if(direction_MAIN == "SAME"){  
            arr[0] = OP_SELL;
         }else{
            arr[0] = OP_BUY;
         }
         
         if(direction_HEDGE == "SAME"){  
            arr[1] = OP_SELL;
         }else{
            arr[1] = OP_BUY;
         }
      }
      */
       
      return true;
      
   }
  
  
  
  
  
  /////////
 // 1. ตรวจสอบว่าการเปิด order ครั้งแรก order อยู่ที่ตำแหน่งอื่น ที่ไม่ใช้ 0 หรือไม่ (ในกรณีที่ไม่ได้เปิดใน space ที่ 0 จริงๆ)
 // 2. ลอง hardcode test zone ดูว่า ถ้ามีการไหลกลับเกิน 25 % จะเปิดไม้หรือไม่ และไม้ที่เปิด เลข 0rder ถูกต้องใช่หรือไม่
 // 3. เช็คระบบเปิด order ตาม current balance ถูกต้องหรือไม่ (ทุกๆ 1000 จะเปิด 0.01)
  ////////