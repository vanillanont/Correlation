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
double arr_Group_Profit[]; 
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
 
int SYMBOL_MAIN_SEND = OP_SELL;
int SYMBOL_HEDGE_SEND = OP_BUY;
int CONFORT_ZONE = 0; 
 
bool clear_order = false;
double TOTAL_TAKE_PROFIT = 0;
bool hasFocusedOrder = false; 
extern double reduce_risk = 1;
 
int OnInit()
  {
  ClearInterface();
     GenArrayGroup(); 
     GenNewArrayZone();
     setup_money_management();
     rebind_ticket();
        
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
   GenNewArrayZone();
   rebind_ticket();
	 
   int size = ArraySize(arr_Group_MAIN);
   for(int i = 0; i< ArraySize(arr_Group_MAIN); i++){
      string SYMBOL_MAIN = arr_Group_MAIN[i];
      string SYMBOL_HEDGE = arr_Group_HEDGE[i];
      int current_zone = PairSeparateTestCustom(SYMBOL_MAIN,SYMBOL_HEDGE,1,PERIOD_M1);
      int current_open = arr_current_open[i];
      int first_open = arr_first_open[i];
      int comfort = arr_Comfort_Zone[i];
      int DIRECTION_MAIN = arr_Group_MAIN_Direction[i];
      int DIRECTION_HEDGE = arr_Group_HEDGE_Direction[i]; 
      int arr_NEXTOPEN_ORDER[];
      ArrayResize(arr_NEXTOPEN_ORDER,lotNumbers);
      for(int n = 0; n < (ArraySize(arr_NEXTOPEN_ORDER)); n++)
      {
         int nextComfort = comfort + ((n)*1000);
         arr_NEXTOPEN_ORDER[n] = nextComfort;       
      }
      
      
      for(int n = 0; n < (ArraySize(arr_NEXTOPEN_ORDER)); n++)
      {
        
         //if(SYMBOL_MAIN == "GBPAUD" && SYMBOL_HEDGE == "GBPCHF" && n == 0){
            //current_zone = 49000;
         //}
      
         double LOT = (double)arr_LotSizeGroup[n];
         bool isAllowNewPair = true;
         int zone_begin = arr_NEXTOPEN_ORDER[n];
         int zone_end = arr_NEXTOPEN_ORDER[n];
         if(n != (ArraySize(arr_NEXTOPEN_ORDER) - 1)){
            zone_end = arr_NEXTOPEN_ORDER[n+1];
         }
         //First
         if(n == 0){
            if(current_zone > zone_begin && current_zone < zone_end && isAllowNewPair){
               if(first_open < n && current_open < n){ 
                  openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOT,n,comfort);
                  openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOT,n,comfort);
                  rebind_ticket();
                   current_open = arr_current_open[i];
                  first_open = arr_first_open[i];
               }
            }
         }
         
         if(n > 0 && n < (ArraySize(arr_NEXTOPEN_ORDER) - 1)){
            if(current_zone > zone_begin && current_zone < zone_end && isAllowNewPair){
               
               if(first_open < n && current_open < n){
                     openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOT,n,comfort);
                     openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOT,n,comfort);
                     rebind_ticket();
                      current_open = arr_current_open[i];
                     first_open = arr_first_open[i];
               }
               /*   
               //if(first_open == -99 && current_open == -99){ 
               if(first_open > n && current_open > n){ 
                     openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOT,n,comfort);
                     openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOT,n,comfort);
                     rebind_ticket();
                     current_open = arr_current_open[i];
                     first_open = arr_first_open[i];
               }
               */
               
            }
         }
         
         //Last
         if(n == (ArraySize(arr_NEXTOPEN_ORDER) - 1)){
            if(current_zone > zone_begin && isAllowNewPair){
               if(first_open != n && current_open != n){
                  openOrder(SYMBOL_MAIN,SYMBOL_HEDGE,DIRECTION_MAIN,LOT,n,comfort);
                  openOrder(SYMBOL_HEDGE,SYMBOL_MAIN,DIRECTION_HEDGE,LOT,n,comfort);
                  rebind_ticket();
                   current_open = arr_current_open[i];
                  first_open = arr_first_open[i];
               }            
            }
         } 
      }      
      
   }
   
     ClearOrder();
     
   
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
            
            iSuccess = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), mode), 10, clrRed);
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
        iSuccess = OrderSend(_symbol, cmd, lot, price, 10, 0.0, 0.0, _symbol+"_"+_symbol_hedge+"_"+IntegerToString(group_id)+"_"+IntegerToString(begin_order)+"_", group_id, 0, clrGreen); 
        
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
   ArrayResize(arr_Group_Profit,size); 
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
      int comfortZone = PairSeparateTestCustom(main,hedge,365,PERIOD_D1);
      arr_Comfort_Zone[i] = comfortZone;
   }
}


