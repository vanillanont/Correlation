//+------------------------------------------------------------------+
//|                                                  Golden Gate.mq4 |
//|                                          Bo Bazooka,Vanillanont. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Bo Bazooka,Vanillanont."
#property link      "https://www.metatrader4.com/"
#property version   "1.00"
#property strict 

//#############################################
int ACCOUNT_NUMBER = 8002993;
string cautionText = "Cannot use this EA Please Contact...";
//#############################################
enum AUTOLOT  // Enumeration of named constants
   {
    AUTO   =1,     
    MANUAL =2 
   };   
   
extern AUTOLOT Center_AutoCal = AUTO; // Auto Calculate Center
extern int Candles = 200;
input ENUM_TIMEFRAMES TIMEFRAME_CAL=PERIOD_D1; // Timeframe to Calculate Center
extern double Center_price = 1270.00;
extern double Tp_price_minimum = 10.00; 
extern string SETUPBUY = "##### SETUP BUY #####"; //##### SETUP BUY #####
extern AUTOLOT Buy_AutoLot = AUTO; // Buy Lot Auto
extern int Buy_LotDivider = 100000; // Buy Lot Divider
extern double Buy_price = 0.01; // Buy Lot
extern int Buy_Distance = 1000;
extern int Buy_Order_Maximum = 10;
extern string SETUPSELL = "##### SETUP SELL #####"; //##### SETUP SELL #####
extern AUTOLOT Sell_AutoLot = AUTO; // Sell Lot Auto
extern int Sell_LotDivider = 100000; // Buy Lot Divider
extern double Sell_price = 0.01;  // Sell Lot
extern int Sell_Distance = 1000;
extern int Sell_Order_Maximum = 10;
extern string ICHIMOKU = "##### SETUP ICHIMOKU #####"; //##### SETUP ICHIMOKU #####
extern int Tekkan_sen = 5; // Tekkan-sen
extern int Kijun_sen = 5;  // Kijun-sen
extern int Senkou_Span_B = 5; // Senkou Span B
input ENUM_TIMEFRAMES TIMEFRAME=PERIOD_D1;
extern string SYSTEM_CONFIG = "##### SYSTEM CONFIG #####"; //##### SYSTEM CONFIG #####
extern int magicNumber = 9999; // Magic Number


int AcceptOpen = 5;
int Latest_Buy_Order = 0;
int Latest_Sell_Order = 0;
double Arr_Buy_Price[];
double Arr_Sell_Price[];
double Arr_Buying_price[];
double Arr_Selling_price[];
bool Arr_Buy_Open[];
bool Arr_Sell_Open[];
int Arr_CloseTicket[];
double topLossBuy = 0;
double topLossSell = 0;
double MaximumLoss_Buy = 0;
double MaximumLoss_Sell = 0;
double lossBuy = 0;
double lossSell =0;
int totalOrderBuy = 0;
int totalOrderSell = 0;
double totalLotBuy = 0;
double totalLotSell = 0;

