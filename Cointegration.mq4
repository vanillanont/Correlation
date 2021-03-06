//+------------------------------------------------------------------+
//|                                                Cointegration.mq4 |
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

extern string SYMBOL_MAIN = "GBPAUD";  
extern string SYMBOL_HEDGE = "GBPCHF"; 

double TAKE_PROFIT = 1; 
extern int TOTAL_PAIR_ALLOW = 2;

extern string OD1 = ""; // Order 01 ///////////////////
extern int NEXTOPEN_ORDER_0 = 0;
double LOT_ORDER_0 = 0.01;
extern double LOT_ORDER_MULTIPLY_0 = 1;
double TP_ORDER_0 = 0;
extern int TP_ORDER_MULTIPLY_0 = 0;

extern string OD2 = ""; // Order 02 ///////////////////
extern int NEXTOPEN_ORDER_1 = 1000;
double LOT_ORDER_1 = 0.01;
extern double LOT_ORDER_MULTIPLY_1 = 1;
double TP_ORDER_1 = 1;
extern int TP_ORDER_MULTIPLY_1 = 1;

extern string OD3 = ""; // Order 03 ///////////////////
extern int NEXTOPEN_ORDER_2 = 1000;
double LOT_ORDER_2 = 0.01;
extern double LOT_ORDER_MULTIPLY_2 = 1;
double TP_ORDER_2 = 0;
extern int TP_ORDER_MULTIPLY_2 = 0;

extern string OD4 = ""; // Order 04 ///////////////////
extern int NEXTOPEN_ORDER_3 = 1000;
double LOT_ORDER_3 = 0.01;
extern double LOT_ORDER_MULTIPLY_3 = 1;
double TP_ORDER_3 = 1;
extern int TP_ORDER_MULTIPLY_3 = 1;

extern string OD5 = ""; // Order 05 ///////////////////
extern int NEXTOPEN_ORDER_4 = 1000;
double LOT_ORDER_4 = 0.02;
extern double LOT_ORDER_MULTIPLY_4 = 2;
double TP_ORDER_4 = 0;
extern int TP_ORDER_MULTIPLY_4 = 0;

extern string OD6 = ""; // Order 06 ///////////////////
extern int NEXTOPEN_ORDER_5 = 1000;
double LOT_ORDER_5 = 0.01;
extern double LOT_ORDER_MULTIPLY_5 = 1;
double TP_ORDER_5 = 1;
extern int TP_ORDER_MULTIPLY_5 = 1;

extern string OD7 = ""; // Order 07 ///////////////////
extern int NEXTOPEN_ORDER_6 = 1000;
double LOT_ORDER_6 = 0.01;
extern double LOT_ORDER_MULTIPLY_6 = 1;
double TP_ORDER_6 = 0;  
extern int TP_ORDER_MULTIPLY_6 = 0;

extern string OD8 = ""; // Order 08 ///////////////////
extern int NEXTOPEN_ORDER_7 = 1000;
double LOT_ORDER_7 = 0.01;
extern double LOT_ORDER_MULTIPLY_7 = 1;
double TP_ORDER_7 = 0;
extern int TP_ORDER_MULTIPLY_7 = 0;

extern string OD9 = ""; // Order 09 ///////////////////
extern int NEXTOPEN_ORDER_8 = 1000;
double LOT_ORDER_8 = 0.01;
extern double LOT_ORDER_MULTIPLY_8 = 1;
double TP_ORDER_8 = 0;
extern int TP_ORDER_MULTIPLY_8 = 0;

extern string OD10 = ""; // Order 10 ///////////////////
extern int NEXTOPEN_ORDER_9 = 1000;
double LOT_ORDER_9 = 0.01; 
extern double LOT_ORDER_MULTIPLY_9 = 1;
double TP_ORDER_9 = 0; 
extern int TP_ORDER_MULTIPLY_9 = 0;

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

int arr_NEXTOPEN_ORDER[10];
int current_zone = 0;
bool clear_order = false;
double TOTAL_TAKE_PROFIT = 0;
bool hasFocusedOrder = false;
double lot_size = 0; 
double tp_size = 0; 
extern double reduce_risk = 1;
 