void GenNewArrayZone(){
   int size = ArraySize(arr_Group_MAIN);
   ArrayResize(arr_first_open,size);
   ArrayResize(arr_current_open,size);
   for(int i = 0; i < size; i++){ 
      arr_first_open[i] = -99;
      arr_current_open[i] = -99;
   }
}


void rebind_ticket(){
     
     for (int i = 0; i <= (OrdersTotal() - 1); i++)
     {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         { 
            string comment = OrderComment();
            for(int n = 0; n < ArraySize(arr_Group_MAIN);n++){
               string symbol_main = arr_Group_MAIN[n];
               string symbol_hedge = arr_Group_HEDGE[n];
               int number = OrderMagicNumber();
               if(isFocusedOrder(symbol_main,symbol_hedge)){
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
                  }             
                  
               }
            }
         }
     }
}





void ClearOrder(){

  for(int n = 0; n < ArraySize(arr_Group_MAIN);n++){
     arr_Group_Profit[n] = 0;
  }
            
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
     if (OrderSelect(i, SELECT_BY_POS) == true)
     {
            string comment = OrderComment();
            for(int n = 0; n < ArraySize(arr_Group_MAIN);n++){
               string symbol_main = arr_Group_MAIN[n];
               string symbol_hedge = arr_Group_HEDGE[n]; 
               if(isFocusedOrder(symbol_main,symbol_hedge)){
                    arr_Group_Profit[n] += (OrderProfit() + OrderSwap() + OrderCommission());  
               }
            }
     }
  }
  
  
  for(int n = 0; n < ArraySize(arr_Group_MAIN);n++){
     double profit = arr_Group_Profit[n];
     int current_open = arr_current_open[n];
     if(current_open != -99){
        double tp_At = (double)arr_TPGroup[current_open];
        string symbol_main = arr_Group_MAIN[n];
        string symbol_hedge = arr_Group_HEDGE[n]; 
        //if(n == 0)
        //{
        // tp_At = -7;
        //}
        if(profit >= tp_At){ 
            for (int i = 0; i <= (OrdersTotal() - 1); i++)
            {
               if (OrderSelect(i, SELECT_BY_POS) == true)
               {
                  if(isFocusedOrder(symbol_main,symbol_hedge))
                  {
                       closeOrder(OrderTicket());
                  }
               }
            } 
         }
     }
  
   }

}



// interface


void ClearInterface(){

   ChartSetInteger(0,CHART_COLOR_BACKGROUND,clrBlack);
   ChartSetInteger(0,CHART_COLOR_FOREGROUND,clrBlack);
   ChartSetInteger(0,CHART_COLOR_GRID,clrBlack);
   ChartSetInteger(0,CHART_COLOR_VOLUME,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_UP,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_DOWN,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CHART_LINE,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BULL,clrBlack);
   ChartSetInteger(0,CHART_COLOR_CANDLE_BEAR,clrBlack);
   ChartSetInteger(0,CHART_COLOR_BID,clrBlack);
   ChartSetInteger(0,CHART_COLOR_ASK,clrBlack);
   ChartSetInteger(0,CHART_COLOR_LAST,clrBlack);
   
   LabelCreate(0,"lable",0,20,20,CORNER_LEFT_UPPER,"Label","Arial",9,clrRed,0,ANCHOR_LEFT_UPPER,false,false,true,0);
   LabelCreate(0,"lable2",0,20,35,CORNER_LEFT_UPPER,"Label","Arial",9,clrRed,0,ANCHOR_LEFT_UPPER,false,false,true,0);
   LabelCreate(0,"lable3",0,20,50,CORNER_LEFT_UPPER,"Label","Arial",9,clrRed,0,ANCHOR_LEFT_UPPER,false,false,true,0);
   LabelCreate(0,"lable4",0,20,20,CORNER_LEFT_UPPER,"Label","Arial",9,clrRed,0,ANCHOR_LEFT_UPPER,false,false,true,0);
   LabelCreate(0,"lable5",0,20,20,CORNER_LEFT_UPPER,"Label","Arial",9,clrRed,0,ANCHOR_LEFT_UPPER,false,false,true,0);

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