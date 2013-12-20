%% Feel free to use, reuse and abuse the code in this file.

-module(ranch_list).
-export([start_link/4, init/4]).

start_link(Ref, Socket, Transport, Opts) ->
	Pid = spawn_link(?MODULE, init, [Ref, Socket, Transport, Opts]),
	{ok, Pid}.

init(Ref, Socket, Transport, _Opts = []) ->
	ok = ranch:accept_ack(Ref),
	loop(Socket, Transport).

loop(Socket, Transport) ->
	case Transport:recv(Socket, 0, 50000) of
		{ok, Data} ->
			Res=data_parser(Data),
			Transport:send(Socket, Res),
			loop(Socket, Transport);
		_ ->
			ok = Transport:close(Socket)
	end.

data_parser(<<"\r\n">>) -> <<"">>;
data_parser(Data) -> 
	case tel_calc_parser:start_parse(Data) of
	R when is_integer(R) -> RI=integer_to_binary(R), <<">> ",RI/binary,"\r\n">>;
	R when is_float(R) -> RF=float_to_binary(R), <<">> ",RF/binary,"\r\n">>;
	{error, rpn_error}  -> <<">> invalid expression\r\n">>;
	{error, Err} -> ErrB=list_to_binary(Err), << ">> ",ErrB/binary," - invalid symbol\r\n">>
	end.
