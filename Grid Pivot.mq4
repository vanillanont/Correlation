//+------------------------------------------------------------------+
//|                                                      Hedging.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict 
  
double Arr_Ratio_High[];
double Arr_Ratio_Low[];
double Arr_High[];
double Arr_Low[];
double Arr_Ratio_Candle_High[];
double Arr_Ratio_Candle_Low[];
int AcceptOpen = 5;
int MaximumOrder = 1;
double pivot = 0; 
double Arr_Open_Price[];
double Arr_isOpened_Price[];
bool isFirstOrderOpen = false;
int OP_TYPE = 0; 
int Arr_CloseTicket[];
double Tp_price_minimum = 0;

string btn_Pause = "btn_Pause";
string btn_Close = "btn_Close";
bool isPause = false;
bool isCloseAll = false;
bool isSymbolFocus = false;
int OnInit()
  {      
   ObjectsDeleteAll(); 
   Util_ButtonCreate(0,btn_Pause,0,20,30,100,18,CORNER_LEFT_UPPER,"STOP","Arial",10,clrWhite,clrRed);
   Util_ButtonCreate(0,btn_Close,0,20,60,100,18,CORNER_LEFT_UPPER,"CLOSE ALL","Arial",10,clrWhite,clrRed);
      
   
   //RatioCal(PERIOD_CURRENT,145,MODE_LOW);
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
   isSymbolFocus = isFocusSymbol();
   Tp_price_minimum = 0;
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
      ArrayFree(Arr_Open_Price);
      ArrayFree(Arr_isOpened_Price);
      isFirstOrderOpen = false;
      isCloseAll = false;
      OP_TYPE = 0;
      //ObjectsDeleteAll();
      SetHLine("PIVOT",pivot,clrGreen); 
   }     
   
   if(Util_IsNewBar(PERIOD_D1))
   {
      //ObjectsDeleteAll();
      pivot = GetPivot(Symbol()); 
      SetHLine("PIVOT",pivot,clrGreen); 
   } 
   double price = (MarketInfo(Symbol(),MODE_BID)+MarketInfo(Symbol(),MODE_ASK))/(double)2;

   double previous_open = iOpen(Symbol(),PERIOD_H1,1);
   double previous_close = iClose(Symbol(),PERIOD_H1,1);
   double previous_low = iLow(Symbol(),PERIOD_H1,1);
   double previous_high = iHigh(Symbol(),PERIOD_H1,1);
   
   double previous_second_open = iOpen(Symbol(),PERIOD_H1,2);
   double previous_second_close = iClose(Symbol(),PERIOD_H1,2);
   double previous_second_low = iLow(Symbol(),PERIOD_H1,2);
   double previous_second_high = iHigh(Symbol(),PERIOD_H1,2);
   
   double previous_third_open = iOpen(Symbol(),PERIOD_H1,3);
   double previous_third_close = iClose(Symbol(),PERIOD_H1,3);
   double previous_third_low = iLow(Symbol(),PERIOD_H1,3);
   double previous_third_high = iHigh(Symbol(),PERIOD_H1,3); 
   
   double previous_fourth_open = iOpen(Symbol(),PERIOD_H1,4);
   double previous_fourth_close = iClose(Symbol(),PERIOD_H1,4);
   double previous_fourth_low = iLow(Symbol(),PERIOD_H1,4);
   double previous_fourth_high = iHigh(Symbol(),PERIOD_H1,4);
   
   double previous_fifth_open = iOpen(Symbol(),PERIOD_H1,5);
   double previous_fifth_close = iClose(Symbol(),PERIOD_H1,5);
   double previous_fifth_low = iLow(Symbol(),PERIOD_H1,5);
   double previous_fifth_high = iHigh(Symbol(),PERIOD_H1,5);
   
   if(isPause == false && isSymbolFocus == true){
       if(price < pivot){ 
      // buy
         if(
               previous_fifth_open > previous_fifth_close 
            && previous_fourth_open > previous_fourth_close 
            && previous_third_open > previous_third_close 
            && previous_second_open > previous_second_close 
            && previous_open > previous_close 
            && isFirstOrderOpen == false
            ){
                Util_OpenOrder(Symbol(),OP_BUY,0.01,"GP_"+Symbol()+"_0"); 
                isFirstOrderOpen = true;
                OP_TYPE = OP_BUY;
                ArrayResize(Arr_Open_Price,50);
                ArrayResize(Arr_isOpened_Price,50);
                double begin_price = MarketInfo(Symbol(),MODE_ASK);
                int Buy_Step = Util_PriceNoDigit(begin_price);     
                for(int i = 0; i < 50; i++){ 
                  Buy_Step -= 100;
                  Arr_Open_Price[i] = Buy_Step/(double)Util_DivideDigit();  
                  //SetHLine("GRID_"+DoubleToStr(Arr_Open_Price[i]),Arr_Open_Price[i],clrYellow);    
                }
            }
      }else{ 
      // sell
         if(
               previous_fifth_open < previous_fifth_close 
            && previous_fourth_open < previous_fourth_close 
            && previous_third_open < previous_third_close 
            && previous_second_open < previous_second_close 
            && previous_open < previous_close 
            && isFirstOrderOpen == false
            ){
                Util_OpenOrder(Symbol(),OP_SELL,0.01,"GP_"+Symbol()+"_0"); 
                isFirstOrderOpen = true;
                OP_TYPE = OP_SELL;
                ArrayResize(Arr_Open_Price,50);
                ArrayResize(Arr_isOpened_Price,50);
                double begin_price = MarketInfo(Symbol(),MODE_BID);
                int Sell_Step = Util_PriceNoDigit(begin_price); 
                for(int i = 0; i < 50; i++){ 
                  Sell_Step += 100;
                  Arr_Open_Price[i] = Sell_Step/(double)Util_DivideDigit(); 
                  //SetHLine("GRID_"+DoubleToStr(Arr_Open_Price[i]),Arr_Open_Price[i],clrYellow);   
                }
            }
      }
   }
  
   
   if(isFirstOrderOpen == true){ 
      double currentPrice = (OP_TYPE == OP_BUY) ? MarketInfo(Symbol(),MODE_ASK) : MarketInfo(Symbol(),MODE_BID);
      for(int i = 0; i < 50; i++){
         double openPrice = Arr_Open_Price[i]; 
         bool isReady = isOrderReady(currentPrice,openPrice);
         bool isOpened = Arr_isOpened_Price[i];
         if(isReady == true && isOpened == false){
            Util_OpenOrder(Symbol(),OP_TYPE,0.01,"GP_"+Symbol()+"_0"); 
            Arr_isOpened_Price[i] = true;
         }
      } 
   }
   
       double profit = 0;
       for (int i = 0; i < OrdersTotal(); i++)
       {
          if (OrderSelect(i, SELECT_BY_POS) == true)
          {   
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){ 
               if(StringFind(OrderComment(),"GP_"+Symbol(),0) >= 0){
                  profit += (OrderProfit() + OrderSwap() + OrderCommission()); 
                  Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                  Tp_price_minimum += 1;
               }
            } 
          }
       } 
       Tp_price_minimum = 0.01*(Tp_price_minimum*100);
       if(isCloseAll == true){
         Tp_price_minimum = -1000000;
       }
       if(profit < Tp_price_minimum){ 
            ArrayFree(Arr_CloseTicket); 
       } 
       Comment("TP At : "+DoubleToStr(Tp_price_minimum)+" profit : "+DoubleToStr(profit));
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
 

  