string btn_ClearBuy = "btn_ClearBuy";
string btn_ClearSell = "btn_ClearSell";
string btn_ClearAll = "btn_ClearAll";
bool isClearBuy = false;
bool isClearSell = false;
bool isClearAll = false;

   int OnInit()
   {      
   
   ObjectsDeleteAll(); 
   if(ACCOUNT_NUMBER != AccountNumber()){
      return(INIT_SUCCEEDED);
   } 
   
   if(Buy_AutoLot == AUTO){
      Buy_price = AccountBalance()/Buy_LotDivider;
      if(Buy_price < 0.01){
         Buy_price = 0.01;
      }
   } 
   
   if(Sell_AutoLot == AUTO){
      Sell_price = AccountBalance()/Sell_LotDivider;
      if(Sell_price < 0.01){
         Sell_price = 0.01;
      }
   }
   
   ArrayFree(Arr_Buy_Price);
   ArrayFree(Arr_Sell_Price);
   ArrayFree(Arr_Buy_Open);
   ArrayFree(Arr_Sell_Open);
   ArrayFree(Arr_CloseTicket);
   topLossBuy = 0;
   topLossSell = 0;
   MaximumLoss_Buy = 0;
   MaximumLoss_Sell = 0;
       
    ArrayResize(Arr_Buy_Price,Buy_Order_Maximum);
    ArrayResize(Arr_Sell_Price,Sell_Order_Maximum);
    ArrayResize(Arr_Buy_Open,Buy_Order_Maximum);
    ArrayResize(Arr_Sell_Open,Sell_Order_Maximum);
  
    CalculateCenter();
    int Buy_Step = Util_PriceNoDigit(Center_price);
    int reverseMultiply = Buy_Order_Maximum;
    for(int i = 0; i < Buy_Order_Maximum; i++){ 
      Buy_Step -= Buy_Distance;
      Arr_Buy_Price[i] = Buy_Step/(double)Util_DivideDigit(); 
      MaximumLoss_Buy += ((double)Buy_Distance*(double)reverseMultiply)*Buy_price;
      reverseMultiply--;
    }
    reverseMultiply = Sell_Order_Maximum;
    int Sell_Step = Util_PriceNoDigit(Center_price);
    for(int i = 0; i < Sell_Order_Maximum;i++){
      int multiply = (i+1);
      Sell_Step += Sell_Distance;
      Arr_Sell_Price[i] = Sell_Step/(double)Util_DivideDigit();  
      MaximumLoss_Sell += ((double)Sell_Distance*(double)reverseMultiply)*Sell_price;
      reverseMultiply--;
    } 
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
   
   void CalculateCenter(){ 
      if(Center_AutoCal == AUTO){
         int highShift = iHighest(Symbol(),TIMEFRAME_CAL,MODE_HIGH,Candles,0); 
         int lowShift = iLowest(Symbol(),TIMEFRAME_CAL,MODE_LOW,Candles,0); 
         double highPrice = iHigh(Symbol(),TIMEFRAME_CAL,highShift);
         double lowPrice = iLow(Symbol(),TIMEFRAME_CAL,lowShift);
         double avr = ((highPrice+lowPrice)/(double)2);
         Center_price = avr; 
      }
   }
   
   void Rebind()
   {     
       ArrayFree(Arr_Buying_price);
       ArrayFree(Arr_Selling_price);
       ArrayResize(Arr_Buying_price,Buy_Order_Maximum);
       ArrayResize(Arr_Selling_price,Sell_Order_Maximum); 
       for(int i = 0; i < Buy_Order_Maximum; i++){
         Arr_Buying_price[i] = -1;
       }
       for(int i = 0; i < Sell_Order_Maximum; i++){
         Arr_Selling_price[i] = -1;
       }
       
       if(Buy_AutoLot == AUTO){
         Buy_price = AccountBalance()/Buy_LotDivider;
         if(Buy_price < 0.01){
            Buy_price = 0.01;
         }
       } 
      
       if(Sell_AutoLot == AUTO){
         Sell_price = AccountBalance()/Sell_LotDivider;
         if(Sell_price < 0.01){
            Sell_price = 0.01;
         }
       }       
       if(Buy_AutoLot == AUTO && Sell_AutoLot == AUTO){
         Tp_price_minimum = Buy_price*1000;
       }            
      
       Latest_Sell_Order = -1;
       Latest_Buy_Order = -1;
       for(int i = 0; i < ArraySize(Arr_Buy_Open); i++){
         Arr_Buy_Open[i] = false;
       }
       for(int i = 0; i < ArraySize(Arr_Sell_Open); i++){
         Arr_Sell_Open[i] = false;
       }
       lossBuy = 0;
       lossSell =0;
       totalOrderSell = 0;
       totalOrderBuy = 0;
       totalLotSell = 0;
       totalLotBuy = 0;
       for (int i = 0; i < OrdersTotal(); i++)
       {
          if (OrderSelect(i, SELECT_BY_POS) == true)
          {  
            if(OrderMagicNumber() == magicNumber){ 
               if(OrderType() == OP_BUY || OrderType() == OP_SELL){ 
                  if(StringFind(OrderComment(),"GG_",0) >= 0){
                     string result[];
                     Util_Split(OrderComment(),"_",result);
                     if(result[1] == "S"){
                        lossSell += OrderProfit()+OrderCommission()+OrderSwap();
                        if(ArraySize(Arr_Sell_Open) >= (int)result[2]){
                           Arr_Sell_Open[((int)result[2]-1)] = true;
                           Arr_Selling_price[((int)result[2]-1)] = OrderOpenPrice();
                           totalOrderSell++;
                           totalLotSell += OrderLots();
                        } 
                        if((int)result[2] > Latest_Sell_Order){
                           Latest_Sell_Order = (int)result[2];
                        }
                     }
                      if(result[1] == "B"){
                         lossBuy += OrderProfit()+OrderCommission()+OrderSwap();
                         if(ArraySize(Arr_Buy_Open) >= (int)result[2]){
                           Arr_Buy_Open[((int)result[2]-1)] = true;
                           Arr_Buying_price[((int)result[2]-1)] = OrderOpenPrice();
                           totalOrderBuy++;
                           totalLotBuy += OrderLots();
                         }
                         if((int)result[2] > Latest_Buy_Order){
                           Latest_Buy_Order = (int)result[2]; 
                        }
                     }
                  }
               }
            }
          }
       } 
       if(lossBuy < topLossBuy){
         topLossBuy = lossBuy;
       }
       if(lossSell < topLossSell){
         topLossSell = lossSell;
       }
       GuiGenerate();
       //Comment("Top Loss Buy : "+ topLossBuy+" / Top Loss Sell : "+topLossSell);
   }
   
   
   void GuiGenerate(){
         
      int y = 40;
      string obj_rect = "obj_rect";
      string lbl_Center =  "lbl_Center";
      string lbl_Center_val =  "lbl_Center_val"; 
      string lbl_balance =  "lbl_balance";
      string lbl_balance_val =  "lbl_balance_val"; 
      string lbl_Equity =  "lbl_Equity";
      string lbl_Equity_val =  "lbl_Equity_val"; 
      string lbl_max_buy_loss = "lbl_max_buy_loss";
      string lbl_max_buy_loss_val = "lbl_max_buy_loss_val";
      string lbl_max_sell_loss = "lbl_max_sell_loss";
      string lbl_max_sell_loss_val = "lbl_max_sell_loss_val";
      string lbl_total_buy_profit = "lbl_total_buy_profit";
      string lbl_total_buy_profit_val = "lbl_total_buy_profit_val";
      string lbl_total_sell_profit = "lbl_total_sell_profit";
      string lbl_total_sell_profit_val = "lbl_total_sell_profit_val";
      string lbl_total_profit = "lbl_total_profit";
      string lbl_total_profit_val = "lbl_total_profit_val";
      string lbl_total_order_buy = "lbl_total_order_buy";
      string lbl_total_order_buy_val = "lbl_total_order_buy_val";
      string lbl_total_order_sell = "lbl_total_order_sell";
      string lbl_total_order_sell_val = "lbl_total_order_sell_val";
      
      string balance = DoubleToStr(AccountBalance(),2); 
      string cenPrice = DoubleToStr(Center_price,Digits); 
      string equity = DoubleToStr(AccountEquity(),2); 
      string max_buy_loss = "- "+DoubleToStr(MaximumLoss_Buy,2); 
      string max_sell_loss = "- "+DoubleToStr(MaximumLoss_Sell,2); 
      string total_buy_profit = DoubleToStr(lossBuy,2);
      string total_sell_profit = DoubleToStr(lossSell,2);
      string total_profit = DoubleToStr(lossBuy+lossSell,2);
      string total_lot_buy = DoubleToStr(totalLotBuy,2);
      string total_lot_sell = DoubleToStr(totalLotSell,2);
      string total_order_buy = IntegerToString(totalOrderBuy);
      string total_order_sell = IntegerToString(totalOrderSell);
      
      if(ObjectFind(lbl_balance) < 0){
          
         ObjectCreate(0,"obj_rect",OBJ_RECTANGLE_LABEL,0,0,0) ;
         
         ObjectSetInteger(0,"obj_rect",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(0,"obj_rect",OBJPROP_XDISTANCE,280);
         ObjectSetInteger(0,"obj_rect",OBJPROP_YDISTANCE,20);
         ObjectSetInteger(0,"obj_rect",OBJPROP_BACK,false);
         ObjectSetInteger(0,"obj_rect",OBJPROP_XSIZE,230);
         ObjectSetInteger(0,"obj_rect",OBJPROP_YSIZE,220);
         ObjectSetInteger(0,"obj_rect",OBJPROP_BORDER_TYPE,BORDER_FLAT);
         ObjectSetInteger(0,"obj_rect",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
         
         Util_LabelCreate(0,lbl_Center,0,260,30,CORNER_RIGHT_UPPER,"Center Price","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_Center_val,0,90,30,CORNER_RIGHT_UPPER,cenPrice,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         
         Util_LabelCreate(0,lbl_balance,0,260,50,CORNER_RIGHT_UPPER,"Balance","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_balance_val,0,90,50,CORNER_RIGHT_UPPER,balance,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         
         Util_LabelCreate(0,lbl_Equity,0,260,70,CORNER_RIGHT_UPPER,"Equity","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_Equity_val,0,90,70,CORNER_RIGHT_UPPER,equity,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         
         Util_LabelCreate(0,lbl_max_buy_loss,0,260,90,CORNER_RIGHT_UPPER,"Maximum Buy Loss","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_max_buy_loss_val,0,90,90,CORNER_RIGHT_UPPER,max_buy_loss,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         
         Util_LabelCreate(0,lbl_max_sell_loss,0,260,110,CORNER_RIGHT_UPPER,"Maximum Sell Loss","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_max_sell_loss_val,0,90,110,CORNER_RIGHT_UPPER,max_sell_loss,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         
         Util_LabelCreate(0,lbl_total_buy_profit,0,260,130,CORNER_RIGHT_UPPER,"Total Buy Profit","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_total_buy_profit_val,0,90,130,CORNER_RIGHT_UPPER,total_buy_profit,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         Util_ButtonCreate(0,btn_ClearBuy,0,80,130,70,18,CORNER_RIGHT_UPPER,"Clear Buy","Arial",10,clrWhite,clrLightCoral);
      
         Util_LabelCreate(0,lbl_total_sell_profit,0,260,150,CORNER_RIGHT_UPPER,"Total Sell Profit","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_total_sell_profit_val,0,90,150,CORNER_RIGHT_UPPER,total_sell_profit,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         Util_ButtonCreate(0,btn_ClearSell,0,80,150,70,18,CORNER_RIGHT_UPPER,"Clear Sell","Arial",10,clrWhite,clrLightSalmon);
         
         Util_LabelCreate(0,lbl_total_profit,0,260,170,CORNER_RIGHT_UPPER,"Total Profit","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_total_profit_val,0,90,170,CORNER_RIGHT_UPPER,total_profit,"Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         Util_ButtonCreate(0,btn_ClearAll,0,80,170,70,18,CORNER_RIGHT_UPPER,"Clear All","Arial",10,clrWhite,clrLightCoral);
          
         Util_LabelCreate(0,lbl_total_order_buy,0,260,190,CORNER_RIGHT_UPPER,"Total Buy Order","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_total_order_buy_val,0,90,190,CORNER_RIGHT_UPPER,total_order_buy+"("+total_lot_buy+")","Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
         
         Util_LabelCreate(0,lbl_total_order_sell,0,260,210,CORNER_RIGHT_UPPER,"Total Sell Order","Arial",9,clrGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);
         Util_LabelCreate(0,lbl_total_order_sell_val,0,90,210,CORNER_RIGHT_UPPER,total_order_sell+"("+total_lot_sell+")","Arial",9,clrBlack,0,ANCHOR_RIGHT_UPPER,false,false,true,0);
          
      }else{
         ObjectSetString(0,lbl_Center_val,OBJPROP_TEXT,cenPrice);   
         ObjectSetString(0,lbl_balance_val,OBJPROP_TEXT,balance);   
         ObjectSetString(0,lbl_Equity_val,OBJPROP_TEXT,equity);         
         ObjectSetString(0,lbl_total_buy_profit_val,OBJPROP_TEXT,total_buy_profit);
         ObjectSetString(0,lbl_total_sell_profit_val,OBJPROP_TEXT,total_sell_profit);
         ObjectSetString(0,lbl_total_profit_val,OBJPROP_TEXT,total_profit);
         ObjectSetString(0,lbl_total_order_buy_val,OBJPROP_TEXT,total_order_buy+"("+total_lot_buy+")");
         ObjectSetString(0,lbl_total_order_sell_val,OBJPROP_TEXT,total_order_sell+"("+total_lot_sell+")");
         
         ObjectSetInteger(0,lbl_total_buy_profit_val,OBJPROP_COLOR,((double)total_buy_profit >= 0) ? clrBlue : clrRed);
         ObjectSetInteger(0,lbl_total_sell_profit_val,OBJPROP_COLOR,((double)total_sell_profit >= 0) ? clrBlue : clrRed);
         ObjectSetInteger(0,lbl_total_profit_val,OBJPROP_COLOR,((double)total_profit >= 0) ? clrBlue : clrRed);               
      }
   }
   
   void OnTick()
   {  
      if(ACCOUNT_NUMBER != AccountNumber()){ 
         if(ObjectFind("lblCaution") < 0){ 
            Util_LabelCreate(0,"lblCaution",0,10,20,CORNER_LEFT_UPPER,cautionText,"Arial",9,clrRed,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
         }
         return;
      }
       
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
      }     
      
      Rebind();
           
      if(Util_IsNewBar(PERIOD_CURRENT)){  
      
         ArrayFree(Arr_Buy_Price);
         ArrayFree(Arr_Sell_Price);
         ArrayFree(Arr_Buy_Open);
         ArrayFree(Arr_Sell_Open);
         ArrayFree(Arr_CloseTicket); 
             
          ArrayResize(Arr_Buy_Price,Buy_Order_Maximum);
          ArrayResize(Arr_Sell_Price,Sell_Order_Maximum);
          ArrayResize(Arr_Buy_Open,Buy_Order_Maximum);
          ArrayResize(Arr_Sell_Open,Sell_Order_Maximum);
     
          CalculateCenter();
          SetHLine("CenterLine",Center_price,clrGreen); 
          int Buy_Step = Util_PriceNoDigit(Center_price);
          int reverseMultiply = Buy_Order_Maximum;
          for(int i = 0; i < Buy_Order_Maximum; i++){ 
            Buy_Step -= Buy_Distance;
            Arr_Buy_Price[i] = Buy_Step/(double)Util_DivideDigit();  
          }
          reverseMultiply = Sell_Order_Maximum;
          int Sell_Step = Util_PriceNoDigit(Center_price);
          for(int i = 0; i < Sell_Order_Maximum;i++){
            int multiply = (i+1);
            Sell_Step += Sell_Distance;
            Arr_Sell_Price[i] = Sell_Step/(double)Util_DivideDigit();   
          } 
                
          for(int i = 0; i < ArraySize(Arr_Sell_Price); i++){
             string LineName = "BuyPoint_"+IntegerToString(i+1);
             SetHLine(LineName,Arr_Sell_Price[i],clrRed); 
          }
          for(int i = 0; i < ArraySize(Arr_Buy_Price); i++){
             string LineName = "SellPoint_"+IntegerToString(i+1);
             SetHLine(LineName,Arr_Buy_Price[i],clrBlue); 
          }
      }
      
      double price = (MathAbs(Ask+Bid)/2);
      if(price > Center_price){ // Sell
         for(int i = 0; i < ArraySize(Arr_Sell_Price); i++){ 
            bool isReady = isOrderReady(Bid,Arr_Sell_Price[i],"d");  
            bool isNearOpenOrders = isOrderNearDistance(Bid,OP_SELL);
            if(isReady && Arr_Sell_Open[i] == false && isClearSell == false && isNearOpenOrders == false){
               Util_OpenOrder(Symbol(),OP_SELL,Sell_price,"GG_S_"+IntegerToString(i+1));
               break;
            } 
            //int current_index = (i+1);
            //if(isReady && current_index > Latest_Sell_Order){
            //   Util_OpenOrder(Symbol(),OP_SELL,Sell_price,"GG_S_"+IntegerToString(i+1));
            //   break;
            //}
         }
      }
      if(price < Center_price){ // Buy
         for(int i = 0; i < ArraySize(Arr_Buy_Price); i++){ 
            bool isReady = isOrderReady(Ask,Arr_Buy_Price[i]);
            bool isNearOpenOrders = isOrderNearDistance(Ask,OP_BUY);
            if(isReady && Arr_Buy_Open[i] == false && isClearBuy == false && isNearOpenOrders == false){
               Util_OpenOrder(Symbol(),OP_BUY,Buy_price,"GG_B_"+IntegerToString(i+1));
               break;
            }
            //int current_index = (i+1);
            //if(isReady && current_index > Latest_Buy_Order){
            //   Util_OpenOrder(Symbol(),OP_BUY,Buy_price,"GG_B_"+IntegerToString(i+1));
            //   break;
            //}
         }
      }   
      
      bool defaultClose = true;
      //if(hasWrongWayOrder("SELL") && totalLotSell > totalLotBuy){
      if(hasWrongWayOrder("SELL")){
         defaultClose = false;
          double totalProfit = 0;
          for (int i = 0; i < OrdersTotal(); i++)
          {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {  
               if(OrderMagicNumber() == magicNumber){ 
                  if(OrderType() == OP_SELL){ 
                     if(StringFind(OrderComment(),"GG_",0) >= 0){ 
                        totalProfit += OrderProfit()+OrderCommission()+OrderSwap(); 
                        Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                     }
                  }
               }
             }
          }
          if(totalProfit < Tp_price_minimum){
            ArrayFree(Arr_CloseTicket);
          }
      }
      if(hasWrongWayOrder("BUY")){
      //if(hasWrongWayOrder("BUY")&& totalLotBuy > totalLotSell){
         defaultClose = false;
         
         double totalProfit = 0;
          for (int i = 0; i < OrdersTotal(); i++)
          {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {  
               if(OrderMagicNumber() == magicNumber){ 
                  if(OrderType() == OP_BUY){ 
                     if(StringFind(OrderComment(),"GG_",0) >= 0){ 
                        totalProfit += OrderProfit()+OrderCommission()+OrderSwap(); 
                        Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                     }
                  }
               }
             }
          }
          if(totalProfit < Tp_price_minimum){
            ArrayFree(Arr_CloseTicket);
          }
      }
      if(defaultClose == true){ 
         prepareClose();  
      }  
   }
   
   void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {
      if(id==CHARTEVENT_OBJECT_CLICK) {
         long z=ObjectGetInteger(0,sparam,OBJPROP_ZORDER); 
         if(sparam == btn_ClearBuy){    
             if(isClearBuy){ 
                  ObjectSetString(0,btn_ClearBuy,OBJPROP_TEXT,"Clear Buy");   
                  ObjectSetInteger(0,btn_ClearBuy,OBJPROP_BGCOLOR,clrLightCoral); 
                  isClearBuy = false;
                  
                  ObjectSetString(0,btn_ClearAll,OBJPROP_TEXT,"Clear All");   
                  ObjectSetInteger(0,btn_ClearAll,OBJPROP_BGCOLOR,clrLightCoral); 
                  isClearAll = false;
                     
             }else{ 
                  ObjectSetString(0,btn_ClearBuy,OBJPROP_TEXT,"Clearing");   
                  ObjectSetInteger(0,btn_ClearBuy,OBJPROP_BGCOLOR,clrCornflowerBlue); 
                  isClearBuy = true;
                  
                  if(isClearSell){
                     ObjectSetString(0,btn_ClearAll,OBJPROP_TEXT,"Clearing");   
                     ObjectSetInteger(0,btn_ClearAll,OBJPROP_BGCOLOR,clrCornflowerBlue); 
                     isClearAll = true;
                  }
             }
             /*for (int i = 0; i < OrdersTotal(); i++)
             {
                if (OrderSelect(i, SELECT_BY_POS) == true)
                {  
                   if(OrderMagicNumber() == magicNumber){ 
                     if(OrderType() == OP_BUY){ 
                        if(StringFind(OrderComment(),"GG_",0) >= 0){ 
                            Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                        }
                     }
                  }
                }
             }    */     
            Sleep(200);
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);  
         }
         
          if(sparam == btn_ClearSell){   
             
               if(isClearSell){ 
                     ObjectSetString(0,btn_ClearSell,OBJPROP_TEXT,"Clear Sell");   
                     ObjectSetInteger(0,btn_ClearSell,OBJPROP_BGCOLOR,clrLightSalmon); 
                     isClearSell = false;
                      
                     ObjectSetString(0,btn_ClearAll,OBJPROP_TEXT,"Clear All");   
                     ObjectSetInteger(0,btn_ClearAll,OBJPROP_BGCOLOR,clrLightCoral); 
                     isClearAll = false;
                     
                }else{ 
                     ObjectSetString(0,btn_ClearSell,OBJPROP_TEXT,"Clearing");   
                     ObjectSetInteger(0,btn_ClearSell,OBJPROP_BGCOLOR,clrLightSkyBlue); 
                     isClearSell = true;
                     
                     if(isClearBuy){
                        ObjectSetString(0,btn_ClearAll,OBJPROP_TEXT,"Clearing");   
                        ObjectSetInteger(0,btn_ClearAll,OBJPROP_BGCOLOR,clrCornflowerBlue); 
                        isClearAll = true;
                     }
                }
            /* 
             for (int i = 0; i < OrdersTotal(); i++)
             {
                if (OrderSelect(i, SELECT_BY_POS) == true)
                {  
                   if(OrderMagicNumber() == magicNumber){ 
                     if(OrderType() == OP_SELL){ 
                        if(StringFind(OrderComment(),"GG_",0) >= 0){ 
                            Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                        }
                     }
                  }
                }
             }      
             */   
            Sleep(200);
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);  
         }
         
         
          if(sparam == btn_ClearAll){   
           
               if(isClearAll){ 
                     ObjectSetString(0,btn_ClearAll,OBJPROP_TEXT,"Clear All");   
                     ObjectSetInteger(0,btn_ClearAll,OBJPROP_BGCOLOR,clrLightCoral); 
                     isClearAll = false;
                     
                     ObjectSetString(0,btn_ClearBuy,OBJPROP_TEXT,"Clear Buy");   
                     ObjectSetInteger(0,btn_ClearBuy,OBJPROP_BGCOLOR,clrLightCoral); 
                     isClearBuy = false;
                     
                     ObjectSetString(0,btn_ClearSell,OBJPROP_TEXT,"Clear Sell");   
                     ObjectSetInteger(0,btn_ClearSell,OBJPROP_BGCOLOR,clrLightSalmon); 
                     isClearSell = false;
                }else{ 
                     ObjectSetString(0,btn_ClearAll,OBJPROP_TEXT,"Clearing");   
                     ObjectSetInteger(0,btn_ClearAll,OBJPROP_BGCOLOR,clrCornflowerBlue); 
                     isClearAll = true;
                        
                     ObjectSetString(0,btn_ClearBuy,OBJPROP_TEXT,"Clearing");   
                     ObjectSetInteger(0,btn_ClearBuy,OBJPROP_BGCOLOR,clrCornflowerBlue); 
                     isClearBuy = true;
                     
                     ObjectSetString(0,btn_ClearSell,OBJPROP_TEXT,"Clearing");   
                     ObjectSetInteger(0,btn_ClearSell,OBJPROP_BGCOLOR,clrLightSkyBlue); 
                     isClearSell = true;
                }
            /* 
             for (int i = 0; i < OrdersTotal(); i++)
             {
                if (OrderSelect(i, SELECT_BY_POS) == true)
                {  
                   if(OrderMagicNumber() == magicNumber){ 
                     if(OrderType() == OP_SELL || OrderType() == OP_BUY){ 
                        if(StringFind(OrderComment(),"GG_",0) >= 0){ 
                            Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                        }
                     }
                  }
                }
             }    
             */      
            Sleep(200);
            ObjectSetInteger(0,sparam,OBJPROP_STATE,false);  
         }
      }
  }
   
   void prepareClose(){
     string CloseAt = ichimokuCheck(); 
       if(CloseAt == "BUY" || isClearSell){
          for (int i = 0; i < OrdersTotal(); i++)
          {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {  
                if(OrderMagicNumber() == magicNumber){ 
                  if(OrderType() == OP_SELL){ 
                     if(StringFind(OrderComment(),"GG_",0) >= 0){
                        double orderProfit = (OrderProfit() + OrderSwap() + OrderCommission()); 
                        double profitClose = Tp_price_minimum;
                        if(isClearSell){
                           profitClose = 1;
                        }
                        if(orderProfit > profitClose){
                           Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                        }
                     }
                  }
               }
             }
          }         
       }
       
       if(CloseAt == "SELL" || isClearBuy){
          for (int i = 0; i < OrdersTotal(); i++)
          {
             if (OrderSelect(i, SELECT_BY_POS) == true)
             {  
               if(OrderMagicNumber() == magicNumber){ 
                  if(OrderType() == OP_BUY || isClearBuy){ 
                     if(StringFind(OrderComment(),"GG_",0) >= 0){
                        double orderProfit = (OrderProfit() + OrderSwap() + OrderCommission()); 
                        double profitClose = Tp_price_minimum;
                        if(isClearBuy){
                           profitClose = 1;
                        }
                        if(orderProfit > profitClose){ 
                           Util_ArrayAddInt(Arr_CloseTicket,OrderTicket());
                        }
                     }
                  }
                }
             }  
          }         
       }
   }
   
   
   bool hasWrongWayOrder(string mode){
       bool result = false;
        double priceSell = 0;
        double priceBuy = 0;
        
        if(mode == "SELL"){ 
              ArraySort(Arr_Selling_price,WHOLE_ARRAY,0,MODE_ASCEND);
              for(int i = 0 ;i < ArraySize(Arr_Selling_price); i++){
                  if(Arr_Selling_price[i] != (double)(-1)){
                     priceSell = Arr_Selling_price[i];
                     break;
                  }
              }
              ArraySort(Arr_Buying_price,WHOLE_ARRAY,0,MODE_DESCEND);
              for(int i = 0 ;i < ArraySize(Arr_Buying_price); i++){
                  if(Arr_Buying_price[i] != (double)(-1)){
                     priceBuy = Arr_Buying_price[i];
                     break;
                  }
              }
           
             if(priceSell < priceBuy && priceSell != 0 && priceBuy != 0){
               result = true;
               //Print("sell worng"+priceSell+" <"+priceBuy);
             }
        }
        
        if(mode == "BUY"){
              ArraySort(Arr_Selling_price,WHOLE_ARRAY,0,MODE_DESCEND);
              for(int i = 0 ;i < ArraySize(Arr_Selling_price); i++){
                  if(Arr_Selling_price[i] != (double)(-1)){
                     priceSell = Arr_Selling_price[i];
                     break;
                  }
              }
              ArraySort(Arr_Buying_price,WHOLE_ARRAY,0,MODE_ASCEND);
              for(int i = 0 ;i < ArraySize(Arr_Buying_price); i++){
                  if(Arr_Buying_price[i] != (double)(-1)){
                     priceBuy = Arr_Buying_price[i];
                     break;
                  }
              }
              
             if(priceBuy > priceSell && priceSell != 0 && priceBuy != 0){
               result = true;
               Print("buy worng = "+priceBuy+" <"+priceSell);
               // for(int i = 0 ;i < ArraySize(Arr_Selling_price); i++){
                //   Print(Arr_Selling_price[i]);
             // }
             // Print("dddddddddd");
             }
        }       
        return result;
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

bool isOrderNearDistance(double priceCurrent,int MODE){
   bool result = false;
   int intPriceCurrent = Util_PriceNoDigit(priceCurrent);
   int intPriceLow = 0;//Util_PriceNoDigit(priceCurrent);
   int intPriceHigh = 0;
   if(MODE == OP_BUY){
      intPriceLow = Util_PriceNoDigit(priceCurrent)-(Buy_Distance-10);
      intPriceHigh = Util_PriceNoDigit(priceCurrent)+(Buy_Distance-10);
   }
    if(MODE == OP_SELL){
      intPriceLow = Util_PriceNoDigit(priceCurrent)-(Sell_Distance-10);
      intPriceHigh = Util_PriceNoDigit(priceCurrent)+(Sell_Distance-10);
   }
      
      for (int i = 0; i < OrdersTotal(); i++)
       {
          if (OrderSelect(i, SELECT_BY_POS) == true)
          {  
            if(OrderMagicNumber() == magicNumber){ 
               if(OrderType() == OP_BUY || OrderType() == OP_SELL){ 
                  if(StringFind(OrderComment(),"GG_",0) >= 0){
                      int openPrice = Util_PriceNoDigit(OrderOpenPrice());
                      if(openPrice > intPriceLow && openPrice < intPriceHigh){
                        result = true;
                      }
                  }
               }
            }
          }
       }
   return result;
}

   
bool Util_RectangleCreate(const long       chart_ID=0,        // chart's ID
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
   

int Util_OpenOrderWithSLTP(string _symbol, int cmd, double lot,double tp,double sl,string comment)
{ 
    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0; 
    double _symbol_Point = MarketInfo(_symbol,MODE_POINT);
    int _symbol_Digits = ((int)MarketInfo(_symbol,MODE_DIGITS));
    double Arr_SLTP[]; 
    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 5, sl, tp, comment, magicNumber, 0, clrGreen);  
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
        iSuccess = OrderSend(_symbol, cmd, lot, price, 10, 0.0, 0.0, comment, magicNumber, 0, clrGreen);  
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
   

bool Util_isUp(double open,double close){
   bool result = false;
   if(open < close){
      result = true;
   }
   return result;
}

bool Util_isDown(double open,double close){
   bool result = false;
   if(open > close){
      result = true;
   }
   return result;
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

void Util_Split(string text,string split,string & results[]){
   StringSplit(text,StringGetCharacter(split,0),results);
   int fnError = GetLastError();
   if(fnError > 0){ 
     // Print("Error function Split: ",fnError," - ",text);  
     // ResetLastError();
   }
}
 
int TotalOrders(){
   
    int order_total = 0;
    for (int i = 0; i < OrdersTotal(); i++)
    { 
       if (OrderSelect(i, SELECT_BY_POS) == true)
       {   
          if(OrderMagicNumber() == magicNumber){ 
             if(OrderType() == OP_BUY){ 
               order_total++;
             }
             if(OrderType() == OP_SELL){ 
               order_total++;
             } 
          } 
       }
    }   
 
   return order_total;
}


string ichimokuCheck(){
   string result = "";
    
   double PRICE = (Ask+Bid)/2;
   double TENKANSEN = iIchimoku(Symbol(),TIMEFRAME,Tekkan_sen,Kijun_sen,Senkou_Span_B,MODE_TENKANSEN,0);
   double KIJUNSEN = iIchimoku(Symbol(),TIMEFRAME,Tekkan_sen,Kijun_sen,Senkou_Span_B,MODE_KIJUNSEN,0);
   double SENKOUSPANA = iIchimoku(Symbol(),TIMEFRAME,Tekkan_sen,Kijun_sen,Senkou_Span_B,MODE_SENKOUSPANA,0);
   double SENKOUSPANB = iIchimoku(Symbol(),TIMEFRAME,Tekkan_sen,Kijun_sen,Senkou_Span_B,MODE_SENKOUSPANB,0);
   double CHIKOUSPAN = iIchimoku(Symbol(),TIMEFRAME,Tekkan_sen,Kijun_sen,Senkou_Span_B,MODE_CHIKOUSPAN,0);
   
   /*
   if(PRICE < TENKANSEN &&
      PRICE < KIJUNSEN &&
      PRICE < SENKOUSPANA &&
      PRICE < SENKOUSPANB &&
      PRICE < CHIKOUSPAN){
         result = "SELL";
      } 
      
   if(PRICE > TENKANSEN &&
      PRICE > KIJUNSEN &&
      PRICE > SENKOUSPANA &&
      PRICE > SENKOUSPANB &&
      PRICE > CHIKOUSPAN){
         result = "BUY";
      }
     */
        
   if(PRICE < TENKANSEN &&
      PRICE < KIJUNSEN &&
      PRICE < SENKOUSPANB
      ){
         result = "SELL";
      } 
      
   if(PRICE > TENKANSEN &&
      PRICE > KIJUNSEN &&
      PRICE > SENKOUSPANB 
      ){
         result = "BUY";
      }
   return result;
}

