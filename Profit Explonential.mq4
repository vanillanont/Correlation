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

//--- global parameters
string Arr_Symbols_FIRST[];
string Arr_Symbols_SECOND[];
string Arr_Symbols_THIRD[];
int Arr_Symbols_FIRST_DIRECTION[];
int Arr_Symbols_SECOND_DIRECTION[];
int Arr_Symbols_THIRD_DIRECTION[];
string Arr_Group_ReadyPosition[];

int Size_Group = 0;

int OnInit()
  {
//---
   ClearInterface();
   InitSymbols();
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
//---
   CalculateDirection();
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
   
   for(int i = 0; i < Size_Group;i++){
      string arr_Symbols[];
      Util_Split(arr_Group[i],"-",arr_Symbols);
      Arr_Symbols_FIRST[i] = arr_Symbols[0];
      Arr_Symbols_SECOND[i] = arr_Symbols[1];
      Arr_Symbols_THIRD[i] = arr_Symbols[2];
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
      
   if(ObjectFind(lbl_Symbol_First) < 0){
      Util_LabelCreate(0,lbl_Symbol_First,0,20,20,CORNER_LEFT_UPPER,"MAIN","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
      Util_LabelCreate(0,lbl_Symbol_Second,0,85,20,CORNER_LEFT_UPPER,"HEDGE","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      Util_LabelCreate(0,lbl_Symbol_Third,0,150,20,CORNER_LEFT_UPPER,"CHECK","Arial",9,clrDarkGray,0,ANCHOR_LEFT_UPPER,false,false,true,0); 

   }
   
   for(int i = 0; i< Size_Group; i++){
      string symbol_first = Arr_Symbols_FIRST[i];
      string symbol_second = Arr_Symbols_SECOND[i];
      string symbol_third = Arr_Symbols_THIRD[i];  
      string Group_ReadyPosition = Arr_Group_ReadyPosition[i];  
      
      color Clr_First = Arr_Symbols_FIRST_DIRECTION[i] == OP_BUY ? clrBlue : clrRed;
      color Clr_Second = Arr_Symbols_SECOND_DIRECTION[i] == OP_BUY ? clrBlue : clrRed;
      color Clr_Third = Arr_Symbols_THIRD_DIRECTION[i] == OP_BUY ? clrBlue : clrRed;
      
      lbl_Symbol_First = "lbl_Symbol_First_"+IntegerToString(i);  
      lbl_Symbol_Second = "lbl_Symbol_Second_"+IntegerToString(i);  
      lbl_Symbol_Third = "lbl_Symbol_Third_"+IntegerToString(i); 
      lbl_Direction = "lbl_Direction_"+IntegerToString(i); 
      
      if(ObjectFind(lbl_Symbol_First) < 0){  
         Util_LabelCreate(0,lbl_Symbol_First,0,20,y,CORNER_LEFT_UPPER,symbol_first,"Arial",9,Clr_First,0,ANCHOR_LEFT_UPPER,false,false,true,0);  
         Util_LabelCreate(0,lbl_Symbol_Second,0,85,y,CORNER_LEFT_UPPER,symbol_second,"Arial",9,Clr_Second,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Symbol_Third,0,150,y,CORNER_LEFT_UPPER,symbol_third,"Arial",9,Clr_Third,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
         Util_LabelCreate(0,lbl_Direction,0,215,y,CORNER_LEFT_UPPER,Group_ReadyPosition,"Arial",9,clrWhite,0,ANCHOR_LEFT_UPPER,false,false,true,0); 
      
      }else{ 
         ObjectSetInteger(0,lbl_Symbol_First,OBJPROP_COLOR,Clr_First);
         ObjectSetInteger(0,lbl_Symbol_Second,OBJPROP_COLOR,Clr_Second);
         ObjectSetInteger(0,lbl_Symbol_Third,OBJPROP_COLOR,Clr_Third); 
         ObjectSetString(0,lbl_Direction,OBJPROP_TEXT,Group_ReadyPosition);
      }
      y += 15;
   }
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function GenInterface: ",fnError);  
      ResetLastError(); 
   }
}

/*
void CalculateDirection(){
  for(int i = 0; i < Size_Group;i++){  
       
      Arr_Symbols_FIRST_DIRECTION[i] = (MarketInfo(Arr_Symbols_FIRST[i],MODE_BID)+MarketInfo(Arr_Symbols_FIRST[i],MODE_ASK))/2 > iMA(Arr_Symbols_FIRST[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;
      Arr_Symbols_SECOND_DIRECTION[i] = (MarketInfo(Arr_Symbols_SECOND[i],MODE_BID)+MarketInfo(Arr_Symbols_SECOND[i],MODE_ASK))/2 > iMA(Arr_Symbols_SECOND[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;
      Arr_Symbols_THIRD_DIRECTION[i] = (MarketInfo(Arr_Symbols_THIRD[i],MODE_BID)+MarketInfo(Arr_Symbols_THIRD[i],MODE_ASK))/2 > iMA(Arr_Symbols_THIRD[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;   
      string Direction = "-";
      if(Arr_Symbols_FIRST_DIRECTION[i] == OP_SELL && Arr_Symbols_SECOND_DIRECTION[i] == OP_BUY)
      {
         string checkWith = "";
         int firstOrSec = -1;
         string chk_1 = StringSubstr(Arr_Symbols_THIRD[i],0,3); 
         if(StringFind(Arr_Symbols_FIRST[i],chk_1,0) != -1)
         { 
            firstOrSec = StringFind(Arr_Symbols_FIRST[i],chk_1,0); 
            if(firstOrSec == 0){
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_SELL){
                  Direction = "MAIN";
               }
            }else{
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_BUY){
                  Direction = "MAIN";
               }
            }
         }else{  
            firstOrSec = StringFind(Arr_Symbols_FIRST[i],chk_1,0);  
            if(firstOrSec == 0){
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_BUY){
                  Direction = "MAIN";
               }
            }else{
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_SELL){
                  Direction = "MAIN";
               }
            }
         } 
      }
      
      if(Arr_Symbols_FIRST_DIRECTION[i] == OP_BUY && Arr_Symbols_SECOND_DIRECTION[i] == OP_SELL)
      {
         string checkWith = "";
         int firstOrSec = -1;
         string chk_1 = StringSubstr(Arr_Symbols_THIRD[i],0,3); 
         if(StringFind(Arr_Symbols_FIRST[i],chk_1,0) != -1)
         { 
            firstOrSec = StringFind(Arr_Symbols_FIRST[i],chk_1,0); 
            if(firstOrSec == 0){
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_BUY){
                  Direction = "HEDGE";
               }
            }else{
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_SELL){
                  Direction = "HEDGE";
               }
            }
         }else{  
            firstOrSec = StringFind(Arr_Symbols_FIRST[i],chk_1,0);  
            if(firstOrSec == 0){
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_SELL){
                  Direction = "HEDGE";
               }
            }else{
               if(Arr_Symbols_THIRD_DIRECTION[i] == OP_BUY){
                  Direction = "HEDGE";
               }
            }
         } 
      } 
      Arr_Group_ReadyPosition[i] = Direction;
   }
}
 */
 
 
void CalculateDirection(){
  for(int i = 0; i < Size_Group;i++){  
       
      Arr_Symbols_FIRST_DIRECTION[i] = (MarketInfo(Arr_Symbols_FIRST[i],MODE_BID)+MarketInfo(Arr_Symbols_FIRST[i],MODE_ASK))/2 > iMA(Arr_Symbols_FIRST[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;
      Arr_Symbols_SECOND_DIRECTION[i] = (MarketInfo(Arr_Symbols_SECOND[i],MODE_BID)+MarketInfo(Arr_Symbols_SECOND[i],MODE_ASK))/2 > iMA(Arr_Symbols_SECOND[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;
      Arr_Symbols_THIRD_DIRECTION[i] = (MarketInfo(Arr_Symbols_THIRD[i],MODE_BID)+MarketInfo(Arr_Symbols_THIRD[i],MODE_ASK))/2 > iMA(Arr_Symbols_THIRD[i],PERIOD_M5,32,0,MODE_SMA,PRICE_CLOSE,0) ? OP_BUY : OP_SELL;   
      string Direction = "-";
      if(Arr_Symbols_FIRST_DIRECTION[i] == OP_SELL && Arr_Symbols_SECOND_DIRECTION[i] == OP_BUY)
      {
         Direction = "MAIN";
      }
      
      if(Arr_Symbols_FIRST_DIRECTION[i] == OP_BUY && Arr_Symbols_SECOND_DIRECTION[i] == OP_SELL)
      {
         Direction = "HEDGE";
      } 
      Arr_Group_ReadyPosition[i] = Direction;
   }
}
 


//////// UTILITIES ///////////
void Util_Split(string text,string split,string & result[]){
   StringSplit(text,StringGetCharacter(split,0),result);
   int fnError = GetLastError();
   if(fnError > 0){
      Print("Error function Split: ",fnError);  
      ResetLastError();
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