%%%-------------------------------------------------------------------
%%% @author saich
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jun 2019 7:15 PM
%%%-------------------------------------------------------------------
-module(customer).
-author("saich").
-import(string,[concat/2]).
-import(lists,[append/2]).
-import(lists,[nth/2]).
-import(lists,[delete/2]).
-import(lists,[sublist/2]).
%% API
-export([customer/7]).

readListGiveSingleBankName(BankList,Index)->
  SingleBankList=[nth(Index,BankList)],
  SinglebankMap = maps:from_list(SingleBankList),
  ValueBank=maps:values(SinglebankMap),
  KeyBank=maps:keys(SinglebankMap),
  Str=concat("",KeyBank),
  Key=nth(1,Str).

removeListGivenSingleBank(BankList,Name)->
  BankListMap = maps:from_list(BankList),
  RemovedBankMap=maps:remove(Name,BankListMap),
  RemovedBankList=maps:to_list(RemovedBankMap).

forPID(_,0,_,_,NewFormedList)->
  NewFormedList;

forPID(Start,End,BankPIDList,Avoid,FormedList) when End > 0 ->
  Item=nth(Start,BankPIDList),
  if Start==Avoid->
    NewFormedList=FormedList;
    true->
      NewFormedList=append(FormedList,[Item])
  end,
  forPID(Start+1,End-1,BankPIDList,Avoid,NewFormedList).


removePIDBasedonIndex(BankPIDList,Size,Index)->
  FormedList=[],
  RemovedBankPIDList=[forPID(1,Size,BankPIDList,Index,FormedList)],
  RemovedBankPIDListFormatted = nth(1,RemovedBankPIDList).


customer(BankPIDList,CustomerJill,BankList,OrignialAmount,CustomerName,CurrentThread,Init)->

   if Init==1->
     timer:sleep(100),
     InitChanged=0;
     true->
     InitChanged=0
   end,

  BankListMap = list_to_tuple(BankList),
  BankListSize=tuple_size(BankListMap),
  RandomBankPID=rand:uniform(BankListSize),
  BankNameCurrent=readListGiveSingleBankName(BankList,RandomBankPID),
  RandomMoneyAmount=rand:uniform(50),
  BankPId=nth(RandomBankPID,BankPIDList),
  ValueBank=maps:values(CustomerJill),
  KeyBank=maps:keys(CustomerJill),
  Str=concat("",KeyBank),
  Key=nth(1,Str),

  NumericalValue=nth(1,ValueBank),
  if
    NumericalValue>=RandomMoneyAmount->
      AmountToDeduct=RandomMoneyAmount;
    NumericalValue<RandomMoneyAmount->
      AmountToDeduct=NumericalValue
  end,

  PrintableCustomerName=concat("",CustomerName),
  PrintCustomer=nth(1,PrintableCustomerName),


  CurrentThread!{1,PrintCustomer,AmountToDeduct,BankNameCurrent},
  BankPId !{customer,self(),AmountToDeduct,CustomerName,CurrentThread},
  receive
    {1}->
      ModifiedLoanAmount=NumericalValue-AmountToDeduct,
      List1=[maps:put(Key,ModifiedLoanAmount,CustomerJill)],
      ModifiedCustomerJill=nth(1,List1),

      if
        ModifiedLoanAmount==0->
          PrintableCustomerName=concat("",CustomerName),
          PrintCustomer=nth(1,PrintableCustomerName),
          CurrentThread!{2,PrintCustomer,OrignialAmount};
        true->
          customer(BankPIDList,ModifiedCustomerJill,BankList,OrignialAmount,CustomerName,CurrentThread,InitChanged)
      end;
    {0}->

      RemovedBankList=removeListGivenSingleBank(BankList,BankNameCurrent),
      RemovedBankPIDList=removePIDBasedonIndex(BankPIDList,BankListSize,RandomBankPID),
      PrintableCustomerName=concat("",CustomerName),
      PrintCustomer=nth(1,PrintableCustomerName),
      RemovedBankListMap = list_to_tuple(RemovedBankList),
      RemovedBankListSize=tuple_size(RemovedBankListMap),
      if RemovedBankListSize==0->
        BorrowedAmount=OrignialAmount-NumericalValue,
        PrintableCustomerName=concat("",CustomerName),
        PrintCustomer=nth(1,PrintableCustomerName),
        CurrentThread!{3,PrintCustomer,BorrowedAmount};
        true->
          customer(RemovedBankPIDList,CustomerJill,RemovedBankList,OrignialAmount,CustomerName,CurrentThread,InitChanged)
      end
  end.