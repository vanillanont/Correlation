//+------------------------------------------------------------------+
//|                                                       Test01.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"   
int current_total_order=0;
int pipstep=10;
bool isPause=false;
bool isClose= false;

ulong ticket_begin=0;
ulong ticket_latest=0;
int begin_order_price= 0;
int last_order_price = 0;
ENUM_ORDER_TYPE order_type_begin;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isNewBar())
     {
      isPause=false;
     }
   if(isClose==true)
     {
      if(Util_TotalOrders()>0)
        {
         Util_CloseAllOrders();
         ticket_begin=0;
         ticket_latest=0;
         begin_order_price= 0;
         last_order_price = 0;
         isPause=true;

         isClose=false;
        }
      return;
     }
   current_total_order=Util_TotalOrders();
   if(current_total_order==0 && isPause==false)
     {
      int bigAvr = Get_Average_Space(1,10);
      int chkAvr = Get_Average_Space(1,5);
      if(chkAvr<bigAvr)
        {
         string type=CheckBar();
         if(type=="UP")
           {

            ticket_begin=Util_OpenOrderWithSLTP(Symbol(),OP_SELL,0.01,0,0,"1");
            if(ticket_begin>0)
              {
               if(OrderSelect(10,SELECT_BY_TICKET)==true)
                 {
                  last_order_price=Util_PriceNoDigit(Symbol(),OrderOpenPrice());
                  begin_order_price= last_order_price;
                  order_type_begin = OP_BUY;
                 }
              }

            if(type=="DOWN")
              {
               ticket_begin=Util_OpenOrderWithSLTP(Symbol(),OP_BUY,0.01,0,0,"1");
               if(ticket_begin>0)
                 { if(OrderSelect(10,SELECT_BY_TICKET)==true)
                    {
                     last_order_price=Util_PriceNoDigit(Symbol(),OrderOpenPrice());
                     begin_order_price= last_order_price;
                     order_type_begin = OP_BUY;
                    }
                 }
              }
           }
           }else{
         if(order_type_begin==ORDER_TYPE_SELL)
           {
            int next_open=last_order_price+pipstep;
            int price=Util_PriceNoDigit(Symbol(),SymbolInfoDouble(Symbol(),SYMBOL_BID));
            //Comment(next_open+" / "+price);
            if(price>=next_open)
              {
               ticket_latest=Util_OpenOrderWithSLTP(Symbol(),OP_SELL,0.01,0,0,"2");
               if(ticket_latest>0)
                 {
                  if(OrderSelect(10,SELECT_BY_TICKET)==true)
                    {
                     last_order_price=Util_PriceNoDigit(Symbol(),OrderOpenPrice());
                    }
                 }
              }
           }

         if(order_type_begin==ORDER_TYPE_BUY)
           {
            int next_open=last_order_price-pipstep;
            int price=Util_PriceNoDigit(Symbol(),SymbolInfoDouble(Symbol(),SYMBOL_ASK));
            //Comment(next_open+" / "+price);
            if(price<=next_open)
              {
               ticket_latest=Util_OpenOrderWithSLTP(Symbol(),OP_BUY,0.01,0,0,"2");
               if(ticket_latest>0)
                 {
                  if(OrderSelect(10,SELECT_BY_TICKET)==true)
                    {
                     last_order_price=Util_PriceNoDigit(Symbol(),OrderOpenPrice());
                    }
                 }
              }
           }
        }
      if(ticket_begin>0)
        {
         for(int i=0; i<PositionsTotal(); i++)
           {
            ulong ticket=PositionGetTicket(i);
            if(ticket!=0)// if the order was successfully copied into the cache, work with it
              {
               if(ticket==ticket_begin)
                 {
                  double ticket_price=PositionGetDouble(POSITION_PRICE_CURRENT);

                  if(ticket_price>0.10)
                    {
                     isClose=true;
                    }
                 }
              }
           }

        }
     }
  }
//+------------------------------------------------------------------+

