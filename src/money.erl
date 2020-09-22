%%%-------------------------------------------------------------------
%%% @author saich
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Jun 2019 6:41 PM
%%%-------------------------------------------------------------------
-module(money).
-author("saich").

-import(string,[concat/2]).
-import(lists,[append/2]).
-import(lists,[nth/2]).
-import(lists,[delete/2]).
-import(lists,[sublist/2]).
-import(string,[sub_string/3]).
-import(bank,[bank/3]).
-import(customer,[customer/7]).

%% API
-export([start/0]).


%%-----------------------------------------------BANK-------------------------------------------------
%% 1.Bank Text File to LIST
readFileGenerateBankList()->
  Txtofbanks = file:consult("banks.txt"),
  BankList = element(2,Txtofbanks).


%% 1(A)Get Single Bank
readListGiveSingleBank(BankList,Index)->
  SingleBankList=[nth(Index,BankList)],
  SinglebankMap = maps:from_list(SingleBankList).

%% 1(B)For Internal of Bank
for(_,0,BankListPIDAdded,BankListDetails,PrintThread)->
  BankListPIDAdded;

for(Start,End,BankPIDList,BankListDetails,PrintThread) when End > 0 ->
  BankPID=spawn(fun() ->
    Bank=readListGiveSingleBank(BankListDetails,Start),
    CurrentThread=PrintThread,
    bank(Bank,CurrentThread,1)
                end),
  BankListPIDAdded=append(BankPIDList,[BankPID]),
  for(Start+1,End-1,BankListPIDAdded,BankListDetails,PrintThread).





%% 2.Get Process ID's For  Banks
getbankProcessIds(BankList,BankListDetails,PrintThread)->
  BankMap = list_to_tuple(BankList),
  BankSize=tuple_size(BankMap),
  BankListData=[],
  BankPIDList=[for(1,BankSize,BankListData,BankListDetails,PrintThread)],
  ActualBankPIds=nth(1,BankPIDList).


%%--------------------------------------Customer----------------------------------------------------------




%%----------------------------------------------------CUSTOMER Helper ----------------------
getOriginalAmountForCustomer(Customer)->
  ValueBank=maps:values(Customer),
  KeyBank=maps:keys(Customer),
  Str=concat("",KeyBank),
  Key=nth(1,Str),
  NumericalValue=nth(1,ValueBank).

getCustomerNameForCustomer(Customer)->
  ValueBank=maps:values(Customer),
  KeyBank=maps:keys(Customer),
  Str=concat("",KeyBank).




%%---------------------------------------------------------------------------------------------

%% 1.Customer Text File to LIST
readFileGenerateCustomerList()->
  TxtofCustomers = file:consult("customers.txt"),
  CustomerList = element(2,TxtofCustomers).


%% 1(A)Get Single Customer
readListGiveSingleCustomer(CustomerListData,Index)->
  SingleCustomerList=[nth(Index,CustomerListData)],
  SinglebankMap = maps:from_list(SingleCustomerList).



%% 1(B)For Internal of Customer
forCustomer(_,0,CustomerListPIDAdded,CustomerListDetails,BankPIDList,BankList,PrintThread)->
  CustomerListPIDAdded;

forCustomer(Start,End,CustomerListData,CustomerListDetails,BankPIDList,BankList,PrintThread) when End > 0 ->

  CustomerPID=spawn(fun() ->
    Customer=readListGiveSingleCustomer(CustomerListDetails,Start),
    OriginalAmount=getOriginalAmountForCustomer(Customer),
    CustomerName=getCustomerNameForCustomer(Customer),
    CurrentThread=PrintThread,
    customer(BankPIDList,Customer,BankList,OriginalAmount,CustomerName,CurrentThread,1)
                    end),
  CustomerListPIDAdded=append(CustomerListData,[CustomerPID]),
  forCustomer(Start+1,End-1,CustomerListPIDAdded,CustomerListDetails,BankPIDList,BankList,PrintThread).

%% 2.Get Process ID's For  Customer
getCustomerProcessIds(BankPIDList,BankList,CustomerList,CustomerListDetails,PrintThread)->

  CustomerMap = list_to_tuple(CustomerList),
  CustomerSize=tuple_size(CustomerMap),
  CustomerListData=[],
  CustomerPIDList=[forCustomer(1,CustomerSize,CustomerListData,CustomerListDetails,BankPIDList,BankList,PrintThread)].


