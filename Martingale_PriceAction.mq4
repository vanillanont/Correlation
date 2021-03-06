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
extern int Total_Allow_Resolve = 1;
   
double Arr_Box_Begin[];
double Arr_Box_End[]; 

int Size = 0; 
double Tp_Size = 0;
double Lot_Size = 0; 
double Loss_Acceptable = 0; 
int Correct_Percent = 80;
bool Hold = false;
int OrderBuy = 0;
int OrderSell = 0;
bool test = false;
bool clearOrder = false;
double top_wrong = 0; 

void SetupMM()
{
    Lot_Size = (AccountBalance()*0.00005);
    if (Lot_Size < 0.01)
    {
        Lot_Size = 0.01;
    }   
    Tp_Size = Lot_Size * 500;   
    //Tp_Size = Lot_Size * 1000;   
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


int CalOpenClosePip(double open,double close){
   return MathAbs(PriceNoDigit(open)-PriceNoDigit(close));
}


bool isAllowOpen(){
   bool allow = false;
   int avr = 0;
   int total_index = 0;
   int current_space = CalOpenClosePip(iOpen(Symbol(),PERIOD_CURRENT,0),((double)MathAbs(Ask-Bid)/2));
   int before_space = CalOpenClosePip(iOpen(Symbol(),PERIOD_CURRENT,1),iClose(Symbol(),PERIOD_CURRENT,1));
   for(int i = 2; i < 20; i++){
      avr += CalOpenClosePip(iOpen(Symbol(),PERIOD_CURRENT,i),iClose(Symbol(),PERIOD_CURRENT,i));
      total_index++;
   }
   avr = avr/total_index;
   if(avr >= current_space){
      allow = true;
   }
   if(avr >= before_space){
      allow = true;
   }
   return allow;   
}


int OnInit()
  {        
   return(INIT_SUCCEEDED);
  }
  
  void tick(){
      SetupMM();
      double totalOrder = TotalOrders(); 
      double totalProfit = 0;
      string trend = trendDetect(PERIOD_H1); 
      string trend_M30 = trendDetect(PERIOD_M30); 
      string trend_M15 = trendDetect(PERIOD_M15); 
      string trend_H4 = trendDetect(PERIOD_H4); 
      for (int i = 0; i < OrdersTotal(); i++)
      {
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {     
         totalProfit += (OrderProfit() + OrderSwap() + OrderCommission()); 
         double profit = (OrderProfit() + OrderSwap() + OrderCommission()); 
         if(trend == "SIDEWAY"){ 
             if(profit > 0){
                //Util_CloseOrder(OrderTicket());
             }  
          }   
          if(totalOrder == 1){
             /*
             if(trend_M30 == "DOWN"){
               if(OrderType() == OP_BUY){
                   if(profit > 0){
                     //Util_CloseOrder(OrderTicket());
                   }  
               }
             */
               if(OrderType() == OP_SELL){
                  /////////////////
                  //if(MathAbs(PriceNoDigit(Ask)-PriceNoDigit(OrderTakeProfit())) < 300){ 
                  if(MathAbs(PriceNoDigit(Ask)-PriceNoDigit(OrderOpenPrice())) > 300 && Ask < OrderOpenPrice()){
                     //double orderTP = ((PriceNoDigit(OrderTakeProfit())-300))/(double)DivideDigit();
                     double orderTP = OrderTakeProfit();
                     double orderSL = ((PriceNoDigit(OrderOpenPrice())-100))/(double)DivideDigit(); 
                     if(orderSL != OrderStopLoss()){
                        int ord = OrderModify(OrderTicket(),OrderOpenPrice(),orderSL,orderTP,0,clrBlue);
                     }
                  }
               }
               /*
               if(MathAbs(PriceNoDigit(Ask)-PriceNoDigit(OrderTakeProfit())) < 300){ 
                  double orderTP = ((PriceNoDigit(OrderTakeProfit())-300))/(double)DivideDigit();
                  double orderSL = ((PriceNoDigit(OrderOpenPrice())-300))/(double)DivideDigit(); 
                  //OrderModify(OrderTicket(),OrderOpenPrice(),orderSL,orderTP,0,clrBlue);
               }
               
               //////////////// 
             }   
             */
             /*
             if(trend_M30 == "UP"){
               if(OrderType() == OP_SELL){
                   if(profit > 0){
                     //Util_CloseOrder(OrderTicket());
                   }  
               }
               */
               /////////////////
               //if(MathAbs(PriceNoDigit(Bid)-PriceNoDigit(OrderTakeProfit())) < 300){
               if(OrderType() == OP_BUY){ 
                  if(MathAbs(PriceNoDigit(Bid)-PriceNoDigit(OrderOpenPrice())) > 300 && Bid > OrderOpenPrice()){
                     //double orderTP = ((PriceNoDigit(OrderTakeProfit())+300))/(double)DivideDigit();
                     double orderTP = OrderTakeProfit();
                     double orderSL = ((PriceNoDigit(OrderOpenPrice())+100))/(double)DivideDigit();
                     if(orderSL != OrderStopLoss()){
                        int ord = OrderModify(OrderTicket(),OrderOpenPrice(),orderSL,orderTP,0,clrBlue);
                     }
                  }
               }
               /*
               if(MathAbs(PriceNoDigit(Bid)-PriceNoDigit(OrderTakeProfit())) < 300){ 
                  double orderTP = ((PriceNoDigit(OrderTakeProfit())+300))/(double)DivideDigit();
                  double orderSL = ((PriceNoDigit(OrderOpenPrice())+300))/(double)DivideDigit(); 
                  //OrderModify(OrderTicket(),OrderOpenPrice(),orderSL,orderTP,0,clrBlue);
               }
               ////////////////
             }   */
          }       
        }
      }     
      if(totalOrder > 1)
      {
         if(totalProfit  > Tp_Size){    
           for (int i = 0; i <= (OrdersTotal() - 1); i++)
           {
              if (OrderSelect(i, SELECT_BY_POS) == true)
              {
               clearOrder = true;
                 //closeOrder(OrderTicket());
              }
           }
         }
      } 
       
       
      if(clearOrder == true){
           for (int i = 0; i <= (OrdersTotal() - 1); i++)
           {
              if (OrderSelect(i, SELECT_BY_POS) == true)
              { 
                 closeOrder(OrderTicket());
              }
           }
           if(TotalOrders() == 0){
               clearOrder = false;
           }else{
               return;
           }
      }
  
  
   double Arr_Zone[]; 
    
    if(isChangeBar()){  
      Hold = false; 
      ArrayFree(Arr_Box_Begin);
      ArrayFree(Arr_Box_End);
      ObjectsDeleteAll();
         
       for(int i = 0; i < 120; i++){
          double barUp = CustomFractals(Symbol(),PERIOD_CURRENT,MODE_UPPER,i); //iFractals(Symbol(),PERIOD_CURRENT,MODE_UPPER,i); 
          double barDown = CustomFractals(Symbol(),PERIOD_CURRENT,MODE_LOWER,i); //iFractals(Symbol(),PERIOD_CURRENT,MODE_LOWER,i); 
          if(barUp > 0){
            Util_ArrayAddDouble(Arr_Zone,barUp);
            SetHLine("FRAC_HIGH_"+IntegerToString(i),barUp,clrBlueViolet); 
            
          } 
          if(barDown > 0){
            Util_ArrayAddDouble(Arr_Zone,barDown);
            SetHLine("FRAC_DOWN_"+IntegerToString(i),barDown,clrOrangeRed); 
          }  
         
         if(i < 72){
            double priceZigzag = iCustom(Symbol(),0,"ZigZag",12,5,3,0,i);
            if(priceZigzag > 0){
               Util_ArrayAddDouble(Arr_Zone,priceZigzag);
               SetHLine("ZIGZAG_"+IntegerToString(i),priceZigzag,clrWhite); 
            }
         }
       }
    
       
       ArraySort(Arr_Zone,WHOLE_ARRAY,0,MODE_DESCEND);
       double begin_price = 0;
       double end_price = 0;
       for(int i = 0; i < ArraySize(Arr_Zone); i++){
         if(i < 3){
            continue;
         }
       
         if(begin_price == 0){
            begin_price = Arr_Zone[i];
            continue;
         }
         
         if(end_price == 0){ 
            if(space(begin_price,Arr_Zone[i]) <= 100){
               end_price = Arr_Zone[i];
               continue;
            }
         }else{
            if(space(end_price,Arr_Zone[i]) <= 100){
               end_price = Arr_Zone[i];
               continue;
            }
         }
         if(begin_price > 0 && end_price > 0){
           Util_Rectangle("rec_no_"+IntegerToString(i),TimeCurrent(),begin_price,iTime(Symbol(),PERIOD_CURRENT,120),end_price); 
           Util_ArrayAddDouble(Arr_Box_Begin,begin_price);
           Util_ArrayAddDouble(Arr_Box_End,end_price);
         }
         begin_price = 0;
         end_price = 0;      
       }
       
    }

    if(TotalOrders() == 0){
       
       if(trend == "UP" && Hold == false){
            double zigzag_latest = 0;
            double zigzag_before_latest = 0;
            for(int i = 0; i < 120 ; i++){
               if(zigzag_latest == 0){ 
                  zigzag_latest = iCustom(Symbol(),0,"ZigZag",12,5,3,0,i);
                  //zigzag_latest = CustomZigZag(0,i);
                  continue;
               } 
               if(zigzag_latest != 0){ 
                  zigzag_before_latest = iCustom(Symbol(),0,"ZigZag",12,5,3,0,i);
                  //zigzag_before_latest = CustomZigZag(0,i);
                  if(zigzag_before_latest != 0){ break; } 
               } 
               //if(zigzag_latest != 0){ break; } 
            }
            for(int i = 0; i < ArraySize(Arr_Box_Begin); i++){
           // Print("Zigzag (1): "+zigzag_latest+" zigzag (2): "+zigzag_before_latest+" Box_begin :"+Arr_Box_Begin[i]+" Box_end "+Arr_Box_End[i] );
               //if((zigzag_latest > Arr_Box_Begin[i] && zigzag_latest > Arr_Box_End[i]) || (zigzag_before_latest > Arr_Box_Begin[i] && zigzag_before_latest > Arr_Box_End[i])){
               if((zigzag_latest > Arr_Box_Begin[i] && zigzag_latest > Arr_Box_End[i]) || (zigzag_before_latest > Arr_Box_Begin[i] && zigzag_before_latest > Arr_Box_End[i])){
                  //if(Bid < Arr_Box_Begin[i] && Bid > Arr_Box_End[i]){  
                  if(Util_Between(Bid,Arr_Box_Begin[i],Arr_Box_End[i])){
                   if(TotalOrders() < Total_Allow_Resolve){
                      //open buy
                      //if(isAllowOpen()){ 
                         Util_OpenOrderWithSLTP(Symbol(),OP_BUY,Lot_Size,Arr_Zone,"UP");
                         Hold = true; 
                      //}
                   }
                  }
               } 
            }
       }
       
       if(trend == "DOWN" && Hold == false){
            double zigzag_latest = 0;
            double zigzag_before_latest = 0;
            for(int i = 0; i < 120 ; i++){ 
               if(zigzag_latest == 0){ 
                  zigzag_latest = iCustom(Symbol(),0,"ZigZag",12,5,3,0,i);
                  //zigzag_latest = CustomZigZag(0,i);
                  continue;
               } 
               if(zigzag_latest != 0){ 
                  zigzag_before_latest = iCustom(Symbol(),0,"ZigZag",12,5,3,0,i);
                  //zigzag_before_latest = CustomZigZag(0,i);
                  if(zigzag_before_latest != 0){ break; } 
               } 
            }  
            for(int i = 0; i < ArraySize(Arr_Box_Begin); i++){
             //  Print("Zigzag (1): "+zigzag_latest+" zigzag (2): "+zigzag_before_latest+" Box_begin :"+Arr_Box_Begin[i]+" Box_end "+Arr_Box_End[i] );
            
               //if((zigzag_latest < Arr_Box_End[i] && zigzag_latest < Arr_Box_Begin[i]) || (zigzag_before_latest < Arr_Box_End[i] && zigzag_before_latest < Arr_Box_Begin[i])){
               if((zigzag_latest < Arr_Box_End[i] && zigzag_latest < Arr_Box_Begin[i]) || (zigzag_before_latest < Arr_Box_End[i] && zigzag_before_latest < Arr_Box_Begin[i])){
                  //if(Ask > Arr_Box_End[i] && Ask < Arr_Box_Begin[i]){  
                  if(Util_Between(Ask,Arr_Box_Begin[i],Arr_Box_End[i])){
                     if(TotalOrders() < Total_Allow_Resolve){
                        //open sell
                        //if(isAllowOpen()){ 
                           Util_OpenOrderWithSLTP(Symbol(),OP_SELL,Lot_Size,Arr_Zone,"DOWN");
                           Hold = true;
                        //} 
                     }
                  }
               }
                
            }
       }
    }else{
      int totalOrd = TotalOrders();
      if(totalOrd < Total_Allow_Resolve && Hold == false){
         double profit = 0;
         int order_type = 0;
         double latest_price = 0;
         double total_lot = 0;
         for (int i = 0; i < OrdersTotal(); i++)
         {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {     
                order_type = OrderType();
                if(latest_price == 0){
                   latest_price = OrderOpenPrice();
                }
                if(order_type == OP_BUY){
                  if(latest_price > OrderOpenPrice()){
                     latest_price = OrderOpenPrice();
                  }
                }
                
                if(order_type == OP_SELL){
                  if(latest_price < OrderOpenPrice()){
                     latest_price = OrderOpenPrice();
                  }
                }
                profit += (OrderProfit() + OrderSwap() + OrderCommission()); 
                total_lot += OrderLots();
             }
         } 
         if(profit < 0){
            if(order_type == OP_BUY){
               if(Bid < latest_price){ 
                  for(int i = 0; i < ArraySize(Arr_Zone); i++){
                  if(space(Bid,Arr_Zone[i]) <= 50){
                      bool near_before = false;
                      for (int i = 0; i < OrdersTotal(); i++)
                      {
                         if (OrderSelect(i, SELECT_BY_POS) == true)
                         {     
                              if(OrderType() == OP_BUY){
                                 if(space(Bid,OrderOpenPrice()) <= 200){
                                    near_before = true;
                                    break;
                                 }
                              }
                         }
                      }
                      if(near_before == false){
                           if(totalOrd < 2){
                               Util_OpenOrder(Symbol(),OP_BUY,((double)Lot_Size*(double)(totalOrd+1)),"UP");  
                               Hold = true;
                           }else{ 
                              for(int i = 0; i < ArraySize(Arr_Box_Begin); i++){
                                if(Util_Between(Bid,Arr_Box_Begin[i],Arr_Box_End[i]) && space(Bid,latest_price) > 500){  
                                     Util_OpenOrder(Symbol(),OP_BUY,((double)Lot_Size*(double)(totalOrd+1)),"UP"); 
                                    Hold = true;  
                                 } 
                              }
                           } 
                      }
                  }
                    // if(Bid < Arr_Zone[i] && Bid > (PriceNoDigit(Arr_Zone[i])+100/DivideDigit())){
                     //   //Util_OpenOrderWithSLTP(Symbol(),OP_BUY,(total_lot*(double)2),Arr_Zone,"UP");
                    //    Util_OpenOrder(Symbol(),OP_BUY,(total_lot*(double)2),"UP");
                    // }
                  }                
               }
            }
            if(order_type == OP_SELL){
               if(Ask > latest_price){ 
                  //Comment("order_type :"+order_type+" profit : "+profit+" latest_price : "+latest_price+" total_lot : "+total_lot);
                  for(int i = 0; i < ArraySize(Arr_Zone); i++){
                     if(space(Ask,Arr_Zone[i]) <= 50){
                        bool near_before = false;
                         for (int i = 0; i < OrdersTotal(); i++)
                         {
                            if (OrderSelect(i, SELECT_BY_POS) == true)
                            {     
                                 if(OrderType() == OP_SELL){
                                    if(space(Ask,OrderOpenPrice()) <= 200){
                                       near_before = true;
                                       break;
                                    }
                                 }
                            }
                         } 
                         if(near_before == false){
                          if(totalOrd < 2){
                              Util_OpenOrder(Symbol(),OP_SELL,((double)Lot_Size*(double)(totalOrd+1)),"DOWN");
                              Hold = true; 
                           }else{
                               for(int i = 0; i < ArraySize(Arr_Box_Begin); i++){
                                   if(Util_Between(Ask,Arr_Box_Begin[i],Arr_Box_End[i]) && space(Ask,latest_price) > 500){  
                                        Util_OpenOrder(Symbol(),OP_SELL,((double)Lot_Size*(double)(totalOrd+1)),"SELL"); 
                                       Hold = true;  
                                    } 
                                 }
                           }
                         }
                     }
                     //if(Ask > Arr_Zone[i] && Ask < (PriceNoDigit(Arr_Zone[i])-100/DivideDigit())){
                     //   //Util_OpenOrderWithSLTP(Symbol(),OP_SELL,(total_lot*(double)2),Arr_Zone,"DOWN");
                     //   Util_OpenOrder(Symbol(),OP_SELL,(total_lot*(double)2),"DOWN");
                     //}
                  }  
               }
            }
         }
       }
    }
   // ObjectsDeleteAll();
   double prof = 0;
        for (int i = 0; i < OrdersTotal(); i++)
         {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {    
                prof += (OrderProfit() + OrderSwap() + OrderCommission());  
             }
         }
         if(top_wrong > prof){
            top_wrong = prof;
         }
         Comment(top_wrong+" / "+totalProfit); 
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
  int space(double v1,double v2){
      string multiple = "1"; 
      int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
      for(int i = 0;i<digits; i++){
         multiple += "0"; 
      }
      int v1Int = (int)(v1*StrToDouble(multiple));  
      int v2Int = (int)(v2*StrToDouble(multiple));    
      return MathAbs(v1Int-v2Int);
  }
     
     
   void Util_ArrayAddDouble(double & arr[],double value){ 
      ArrayResize(arr,(ArraySize(arr)+1));
      arr[(ArraySize(arr)-1)] = value; 
   }


   void Util_ArrayAddString(string & arr[],string value){ 
      ArrayResize(arr,(ArraySize(arr)+1));
      arr[(ArraySize(arr)-1)] = value; 
   }
   
   
   double CustomZigZag(int timeframe,int i){
      double zigzag_latest = 0;
      double zigzag_before_latest = 0;
      int index_latest = 0;
      int index_before_latest = 0;
      int space_bar = 0;
      for(i; i < 120 ; i++){
         if(zigzag_latest == 0){ 
            zigzag_latest = iCustom(Symbol(),0,"ZigZag",12,5,3,0,i);
            index_latest = i;
            continue;
         } 
         if(zigzag_latest != 0){ 
            zigzag_before_latest = iCustom(Symbol(),0,"ZigZag",12,5,3,0,i);
            index_before_latest = i;
            if(zigzag_before_latest != 0){ break; } 
         } 
         //if(zigzag_latest != 0){ break; } 
      }
      space_bar = MathAbs(index_latest-index_before_latest);
      if(space_bar > 5){
         return iCustom(Symbol(),timeframe,"ZigZag",12,5,3,0,i);
      }else{
         return 0;
      } 
   }
  
  double CustomFractals(string symbol,int period,int mode,int shift)
  {   
      if(shift <= 2) return 0;
      
      double result = 0;
      double current_open = iOpen(symbol,period,shift);
      double current_close = iClose(symbol,period,shift);
      double current_high = iHigh(symbol,period,shift);
      double current_low = iLow(symbol,period,shift);
      
      double before_open = iOpen(symbol,period,shift+1);
      double before_close = iClose(symbol,period,shift+1);
      double before_high = iHigh(symbol,period,shift+1);
      double before_low = iLow(symbol,period,shift+1);
      
      double before2_open = iOpen(symbol,period,shift+2);
      double before2_close = iClose(symbol,period,shift+2);
      double before2_high = iHigh(symbol,period,shift+2);
      double before2_low = iLow(symbol,period,shift+2);
      
      double next_open = iOpen(symbol,period,shift-1);
      double next_close = iClose(symbol,period,shift-1);
      double next_high = iHigh(symbol,period,shift-1);
      double next_low = iLow(symbol,period,shift-1);
      
      
      double next2_open = iOpen(symbol,period,shift-2);
      double next2_close = iClose(symbol,period,shift-2);
      double next2_high = iHigh(symbol,period,shift-2);
      double next2_low = iLow(symbol,period,shift-2);
      
          
      if(mode == MODE_UPPER){
         if((before_high < current_close) && (next_open >= next2_high)){
            result = iFractals(Symbol(),period,mode,shift); 
            if(result > 0){
               result = current_close;
            }
         } 
         
         if((before2_close < before_close) && (before_close < current_close) &&
            (next_open > next2_open)
         ){
            result = iFractals(Symbol(),period,mode,shift); 
            if(result > 0){
               result = current_close;
            }
         } 
      }
      
      if(mode == MODE_LOWER){
         if((before_low > current_close) && (next_open <= next2_low)){
            result = iFractals(Symbol(),period,mode,shift); 
         }
         
         if((before2_close > before_close) && (before_close > current_close) &&
            (next_open < next2_open)
         ){
            result = iFractals(Symbol(),period,mode,shift); 
            if(result > 0){
               result = current_close;
            }
         }
         
      }
      
      return result;
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
      tick();
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

  bool SetHLine(string name,double price,color clr){ 
       
      if( ObjectFind(name) < 0){
         HLineCreate(0,name,0,price,clr); return true;
      }else{
         HLineMove(0,name,price); return true;
      } 
      return false;
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


int Util_OpenOrderWithSLTP(string _symbol, int cmd, double lot,double &arr_zone[],string comment)
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
    double Arr_SLTP[];
    CalSLTP(price,cmd,arr_zone,Arr_SLTP);
    sl = Arr_SLTP[1];
    //sl = 0;
    tp = Arr_SLTP[0];
    //Print("SL : "+sl+" / TP : "+tp );
    /*
    if(cmd == OP_BUY){ 
      sl = NormalizeDouble(price-700*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price+1000*_symbol_Point,_symbol_Digits);
    }else{
      sl = NormalizeDouble(price+700*_symbol_Point,_symbol_Digits);
      tp = NormalizeDouble(price-1000*_symbol_Point,_symbol_Digits);
    } 
    */
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

void CalSLTP(double price,int order_type,double & Arr_Zone[],double & Arr_SLTP[]){
   ArrayResize(Arr_SLTP,2);
   double result = 0;
   int tp = 1000;
   int sl = 700;
   double tp_nearest = 999999999;
   double sl_nearest = 999999999;
   double tp_price = 0;
   double sl_price = 0;
   if(order_type == OP_BUY){ 
      for(int i = 0 ; i < ArraySize(Arr_Zone); i++){
         if(Arr_Zone[i] > price){
            double tp_near = (MathAbs(PriceNoDigit(Arr_Zone[i]) - (PriceNoDigit(price)+1000))*Digits);
            if(tp_near < tp_nearest){
               tp_nearest = tp_near;
               tp_price = Arr_Zone[i];
            }
            /*
            if(tp_nearest == 0){
               tp_nearest = MathAbs(PriceNoDigit(Arr_Zone[i]) - PriceNoDigit(price));
               tp_price = Arr_Zone[i];
            }else{
               if(MathAbs(PriceNoDigit(Arr_Zone[i]) - PriceNoDigit(price)) < tp_nearest){
                  tp_nearest = MathAbs(PriceNoDigit(Arr_Zone[i]) - PriceNoDigit(price));
                  tp_price = Arr_Zone[i];
               }
            }
            */
         }
         
         if(Arr_Zone[i] < price){
            double sl_near = (MathAbs(PriceNoDigit(Arr_Zone[i]) - (PriceNoDigit(price)-700))*Digits);
            if(sl_near < sl_nearest){
               sl_nearest = sl_near;
               sl_price = Arr_Zone[i];
            }
            /*
            if(sl_nearest == 999999999){
               sl_nearest = MathAbs(PriceNoDigit(Arr_Zone[i]) - PriceNoDigit(price));
               sl_price = Arr_Zone[i];
            }else{
               if(MathAbs(PriceNoDigit(Arr_Zone[i]) - PriceNoDigit(price)) < sl_nearest){
                  sl_nearest = MathAbs(PriceNoDigit(Arr_Zone[i]) - PriceNoDigit(price));
                  sl_price = Arr_Zone[i];
               }
            }
            */
         } 
      } 
      if(tp_price == 0 || tp_price == 999999999){
         tp_price = (PriceNoDigit(price)+1000)/DivideDigit();
      } 
      
      if(sl_price == 0 || sl_price == 999999999){
         sl_price = (PriceNoDigit(price)-700)/DivideDigit();
      }
      
      if(MathAbs(PriceNoDigit(tp_price)-PriceNoDigit(price)) > 1200 || MathAbs(PriceNoDigit(tp_price)-PriceNoDigit(price)) < 200){
         tp_price = (PriceNoDigit(price)+1000)/DivideDigit();
      }
      
      if(MathAbs(PriceNoDigit(sl_price)-PriceNoDigit(price)) > 700 || MathAbs(PriceNoDigit(sl_price)-PriceNoDigit(price)) < 200){
         sl_price = (PriceNoDigit(price)-700)/DivideDigit();
      }
      
   }else{ 
      for(int i = 0 ; i < ArraySize(Arr_Zone); i++){
         if(Arr_Zone[i] < price){
             double tp_near = (MathAbs(PriceNoDigit(Arr_Zone[i]) - (PriceNoDigit(price)-1000))*Digits);
             if(tp_near < tp_nearest){
                tp_nearest = tp_near;
                tp_price = Arr_Zone[i];
             }
           
         }
         
         if(Arr_Zone[i] > price){
            double sl_near = (MathAbs(PriceNoDigit(Arr_Zone[i]) - (PriceNoDigit(price)+700))*Digits);
            if(sl_near < sl_nearest){
               sl_nearest = sl_near;
               sl_price = Arr_Zone[i];
            }
         
         }
      }
      if(tp_price == 0 || tp_price == 999999999){
         tp_price = (PriceNoDigit(price)-1000)/DivideDigit();
      } 
      
      if(sl_price == 0 || sl_price == 999999999){
         sl_price = (PriceNoDigit(price)+700)/DivideDigit();
      } 
        
      if(MathAbs(PriceNoDigit(tp_price)-PriceNoDigit(price)) > 1200 || MathAbs(PriceNoDigit(tp_price)-PriceNoDigit(price)) < 200){
         tp_price = (PriceNoDigit(price)-1000)/DivideDigit();
      }
      
      if(MathAbs(PriceNoDigit(sl_price)-PriceNoDigit(price)) > 700 || MathAbs(PriceNoDigit(sl_price)-PriceNoDigit(price)) < 200){
         sl_price = (PriceNoDigit(price)+700)/DivideDigit();
      }
   }
   Arr_SLTP[0] = tp_price;
   Arr_SLTP[1] = sl_price; 
}


int PriceNoDigit(double price){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   return (int)(price*StrToDouble(multiple));   
}

double DivideDigit(){
   string multiple = "1";
   int digits =  (int)MarketInfo(Symbol(),MODE_DIGITS);
   for(int i = 0;i<digits; i++){
      multiple += "0"; 
   }
   return StrToDouble(multiple);
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
  
  void Util_Rectangle(string name,datetime time1,double price1,datetime time2,double price2){
     RectangleCreate(0,name,0,time1,price1,time2,price2,clrGreen);
  }
  
  bool RectangleCreate(const long            chart_ID=0,        // chart's ID
                     const string          name="Rectangle",  // rectangle name
                     const int             sub_window=0,      // subwindow index 
                     datetime              time1=0,           // first point time
                     double                price1=0,          // first point price
                     datetime              time2=0,           // second point time
                     double                price2=0,          // second point price
                     const color           clr=clrRed,        // rectangle color
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines
                     const int             width=1,           // width of rectangle lines
                     const bool            fill=false,        // filling rectangle with color
                     const bool            back=false,        // in the background
                     const bool            selection=true,    // highlight to move
                     const bool            hidden=true,       // hidden in the object list
                     const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a rectangle by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a rectangle! Error code = ",GetLastError());
      return(false);
     }
//--- set rectangle color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the style of rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the rectangle lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the rectangle
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving
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
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, move it 300 points lower than the first one
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }

  
//////////////////////////////


string trendDetect(int timeframe){ 
  string way = "";
  double ArrZigZag[];
   for(int i = 0; i < 120; i++){ 
      double price = iCustom(Symbol(),timeframe,"ZigZag",12,5,3,0,i);
      if(price > 0){
         Util_ArrayAddDouble(ArrZigZag,price);
      }
   }
   
   /*
   int count_odd = 0;
   int count_even = 0;
   double first_odd = ArrZigZag[0];
   double first_even = ArrZigZag[1];
   double avr_odd = 0;
   double avr_even = 0;
   for(int i = 0; i < ArraySize(ArrZigZag); i++){
     // ArrZigZag[i];
      if(i % 2 == 0){ 
         avr_odd += ArrZigZag[i];
         count_odd++;
      }else{
         avr_even += ArrZigZag[i];
         count_even++;
      }
   }
   if(count_odd > 0){
      avr_odd = avr_odd/count_odd;
   }
   if(count_even > 0){
      avr_even = avr_even/count_even;
   }
   
   if((avr_odd > first_odd) && (avr_even > first_even)){
      way = "UP";
   } 
   if((avr_odd < first_odd) && (avr_even < first_even)){
      way = "DOWN";
   }  
   */ 
   
   int loop = 0;
   if(ArraySize(ArrZigZag) > 5){
      loop = 4;
   }else{
      loop = ArraySize(ArrZigZag)-1;
   }
   for(int i = 0; i < loop; i++){ 
      if(i % 2 == 0){ 
         if(i-2 >= 0){  
        
            if(ArrZigZag[i] < ArrZigZag[i-2]){ 
               if(way == "UP" || way == ""){ 
                  way = "UP";
               }else{
                  way = "SIDEWAY";
                  break;
               }
            }else{
               if(way == "DOWN" || way == ""){ 
                  way = "DOWN";
               }else{
                  way = "SIDEWAY";
                  break;
               }
            } 
            
         }
         //count_odd++;
      }else{
         if(i-2 >= 0){  
            
            if(ArrZigZag[i] < ArrZigZag[i-2]){
               if(way == "UP" || way == ""){ 
                  way = "UP";
               }else{
                  way = "SIDEWAY";
                  break;
               }
            }else{
               if(way == "DOWN" || way == ""){ 
                  way = "DOWN";
               }else{
                  way = "SIDEWAY";
                  break;
               }
            }
            
         }
         //count_even++;
      }
   }
   
   return way;
}

bool Util_Between(double price,double price_begin,double price_end){
   bool between = false;
   if(price_begin > price_end){
         if(price < price_begin && price > price_end) between = true;
   }else{
         if(price < price_end && price > price_begin) between = true;
   }
   return between;
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