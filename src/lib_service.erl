%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(lib_service).   
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%-include("log.hrl").
%-include("configs.hrl").
%%---------------------------------------------------------------------
%% Records for test
%%
%-define(ScheduleInterval,20*1000).
%-define(ConfigsGitPath,"https://github.com/joq62/configs.git").
%-define(ConfigsDir,filename:join(?ApplMgrConfigDir,"configs")).
%-define(ApplicationsDir,filename:join(?ConfigsDir,"applications")).
%-define(ApplMgrConfigDir,"appl_mgr.dir").

%% --------------------------------------------------------------------
%-compile(export_all).

-export([
	 
	 start_template/2
	
	]).


%% ====================================================================
%% External functions
%% ====================================================================


start_template(Template,LoaderVm)->
    start_template(Template,LoaderVm,[]).

start_template([],_LoaderVm,StartRes)->
    case [{error,Reason}||{error,Reason}<-StartRes] of
	[]->
	    {ok,StartRes};
	ErrorList ->
	    {error,ErrorList}
    end;
start_template([{App,Vsn}|T],LoaderVm,Acc)->
    Result=case rpc:call(LoaderVm,loader,load_appl,[App,node()],30*1000) of
	       {error,Reason}->
		   {error,[Reason,App,Vsn]};
	       ok->
		   case rpc:call(LoaderVm,loader,start_appl,[App,node()],30*1000) of
		        {error,Reason}->
			   {error,[Reason,App,Vsn]};
		       ok->
			   case rpc:call(node(),App,ping,[],5*1000) of
			       pong->
				   {ok,[App,Vsn]};
			       {badrpc,Reason}->
				   {error,[{badrpc,Reason},App,Vsn]};
			       {error,Reason}->
				   {error,[Reason,App,Vsn]}
			   end
		   end
	   end,
    start_template(T,LoaderVm,[Result|Acc]).
				   



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
