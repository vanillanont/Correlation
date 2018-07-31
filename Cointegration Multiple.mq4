//+------------------------------------------------------------------+
//|                                       Cointegration Multiple.mq4 |
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

extern string GroupSymbol = "GBPAUD-GBPCHF,AUDUSD-AUDCAD,GBPNZD-EURNZD,EURGBP-EURCHF,EURJPY-GBPJPY,EURAUD-EURCAD"; 
string arr_Group_MAIN[];
string arr_Group_HEDGE[];
int arr_Group_MAIN_Direction[];
int arr_Group_HEDGE_Direction[];
int arr_Comfort_Zone[];
int arr_Current_Zone[];
 
extern string LotSizes = "1,1,1,2,1,1,1,1,1,1";
int lotNumbers = 0;
string arr_LotSizeGroup[];
string arr_TPGroup[];

extern int TOTAL_PAIR_ALLOW = 2;

int arr_current_open[];
int arr_first_open[];

  
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
 
int SYMBOL_MAIN_SEND = OP_SELL;
int SYMBOL_HEDGE_SEND = OP_BUY;
int CONFORT_ZONE = 0; 
 
bool clear_order = false;
double TOTAL_TAKE_PROFIT = 0;
bool hasFocusedOrder = false; 
extern double reduce_risk = 1;
 
int OnInit()
  {
     GenArrayGroup(); 
   setup_money_management();
     
      
   
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

   setup_money_management();   
   ReloadArrayCurrentSpace();
	 
   
   for(int i = 0; i< ArraySize(arr_Group_MAIN); i++){
      int current_zone = arr_Current_Zone[i];
      int current_open = arr_current_open[i];
      int first_open = arr_first_open[i];
      
      int arr_NEXTOPEN_ORDER[];
      ArrayResize(arr_NEXTOPEN_ORDER,lotNumbers);
      for(int n = 0; n < (ArraySize(arr_NEXTOPEN_ORDER)); n++){
         int comfort = arr_Comfort_Zone[i];
         int nextComfort = comfort + ((n+1)*1000);
         arr_NEXTOPEN_ORDER[n] = nextComfort;       
      }
      
      for(int n = 0; n < (ArraySize(arr_NEXTOPEN_ORDER)); n++){
         bool isAllowNewPair = true;
         //First
         if(n == 0){
            if(current_zone > arr_NEXTOPEN_ORDER[n] && current_zone < arr_NEXTOPEN_ORDER[n+1] && isAllowNewPair){
               if(first_open < n && current_open < n){
                  // open order
               }
            }
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[n] && current_zone < arr_NEXTOPEN_ORDER[n+1] && isAllowNewPair){
            
            if(first_open < n && current_open < n){
            
            }
       
            if(first_open > n && current_open > n){
               // open order
            }
            
         }
         
         
         //Last
         if(n == (ArraySize(arr_NEXTOPEN_ORDER) - 1)){
            if(current_zone > arr_NEXTOPEN_ORDER[n] && isAllowNewPair){
               if(first_open != n && current_open != n){
                  // open order
                  
               }            
            }
         } 
      }      
   }
     
   
}
//+------------------------------------------------------------------+

bool isFocusedOrder(string SYMBOL_MAIN,string SYMBOL_HEDGE){
   //OrderSelect needed before call this function
   if(StringFind(OrderComment(),SYMBOL_MAIN,0) >= 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) >= 0){
      return true;
   }else{
      return false;
   }
}

 

 bool isNotFocusedOrder(string SYMBOL_MAIN,string SYMBOL_HEDGE){
     //OrderSelect needed before call this function
     if(StringFind(OrderComment(),SYMBOL_MAIN,0) < 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) < 0){
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
 

int openOrder(string _symbol,string _symbol_hedge, int cmd, double lot, int group_id,int begin_order)
{

    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;

    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 3, 0.0, 0.0, _symbol+"_"+_symbol_hedge+"_"+IntegerToString(group_id)+"_"+IntegerToString(begin_order)+"_", group_id, 0, clrGreen); 
        
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


bool isOpenedOrder(string _symbol,string _symbol_hedge,int ticket_number,int group_id){
   bool opened = false;
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) == true)
    { 
      if(isFocusedOrder(_symbol,_symbol_hedge)){ 
         if(StringFind(OrderComment(),IntegerToString(ticket_number),0) >= 0 && StringFind(OrderComment(),"_"+IntegerToString(group_id)+"_",0) >= 0){
           opened = true; 
           break;
         }
      }
    }
  }
  return opened;
}

  
int PairSeparateTestCustom(string SYMBOL_MAIN,string SYMBOL_HEDGE,int candle_number,int period){ 
      double price_COMPARE = 0;
      int price_AVERAGE = 0;
      int price_MAXIMUM = 0;
      int price_MINIMUM = 0;
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
 
  
    

void setup_money_management()
{   
    double lot_size = (AccountBalance() * 0.0001) / reduce_risk;
    if (lot_size < 0.01)
    {
        lot_size = 0.01;
    }    
    double tp_size = lot_size * 100;
      
    Split(LotSizes,",",arr_LotSizeGroup);
    Split(LotSizes,",",arr_TPGroup);
    int size = ArraySize(arr_LotSizeGroup);
        
        
    lotNumbers = 0;
    for(int i = 0; i < size; i++){
      lotNumbers++;
      string lotGrp = (string)((double)arr_LotSizeGroup[i] * lot_size);
      string lotTP = (string)((double)arr_TPGroup[i] * tp_size);
      arr_LotSizeGroup[i] = lotGrp;
      arr_TPGroup[i]      = lotTP;
    }         
}
 
void Split(string text,string split,string & result[]){
   StringSplit(text,StringGetCharacter(split,0),result);
}

void GenArrayGroup(){
   string arr_Group[];
   Split(GroupSymbol,",",arr_Group);
   int size = ArraySize(arr_Group);
   ArrayResize(arr_Group_MAIN,size);
   ArrayResize(arr_Group_HEDGE,size);  
   ArrayResize(arr_Comfort_Zone,size);      
   ArrayResize(arr_Group_MAIN_Direction,size);
   ArrayResize(arr_Group_HEDGE_Direction,size);  
   for(int i = 0; i < size; i++){
      string arr[];
      Split(arr_Group[i],"-",arr);
      string main = arr[0];
      string hedge = arr[1];
      StringToUpper(main);
      StringToUpper(hedge);
      arr_Group_MAIN[i]  = main;
      arr_Group_HEDGE[i] = hedge;
      arr_Comfort_Zone[i] = PairSeparateTestCustom(main,hedge,365,PERIOD_D1);
      if(iOpen(main,PERIOD_M1,0) > iOpen(hedge,PERIOD_M1,0)){
         arr_Group_MAIN_Direction[i] = OP_SELL;
         arr_Group_HEDGE_Direction[i] = OP_BUY;
      }else{
         arr_Group_MAIN_Direction[i] = OP_BUY;
         arr_Group_HEDGE_Direction[i] = OP_SELL;
      }
      
   }    
}

void ReloadArrayCurrentSpace(){ 
   int size = ArraySize(arr_Group_MAIN);
   for(int i = 0; i < size; i++){ 
      string main = arr_Group_MAIN[i];
      string hedge = arr_Group_HEDGE[i]; 
      int comfortZone = PairSeparateTestCustom(main,hedge,1,PERIOD_M1);
      arr_Comfort_Zone[i] = comfortZone;
   }
}

