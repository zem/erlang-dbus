%%
%% @copyright 2006-2007 Mikael Magnusson
%% @author Mikael Magnusson <mikma@users.sourceforge.net>
%% @doc message module. Builds error and result messages
%%

-module(dbus_message).

-include("dbus.hrl").

%% api

-export([
	 header_find/2,
	 header_fetch/2,
	 build_error/3,
	 build_method_return/3,
	 build_signal/4
	]).

%% send_hello(State) ->
%%     Serial = State#state.serial + 1,
%%     Hello = build_hello(Serial),
%%     {ok, Data} = dbus_marshaller:marshal_message(Hello),
%% %%     io:format("send_hello ~p~n", [Hello]),
%%     ok = dbus_connection:send(State#state.sock, Data),
%%     {ok, State#state{serial=Serial}}.

%% send_list_names(State) ->
%%     Serial = State#state.serial + 1,
%%     Msg = build_list_names(Serial),
%%     {ok, Data} = dbus_marshaller:marshal_message(Msg),
%%     ok = dbus_connection:send(State#state.sock, Data),
%%     {ok, State#state{serial=Serial}}.

%% send_introspect(State) ->
%%     Serial = State#state.serial + 1,
%%     Msg = dbus_introspect:build_introspect("org.freedesktop.DBus", "/"),
%%     {ok, Data} = dbus_marshaller:marshal_message(Msg#header{serial=Serial}),
%%     ok = dbus_connection:send(State#state.sock, Data),
%%     {ok, State#state{serial=Serial}}.

%% handle_data(Data, State) ->
%%     {ok, Messages, Data1} = dbus_marshaller:unmarshal_data(Data),

%% %%     io:format("handle_data ~p ~p~n", [Messages, size(Data1)]),

%%     {ok, State1} = handle_messages(Messages, State#state{buf=Data1}),

%%     {ok, State1}.

%% handle_messages([], State) ->
%%     {ok, State};
%% handle_messages([Message|R], State) ->
%%     {Header, Body} = Message,
%%     {ok, State1} = handle_message(Header#header.type, Header, Body, State),
%%     handle_messages(R, State1).

%% %% FIXME handle illegal messages
%% handle_message(?TYPE_METHOD_RETURN, Header, Body, State) ->
%%     [_, SerialHdr] = header_fetch(?HEADER_REPLY_SERIAL, Header),
%%     Pending = State#state.pending,
%%     Serial = SerialHdr#variant.value,
%%     State1 =
%% 	case lists:keysearch(Serial, 1, Pending) of
%% 	    {value, {Serial, Pid}} ->
%% 		ok = call:reply(Pid, Header, Body),
%% 		State#state{pending=lists:keydelete(Serial, 1, Pending)};
%% 	    _ ->
%% 		io:format("Ignore reply ~p~n", [Serial]),
%% 		State
%% 	end,
%%     {ok, State1};
%% handle_message(?TYPE_ERROR, Header, Body, State) ->
%%     [_, SerialHdr] = header_fetch(?HEADER_REPLY_SERIAL, Header),
%%     Pending = State#state.pending,
%%     Serial = SerialHdr#variant.value,
%%     State1 =
%% 	case lists:keysearch(Serial, 1, Pending) of
%% 	    {value, {Serial, Pid}} ->
%% 		ok = call:error(Pid, Header, Body),
%% 		State#state{pending=lists:keydelete(Serial, 1, Pending)};
%% 	    _ ->
%% 		io:format("Ignore error ~p~n", [Serial]),
%% 		State
%% 	end,
%%     {ok, State1};
%% handle_message(?TYPE_METHOD_CALL, Header, Body, State) ->
%%     io:format("Handle call ~p ~p~n", [Header, Body]),

%%     Serial = State#state.serial + 1,
%%     Path = header_fetch(?HEADER_PATH, Header),
%%     Iface = header_fetch(?HEADER_INTERFACE, Header),
%%     [_Type1, To] = header_fetch(?HEADER_DESTINATION, Header),
%%     [_Type2, From] = header_fetch(?HEADER_SENDER, Header),
%%     Error = #variant{type=string, value="org.freedesktop.DBus.Error.UnknownObject"},
%%     ReplySerial = #variant{type=uint32, value=Header#header.serial},

%%     {ok, ReplyBody, _Pos} = 
%% 	dbus_marshaller:marshal_list([string], ["Erlang: Object not found."]),
%%     Headers = [
%% 	       [?HEADER_ERROR_NAME, Error],
%% 	       [?HEADER_REPLY_SERIAL, ReplySerial],
%%  	       [?HEADER_DESTINATION, From],
%% 	       [?HEADER_SIGNATURE, #variant{type=signature, value="s"}]
%% 	      ],

%%     ReplyHeader = #header{type=?TYPE_ERROR,
%% 			  serial=Header#header.serial,
%% 			  headers=Headers},

%%     io:format("Reply ~p ~p~n", [ReplyHeader, ReplyBody]),

%%     {ok, Data} = dbus_marshaller:marshal_message(ReplyHeader, ReplyBody),
%%     ok = dbus_connection:send(State#state.sock, Data),

%%     {ok, State#state{serial=Serial}};
    
%% handle_message(Type, Header, Body, State) ->
%%     io:format("Ignore ~p ~p ~p~n", [Type, Header, Body]),
%%     {ok, State}.

%% handle_method_call(Header, Body) ->
%%     ok.


%% header_fetch(Code, Header) ->
%%     Headers = Header#header.headers,
%%     Fun = fun(F) ->
%% 		  case F of
%% 		      [Code | _] ->
%% 			  true;
%% 		      _ ->
%% 			  false
%% 		  end
%% 	  end,

%%     [Field] = lists:filter(Fun, Headers),
%%     Field.

%% new_request(Path, Destination, Interface, Member)

%% to_list(Message) ->
%%     [$l,
%%      Message#header.type,
%%      Message#header.flags,
%%      ?DBUS_VERSION_MAJOR,
%%      size(Message#header.body),
%%      Message#header.serial,
%%      { headers_to_list(Message#header.headers) }].

%% headers_to_list(Headers) ->
    


%%     [Endianess, Type, Flags, Version, Size, Serial, NoHeaders

%%      = [$l,
%% 		  Header#header.type,
%% 		  Header#header.flags,
%% 		  ?DBUS_VERSION_MAJOR,
%% 		  size(Body),
%% 		  Header#header.serial,
%% 		  Header#header.headers],



build_hello(Serial) ->
    Headers = [
	       {?HEADER_PATH, #variant{type=object_path, value="/org/freedesktop/DBus"}},
	       {?HEADER_DESTINATION, #variant{type=string, value="org.freedesktop.DBus"}},
	       {?HEADER_INTERFACE, #variant{type=string, value="org.freedesktop.DBus"}},
	       {?HEADER_MEMBER, #variant{type=string, value="Hello"}}
	      ],

    #header{type=?TYPE_METHOD_CALL,
	    serial=Serial,
	    headers=Headers}.

build_list_names(Serial) ->
    Headers = [
	       {?HEADER_PATH, #variant{type=object_path, value="/org/freedesktop/DBus"}},
	       {?HEADER_DESTINATION, #variant{type=string, value="org.freedesktop.DBus"}},
	       {?HEADER_INTERFACE, #variant{type=string, value="org.freedesktop.DBus"}},
	       {?HEADER_MEMBER, #variant{type=string, value="ListNames"}}
	      ],

    #header{type=?TYPE_METHOD_CALL,
	    serial=Serial,
	    headers=Headers}.

build_error(Header, ErrorName, ErrorText) ->
%%     Path = dbus_message:header_fetch(?HEADER_PATH, Header),
%%     Iface = dbus_message:header_fetch(?HEADER_INTERFACE, Header),
%%     {_Type1, To} = dbus_message:header_fetch(?HEADER_DESTINATION, Header),
    {_Type2, From} = dbus_message:header_fetch(?HEADER_SENDER, Header),
    Error = #variant{type=string, value=ErrorName},
    ReplySerial = #variant{type=uint32, value=Header#header.serial},

    {ok, ReplyBody, _Pos} = 
	dbus_marshaller:marshal_list([string], [ErrorText]),
    Headers = [
	       {?HEADER_ERROR_NAME, Error},
	       {?HEADER_REPLY_SERIAL, ReplySerial},
 	       {?HEADER_DESTINATION, From},
	       {?HEADER_SIGNATURE, #variant{type=signature, value="s"}}
	      ],

    ReplyHeader = #header{type=?TYPE_ERROR,
			  serial=Header#header.serial,
			  headers=Headers,
			  body=ReplyBody},
    {ok, ReplyHeader}.

build_method_return(Header, Types, Body) ->
    {_Type2, From} = dbus_message:header_fetch(?HEADER_SENDER, Header),
    ReplySerial = #variant{type=uint32, value=Header#header.serial},
    Signature = dbus_marshaller:marshal_signature(Types),

    {ok, BinBody, _Pos} = 
	dbus_marshaller:marshal_list(Types, Body),
    Headers = [
	       {?HEADER_REPLY_SERIAL, ReplySerial},
 	       {?HEADER_DESTINATION, From},
	       {?HEADER_SIGNATURE, #variant{type=signature, value=Signature}}
	      ],

    ReplyHeader = #header{type=?TYPE_METHOD_RETURN,
			  serial=Header#header.serial,
			  headers=Headers,
			  body=BinBody},
    {ok, ReplyHeader}.

build_signal(Path, Iface_name, Signal, Args) when is_atom(Path),
						  is_atom(Iface_name),
						  is_record(Signal, signal),
						  is_list(Args) ->
    Signal_name = Signal#signal.name,
    Signature = Signal#signal.out_sig,
    Types = Signal#signal.out_types,

    Signature = dbus_marshaller:marshal_signature(Types),

    {ok, Body, _Pos} = 
	dbus_marshaller:marshal_list(Types, Args),
    Headers = [
	       {?HEADER_PATH, #variant{type=object_path, value=Path}},
	       {?HEADER_INTERFACE, #variant{type=string, value=Iface_name}},
	       {?HEADER_MEMBER, #variant{type=string, value=Signal_name}},
	       {?HEADER_SIGNATURE, #variant{type=signature, value=Signature}}
	      ],

    Header = #header{type=?TYPE_SIGNAL,
		     headers=Headers,
		     body=Body},
    {ok, Header}.

header_fetch(Code, Header) ->
    {ok, Field} = header_find(Code, Header),
    Field.

header_find(Code, Header) ->
    Headers = Header#header.headers,

    case lists:keysearch(Code, 1, Headers) of
	{value, Field} ->
	    {ok, Field};
	_ ->
	    error
    end.