%%---------------------------------------------------------BANK DETAILS---------------------------------------------------------

forBankDetails(_,0,Input)->
  Input;

forBankDetails(Start,End,Input) when End > 0 ->
  InputKeyValuePair=nth(Start,Input),
  InputInsideList=tuple_to_list(InputKeyValuePair),
  BankName=nth(1,InputInsideList),
  AmountLeft=nth(2,InputInsideList),
  io:fwrite("~w has  ~w dollar(s) Remaining~n",[BankName,AmountLeft]),
  forBankDetails(Start+1,End-1,Input).

convertTheListToBankSentence(Input)->
  InputTuple=list_to_tuple(Input),
  Size=tuple_size(InputTuple),
  Len=[Size*2],
  SSSS=[forBankDetails(1,Size,Input)].
%%---------------------------------------------------------CUSTOMER GOT IT ---------------------------------------------------------

forSucess(_,0,Input)->
  Input;

forSucess(Start,End,Input) when End > 0 ->
  FirstValue=[nth(Start,Input)],
  CustomerName=concat("",FirstValue),
  SecondPosition=Start+1,
  SecondValue=[nth(SecondPosition,Input)],
  io:fwrite("~p has reached the objective ",CustomerName),
  io:fwrite("of ~p dollar(s). Woo Hoo!~n",SecondValue),
  forSucess(Start+2,End-2,Input).

convertTheListToSucessSentence(Input)->
  InputTuple=list_to_tuple(Input),
  Size=tuple_size(InputTuple),
  SentenceList=[forSucess(1,Size,Input)].

%%----------------------------------------------------------CUSTOMER only Able--------------------------------------------------------------------------------------

forFailure(_,0,Input)->
  Input;

forFailure(Start,End,Input) when End > 0 ->
  FirstValue=[nth(Start,Input)],
  CustomerName=concat("",FirstValue),
  SecondPosition=Start+1,
  SecondValue=[nth(SecondPosition,Input)],
  io:fwrite("~p was only able to borrow ",CustomerName),
  io:fwrite("of ~p dollar(s). Boo Hoo!~n",SecondValue),
  forFailure(Start+2,End-2,Input).

convertTheListToFailureSentence(Input)->
  InputTuple=list_to_tuple(Input),
  Size=tuple_size(InputTuple),
  SentenceList=[forFailure(1,Size,Input)].




%%------------------------------------------BANK AND CUSTOMER---------------------------------------------






forBankToOpen(_,0,Input)->
  Input;

forBankToOpen(Start,End,Input) when End > 0 ->
  SingleMap= readListGiveSingleBank(Input,Start),
  ValueBank=maps:values(SingleMap),
  KeyBank=maps:keys(SingleMap),
  io:fwrite("~n~p: ",KeyBank),
  io:fwrite("~p",ValueBank),
  forBankToOpen(Start+1,End-1,Input).


printOpeningLinesFromBankList(BankList)->
io:fwrite("** Banks and financial resources **"),
  BankTuple=list_to_tuple(BankList),
  BankSize=tuple_size(BankTuple),
  Ou=[forBankToOpen(1,BankSize,BankList)],
  io:fwrite("~n").





forCustomerToOpen(_,0,Input)->
  Input;

forCustomerToOpen(Start,End,Input) when End > 0 ->
  SingleMap= readListGiveSingleBank(Input,Start),
  ValueBank=maps:values(SingleMap),
  KeyBank=maps:keys(SingleMap),
  io:fwrite("~n~p: ",KeyBank),
  io:fwrite("~p",ValueBank),
  forCustomerToOpen(Start+1,End-1,Input).


printOpeningLinesFromCustomerList(CustomerList)->
  io:fwrite("** Customers and loan objectives **"),
  CustomerTuple=list_to_tuple(CustomerList),
  CustomerSize=tuple_size(CustomerTuple),
  Ou=[forCustomerToOpen(1,CustomerSize,CustomerList)],
  io:fwrite("~n").



