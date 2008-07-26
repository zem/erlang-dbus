%%
%% @copyright 2006-2007 Mikael Magnusson
%% @author Mikael Magnusson <mikma@users.sourceforge.net>
%% @doc Exported D-BUS service gen_server
%%

-module(dberl.service).

-import(error_logger).
-import(gen_server).
-import(io).
-import(lists).
-import(timer).

-behaviour(gen_server).

-include("dbus.hrl").

%% api
-export([
	 start_link/1,
	 register_object/3,
	 unregister_object/2
	]).

%% gen_server callback2
-export([
	 init/1,
	 code_change/3,
	 handle_call/3,
	 handle_cast/2,
	 handle_info/2,
	 terminate/2
	]).

-record(state, {
	  name,
	  objects=[]
	 }).

start_link(ServiceName) ->
    gen_server:start_link(?MODULE, [ServiceName], []).

register_object(Service, Path, Object) ->
    gen_server:call(Service, {register_object, Path, Object}).

unregister_object(Service, Object) ->
    gen_server:call(Service, {unregister_object, Object}).

%%
%% gen_server callbacks
%%
init([ServiceName]) ->
    process_flag(trap_exit, true),
    State = #state{name=ServiceName},
    self() ! setup,
    {ok, State}.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


handle_call({register_object, Path, Object}, _From, State) ->
    Objects = State#state.objects,
    case lists:keysearch(Path, 1, Objects) of
	{value, _} ->
	    {reply, {already_registered, Path}, State};
	false ->
	    true = link(Object),
	    Objects1 = [{Path, Object} | Objects],
	    {reply, ok, State#state{objects=Objects1}}
    end;

handle_call({unregister_object, Object}, _From, State) ->
    case handle_unregister_object(Object, State) of
	{ok, State1} ->
	    {reply, ok, State1};
	{error, Reason, State1} ->
	    {reply, Reason, State1};
	{stop, State1} ->
	    {stop, normal, State1}
    end;

handle_call(Request, _From, State) ->
    error_logger:error_msg("Unhandled call in ~p: ~p~n", [?MODULE, Request]),
    {reply, ok, State}.


handle_cast(stop, State) ->
    {stop, normal, State};
handle_cast(Request, State) ->
    error_logger:error_msg("Unhandled cast in ~p: ~p~n", [?MODULE, Request]),
    {noreply, State}.


handle_info(setup, State) ->
    {noreply, State};

handle_info({dbus_method_call, Header, Conn}, State) ->
    {_, PathVar} = message:header_fetch(?HEADER_PATH, Header),
    PathStr = PathVar#variant.value,
    Path = list_to_atom(PathStr),

    case lists:keysearch(Path, 1, State#state.objects) of
	{value, {Path, Object}} ->
	    Object ! {dbus_method_call, Header, Conn};

	_ ->
	    ErrorName = "org.freedesktop.DBus.Error.UnknownObject",
	    ErrorText = "Erlang: Object not found: " ++ PathStr,
	    {ok, Reply} = message:build_error(Header, ErrorName, ErrorText),
	    io:format("Reply ~p~n", [Reply]),
	    ok = connection:cast(Conn, Reply)
    end,
    {noreply, State};

handle_info({'EXIT', Pid, Reason}, State) ->
    case handle_unregister_object(Pid, State) of
	{ok, State1} ->
	    {noreply, State1};
	{stop, State1} ->
	    {stop, normal, State1};
	{error, not_registered, State1} ->
	    if
		Reason /= normal ->
		    {stop, Reason, State1};
		true ->
		    {noreply, State1}
	    end
    end;

handle_info(Info, State) ->
    error_logger:error_msg("Unhandled info in ~p: ~p~n", [?MODULE, Info]),
    {noreply, State}.


terminate(_Reason, _State) ->
    terminated.

%%
%% Return {ok, State}|{error, Reason, State}|{stop, State}
%%
handle_unregister_object(Object, State) ->
    Objects = State#state.objects,
    case lists:keysearch(Object, 2, Objects) of
	{value, {Path, _}} ->
	    true = unlink(Object),
	    error_logger:info_msg("~p: Object terminated ~p ~p~n", [?MODULE, Object, Path]),
	    Objects1 = lists:keydelete(Object, 2, Objects),
	    if
		Objects1 == [] ->
		    error_logger:info_msg("~p: No more objects stopping ~p service~n", [?MODULE, State#state.name]),
		    {stop, State};
		true ->
		    {ok, State#state{objects=Objects1}}
	    end;
	false ->
	    {error, not_registered, State}
    end.