%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description :  1
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(prototype_test).   
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").
-include("configs.hrl").
%% --------------------------------------------------------------------

%% External exports
-export([start/0]). 


%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
  %  io:format("~p~n",[{"Start setup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=setup(),
    io:format("~p~n",[{"Stop setup",?MODULE,?FUNCTION_NAME,?LINE}]),

%    io:format("~p~n",[{"Start boot()",?MODULE,?FUNCTION_NAME,?LINE}]),
%    ok= boot(),
%    io:format("~p~n",[{"Stop  boot()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=start_script(),
    io:format("~p~n",[{"Stop  start_script()",?MODULE,?FUNCTION_NAME,?LINE}]),

    io:format("~p~n",[{"Start service_init()",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=service_init(),
    io:format("~p~n",[{"Stop  service_init()",?MODULE,?FUNCTION_NAME,?LINE}]),

      %% End application tests
  %  io:format("~p~n",[{"Start cleanup",?MODULE,?FUNCTION_NAME,?LINE}]),
    ok=cleanup(),
  %  io:format("~p~n",[{"Stop cleaup",?MODULE,?FUNCTION_NAME,?LINE}]),
   
    io:format("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.
 %  io:format("application:which ~p~n",[{application:which_applications(),?FUNCTION_NAME,?MODULE,?LINE}]),

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
start_script()->
    % suppor debugging
    ok=application:start(sd),

    % Simulate host
    ok=test_nodes:start_nodes(),
    [Vm1|_]=test_nodes:get_nodes(),
    
    %simulate start script
    % rm -rf loader
    % git clone https://github.com/joq62/loader.git loader
    % erl -pa loader/ebin -sname loader -setcookie cookie_test -s boot_loader start worker -detached 
    
    LoaderDir="loader",
    LoaderGitPath="https://github.com/joq62/loader.git",
    Ebin="loader/ebin",
    
    os:cmd("rm -rf "++LoaderDir),
    os:cmd("git clone "++LoaderGitPath++" "++LoaderDir), 
    true=rpc:call(Vm1,code,add_path,[Ebin],5000),
    ok=rpc:call(Vm1,boot_loader,start,[[worker]],15000),
    
    pong=rpc:call(Vm1,loader,ping,[],2000),
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
service_init()->
    
    [LoaderVm]=sd:get(loader),
    %% 1. 
    {ok,Depl1}=init("math","1.0.0",[{myadd,"1.0.0"},{mydivi,"1.0.0"}],LoaderVm),
    {Id1,S1}=Depl1,
    42=rpc:call(S1,myadd,add,[20,22],5000),
    
    %% 2.

    {ok,Depl2}=init("add","1.0.0",[{myadd,"1.0.0"}],LoaderVm),
    {Id2,S2}=Depl2,
    222=rpc:call(S2,myadd,add,[200,22],5000),
    {badrpc,_}=rpc:call(S2,mydivi,divi,[200,22],5000),

    %% 3.
    {ok,Depl3}=init("divi","1.0.0",[{mydivi,"1.0.0"}],LoaderVm),
    {Id3,S3}=Depl3,
    10.0=rpc:call(S3,mydivi,divi,[200,20],5000),

    Node=node(),
    MissingId={"missing","2.1.3"},
    DeleteDepl={Id1,S1},
    WantedState=[Id2,Id3,MissingId],
    CurrentState=lists:sort([{rpc:call(Vm,service,id,[],5000),Vm}||Vm<-sd:get(service)]),
 
    [MissingId]=[Id||Id<-WantedState,
		      false=:=lists:keymember(Id,1,CurrentState)],
    [DeleteDepl]=[{Id,Vm}||{Id,Vm}<-CurrentState,
		      false=:=lists:member(Id,WantedState)],
    
    
    ok.

init(Name,Vsn,Template,LoaderVm)->
    {ok,ServiceVm}=rpc:call(LoaderVm,loader,create,[],10000),
    %Fix
    true=rpc:call(ServiceVm,code,add_patha,["ebin"],5000),
    ok=rpc:call(ServiceVm,application,set_env,[[{service,[{id,{Name,Vsn}},{template,Template},{loader_vm,LoaderVm}]}]],5000),
    ok=rpc:call(ServiceVm,application,start,[service],5000),
    {ok,{{Name,Vsn},ServiceVm}}.
  
    

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
dist_1()->
    [H1,H2,H3]=test_nodes:get_nodes(),
    io:format("sd:all ~p~n",[{rpc:call(H1,sd,all,[],2000),?FUNCTION_NAME,?MODULE,?LINE}]),

    ok.
    


    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
  
          
   
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
   
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
