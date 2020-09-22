%%%-------------------------------------------------------------------
%%% @author saich
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jun 2019 7:13 PM
%%%-------------------------------------------------------------------
-module(bank).
-author("saich").

%% API
%%-export([]).
%%----------------------------------------------------BANK  Helper ----------------------


-import(string,[concat/2]).
-import(lists,[append/2]).
-import(lists,[nth/2]).
-import(lists,[delete/2]).
-import(lists,[sublist/2]).

%%---------------------------------------------------------------------------------------------
-export([bank/3]).



bank(Bank,CurrentThread,Init)->

  if Init==1->
    timer:sleep(100),
    InitChanged=0;
    true->
      InitChanged=0
  end,
  ValueBank=maps:values(Bank),
  KeyBank=maps:keys(Bank),
  Str=concat("",KeyBank),
  Key=nth(1,Str),
  NumericalValue=nth(1,ValueBank),

  receive
    {customer,CustomerId,AmountToDeduct,CustomerName,CurrentThread}->
      if
        NumericalValue>=AmountToDeduct->
          PrintableCustomerName=concat("",CustomerName),
          PrintCustomer=nth(1,PrintableCustomerName),
          PrintBankName=nth(1,Str),
          CurrentThread! {4,PrintBankName,AmountToDeduct,PrintCustomer},
          Dec=1,
          ModifiedLoanAmount=NumericalValue-AmountToDeduct,
          List1=[maps:put(Key,ModifiedLoanAmount,Bank)],
          Modifiedbank=nth(1,List1),
          CurrentThread!{6,PrintBankName,ModifiedLoanAmount,CustomerName},
          CustomerId ! {Dec},
          bank(Modifiedbank,CurrentThread,InitChanged);
        NumericalValue<AmountToDeduct->
          PrintableCustomerName=concat("",CustomerName),
          PrintCustomer=nth(1,PrintableCustomerName),
          PrintBankName=nth(1,Str),
          CurrentThread!{5,PrintBankName,AmountToDeduct,PrintCustomer},
          CurrentThread!{6,PrintBankName,NumericalValue,PrintCustomer},
          Dec=0,
          CustomerId ! {Dec},
          bank(Bank,CurrentThread,InitChanged);
        true->
         Dec=8

      end


  end.