int OnInit()
  {
  
   StringToUpper(SYMBOL_MAIN);
   StringToUpper(SYMBOL_HEDGE); 
   setup_money_management();
   
   if(iOpen(SYMBOL_MAIN,PERIOD_M1,0) > iOpen(SYMBOL_HEDGE,PERIOD_M1,0)){
      SYMBOL_MAIN_SEND = OP_SELL;
      SYMBOL_HEDGE_SEND = OP_BUY;
   }else{
      SYMBOL_MAIN_SEND = OP_BUY;
      SYMBOL_HEDGE_SEND = OP_SELL;
   }
   
   
   CONFORT_ZONE = PairSeparateTest(365,PERIOD_D1); 
   rebind_ticket();
   
   arr_NEXTOPEN_ORDER[0] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0);
   arr_NEXTOPEN_ORDER[1] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1);
   arr_NEXTOPEN_ORDER[2] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1 + 
                            NEXTOPEN_ORDER_2);
   arr_NEXTOPEN_ORDER[3] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1 + 
                            NEXTOPEN_ORDER_2 + 
                            NEXTOPEN_ORDER_3);
   arr_NEXTOPEN_ORDER[4] = (CONFORT_ZONE + 
                            NEXTOPEN_ORDER_0 + 
                            NEXTOPEN_ORDER_1 + 
                            NEXTOPEN_ORDER_2 + 
                            NEXTOPEN_ORDER_3 + 
                            NEXTOPEN_ORDER_4);
   arr_NEXTOPEN_ORDER[5] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5);
   arr_NEXTOPEN_ORDER[6] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6);
   arr_NEXTOPEN_ORDER[7] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6 + 
                           NEXTOPEN_ORDER_7);
   arr_NEXTOPEN_ORDER[8] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6 + 
                           NEXTOPEN_ORDER_7 + 
                           NEXTOPEN_ORDER_8);
   arr_NEXTOPEN_ORDER[9] = (CONFORT_ZONE + 
                           NEXTOPEN_ORDER_0 + 
                           NEXTOPEN_ORDER_1 + 
                           NEXTOPEN_ORDER_2 + 
                           NEXTOPEN_ORDER_3 + 
                           NEXTOPEN_ORDER_4 + 
                           NEXTOPEN_ORDER_5 + 
                           NEXTOPEN_ORDER_6 + 
                           NEXTOPEN_ORDER_7 + 
                           NEXTOPEN_ORDER_8 + 
                           NEXTOPEN_ORDER_9);
                           
   
   
   
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
	TOTAL_TAKE_PROFIT += TAKE_PROFIT;
	if(IS_OPEN_0 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_0;
	}
	if(IS_OPEN_1 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_1;
	}
	if(IS_OPEN_2 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_2;
	}
	if(IS_OPEN_3 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_3;
	}
	if(IS_OPEN_4 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_4;
	}
	if(IS_OPEN_5 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_5;
	}
	if(IS_OPEN_6 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_6;
	}
	if(IS_OPEN_7 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_7;
	}
	if(IS_OPEN_8 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_8;
	}
	if(IS_OPEN_9 == true){
		 TOTAL_TAKE_PROFIT += TP_ORDER_9;
	} 

   int SYMBOL_MAIN_TICKET = 0;
   int SYMBOL_HEDGE_TICKET = 0; 
   current_zone = PairSeparateTest(1,PERIOD_M1);
   //CONFORT_ZONE = 20000;
   //current_zone = 22659+3003; 
   string comment = "Comfort : "+ IntegerToString(CONFORT_ZONE)+" // Current : "+IntegerToString(current_zone)+" // 0:"+IS_OPEN_0+" 1:"+IS_OPEN_1+" 2:"+IS_OPEN_2+" 3:"+IS_OPEN_3+" 4:"+IS_OPEN_4+" 5:"+IS_OPEN_5+" 6:"+IS_OPEN_6+" 7:"+IS_OPEN_7+" 8:"+IS_OPEN_8+" 9:"+IS_OPEN_9+" Clear_order:"+clear_order; 
   Comment(comment);
   //return; 
         bool isAllowNewPair = AllowNewPair();
   
         if(current_zone > arr_NEXTOPEN_ORDER[0] && current_zone < arr_NEXTOPEN_ORDER[1] && isAllowNewPair){
            if(!IS_OPEN_0 && !IS_OPEN_1 && 
               !IS_OPEN_2 && !IS_OPEN_3 && 
               !IS_OPEN_4 && !IS_OPEN_5 && 
               !IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9){
              //BEGIN FIRST ORDER 
               //if(!isOpenedOrder(SYMBOL_MAIN_TICKET,0))  SYMBOL_MAIN_TICKET = openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
               //if(!isOpenedOrder(SYMBOL_HEDGE_TICKET,0)) SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
               SYMBOL_MAIN_TICKET = openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_0 = true;
               }
            } 
         }
         
         
         if(current_zone > arr_NEXTOPEN_ORDER[1]  && current_zone < arr_NEXTOPEN_ORDER[2] &&  AllowNewPair()){
         
            if( IS_OPEN_0 && !IS_OPEN_1 && 
               !IS_OPEN_2 && !IS_OPEN_3 && 
               !IS_OPEN_4 && !IS_OPEN_5 && 
               !IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){ 
                  //NEXT ORDER
                  SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_1,1,99999999);
                  SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_1,1,99999999);
                   if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                     IS_OPEN_1 = true;
                  }
            } 
            
            if(!IS_OPEN_0 && !IS_OPEN_1 && !IS_OPEN_2){
                  //NEXT ORDER
                SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_1,1,CONFORT_ZONE);
                SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_1,1,CONFORT_ZONE);
                if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_1 = true;
               }
            } 
         } 
         
         
         if(current_zone > arr_NEXTOPEN_ORDER[2]  && current_zone < arr_NEXTOPEN_ORDER[3] && isAllowNewPair){ 
            if( IS_OPEN_1 && 
               !IS_OPEN_2 && !IS_OPEN_3 && 
               !IS_OPEN_4 && !IS_OPEN_5 && 
               !IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){  
               //NEXT ORDER
                SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_2,2,99999999);
                SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_2,2,99999999); 
                if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_2 = true;
                }
            }
            
            if(!IS_OPEN_1 && !IS_OPEN_2 && !IS_OPEN_3){
                //NEXT ORDER
                SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_2,2,CONFORT_ZONE);
                SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_2,2,CONFORT_ZONE); 
                if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_2 = true;
                }
            } 
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[3] && current_zone < arr_NEXTOPEN_ORDER[4] && isAllowNewPair){
         
         
            if( IS_OPEN_2 && !IS_OPEN_3 && 
               !IS_OPEN_4 && !IS_OPEN_5 && 
               !IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){  
               //NEXT ORDER
                SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_3,3,99999999);
                SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_3,3,99999999);
                if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_3 = true;
                }
            }
            
            if(!IS_OPEN_2 && !IS_OPEN_3 && !IS_OPEN_4){
               //NEXT ORDER
                SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_3,3,CONFORT_ZONE);
                SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_3,3,CONFORT_ZONE);
                if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_3 = true;
                }
            }
             
                        
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[4]  && current_zone < arr_NEXTOPEN_ORDER[5] && isAllowNewPair){
         
            if( IS_OPEN_3 && 
               !IS_OPEN_4 && !IS_OPEN_5 && 
               !IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){    
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_4,4,99999999);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_4,4,99999999);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_4 = true;
               } 
            }
              
            if(!IS_OPEN_3 && !IS_OPEN_4 && !IS_OPEN_5){    
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_4,4,CONFORT_ZONE);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_4,4,CONFORT_ZONE);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_4 = true;
               } 
            }          
         }
          
         if(current_zone > arr_NEXTOPEN_ORDER[5] && current_zone < arr_NEXTOPEN_ORDER[6] && isAllowNewPair){
            
            if( IS_OPEN_4 && !IS_OPEN_5 && 
               !IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){    
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_5,5,99999999);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_5,5,99999999);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_5 = true;
               }
            }
             
            if(!IS_OPEN_4 && !IS_OPEN_5 && !IS_OPEN_6){    
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_5,5,CONFORT_ZONE);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_5,5,CONFORT_ZONE);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_5 = true;
               }
            }    
         }
          
         if(current_zone > arr_NEXTOPEN_ORDER[6] && current_zone < arr_NEXTOPEN_ORDER[7] && isAllowNewPair){
          
            if( IS_OPEN_5 && 
               !IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){  
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_6,6,99999999);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_6,6,99999999);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_6 = true;
                }
            }
             
            if(!IS_OPEN_5 && !IS_OPEN_6 && !IS_OPEN_7){
              //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_6,6,CONFORT_ZONE);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_6,6,CONFORT_ZONE);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_6 = true;
                }
            }
         
         }
          
         if(current_zone > arr_NEXTOPEN_ORDER[7]  && current_zone < arr_NEXTOPEN_ORDER[8] && isAllowNewPair){
         
            if( IS_OPEN_6 && !IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){  
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_7,7,99999999);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_7,7,99999999);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_7 = true;
                }
            }
            
            if(!IS_OPEN_6 && !IS_OPEN_7 && !IS_OPEN_8){
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_7,7,CONFORT_ZONE);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_7,7,CONFORT_ZONE);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_7 = true;
                }
            }
        
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[8]  && current_zone < arr_NEXTOPEN_ORDER[9] && isAllowNewPair){
          
            if( IS_OPEN_7 && 
               !IS_OPEN_8 && !IS_OPEN_9 ){  
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_8,8,99999999);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_8,8,99999999);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_8 = true;
                }
            }
            
            if(!IS_OPEN_7 && !IS_OPEN_8 && !IS_OPEN_9){  
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_8,8,CONFORT_ZONE);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_8,8,CONFORT_ZONE);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_8 = true;
                }
            }          
         }
         
         if(current_zone > arr_NEXTOPEN_ORDER[9] && isAllowNewPair){
         
            if(IS_OPEN_8 && !IS_OPEN_9 ){  
               //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_9,9,99999999);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_9,9,99999999);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_9 = true;
                }
            }
            
            if(!IS_OPEN_8 && !IS_OPEN_9){
             //NEXT ORDER
               SYMBOL_MAIN_TICKET =  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_9,9,CONFORT_ZONE);
               SYMBOL_HEDGE_TICKET = openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_9,9,CONFORT_ZONE);
               if(SYMBOL_MAIN_TICKET > 0 && SYMBOL_HEDGE_TICKET > 0){ 
                  IS_OPEN_9 = true;
               }
            }
            
        
         }
      
    
   SYMBOL_MAIN_TICKET = 0;
   SYMBOL_HEDGE_TICKET = 0;
   
   completeOrders();  
}
//+------------------------------------------------------------------+

