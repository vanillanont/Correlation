//+------------------------------------------------------------------+
//|                                          Profit Explonential.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict
//--- input parameters
extern string Symbols_01 = "GBPNZD-EURNZD-EURGBP,EURNZD-EURGBP-GBPNZD,GBPNZD-EURGBP-EURNZD";
extern string Symbols_02 = ",AUDCAD-AUDUSD-USDCAD,USDCAD-AUDUSD-AUDCAD,USDCAD-AUDCAD-AUDUSD";
extern string Symbols_03 = "";
extern string Symbols_04 = "";
extern int Total_Allow_Resolve = 2;

//--- global parameters
string Arr_Symbols_FIRST[];
string Arr_Symbols_SECOND[];
string Arr_Symbols_THIRD[];
int Arr_Symbols_FIRST_DIRECTION[];
int Arr_Symbols_SECOND_DIRECTION[];
int Arr_Symbols_THIRD_DIRECTION[];
string Arr_Group_ReadyPosition[];
int Arr_Group_Space[];
int Arr_Main_Order_Space[];
int Arr_Hedge_Order_Space[];
int Arr_Main_Order_Space_Of_Space[];
int Arr_Hedge_Order_Space_Of_Space[];
int Arr_Main_Order_Total[];
int Arr_Hedge_Order_Total[];
double Arr_Main_Order_Lot[];
double Arr_Main_Order_Latest_Lot[];
double Arr_Hedge_Order_Lot[];
double Arr_Hedge_Order_Latest_Lot[];
double Arr_Main_Order_Profit[];
double Arr_Main_Order_Latest_Profit[];
double Arr_Hedge_Order_Profit[];
double Arr_Hedge_Order_Latest_Profit[];
bool Arr_Main_IsOpenCondition[];
bool Arr_Hedge_IsOpenCondition[];
int Arr_Ticket_Pending_Close[];
bool Arr_Main_Hold[];
bool Arr_Hedge_Hold[];

int Size_Group = 0;
double Lot_Size = 0;
double Tp_Size = 0;
double Loss_Acceptable = 0;