bool Util_CloseOrder(int ticket)
{
        bool iSuccess = false;
    if (OrderSelect(ticket, SELECT_BY_TICKET))
    {
      // if(OrderMagicNumber() == magicNumber){ 
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
      //  }
    }
    int fnError = GetLastError();
    if(fnError > 0){
      Print("Error function closeOrder: ",fnError," Ticket: ",ticket);
      ResetLastError();
    }
    return iSuccess;
}

  
double GetPivot(string symbol,int period = PERIOD_D1,int shift = 1){
   return (iHigh(symbol,period,shift)+iLow(symbol,period,shift))/(double)2;
}

 
double Util_DivideDigit(){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   return StrToDouble(multiple);
}


int Util_PriceNoDigit(double price){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   
   return (int)(price*StrToDouble(multiple));   
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




  bool SetHLine(string name,double price,color clr){ 
       
      if( ObjectFind(name) < 0){
         HLineCreate(0,name,0,price,clr,0,1,true); return true;
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
   
   
  bool Util_ButtonCreate(const long              chart_ID=0,               // chart's ID
                  const string            name="Button",            // button name
                  const int               sub_window=0,             // subwindow index
                  const int               x=0,                      // X coordinate
                  const int               y=0,                      // Y coordinate
                  const int               width=50,                 // button width
                  const int               height=18,                // button height
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                  const string            text="Button",            // text
                  const string            font="Arial",             // font
                  const int               font_size=10,             // font size
                  const color             clr=clrBlack,             // text color
                  const color             back_clr=C'236,233,216',  // background color
                  const color             border_clr=clrNONE,       // border color
                  const bool              state=false,              // pressed/released
                  const bool              back=false,               // in the background
                  const bool              selection=false,          // highlight to move
                  const bool              hidden=true,              // hidden in the object list
                  const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create the button
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse
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
         if(sparam == btn_Pause){    
            
            if(isPause == false){  
                  ObjectSetString(0,btn_Pause,OBJPROP_TEXT,"START");   
                  ObjectSetInteger(0,btn_Pause,OBJPROP_BGCOLOR,clrBlue); 
                  isPause = true;
            }else{ 
                  ObjectSetString(0,btn_Pause,OBJPROP_TEXT,"STOP");   
                  ObjectSetInteger(0,btn_Pause,OBJPROP_BGCOLOR,clrRed); 
                  isPause = false; 
            }
              
            Sleep(200);
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);  
         }
         
          if(sparam == btn_Close){    
            isCloseAll = true;
            Sleep(200);
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);  
         } 
      }
  }
  
  
  bool isFocusSymbol(){
     bool focus = true;
     for (int i = 0; i < OrdersTotal(); i++)
       {
          if (OrderSelect(i, SELECT_BY_POS) == true)
          {   
            if(OrderType() == OP_BUY || OrderType() == OP_SELL){ 
               if(StringFind(OrderComment(),"GP_",0) >= 0){
                  string result[];
                  Util_Split(OrderComment(),"_",result);
                  if(result[1] != Symbol()){
                     focus = false;
                  }
               }
            } 
          }
       }  
    return focus;
  }
  
  void Util_Split(string text,string split,string & results[]){
   StringSplit(text,StringGetCharacter(split,0),results);
   int fnError = GetLastError();
   if(fnError > 0){ 
     // Print("Error function Split: ",fnError," - ",text);  
     // ResetLastError();
   }
}