%%------------------------------------------------------------------------------------------------------------------------------------
start() ->

  BankListOriginal= readFileGenerateBankList(),

  BankListMap = maps:from_list(BankListOriginal),

  BankList=maps:to_list(BankListMap),
  printOpeningLinesFromBankList(BankList),
  io:fwrite("~n"),

  CustomerList=readFileGenerateCustomerList(),
  printOpeningLinesFromCustomerList(CustomerList),
  io:fwrite("~n"),
  io:fwrite("~n"),

  TupleCustomer=list_to_tuple(CustomerList),
  CustomerSize=tuple_size(TupleCustomer),
  CustomerLen=2*CustomerSize,
  PrintCustomerDetailsSucess=[],
  PrintCustomerDetailsFailure=[],
  PrintBankDetails=[],
  PrintThread=spawn(fun() ->
    print(CustomerSize,PrintCustomerDetailsSucess,PrintCustomerDetailsFailure,PrintBankDetails)end),
  BankPIDList=getbankProcessIds(BankList,BankList,PrintThread),
  CustomerPIDList=getCustomerProcessIds(BankPIDList,BankList,CustomerList,CustomerList,PrintThread).

print(CustomerSize,PrintCustomerDetailsSucess,PrintCustomerDetailsFailure,PrintBankDetails)->

  receive
    {1,PrintCustomer,AmountToDeduct,BankNameCurrent}->
      io:fwrite("~p requests a loan of ~p dollar(s)from ~p~n",[PrintCustomer,AmountToDeduct,BankNameCurrent]),
      print(CustomerSize,PrintCustomerDetailsSucess,PrintCustomerDetailsFailure,PrintBankDetails);

    {2,PrintCustomer,OrignialAmount}->
      SucessPast=append(PrintCustomerDetailsSucess,[PrintCustomer]),
      PrintCustomerDetailsSucessUpdated=append(SucessPast,[OrignialAmount]),
      ChangedCustomerSize=CustomerSize-1,
      if ChangedCustomerSize==0->
        convertTheListToBankSentence(PrintBankDetails),
        convertTheListToSucessSentence(PrintCustomerDetailsSucessUpdated),
        convertTheListToFailureSentence(PrintCustomerDetailsFailure);
        true->
      print(ChangedCustomerSize,PrintCustomerDetailsSucessUpdated,PrintCustomerDetailsFailure,PrintBankDetails)
      end;

    {3,PrintCustomer,BorrowedAmount}->
      FailurePast=append(PrintCustomerDetailsFailure,[PrintCustomer]),
      PrintCustomerDetailsFailureUpdated=append(FailurePast,[BorrowedAmount]),
      ChangedCustomerSize=CustomerSize-1,
      if ChangedCustomerSize==0->
        convertTheListToSucessSentence(PrintCustomerDetailsSucess),
        convertTheListToBankSentence(PrintBankDetails),
        convertTheListToFailureSentence(PrintCustomerDetailsFailureUpdated);
      true->
      print(ChangedCustomerSize,PrintCustomerDetailsSucess,PrintCustomerDetailsFailureUpdated,PrintBankDetails)
      end;



    {4,PrintBankName,AmountToDeduct,PrintCustomer}->
        io:fwrite("~w approves a loan of ~w dollars from ~p~n",[PrintBankName,AmountToDeduct,PrintCustomer]),
      print(CustomerSize,PrintCustomerDetailsSucess,PrintCustomerDetailsFailure,PrintBankDetails);


    {5,PrintBankName,AmountToDeduct,PrintCustomer}->
      io:fwrite("~w denies a loan of ~w dollars from ~p~n",[PrintBankName,AmountToDeduct,PrintCustomer]),
      print(CustomerSize,PrintCustomerDetailsSucess,PrintCustomerDetailsFailure,PrintBankDetails);


    {6,PrintBankName,AmountToDeduct,PrintCustomer}->
      InputMap= maps:from_list(PrintBankDetails),
      List1=[maps:put(PrintBankName,AmountToDeduct,InputMap)],
      OutMap=nth(1,List1),
      OutputPrintBankDetails=maps:to_list(OutMap),
     print(CustomerSize,PrintCustomerDetailsSucess,PrintCustomerDetailsFailure,OutputPrintBankDetails)

  end.



