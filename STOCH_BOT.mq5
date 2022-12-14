//+------------------------------------------------------------------+
//|                     STOCH_bot                                    |
//|                     Copyright 2022, Marcin Zubrzycki             |
//|                     Edited, Described & Adjusted, McFat          |
//+------------------------------------------------------------------+

#include<Trade\Trade.mqh>
CTrade trade;

string signal="";
input int laverage=1;       // 1-20x range
input double stoplos=0.016;  // 0.01 = 1% BTC Price change off of the position

input double K_value = 21;  // Stoch 1
input double D_value = 3;   // Stoch 2

input double STOCH_up = 75;  // Default 80
input double STOCH_down = 15;  // Default 20, adjust to the Market conditions (growth/decline)

void OnTick(){

  double ask=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
  double bid=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
  double last=NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_LAST),_Digits);  // Average
  double maxsize=NormalizeDouble((AccountInfoDouble(ACCOUNT_BALANCE))/(0.0001*last*0.05),4); // max position size (25x)

  MqlRates candlesticks_info[];            // OHLC Candles                            
  ArraySetAsSeries(candlesticks_info,true);
  int Data=CopyRates(Symbol(),Period(),0,3,candlesticks_info);
    
  int Stoch = iStochastic(_Symbol,_Period,K_value,D_value,3,MODE_SMA,STO_LOWHIGH); 
    
   double K_period[]; // %K
   double D_period[]; // %D

   ArraySetAsSeries(K_period,true);
   ArraySetAsSeries(D_period,true);
   
   CopyBuffer(Stoch,0,0,3,K_period);
   CopyBuffer(Stoch,1,0,3,D_period);

if((K_period[0]<STOCH_down)&&(D_period[0]<STOCH_down)){if((K_period[0]>D_period[0])&&(K_period[1]<D_period[1])){signal="buy";}}
if((K_period[0]>STOCH_up)&&(D_period[0]>STOCH_up)){if((K_period[0]<D_period[0])&&(K_period[1]>D_period[1])){signal="sell";}}


  if(signal=="buy"){  

   if(last>candlesticks_info[1].close){   
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){  
         trade.PositionClose(PositionGetTicket(0)); 
         trade.OrderDelete(OrderGetTicket(0)); 
        }

   if(PositionsTotal()==0){ 
      trade.Buy(NormalizeDouble((maxsize/20)*laverage,4),NULL,ask,0,0,NULL);
           
}}}

  if(signal=="sell"){
   
   if(last<candlesticks_info[1].close){ 
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
        trade.PositionClose(PositionGetTicket(0));
        trade.OrderDelete(OrderGetTicket(0));
        }

    if(PositionsTotal()==0){
       trade.Sell(NormalizeDouble((maxsize/20)*laverage,4),NULL,bid,0,0,NULL);
}}}



if((PositionsTotal()!=0)&&(OrdersTotal()==0)){

   if(Symbol()==PositionGetSymbol(0)){ 
      
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
        trade.SellStop(PositionGetDouble(POSITION_VOLUME),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)*(1-stoplos),0),_Symbol,0,0,ORDER_TIME_GTC,0,NULL); 
        }
      
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){ 
        trade.BuyStop(PositionGetDouble(POSITION_VOLUME),NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)*(1+stoplos),0),_Symbol,0,0,ORDER_TIME_GTC,0,NULL);
        }
   }}

}