void completeOrders(){ 
  double profit = 0;
  bool opening_order = false;
  
   //////////////// recheck open order ///////////////
   int order_0 = 0;
   int order_1 = 0;
   int order_2 = 0;
   int order_3 = 0;
   int order_4 = 0;
   int order_5 = 0;
   int order_6 = 0;
   int order_7 = 0;
   int order_8 = 0;
   int order_9 = 0;
   
   string order_symbol_0 = "";
   string order_symbol_1 = "";
   string order_symbol_2 = "";
   string order_symbol_3 = "";
   string order_symbol_4 = "";
   string order_symbol_5 = "";
   string order_symbol_6 = "";
   string order_symbol_7 = "";
   string order_symbol_8 = "";
   string order_symbol_9 = "";
   //////////////// recheck open order ///////////////
  int isClear = 0;
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
      if (OrderSelect(i, SELECT_BY_POS) == true)
      {
         if(isFocusedOrder()){
            if(clear_order == true){
               closeOrder(OrderTicket());
               if(isFocusedOrder()){
                  opening_order = true;
               } 
               
               if(opening_order == true){
                   clear_order = true;
               }else{
                  IS_OPEN_0 = false;
                  IS_OPEN_1 = false;
                  IS_OPEN_2 = false;
                  IS_OPEN_3 = false;
                  IS_OPEN_4 = false;
                  IS_OPEN_5 = false;
                  IS_OPEN_6 = false;
                  IS_OPEN_7 = false;
                  IS_OPEN_8 = false;
                  IS_OPEN_9 = false; 
                  clear_order = false;
               }  
            }else{
               profit += (OrderProfit() + OrderSwap() + OrderCommission());  
             
               if(StringFind(OrderComment(),"_0_",0) >= 0){
                    order_symbol_0 = OrderSymbol();
                    order_0++;
               }
               if(StringFind(OrderComment(),"_1_",0) >= 0){
                    order_symbol_1 = OrderSymbol();
                    order_1++;
               }
               if(StringFind(OrderComment(),"_2_",0) >= 0){
                    order_symbol_2 = OrderSymbol();
                    order_2++;
               }
               if(StringFind(OrderComment(),"_3_",0) >= 0){
                    order_symbol_3 = OrderSymbol();
                    order_3++;
               }
               if(StringFind(OrderComment(),"_4_",0) >= 0){
                    order_symbol_4 = OrderSymbol();
                    order_4++;
               }
               if(StringFind(OrderComment(),"_5_",0) >= 0){
                    order_symbol_5 = OrderSymbol();
                    order_5++;
               }
               if(StringFind(OrderComment(),"_6_",0) >= 0){
                    order_symbol_6 = OrderSymbol();
                    order_6++;
               }
               if(StringFind(OrderComment(),"_7_",0) >= 0){
                    order_symbol_7 = OrderSymbol();
                    order_7++;
               }
               if(StringFind(OrderComment(),"_8_",0) >= 0){
                    order_symbol_8 = OrderSymbol();
                    order_8++;
               }
               if(StringFind(OrderComment(),"_9_",0) >= 0){
                    order_symbol_9 = OrderSymbol();
                    order_9++;
               } 
            }  
            isClear++;
            hasFocusedOrder = true;
         }else{
            hasFocusedOrder = false;
         }
      }
  } 
  
  if(clear_order == true){
   if(isClear >= 0){
      IS_OPEN_0 = false;
      IS_OPEN_1 = false;
      IS_OPEN_2 = false;
      IS_OPEN_3 = false;
      IS_OPEN_4 = false;
      IS_OPEN_5 = false;
      IS_OPEN_6 = false;
      IS_OPEN_7 = false;
      IS_OPEN_8 = false;
      IS_OPEN_9 = false; 
      clear_order = false;
   }
  }
   
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
   if(clear_order == false){ 
        if(order_0 == 1){
       // Alert("x");
            if(order_symbol_0 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_0,0,CONFORT_ZONE);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_0,0,CONFORT_ZONE); 
            }
            IS_OPEN_0 = true;
        }
        
        if(order_1 == 1){
            if(order_symbol_1 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_1,1,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_1,1,99999999); 
            }
            IS_OPEN_1 = true;
        }
        
        if(order_2 == 1){
            if(order_symbol_2 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_2,2,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_2,2,99999999); 
            }
            IS_OPEN_2 = true;
        }
        
        if(order_3 == 1){
            if(order_symbol_3 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_3,3,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_3,3,99999999); 
            }
            IS_OPEN_3 = true;
        }
        
        if(order_4 == 1){
            if(order_symbol_4 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_4,4,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_4,4,99999999); 
            }
            IS_OPEN_4 = true;
        }
        
        if(order_5 == 1){
            if(order_symbol_5 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_5,5,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_5,5,99999999); 
            }
            IS_OPEN_5 = true;
        }
        
        if(order_6 == 1){
            if(order_symbol_6 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_6,6,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_6,6,99999999); 
            }
            IS_OPEN_6 = true;
        }
        if(order_7 == 1){
            if(order_symbol_7 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_7,7,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_7,7,99999999); 
            }
            IS_OPEN_7 = true;
        }
        if(order_8 == 1){
            if(order_symbol_8 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_8,8,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_8,8,99999999); 
            }
            IS_OPEN_8 = true;
        }
        if(order_9 == 1){
            if(order_symbol_9 == SYMBOL_MAIN){
                  openOrder(SYMBOL_HEDGE,SYMBOL_HEDGE_SEND,LOT_ORDER_9,9,99999999);
            }else{
                  openOrder(SYMBOL_MAIN,SYMBOL_MAIN_SEND,LOT_ORDER_9,9,99999999); 
            }
            IS_OPEN_9 = true;
        }
   }
   //////////////// recheck open order ///////////////
   //////////////// recheck open order ///////////////
  
     if(clear_order == false){
        if(profit > TAKE_PROFIT){
           clear_order = true;
           for (int i = 0; i <= (OrdersTotal() - 1); i++)
           {
               if (OrderSelect(i, SELECT_BY_POS) == true)
               {
                  if(isFocusedOrder()){
                     closeOrder(OrderTicket());
                  }
               }
           }  
           CONFORT_ZONE = PairSeparateTest(365,PERIOD_D1); 
        } 
     }
}