string CheckBar()
  {
   string result="";
   int previous_open=Util_PriceNoDigit(Symbol(),iOpen(Symbol(),PERIOD_CURRENT,1));
   int previous_close=Util_PriceNoDigit(Symbol(),iClose(Symbol(),PERIOD_CURRENT,1));
   int previous_2_open=Util_PriceNoDigit(Symbol(),iOpen(Symbol(),PERIOD_CURRENT,2));
   int previous_2_close= Util_PriceNoDigit(Symbol(),iClose(Symbol(),PERIOD_CURRENT,2));
   int previous_3_open = Util_PriceNoDigit(Symbol(),iOpen(Symbol(),PERIOD_CURRENT,3));
   int previous_3_close= Util_PriceNoDigit(Symbol(),iClose(Symbol(),PERIOD_CURRENT,3));
   int previous_4_open = Util_PriceNoDigit(Symbol(),iOpen(Symbol(),PERIOD_CURRENT,4));
   int previous_4_close= Util_PriceNoDigit(Symbol(),iClose(Symbol(),PERIOD_CURRENT,4));
   int previous_5_open = Util_PriceNoDigit(Symbol(),iOpen(Symbol(),PERIOD_CURRENT,5));
   int previous_5_close= Util_PriceNoDigit(Symbol(),iClose(Symbol(),PERIOD_CURRENT,5));

   if(previous_open<previous_close
      && previous_2_open<previous_2_close
      && previous_3_open<previous_3_close
      && previous_4_open<previous_4_close
      && previous_5_open<previous_5_close
      )
     {
      result="UP";
     }

   if(previous_open>previous_close
      && previous_2_open>previous_2_close
      && previous_3_open>previous_3_close
      && previous_4_open>previous_4_close
      && previous_5_open>previous_5_close
      )
     {
      result="DOWN";
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Get_Average_Space(int shift,int total_bar)
  {
   int total_price=0;
   int result=0;
   int divider=0;
   for(int i=shift; i<(total_bar+shift);i++)
     {
      total_price+=MathAbs(Util_PriceNoDigit(Symbol(),iOpen(Symbol(),PERIOD_CURRENT,i))-Util_PriceNoDigit(Symbol(),iClose(Symbol(),PERIOD_CURRENT,i)));
      divider++;
     }
   if(total_bar>0)
     {
      result=(int)MathRound(total_price/divider);
     }
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSpace(double value1,double value2)
  {
   return MathAbs(Util_PriceNoDigit(Symbol(),value1)-Util_PriceNoDigit(Symbol(),value2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Util_PriceNoDigit(string _symbol,double price)
  {
   string multiple="1";
   int digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   for(int i=0;i<digits; i++)
     {
      multiple+="0";
     }
   return (int)(price*StringToDouble(multiple));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Util_TotalOrders()
  {

   int order_total=0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket=0;
      if((ticket=PositionGetTicket(i))>0)
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL || PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            order_total++;
           }
        }
     }
   return order_total;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Util_CloseAllOrders()
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      ulong ticket=0;
      if((ticket=PositionGetTicket(i))>0)
        {
         Comment(MathRand()+" xxx +"+ticket);
         trade.PositionClose(i);
        }
     }
  }
//+------------------------------------------------------------------+

bool isNewBar()
  {
//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time23=SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time23;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time23)
     {
      //--- memorize the time and return true
      last_time=lastbar_time23;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Util_OpenOrderWithSLTP(string _symbol,int cmd,double lot,double tp,double sl,string comment)
  {
   double price=0;
   if(cmd==OP_BUY) price=MarketInfo(_symbol,MODE_ASK); else price=MarketInfo(_symbol,MODE_BID);
   int iSuccess=-1;
   int count=0;
   double _symbol_Point=MarketInfo(_symbol,MODE_POINT);
   int _symbol_Digits=((int)MarketInfo(_symbol,MODE_DIGITS));
   while(iSuccess<0)
     {
      iSuccess=OrderSend(_symbol,cmd,lot,price,10,sl,tp,comment,0,0,clrGreen);
      if(iSuccess>=0)
        {
         return iSuccess;
        }

      if(count==5)
        {
         return 0;
        }
      count++;
     }
   int fnError=GetLastError();
   if(fnError>0)
     {
      Print("Error function OpenOrder: ",fnError);
      ResetLastError();
     }
   return 0;
  }
//+------------------------------------------------------------------+
