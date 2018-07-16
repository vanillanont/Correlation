//+------------------------------------------------------------------+
//|                                                  Correlation.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

extern string SYMBOL_MAIN = "EURGBP";  
extern string SYMBOL_HEDGE = "GBPCHF";

enum WAY 
  {
   SAME = 0,        // BOTH SYMBOL GO SAME WAY
   DIFFERENCE = 1,  // EACH SYMBOL GO DIFFERENCE WAY
  }; 
extern WAY SYMBOL_WAY = DIFFERENCE;
extern int CONFORT_ZONE = 95; // CHECKING FOR OPEN OUTSIDE ZONE

bool IS_OPEN_1 = false;
bool IS_OPEN_2 = false;
bool IS_OPEN_3 = false;
bool IS_OPEN_4 = false;
bool IS_OPEN_5 = false;
bool IS_OPEN_6 = false;
bool IS_OPEN_7 = false;
bool IS_OPEN_8 = false;
bool IS_OPEN_9 = false;

int OnInit()
  {
   SYMBOL_MAIN = StringToUpper(SYMBOL_MAIN);
   SYMBOL_HEDGE = StringToUpper(SYMBOL_HEDGE);

   if((SYMBOL_MAIN == "EURGBP" && SYMBOL_MAIN == "GBPCHF") || 
      (SYMBOL_MAIN == "GBPCHF" && SYMBOL_MAIN == "EURGBP")){
         SYMBOL_WAY = DIFFERENCE;
      }
      
   if((SYMBOL_MAIN == "EURUSD" && SYMBOL_MAIN == "USDJPY") || 
      (SYMBOL_MAIN == "USDJPY" && SYMBOL_MAIN == "EURUSD")){
         SYMBOL_WAY = DIFFERENCE;
      }
          
   if((SYMBOL_MAIN == "USDCHF" && SYMBOL_MAIN == "EURUSD") || 
      (SYMBOL_MAIN == "EURUSD" && SYMBOL_MAIN == "USDCHF")){
         SYMBOL_WAY = DIFFERENCE;
      } 
               
   if((SYMBOL_MAIN == "CHFJPY" && SYMBOL_MAIN == "EURJPY") || 
      (SYMBOL_MAIN == "EURJPY" && SYMBOL_MAIN == "CHFJPY")){
         SYMBOL_WAY = DIFFERENCE;
      } 
            
   if((SYMBOL_MAIN == "CHFJPY" && SYMBOL_MAIN == "EURJPY") || 
      (SYMBOL_MAIN == "EURJPY" && SYMBOL_MAIN == "CHFJPY")){
         SYMBOL_WAY = SAME;
      } 
       
   if((SYMBOL_MAIN == "USDJPY" && SYMBOL_MAIN == "USDCHF") || 
      (SYMBOL_MAIN == "USDCHF" && SYMBOL_MAIN == "USDJPY")){
         SYMBOL_WAY = SAME;
      } 
        
   if((SYMBOL_MAIN == "GBPCHF" && SYMBOL_MAIN == "GBPJPY") || 
      (SYMBOL_MAIN == "GBPJPY" && SYMBOL_MAIN == "GBPCHF")){
         SYMBOL_WAY = SAME;
      } 
      
   if((SYMBOL_MAIN == "USDJPY" && SYMBOL_MAIN == "CHFJPY") || 
      (SYMBOL_MAIN == "CHFJPY" && SYMBOL_MAIN == "USDJPY")){
         SYMBOL_WAY = SAME;
      } 
       
   if((SYMBOL_MAIN == "EURUSD" && SYMBOL_MAIN == "NZDUSD") || 
      (SYMBOL_MAIN == "NZDUSD" && SYMBOL_MAIN == "EURUSD")){
         SYMBOL_WAY = SAME;
      } 
        
        
//---
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

   double MONTH_DIRECTION = MathAbs(Cor(_symbol1, _symbol2, 30, 0, PERIOD_D1);
   double HOUR_DIRECTION = MathAbs(Cor(_symbol1, _symbol2, 72, 0, PERIOD_H1);
      
   if(MONTH_DIRECTION > 90){ // BIG TIMEFRAME STILL RUNNING IN CONFORT ZONE
      if(HOUR_DIRECTION < 90 && HOUR_DIRECTION > 85 && IS_OPEN_1){
         //BEGIN FIRST ORDER
      }
      
      if(HOUR_DIRECTION < 85 && HOUR_DIRECTION > 80 && IS_OPEN_2){
         //NEXT ORDER
      }
      
      if(HOUR_DIRECTION < 80 && HOUR_DIRECTION > 75 && IS_OPEN_3){
         //NEXT ORDER
      }
      
      if(HOUR_DIRECTION < 75 && HOUR_DIRECTION > 70 && IS_OPEN_4){
         //NEXT ORDER
      }
      
      if(HOUR_DIRECTION < 70 && HOUR_DIRECTION > 65 && IS_OPEN_5){
         //NEXT ORDER
      }
       
      if(HOUR_DIRECTION < 65 && HOUR_DIRECTION > 60 && IS_OPEN_6){
         //NEXT ORDER
      }
       
      if(HOUR_DIRECTION < 60 && HOUR_DIRECTION > 55 && IS_OPEN_7){
         //NEXT ORDER
      }
       
      if(HOUR_DIRECTION < 55 && HOUR_DIRECTION > 50 && IS_OPEN_8){
         //NEXT ORDER
      }
      
   }      
    
   
   //MathAbs
}
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
double sDif(string symbol, int shift, int _period, int timeframe)
{
    return (iClose(symbol, timeframe, shift) - iMA(symbol, timeframe, _period, 0, MODE_SMA, PRICE_CLOSE, shift));
}

double pDif(double val)
{
    return (MathPow(val, 2));
}

double Cor(string base, string hedge, int _period, int shift, int timeframe = 0)
{
    double u1 = 0, l1 = 0, s1 = 0;
    for (int i = (_period + shift) - 1; i >= shift; i--)
    {
        u1 += sDif(base, i, _period, timeframe) * sDif(hedge, i, _period, timeframe);
        l1 += pDif(sDif(base, i, _period, timeframe));
        s1 += pDif(sDif(hedge, i, _period, timeframe));
    }
    double dMathSqrt = MathSqrt(l1 * s1);
    if (dMathSqrt > 0)
    {
        return (u1 / dMathSqrt);
    }
    else
    {
        return dMathSqrt;
    }
}