bool isFocusedOrder(){
   //OrderSelect needed before call this function
   if(StringFind(OrderComment(),SYMBOL_MAIN,0) >= 0 && StringFind(OrderComment(),SYMBOL_HEDGE,0) >= 0){
      return true;
   }else{
      return false;
   }
}

 

 bool isNotFocusedOrder(){
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
 

int openOrder(string _symbol, int cmd, double lot, int group_id,int begin_order)
{

    //return order ticket
    double price = 0;
    if (cmd == OP_BUY) price = MarketInfo(_symbol, MODE_ASK); else price = MarketInfo(_symbol, MODE_BID);
    int iSuccess = -1;
    int count = 0;

    while (iSuccess < 0)
    {  
        iSuccess = OrderSend(_symbol, cmd, lot, price, 3, 0.0, 0.0, SYMBOL_MAIN+"_"+SYMBOL_HEDGE+"_"+IntegerToString(group_id)+"_"+IntegerToString(begin_order)+"_", group_id, 0, clrGreen); 
        
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



void rebind_ticket()
{ 
     for (int i = 0; i <= (OrdersTotal() - 1); i++)
     {
         if (OrderSelect(i, SELECT_BY_POS) == true)
         { 
            if(isFocusedOrder()){
               int ticket = OrderTicket();
               int magic_number = OrderMagicNumber();
               if(magic_number == 0){
               
                  // change comfort zone to first open order /////////
                  string result[];
                  StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                  CONFORT_ZONE = (int)result[3];
                   ///////// ///////// ///////// ///////// /////////
                   
                  IS_OPEN_0 = true;
               }
               if(magic_number == 1){ 
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                  IS_OPEN_1 = true;
               }
               if(magic_number == 2){
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                  IS_OPEN_2 = true;
               }
               if(magic_number == 3){
               
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                    
                  IS_OPEN_3 = true;
               }
               if(magic_number == 4){
               
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                    
                  IS_OPEN_4 = true;
               }
               if(magic_number == 5){
               
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                    
                  IS_OPEN_5 = true;
               }
               if(magic_number == 6){
               
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                    
                  IS_OPEN_6 = true;
               }
               if(magic_number == 7){
               
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                    
                  IS_OPEN_7 = true;
               }
               if(magic_number == 8){
               
                    if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                    } 
                    
                  IS_OPEN_8 = true;
               }
               if(magic_number == 9){
               
                  if(StringFind(OrderComment(),"_99999999_") != -1){
                        // change comfort zone to first open order /////////
                        string result[];
                        StringSplit(OrderComment(),StringGetCharacter("_",0),result);
                        CONFORT_ZONE = (int)result[3];
                         ///////// ///////// ///////// ///////// /////////
                  } 
                  IS_OPEN_9 = true;
               } 
            }
         }
     }
}

bool isOpenedOrder(int ticket_number,int group_id){
   bool opened = false;
  for (int i = 0; i <= (OrdersTotal() - 1); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) == true)
    { 
      if(isFocusedOrder()){ 
         if(StringFind(OrderComment(),IntegerToString(ticket_number),0) >= 0 && StringFind(OrderComment(),"_"+IntegerToString(group_id)+"_",0) >= 0){
           opened = true; 
           break;
         }
      }
    }
  }
  return opened;
}

 