int OnInit()
  {
//---
   ClearInterface();
   InitSymbols();
   Rebind();
   SetupMM();
   GenInterface();
   
//---
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
   SetupMM();
   CalculateDirection();
   CalculateSpace();   
   for(int i = 0; i < Size_Group;i++){   
      double Lot = Lot_Size;
      string Group_ReadyPosition = Arr_Group_ReadyPosition[i];
      string Group_Space = IntegerToString(Arr_Group_Space[i]);
      string Symbols_FIRST = Arr_Symbols_FIRST[i];
      string Symbols_SECOND = Arr_Symbols_SECOND[i];
      string Symbols_THIRD = Arr_Symbols_THIRD[i];
      Arr_Main_Order_Space_Of_Space[i] = Arr_Main_Order_Space[i] == 0 ? 0 : (Arr_Main_Order_Space[i]-Arr_Group_Space[i]);
      Arr_Hedge_Order_Space_Of_Space[i] = Arr_Hedge_Order_Space[i] == 99999999 ? 0 : (Arr_Group_Space[i]-Arr_Hedge_Order_Space[i]); 
      
      bool isHoldMain = Arr_Main_Hold[i];
      bool isHoldHedge = Arr_Hedge_Hold[i];
      
      if(isHoldMain == false){
         if(Arr_Main_Order_Total[i] == 0){
            //if(isOpenFirst(Symbols_FIRST,Symbols_SECOND,Symbols_THIRD,"M",i)){
            if(Group_ReadyPosition == "M"){
                Util_OpenOrder(Symbols_FIRST,OP_SELL,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_M_"+Group_Space);
                Util_OpenOrder(Symbols_SECOND,OP_BUY,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_M_"+Group_Space);
            // }
            }
         }else{
            if(Total_Allow_Resolve >Arr_Main_Order_Total[i]){
               int Order_Space = Arr_Main_Order_Space_Of_Space[i];
               if(Order_Space > 1000){
                  // 3 symbols confirm macd,sto,and others...
                  bool isNextOpen = Arr_Main_IsOpenCondition[i];
                  if(isNextOpen){ 
                     Lot = (Lot_Size*((Order_Space/1000)*2));
                     Util_OpenOrder(Symbols_FIRST,OP_SELL,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_M_"+Group_Space);
                     Util_OpenOrder(Symbols_SECOND,OP_BUY,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_M_"+Group_Space);
                  }
               }
            } 
         }
      }
      
      if(isHoldHedge == false){
         if(Arr_Hedge_Order_Total[i] == 0){
           //if(isOpenFirst(Symbols_FIRST,Symbols_SECOND,Symbols_THIRD,"H",i)){
           if(Group_ReadyPosition == "H"){
               Util_OpenOrder(Symbols_FIRST,OP_BUY,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_H_"+Group_Space);
               Util_OpenOrder(Symbols_SECOND,OP_SELL,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_H_"+Group_Space);
           }
           //}
         }else{
            if(Total_Allow_Resolve >Arr_Hedge_Order_Total[i]){
               int Order_Space = Arr_Hedge_Order_Space_Of_Space[i];
               if(Order_Space > 1000){
                  // 3 symbols confirm macd,sto,and others...
                  bool isNextOpen = Arr_Hedge_IsOpenCondition[i];
                  if(isNextOpen){ 
                     Lot = (Lot_Size*((Order_Space/1000)*2));
                     Util_OpenOrder(Symbols_FIRST,OP_BUY,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_H_"+Group_Space);
                     Util_OpenOrder(Symbols_SECOND,OP_SELL,Lot,Symbols_FIRST+"_"+Symbols_SECOND+"_H_"+Group_Space);
                  }
               }
            } 
         }
      }
      
       
   }
   ClearOrders(); 
   Rebind();  
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
      if(id==CHARTEVENT_OBJECT_CLICK) { 
         long z=ObjectGetInteger(0,sparam,OBJPROP_ZORDER); 
         for(int i = 0; i < Size_Group; i++){ 
            string btn_Main_Hold = "btn_Main_Hold_"+IntegerToString(i); 
            string btn_Hedge_Hold = "btn_Hedge_Hold_"+IntegerToString(i); 
            
            if(sparam == btn_Main_Hold){
               Arr_Main_Hold[i] = (Arr_Main_Hold[i] == true) ? false : true;
            }
            
            if(sparam == btn_Hedge_Hold){
               Arr_Hedge_Hold[i] = (Arr_Hedge_Hold[i] == true) ? false : true;
            }
            
         }
      }
  }
//+------------------------------------------------------------------+


void InitSymbols(){
   string arr_Group[];
   string symbols = Symbols_01+Symbols_02+Symbols_03+Symbols_04;
   Util_Split(symbols,",",arr_Group);
   Size_Group = ArraySize(arr_Group);
   ArrayResize(Arr_Symbols_FIRST,Size_Group);
   ArrayResize(Arr_Symbols_SECOND,Size_Group);
   ArrayResize(Arr_Symbols_THIRD,Size_Group); 
   ArrayResize(Arr_Symbols_FIRST_DIRECTION,Size_Group);
   ArrayResize(Arr_Symbols_SECOND_DIRECTION,Size_Group);
   ArrayResize(Arr_Symbols_THIRD_DIRECTION,Size_Group); 
   ArrayResize(Arr_Group_ReadyPosition,Size_Group); 
   ArrayResize(Arr_Group_Space,Size_Group); 
   ArrayResize(Arr_Main_Order_Space,Size_Group); 
   ArrayResize(Arr_Hedge_Order_Space,Size_Group); 
   ArrayResize(Arr_Main_Order_Space_Of_Space,Size_Group); 
   ArrayResize(Arr_Hedge_Order_Space_Of_Space,Size_Group); 
   ArrayResize(Arr_Main_Order_Total,Size_Group); 
   ArrayResize(Arr_Hedge_Order_Total,Size_Group); 
   ArrayResize(Arr_Main_Order_Lot,Size_Group); 
   ArrayResize(Arr_Main_Order_Latest_Lot,Size_Group);  
   ArrayResize(Arr_Hedge_Order_Lot,Size_Group); 
   ArrayResize(Arr_Hedge_Order_Latest_Lot,Size_Group); 
   ArrayResize(Arr_Main_Order_Profit,Size_Group); 
   ArrayResize(Arr_Hedge_Order_Profit,Size_Group); 
   ArrayResize(Arr_Main_Order_Latest_Profit,Size_Group); 
   ArrayResize(Arr_Hedge_Order_Latest_Profit,Size_Group); 
   ArrayResize(Arr_Main_IsOpenCondition,Size_Group); 
   ArrayResize(Arr_Hedge_IsOpenCondition,Size_Group);  
   ArrayResize(Arr_Main_Hold,Size_Group); 
   ArrayResize(Arr_Hedge_Hold,Size_Group);  
    
   for(int i = 0; i < Size_Group;i++){
      string arr_Symbols[];
      Util_Split(arr_Group[i],"-",arr_Symbols);
      Arr_Symbols_FIRST[i] = arr_Symbols[0];
      Arr_Symbols_SECOND[i] = arr_Symbols[1];
      Arr_Symbols_THIRD[i] = arr_Symbols[2];
      
      Arr_Main_Order_Total[i]    = 0;
      Arr_Hedge_Order_Total[i]   = 0;
      Arr_Main_Order_Lot[i]      = 0;
      Arr_Main_Order_Latest_Lot[i] = 0;
      Arr_Hedge_Order_Lot[i]     = 0;
      Arr_Hedge_Order_Latest_Lot[i]     = 0;
      Arr_Main_Order_Profit[i]   = 0;
      Arr_Hedge_Order_Profit[i]  = 0; 
      Arr_Main_Order_Latest_Profit[i]   = 0;
      Arr_Hedge_Order_Latest_Profit[i]  = 0; 
      Arr_Main_IsOpenCondition[i] = false; 
      Arr_Hedge_IsOpenCondition[i] = false;  
      Arr_Hedge_Order_Space[i]   = 99999999; 
      Arr_Main_Hold[i] = false; 
      Arr_Hedge_Hold[i] = false; 
   }
}

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
   string lbl_Symbol_First  =  "lbl_Symbol_Main";
   string lbl_Symbol_Second =  "lbl_Symbol_Hedge";
   string lbl_Symbol_Third  =  "lbl_Symbol_Third";
   string lbl_Direction  =  "lbl_Direction";
   string lbl_Space  =  "lbl_Space";
   string lbl_Main_Profit  =  "lbl_Main_Profit";
   string lbl_Hedge_Profit  =  "lbl_Hedge_Profit";
   string lbl_Total_Profit  =  "lbl_Total_Profit";
   string lbl_Main_Lot  =  "lbl_Main_Lot";
   string lbl_Hedge_Lot  =  "lbl_Hedge_Lot";
   string lbl_Total_Lot  =  "lbl_Total_Lot";
   string lbl_Main_Total  =  "lbl_Main_Total";
   string lbl_Hedge_Total  =  "lbl_Hedge_Total";
   string lbl_Total_Total  =  "lbl_Total_Total";
   
   string btn_Main_Hold  =  "btn_Main_Hold";
   string btn_Hedge_Hold  =  "btn_Hedge_Hold";
      
   if(ObjectFind(lbl_Symbol_First) < 0){
      Util_LabelCreate(0,lbl_Symbol_First,0,20,20,CORNER_LEFT_UPPER,"MAIN","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
      Util_LabelCreate(0,lbl_Symbol_Second,0,85,20,CORNER_LEFT_UPPER,"HEDGE","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      Util_LabelCreate(0,lbl_Symbol_Third,0,150,20,CORNER_LEFT_UPPER,"CHECK","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      Util_LabelCreate(0,lbl_Space,0,240,20,CORNER_LEFT_UPPER,"SPACE","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      Util_LabelCreate(0,lbl_Main_Profit,0,300,20,CORNER_LEFT_UPPER,"MAIN : PROFIT    LOT/SPACE","Arial",9,clrGreen,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      Util_LabelCreate(0,lbl_Hedge_Profit,0,490,20,CORNER_LEFT_UPPER,"HEDGE : PROFIT    LOT/SPACE","Arial",9,clrYellow,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      Util_LabelCreate(0,lbl_Total_Profit,0,700,20,CORNER_LEFT_UPPER,"TOTAL : PROFIT    LOT/ORDER","Arial",9,clrAqua,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
     
   }
   
   for(int i = 0; i< Size_Group; i++){
      string symbol_first = Arr_Symbols_FIRST[i];
      string symbol_second = Arr_Symbols_SECOND[i];
      string symbol_third = Arr_Symbols_THIRD[i];  
      string Group_ReadyPosition = Arr_Group_ReadyPosition[i];  
      string Group_Space = (string)Arr_Group_Space[i];  //(string)Arr_Hedge_Order_Space[i];//(string)Arr_Group_Space[i];  
      string Main_Order_Profit = DoubleToString(Arr_Main_Order_Profit[i],2);  
      string Hedge_Order_Profit = DoubleToString(Arr_Hedge_Order_Profit[i],2); 
      string Main_Order_Lot = DoubleToString(Arr_Main_Order_Lot[i],2);  
      string Hedge_Order_Lot = DoubleToString(Arr_Hedge_Order_Lot[i],2);   
      string Main_Order_Total = (string)Arr_Main_Order_Total[i];  
      string Hedge_Order_Total = (string)Arr_Hedge_Order_Total[i];  
      string Total_Order_Profit = DoubleToString(Arr_Main_Order_Profit[i]+Arr_Hedge_Order_Profit[i],2);
      string Total_Order_Lot = DoubleToString(Arr_Main_Order_Lot[i]+Arr_Hedge_Order_Lot[i],2);
      string Total_Order_Total = (string)(Arr_Main_Order_Total[i]+Arr_Hedge_Order_Total[i]); 
      int Order_MainSpace = Arr_Main_Order_Space_Of_Space[i];
      int Order_HedgeSpace = Arr_Hedge_Order_Space_Of_Space[i];
      color Clr_First = Arr_Symbols_FIRST_DIRECTION[i] == OP_BUY ? clrBlue : clrRed;
      color Clr_Second = Arr_Symbols_SECOND_DIRECTION[i] == OP_BUY ? clrBlue : clrRed;
      color Clr_Third = Arr_Symbols_THIRD_DIRECTION[i] == OP_BUY ? clrBlue : clrRed;
      
      color Main_Hold = Arr_Main_Hold[i] == true ? clrGreenYellow : clrWhite;
      color Hedge_Hold = Arr_Hedge_Hold[i]  == true ? clrGreenYellow : clrWhite;
      
      lbl_Symbol_First = "lbl_Symbol_First_"+IntegerToString(i);  
      lbl_Symbol_Second = "lbl_Symbol_Second_"+IntegerToString(i);  
      lbl_Symbol_Third = "lbl_Symbol_Third_"+IntegerToString(i); 
      lbl_Direction = "lbl_Direction_"+IntegerToString(i); 
      lbl_Space = "lbl_Space_"+IntegerToString(i); 
      lbl_Main_Profit = "lbl_Main_Profit_"+IntegerToString(i); 
      lbl_Main_Lot = "lbl_Main_lot_"+IntegerToString(i); 
      lbl_Main_Total = "lbl_Main_Total_"+IntegerToString(i); 
      
      lbl_Hedge_Profit = "lbl_Hedge_Profit_"+IntegerToString(i); 
      lbl_Hedge_Lot = "lbl_Hedge_lot_"+IntegerToString(i); 
      lbl_Hedge_Total = "lbl_Hedge_Total_"+IntegerToString(i); 
      
      
      lbl_Total_Profit = "lbl_Total_Profit_"+IntegerToString(i); 
      lbl_Total_Lot = "lbl_Total_Lot_"+IntegerToString(i); 
      lbl_Total_Total = "lbl_Total_Total_"+IntegerToString(i); 
      
      btn_Main_Hold = "btn_Main_Hold_"+IntegerToString(i); 
      btn_Hedge_Hold = "btn_Hedge_Hold_"+IntegerToString(i); 
      
      if(ObjectFind(lbl_Symbol_First) < 0){  
         Util_LabelCreate(0,lbl_Symbol_First,0,20,y,CORNER_LEFT_UPPER,symbol_first,"Arial",9,Clr_First,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
         Util_LabelCreate(0,lbl_Symbol_Second,0,85,y,CORNER_LEFT_UPPER,symbol_second,"Arial",9,Clr_Second,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Symbol_Third,0,150,y,CORNER_LEFT_UPPER,symbol_third,"Arial",9,Clr_Third,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Direction,0,215,y,CORNER_LEFT_UPPER,Group_ReadyPosition,"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Space,0,280,y,CORNER_LEFT_UPPER,Group_Space,"Arial",9,clrWhite,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Main_Profit,0,380,y,CORNER_LEFT_UPPER,Main_Order_Profit,"Arial",9,clrGreen,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Main_Lot,0,460,y,CORNER_LEFT_UPPER,Main_Order_Lot+" / "+IntegerToString(Order_MainSpace),"Arial",9,clrGreen,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Hedge_Profit,0,583,y,CORNER_LEFT_UPPER,Hedge_Order_Profit,"Arial",9,clrYellow,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Hedge_Lot,0,666,y,CORNER_LEFT_UPPER,Hedge_Order_Lot+" / "+IntegerToString(Order_HedgeSpace),"Arial",9,clrYellow,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Total_Profit,0,788,y,CORNER_LEFT_UPPER,Total_Order_Profit,"Arial",9,clrAqua,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Total_Lot,0,870,y,CORNER_LEFT_UPPER,Total_Order_Lot+" / "+Total_Order_Total,"Arial",9,clrAqua,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
        
         Util_LabelCreate(0,btn_Main_Hold,0,300,y,CORNER_LEFT_UPPER,"H","Arial",9,Main_Hold,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,btn_Hedge_Hold,0,490,y,CORNER_LEFT_UPPER,"H","Arial",9,Hedge_Hold,0,ANCHOR_RIGHT_UPPER,false,false,true,0); 
        
      }else{ 
         ObjectSetInteger(0,lbl_Symbol_First,OBJPROP_COLOR,Clr_First);
         ObjectSetInteger(0,lbl_Symbol_Second,OBJPROP_COLOR,Clr_Second);
         ObjectSetInteger(0,lbl_Symbol_Third,OBJPROP_COLOR,Clr_Third); 
         ObjectSetString(0,lbl_Direction,OBJPROP_TEXT,Group_ReadyPosition);
         ObjectSetString(0,lbl_Space,OBJPROP_TEXT,Group_Space);
         ObjectSetString(0,lbl_Main_Profit,OBJPROP_TEXT,Main_Order_Profit);
         ObjectSetString(0,lbl_Main_Lot,OBJPROP_TEXT,Main_Order_Lot+" / "+IntegerToString(Order_MainSpace)); 
         ObjectSetString(0,lbl_Main_Lot,OBJPROP_TOOLTIP,(Main_Order_Total));  
         
         ObjectSetString(0,lbl_Hedge_Profit,OBJPROP_TEXT,Hedge_Order_Profit);
         ObjectSetString(0,lbl_Hedge_Lot,OBJPROP_TEXT,Hedge_Order_Lot+" / "+IntegerToString(Order_HedgeSpace)); 
         ObjectSetString(0,lbl_Hedge_Lot,OBJPROP_TOOLTIP,Hedge_Order_Total);  
         ObjectSetString(0,lbl_Total_Profit,OBJPROP_TEXT,Total_Order_Profit);
         ObjectSetString(0,lbl_Total_Lot,OBJPROP_TEXT,Total_Order_Lot+" / "+Total_Order_Total); 
         
         ObjectSetInteger(0,btn_Main_Hold,OBJPROP_COLOR,Main_Hold);
         ObjectSetInteger(0,btn_Hedge_Hold,OBJPROP_COLOR,Hedge_Hold);
         ObjectSetString(0,btn_Main_Hold,OBJPROP_TOOLTIP,"Hold"); 
         ObjectSetString(0,btn_Hedge_Hold,OBJPROP_TOOLTIP,"Hold"); 
      }
      y += 15;
   }
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function GenInterface: ",fnError);  
      ResetLastError(); 
   }
}

void Rebind(){
 
   for(int i = 0; i < Size_Group;i++){    
      string Symbols_FIRST = Arr_Symbols_FIRST[i];
      string Symbols_SECOND = Arr_Symbols_SECOND[i];    
      string Symbols_THIRD = Arr_Symbols_THIRD[i];   
      Arr_Main_Order_Lot[i] = 0;  
      Arr_Main_Order_Latest_Lot[i] = 0;
      Arr_Main_Order_Profit[i] = 0;
      Arr_Main_Order_Latest_Profit[i] = 0;
      Arr_Hedge_Order_Lot[i] = 0;
      Arr_Hedge_Order_Latest_Lot[i] = 0;
      Arr_Hedge_Order_Profit[i] = 0;
      Arr_Hedge_Order_Latest_Profit[i] = 0;
      Arr_Main_Order_Total[i] = 0;
      Arr_Hedge_Order_Total[i] = 0; 
      Arr_Main_IsOpenCondition[i] = false; 
      Arr_Hedge_IsOpenCondition[i] = false;  
      Arr_Main_Order_Space[i] = 0;
      Arr_Hedge_Order_Space[i] = 99999999;
      //Arr_Main_Order_Space_Of_Space[i] = 0;
      //Arr_Hedge_Order_Space_Of_Space[i] = 0;
      for (int n = 0; n < OrdersTotal(); n++)
      {
         if (OrderSelect(n, SELECT_BY_POS) == true)
         {  
            string arr_Info[];
            //Util_Split(OrderComment(),"_",arr_Info);
            Util_Split(CustomOrderComment(),"_",arr_Info);
            int Main_Space = 0;
            int Hedge_Space = 0;
            if(Symbols_FIRST == arr_Info[0] && Symbols_SECOND == arr_Info[1] && arr_Info[2] == "M"){
               Main_Space = (int)arr_Info[3];
               if(Main_Space >= Arr_Main_Order_Space[i]){
                  Arr_Main_Order_Space[i] = Main_Space;
                  Arr_Main_Order_Latest_Lot[i] = OrderLots();
                  Arr_Main_Order_Latest_Profit[i] = (OrderProfit() + OrderSwap() + OrderCommission()); 
               }
                  Arr_Main_Order_Total[i]++;
                  Arr_Main_Order_Lot[i] += OrderLots();
                  Arr_Main_Order_Profit[i] += (OrderProfit() + OrderSwap() + OrderCommission()); 
               
            }
            
            if(Symbols_FIRST == arr_Info[0] && Symbols_SECOND == arr_Info[1] && arr_Info[2] == "H"){
               Hedge_Space = (int)arr_Info[3];
               if(Hedge_Space <= Arr_Hedge_Order_Space[i]){
                  Arr_Hedge_Order_Space[i] = Hedge_Space; 
                  Arr_Hedge_Order_Latest_Lot[i] = OrderLots();
                  Arr_Hedge_Order_Latest_Profit[i] = (OrderProfit() + OrderSwap() + OrderCommission()); 
               }
                  Arr_Hedge_Order_Total[i]++;
                  Arr_Hedge_Order_Lot[i] += OrderLots();
                  Arr_Hedge_Order_Profit[i] += (OrderProfit() + OrderSwap() + OrderCommission());  
            }
         }
         
         Arr_Main_IsOpenCondition[i] =  isOpenNext(Symbols_FIRST,Symbols_SECOND,Symbols_THIRD,"M");//isOpenCondition(Symbols_FIRST,Symbols_SECOND,Symbols_THIRD,"MAIN",PERIOD_H1,15,35,9); 
         Arr_Hedge_IsOpenCondition[i] = isOpenNext(Symbols_FIRST,Symbols_SECOND,Symbols_THIRD,"H"); //isOpenCondition(Symbols_FIRST,Symbols_SECOND,Symbols_THIRD,"HEDGE",PERIOD_H1,15,35,9);  
      }
      Arr_Main_Order_Lot[i] = Arr_Main_Order_Lot[i]/2;
      Arr_Hedge_Order_Lot[i] = Arr_Hedge_Order_Lot[i]/2;
      Arr_Main_Order_Total[i] = Arr_Main_Order_Total[i]/2;
      Arr_Hedge_Order_Total[i] = Arr_Hedge_Order_Total[i]/2;
   }
}
  

 
void CalculateDirection(){
  for(int i = 0; i < Size_Group;i++){  
      /*
      Arr_Symbols_FIRST_DIRECTION[i] = (MarketInfo(Arr_Symbols_FIRST[i],MODE_BID)+MarketInfo(Arr_Symbols_FIRST[i],MODE_ASK))/2 > iMA(Arr_Symbols_FIRST[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;
      Arr_Symbols_SECOND_DIRECTION[i] = (MarketInfo(Arr_Symbols_SECOND[i],MODE_BID)+MarketInfo(Arr_Symbols_SECOND[i],MODE_ASK))/2 > iMA(Arr_Symbols_SECOND[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;
      Arr_Symbols_THIRD_DIRECTION[i] = (MarketInfo(Arr_Symbols_THIRD[i],MODE_BID)+MarketInfo(Arr_Symbols_THIRD[i],MODE_ASK))/2 > iMA(Arr_Symbols_THIRD[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;   
      string Direction = "";
      if(Arr_Symbols_FIRST_DIRECTION[i] == OP_SELL && Arr_Symbols_SECOND_DIRECTION[i] == OP_BUY)
      {
         Direction = "M";
      }
      
      if(Arr_Symbols_FIRST_DIRECTION[i] == OP_BUY && Arr_Symbols_SECOND_DIRECTION[i] == OP_SELL)
      {
         Direction = "H";
      } 
      */ 
      string Direction = "";
      bool isMainOK = isOpenFirst(Arr_Symbols_FIRST[i],Arr_Symbols_SECOND[i],Arr_Symbols_THIRD[i],"M",i);
      if(isMainOK){
         Direction = "M";
      }
      
      bool isMainHedge = isOpenFirst(Arr_Symbols_FIRST[i],Arr_Symbols_SECOND[i],Arr_Symbols_THIRD[i],"H",i);
      if(isMainHedge){
         Direction = "H";
      }
      
      Arr_Group_ReadyPosition[i] = Direction;
   }
}


void CalculateSpace(){
    for(int i = 0; i < Size_Group;i++){   
      Arr_Group_Space[i] = GetSpace(Arr_Symbols_FIRST[i],Arr_Symbols_SECOND[i],1,PERIOD_M1);
    }
}

  
int GetSpace(string SYMBOL_MAIN,string SYMBOL_HEDGE,int candle_number,int period)
{ 

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
          Print("Error function GetSpace: ",fnError," / ",SYMBOL_MAIN,"-",SYMBOL_HEDGE); 
          ResetLastError(); 
      }
      return price_AVERAGE;
} 
    
   void SetupMM()
   {
       Lot_Size = ((AccountBalance()/3) * 0.0001);
       if (Lot_Size < 0.01)
       {
           Lot_Size = 0.01;
       }    
       Tp_Size = Lot_Size * 100; 
       Loss_Acceptable = (AccountBalance()/Size_Group);
   }
   
   
   bool isOpenFirst(string _SymbolMain,string _SymbolHedge,string _SymbolCheck,string type,int index)
   { 
      bool isOk = false;
      bool isMainOk = false;
      bool isHedgeOk = false;
      bool isCheckOk = false;
      
      int period = PERIOD_M15;
      int fast = 10;
      int slow = 34;
      int signal = 9;
      double MAIN_MACD_MAIN = iMACD(_SymbolMain,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double MAIN_MACD_SIGNAL = iMACD(_SymbolMain,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      
      double HEDGE_MACD_MAIN = iMACD(_SymbolHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double HEDGE_MACD_SIGNAL = iMACD(_SymbolHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
   
      double CHECK_MACD_MAIN = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double CHECK_MACD_SIGNAL = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
   
      if(MAIN_MACD_MAIN < MAIN_MACD_SIGNAL){
         isMainOk = true;
         Arr_Symbols_FIRST_DIRECTION[index] = OP_SELL;
      }else{
         Arr_Symbols_FIRST_DIRECTION[index] = OP_BUY;
      }
      
      if(HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL){
         isHedgeOk = true;
         Arr_Symbols_SECOND_DIRECTION[index] = OP_BUY;
      }else{ 
         Arr_Symbols_SECOND_DIRECTION[index] = OP_SELL;
      }
         
      string checkWith = "";
      int firstOrSec = -1;
      string chk_1 = StringSubstr(_SymbolCheck,0,3); 
      if(StringFind(_SymbolMain,chk_1,0) != -1)
      {
         firstOrSec = StringFind(_SymbolMain,chk_1,0); 
         if(firstOrSec == 0){
            if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
               isCheckOk = true;
               Arr_Symbols_THIRD_DIRECTION[index] = OP_SELL;
            }else{
               Arr_Symbols_THIRD_DIRECTION[index] = OP_BUY; 
            }
         }else{
            if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
               isCheckOk = true;
               Arr_Symbols_THIRD_DIRECTION[index] = OP_BUY;
            }else{ 
               Arr_Symbols_THIRD_DIRECTION[index] = OP_SELL;
            }
         }
      }else{ 
         firstOrSec = StringFind(_SymbolHedge,chk_1,0);  
         if(firstOrSec == 0){
            if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
               isCheckOk = true; 
               Arr_Symbols_THIRD_DIRECTION[index] = OP_BUY;
            }else{
               Arr_Symbols_THIRD_DIRECTION[index] = OP_SELL; 
            }
         }else{
            if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
               isCheckOk = true;
               Arr_Symbols_THIRD_DIRECTION[index] = OP_SELL; 
            }else{
               Arr_Symbols_THIRD_DIRECTION[index] = OP_BUY;
            }
         }
      }
      
      if(type == "H"){
         isMainOk = !isMainOk;
         isHedgeOk = !isHedgeOk;
         isCheckOk = !isCheckOk;
      }
      
     // Arr_Symbols_FIRST_DIRECTION[index] = isMainOk == true ? OP_SELL : OP_BUY;
     // Arr_Symbols_SECOND_DIRECTION[index] = isHedgeOk == true ? OP_SELL : OP_BUY;
     // Arr_Symbols_THIRD_DIRECTION[index] = isCheckOk == true ? OP_SELL : OP_BUY;
      
      if(isMainOk == true && isHedgeOk == true && isCheckOk == true){
         isOk = true;
      }      
      return isOk;
   }
   
   bool isOpenNext(string _SymbolMain,string _SymbolHedge,string _SymbolCheck,string type)
   { 
      bool isOk = false;
      bool isMainOk = false;
      bool isHedgeOk = false;
      bool isCheckOk = false;
      
      int period = PERIOD_H1;
      int fast = 10;
      int slow = 34;
      int signal = 9;
      double MAIN_MACD_MAIN = iMACD(_SymbolMain,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double MAIN_MACD_SIGNAL = iMACD(_SymbolMain,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
      
      double HEDGE_MACD_MAIN = iMACD(_SymbolHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double HEDGE_MACD_SIGNAL = iMACD(_SymbolHedge,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
   
      double CHECK_MACD_MAIN = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_MAIN,0);
      double CHECK_MACD_SIGNAL = iMACD(_SymbolCheck,period,fast,slow,signal,PRICE_CLOSE,MODE_SIGNAL,0);
   
      if(MAIN_MACD_MAIN < MAIN_MACD_SIGNAL){
         isMainOk = true;
      }
      
      if(HEDGE_MACD_MAIN > HEDGE_MACD_SIGNAL){
         isHedgeOk = true;
      }
         
      string checkWith = "";
      int firstOrSec = -1;
      string chk_1 = StringSubstr(_SymbolCheck,0,3); 
      if(StringFind(_SymbolMain,chk_1,0) != -1)
      {
         firstOrSec = StringFind(_SymbolMain,chk_1,0); 
         if(firstOrSec == 0){
            if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
               isCheckOk = true;
            }
         }else{
            if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
               isCheckOk = true;
            }
         }
      }else{ 
         firstOrSec = StringFind(_SymbolHedge,chk_1,0);  
         if(firstOrSec == 0){
            if(CHECK_MACD_MAIN > CHECK_MACD_SIGNAL){
               isCheckOk = true;
            }
         }else{
            if(CHECK_MACD_MAIN < CHECK_MACD_SIGNAL){
               isCheckOk = true;
            }
         }
      }
      
      if(type == "H"){
         isMainOk = !isMainOk;
         isHedgeOk = !isHedgeOk;
         isCheckOk = !isCheckOk;
      }
      
      if(isMainOk == true && isHedgeOk == true && isCheckOk == true){
         isOk = true;
      }      
      return isOk;
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
   
   void ClearOrders()
   {
      int Ticket_Pending_Close = ArraySize(Arr_Ticket_Pending_Close);
      if(Ticket_Pending_Close > 0){
         for(int i = 0; i < Ticket_Pending_Close; i++){
            int ticket = Arr_Ticket_Pending_Close[i];
            if(ticket > 0){
               bool isClosed = Util_CloseOrder(ticket);
               if(isClosed){
                  Arr_Ticket_Pending_Close[i] = 0;
               } 
            }
         }
         int j = 0;
         for(int i = 0; i < Ticket_Pending_Close; i++){
            int ticket = Arr_Ticket_Pending_Close[i];
            if(ticket > 0){
               j++;
            }
         }
         if(j == 0){
            ArrayFree(Arr_Ticket_Pending_Close);
         }
         
         return;
      }  
      
      for(int i = 0; i < Size_Group; i++)
      {
         double Tp_Main_Profit = (Arr_Main_Order_Latest_Lot[i]*100)*2;
         double Tp_Hedge_Profit = (Arr_Hedge_Order_Latest_Lot[i]*100)*2;
         double Current_Main_Profit = Arr_Main_Order_Profit[i];
         double Current_Hedge_Profit = Arr_Hedge_Order_Profit[i];
            
         string Symbols_FIRST = Arr_Symbols_FIRST[i];
         string Symbols_SECOND = Arr_Symbols_SECOND[i];
         string Symbols_THIRD = Arr_Symbols_THIRD[i];
         if(Current_Main_Profit > Tp_Main_Profit)
         {
            //if(Current_Hedge_Profit < Loss_Acceptable){
               // clearOrders
               Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"M",Arr_Ticket_Pending_Close);
            //}else{
            //   int Order_Space = Arr_Hedge_Order_Space[i] == 0 ? 0 : MathAbs(Arr_Group_Space[i]-Arr_Hedge_Order_Space[i]);
            //   if(Order_Space > 1000){ 
            //      bool isNextOpen = Arr_Hedge_IsOpenCondition[i];
            //      if(isNextOpen){
                     // clearOrders
            //         Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"M",Arr_Ticket_Pending_Close);
            //      }
            //   }else{
            //      Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"M",Arr_Ticket_Pending_Close);
            //   }
            //}
           
         }else{
            if(Current_Main_Profit >= 0 && Arr_Hedge_IsOpenCondition[i] && Arr_Hedge_Order_Space_Of_Space[i] > 1000)
            {
               Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"M",Arr_Ticket_Pending_Close);
            }
         }
         
         if(Current_Hedge_Profit > Tp_Hedge_Profit)
         {
            //if(Current_Main_Profit < Loss_Acceptable){
               // clearOrders 
               Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"H",Arr_Ticket_Pending_Close);
            //}else{
            //   int Order_Space = Arr_Main_Order_Space[i] == 0 ? 0 : MathAbs(Arr_Group_Space[i]-Arr_Main_Order_Space[i]);
            //   if(Order_Space > 1000){ 
            //      bool isNextOpen = Arr_Main_IsOpenCondition[i];
            //      if(isNextOpen){
                     // clearOrders
            //         Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"H",Arr_Ticket_Pending_Close);
            //      }
            //   }else{
            //      Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"H",Arr_Ticket_Pending_Close);
            //   }
            //}
         }else{
             if(Current_Hedge_Profit >= 0 && Arr_Main_IsOpenCondition[i] && Arr_Main_Order_Space_Of_Space[i] > 1000)
             {
               Util_ListTickets(Symbols_FIRST,Symbols_SECOND,"H",Arr_Ticket_Pending_Close);
             }
         }
      }
   } 
   
   
   //temp
      string CustomOrderComment(){
          int ticket = OrderTicket();
          
          
          if(ticket == 28626400){ return "GBPNZD_EURNZD_M_20755";}
          if(ticket == 28626401){ return "GBPNZD_EURNZD_M_20755";}
          if(ticket == 28763095){ return "GBPNZD_EURNZD_H_21411";}
          if(ticket == 28763099){ return "GBPNZD_EURNZD_H_21411";} //2
          if(ticket == 28635593){ return "EURNZD_EURGBP_H_87725";}
          if(ticket == 28635594){ return "EURNZD_EURGBP_H_87725";} //1
          
          
          if(ticket == 28594836){ return "GBPNZD_EURGBP_M_107053";}
          if(ticket == 28594837){ return "GBPNZD_EURGBP_M_107053";}
          if(ticket == 28650890){ return "GBPNZD_EURGBP_M_108402";}
          if(ticket == 28650891){ return "GBPNZD_EURGBP_M_108402";}
          if(ticket == 28763244){ return "GBPNZD_EURGBP_H_107959";}
          if(ticket == 28763249){ return "GBPNZD_EURGBP_H_107959";} // 3
           
          if(ticket == 28696801){ return "AUDCAD_AUDUSD_H_22154";}
          if(ticket == 28696803){ return "AUDCAD_AUDUSD_H_22154";}
          if(ticket == 28755591){ return "AUDCAD_AUDUSD_M_20277";}
          if(ticket == 28755592){ return "AUDCAD_AUDUSD_M_20277";} // 2
           
          if(ticket == 28696865){ return "USDCAD_AUDUSD_H_58444";}
          if(ticket == 28696868){ return "USDCAD_AUDUSD_H_58444";}
          if(ticket == 28773643){ return "USDCAD_AUDUSD_M_55587";}
          if(ticket == 28773644){ return "USDCAD_AUDUSD_M_55587";} //2
          
          if(ticket == 28705648){ return "USDCAD_AUDCAD_H_36472";}
          if(ticket == 28705649){ return "USDCAD_AUDCAD_H_36472";}
          if(ticket == 28773862){ return "USDCAD_AUDCAD_M_35437";}
          if(ticket == 28773863){ return "USDCAD_AUDCAD_M_35437";}
          return OrderComment(); 
      }
   
   //temp
   
   

//////// UTILITIES ///////////

void Util_ListTickets(string _SymbolMain,string _SymbolHedge,string _Type,int &Arr_Tickets[])
{
     for (int i = 0; i <= (OrdersTotal() - 1); i++)
     {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         {
            if(Util_isFocusedOrder(_SymbolMain,_SymbolHedge,_Type))
            {
                int newSize = ArraySize(Arr_Tickets)+1;
                ArrayResize(Arr_Tickets,newSize);
                Arr_Tickets[newSize-1] = OrderTicket(); 
            }
         }
     } 
}

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
   
void Util_Split(string text,string split,string & result[]){
   StringSplit(text,StringGetCharacter(split,0),result);
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function Split: ",fnError);  
      ResetLastError();
   }
}



bool Util_isFocusedOrder(string SYMBOL_MAIN,string SYMBOL_HEDGE,string TYPE){
   //OrderSelect needed before call this function
   //if(StringFind(OrderComment(),SYMBOL_MAIN,0) >= 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) >= 0){
   //   if(StringFind(OrderComment(),TYPE,0) >= 0){
   if(StringFind(CustomOrderComment(),SYMBOL_MAIN,0) >= 0 && StringFind(CustomOrderComment(),SYMBOL_HEDGE,0) >= 0){
      if(StringFind(CustomOrderComment(),TYPE,0) >= 0){
         return true;
      }else{
         return false;
      } 
   }else{
      return false;
   }
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