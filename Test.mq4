//+------------------------------------------------------------------+
//|                                              Profit Playsafe.mq4 |
//|                                          Tanawat Vanitchayanont. |
//|    https://www.myfxbook.com/portfolio/profit-exponential/2686200 |
//+------------------------------------------------------------------+
#property copyright "Tanawat Vanitchayanont."
#property link      "https://www.myfxbook.com/portfolio/profit-exponential/2686200"
#property version   "1.00"
#property strict
//--- input parameters
extern string Symbol_Focus = "GBPNZD";
extern string Symbols_Main = "GBPUSD,GBPCHF,GBPJPY,GBPCAD,GBPAUD";
extern string Symbols_Hedge = "NZDUSD,NZDCHF,NZDJPY,NZDCAD,AUDNZD";
extern int Total_Allow_Resolve = 4;
 
int OnInit()
  {    
  Trending();
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


int Trending(){
   
   double Arr_High[];
   double Arr_Low[];
   double Arr_High_Shift[];
   double Arr_Low_shift[];
   double Arr_High_Slope[];
   double Arr_Low_Slope[];
   

   MqlDateTime dt;
   TimeCurrent(dt); 
   int currentDay = dt.day; 
   int shiftDay = currentDay-1; 
   int EarlyDay = currentDay-10;  
   datetime time = StrToTime(IntegerToString(dt.year)+"."+IntegerToString(dt.mon)+"."+IntegerToString(dt.day-1)+" 23:00");  
   int barNumber = iBarShift(Symbol(),PERIOD_H1,time); 
   for(shiftDay; shiftDay >= EarlyDay; shiftDay--)
   {
      int barHighest = iHighest(Symbol(),PERIOD_H1,MODE_CLOSE,23,barNumber);
      int barLowest = iLowest(Symbol(),PERIOD_H1,MODE_CLOSE,23,barNumber);
      ArrayAdd_Double(Arr_High_Shift,barHighest);
      ArrayAdd_Double(Arr_Low_shift,barLowest);      
      double priceHighest = iHigh(Symbol(),PERIOD_H1,barHighest);
      double priceLowest = iLow(Symbol(),PERIOD_H1,barLowest);
      ArrayAdd_Double(Arr_High,priceHighest);
      ArrayAdd_Double(Arr_Low,priceLowest);
      //Print("Highest: "+priceHighest+" Lowest: "+priceLowest);
      barNumber = barNumber + 24; 
      //for(int n = 23; n >= 0; n--){ 
      //   barNumber--; 
      //}
   }
   
   double FirstHighestPrice = Arr_High[ArraySize(Arr_High)-1]; // (X1 Highest);
   double FirstLowestPrice = Arr_Low[ArraySize(Arr_Low)-1]; // (X1 Lowest);
   
   double FirstHighestShift = Arr_High_Shift[ArraySize(Arr_High_Shift)-1]; // (Y1 Highest);
   double FirstLowestShift = Arr_Low_shift[ArraySize(Arr_Low_shift)-1]; // (Y1 Lowest);
   for(int i = (ArraySize(Arr_High)-2); i >= 0; i--){ 
      double NextHighestPrice = Arr_High[i];
      double NextLowestPrice = Arr_Low[i]; 
       
      double NextHighestShift = Arr_High_Shift[i];
      double NextLowestShift = Arr_Low_shift[i];
      
      double HighestSlope = (FirstHighestPrice-NextHighestPrice)/(FirstHighestShift-NextHighestShift);
      double LowestSlope = (FirstLowestPrice-NextLowestPrice)/(FirstLowestShift-NextLowestPrice);
      
      Print("High Slope: "+FirstHighestShift+"-"+NextHighestShift+"/"+FirstHighestPrice+"-"+NextHighestPrice+" = "+HighestSlope);  
      Print("Low Slope: "+FirstLowestShift+"-"+NextLowestShift+"/"+FirstLowestPrice+"-"+NextLowestPrice+" = "+LowestSlope);  
      
   }
    
   return 0;
}


void ArrayAdd_Double(double &array[],double value){ 
      ArrayResize(array,(ArraySize(array)+1));
      array[(ArraySize(array)-1)] = value;
}
  