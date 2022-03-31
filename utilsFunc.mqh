//+------------------------------------------------------------------+
//|                                                    utilsFunc.mqh |
//|                                           Micael Fernandes, 2022 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Micael Fernandes, 2022"
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

#include  <Trade/Trade.mqh>

CTrade Trade;

double pipSubtrac(string symbol, double price1, double price2){
/* 
   Return the distance between price1 to price2 in pips
*/
   long digits = SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double out = pow(10,digits)*MathAbs(price1 - price2);
   return out/10.f;
}


double getTP(double tpPips, bool isBuy){
   if(isBuy){
      return Ask() + tpPips*10*_Point;
   }else{
      return Bid() - tpPips*10*_Point;
   }
}


double getSL(double slPips, bool isBuy){
   if(isBuy){
      return Ask() - slPips*10*_Point;
   }else{
      return Bid() + slPips*10*_Point;
   }
}

double Bid(){
   return NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
}

double Ask(){
   return NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
}


void TrailingStop(string symbol, ulong magicNum, double price, double trailingStart, double trailingStep){
   for(int i = PositionsTotal()-1; i>=0; i--){
         string sy = PositionGetSymbol(i);
         ulong magic = PositionGetInteger(POSITION_MAGIC);
         if(sy == symbol && magic==magicNum){
               ulong ticket = PositionGetInteger(POSITION_TICKET);
               double StopLossCorrente = PositionGetDouble(POSITION_SL);
               double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
               if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                     if(price >= (StopLossCorrente + trailingStart) ){
                           double newSL = NormalizeDouble(StopLossCorrente + trailingStep, _Digits);
                           Trade.PositionModify(ticket, newSL, TakeProfitCorrente);
                        }
                  }
               else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                     if(price <= (StopLossCorrente - trailingStart) ){
                           double newSL = NormalizeDouble(StopLossCorrente - trailingStep, _Digits);
                           Trade.PositionModify(ticket, newSL, TakeProfitCorrente);
                        }
                  }
            }
      }
}

void BreakEven(string symbol, ulong magicNum, double price, double be){
      for(int i = PositionsTotal()-1; i>=0; i--){
            string sy = PositionGetSymbol(i);
            ulong magic = PositionGetInteger(POSITION_MAGIC);
            if(sy == symbol && magic == magicNum){
                  ulong ticket = PositionGetInteger(POSITION_TICKET);
                  double posOpen = PositionGetDouble(POSITION_PRICE_OPEN);
                  double TakeProfitCorrente = PositionGetDouble(POSITION_TP);
                  if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                        if( price >= posOpen + be ){
                              Trade.PositionModify(ticket, posOpen, TakeProfitCorrente);
                           }                           
                     }
                  else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                        if( price <= posOpen - be){
                              Trade.PositionModify(ticket, posOpen, TakeProfitCorrente);
                           }
                     }
               }
         }
   }