int PairSeparateTest(int candle_number,int period){ 
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
 


    bool AllowNewPair()
    {
        string arr[];
        int count = 0;
        bool hasArrFocus = false;
        for (int i = 0; i <= (OrdersTotal() - 1); i++)
        {
            if (OrderSelect(i, SELECT_BY_POS) == true)
            {
                if (isNotFocusedOrder()) { 
                    bool hasArr = false;
                    for(int j=0;j<ArraySize(arr);j++)
                    { 
                        if(StringFind(arr[j],StringSubstr(OrderComment(),0,13)) != -1)
                        {
                            hasArr = true;
                            break;
                        }
                    }
                    
                    if (hasArr == false) {
                        ArrayResize(arr, (ArraySize(arr) + 1));
                        arr[(ArraySize(arr) - 1)] = StringSubstr(OrderComment(), 0, 13);  
                    }
                }
                
                if(isFocusedOrder() && !hasArrFocus){
                     ArrayResize(arr, (ArraySize(arr) + 1));
                     arr[(ArraySize(arr) - 1)] = StringSubstr(OrderComment(), 0, 13);  
                     hasArrFocus = true;
                }
            }
        }
        count = ArraySize(arr); // FOR CURRENT FOCUSED PAIR
        if (TOTAL_PAIR_ALLOW > count)
        {
            return true;
        }
        else {
            return false;
        }
    }
    
    
    
    

void setup_money_management()
{   
    lot_size = (AccountBalance() * 0.0001) / reduce_risk;
    if (lot_size < 0.01)
    {
        lot_size = 0.01;
    }    
    tp_size = lot_size * 100;
    
    LOT_ORDER_0 = lot_size * LOT_ORDER_MULTIPLY_0;
    LOT_ORDER_1 = lot_size * LOT_ORDER_MULTIPLY_1;
    LOT_ORDER_2 = lot_size * LOT_ORDER_MULTIPLY_2;
    LOT_ORDER_3 = lot_size * LOT_ORDER_MULTIPLY_3;
    LOT_ORDER_4 = lot_size * LOT_ORDER_MULTIPLY_4;
    LOT_ORDER_5 = lot_size * LOT_ORDER_MULTIPLY_5;
    LOT_ORDER_6 = lot_size * LOT_ORDER_MULTIPLY_6;
    LOT_ORDER_7 = lot_size * LOT_ORDER_MULTIPLY_7;
    LOT_ORDER_8 = lot_size * LOT_ORDER_MULTIPLY_8;
    LOT_ORDER_9 = lot_size * LOT_ORDER_MULTIPLY_9;
    
    TP_ORDER_0 = tp_size * TP_ORDER_MULTIPLY_0;
    TP_ORDER_1 = tp_size * TP_ORDER_MULTIPLY_1;
    TP_ORDER_2 = tp_size * TP_ORDER_MULTIPLY_2;
    TP_ORDER_3 = tp_size * TP_ORDER_MULTIPLY_3;
    TP_ORDER_4 = tp_size * TP_ORDER_MULTIPLY_4;
    TP_ORDER_5 = tp_size * TP_ORDER_MULTIPLY_5;
    TP_ORDER_6 = tp_size * TP_ORDER_MULTIPLY_6;
    TP_ORDER_7 = tp_size * TP_ORDER_MULTIPLY_7;
    TP_ORDER_8 = tp_size * TP_ORDER_MULTIPLY_8;
    TP_ORDER_9 = tp_size * TP_ORDER_MULTIPLY_9;
    
    TAKE_PROFIT = tp_size;
      
}

 