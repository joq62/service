%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(service). 

-behaviour(gen_server). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("log.hrl").

%% --------------------------------------------------------------------
-define(SERVER,?MODULE).


%% External exports
-export([
	 id/0,
	 template/0,

	 read_state/0,
	 ping/0
	]).


-export([
	 start/0,
	 stop/0
	]).


-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {
		id,
		template
		
	       }).

%% ====================================================================
%% External functions
%% ====================================================================


%% ====================================================================
%% Server functions
%% ====================================================================
%% Gen server functions

start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).

%% ====================================================================
%% Application handling
%% ====================================================================

%%---------------------------------------------------------------
%% Function:id()
%% @doc: service id == service spec        
%% @param: non
%% @returns:{Name,Vsn}
%%
%%---------------------------------------------------------------
-spec id()-> {string(),string()}.
id()->
    gen_server:call(?SERVER, {id},infinity).

%%---------------------------------------------------------------
%% Function:template()
%% @doc: service spec template  list of {app,vsn} to run      
%% @param: 
%% @returns:[{app,vsn}]
%%
%%---------------------------------------------------------------
-spec template()-> [{atom(),string()}].
template()->
    gen_server:call(?SERVER, {template},infinity).


%% ====================================================================
%% Support functions
%% ====================================================================
%%---------------------------------------------------------------
%% Function:read_state()
%% @doc: read theServer State variable      
%% @param: non 
%% @returns:State
%%
%%---------------------------------------------------------------
-spec read_state()-> term().
read_state()->
    gen_server:call(?SERVER, {read_state},infinity).
%% 
%% @doc:check if service is running
%% @param: non
%% @returns:{pong,node,module}|{badrpc,Reason}
%%
-spec ping()-> {atom(),node(),module()}|{atom(),term()}.
ping()-> 
    gen_server:call(?SERVER, {ping},infinity).

%% ====================================================================
%% Gen Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok,{ServiceName,Vsn}}=application:get_env(?MODULE,id),
    {ok,Template}=application:get_env(?MODULE,template),
    {ok,LoaderVm}=application:get_env(?MODULE,loader_vm),
     
    {ok,StartRes}= lib_service:start_template(Template,LoaderVm),
    
%    spawn(fun()->do_desired_state() end),
%    rpc:cast(node(),log,log,[?Log_info("server started",[])]),
    {ok, #state{id={ServiceName,Vsn},
		template=Template}
    }.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------



handle_call({id},_From, State) ->
    Reply=State#state.id,
    {reply, Reply, State};

handle_call({template},_From, State) ->
    Reply=State#state.template,
    {reply, Reply, State};

handle_call({read_state},_From, State) ->
    Reply=State,
    {reply, Reply, State};
handle_call({ping},_From, State) ->
    Reply=pong,
    {reply, Reply, State};

handle_call({stopped},_From, State) ->
    Reply=ok,
    {reply, Reply, State};




handle_call({not_implemented},_From, State) ->
    Reply=not_implemented,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched call",[Request, From])]),
    Reply = {ticket,"unmatched call",Request, From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_cast(Msg, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched cast",[Msg])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info(Info, State) ->
    rpc:cast(node(),log,log,[?Log_ticket("unmatched info",[Info])]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------

		  
