-module(tel_calc_parser).
-export([start_parse/1]).

start_parse(Binary) -> 
	T = parse(Binary,[],[]),
	case T of
		{ok, ResL} -> 
			try tel_calc_rpn:rpn(ResL) of
				Result -> Result
			catch
				error:_ -> {error, rpn_error}
			end;
		{error, E} -> {error, E}
	end.
parse(<<"">>, ResL, []) -> ResL;
parse(Binary, ResL, Stack) -> 
	{Number, Sign, Rest} = read_number(<<"">>, Binary),
	ResL_new = write_number(Number, ResL),
	Sign_new = sign_priority(Sign),
	{ResL_snew, Stack_new}=write_sign(Sign_new, ResL_new, Stack),
	case Sign_new of
		bin_end -> {ok, lists:reverse(ResL_snew)};
		{error, E} -> {error, E};
		_ -> parse(Rest, ResL_snew, Stack_new)
	end.

write_sign({error, _}, _, _) -> {[],[]};
write_sign(space, ResL, Stack) -> {ResL, Stack};
write_sign(bin_end, ResL, []) -> {ResL, []};
write_sign(bin_end, ResL, Stack) -> 
	[H | T] = Stack, 
	{_, S} = H, 
	write_sign(bin_end, [S | ResL], T);
write_sign(Sign, ResL, []) ->  {ResL, [Sign]};
write_sign({0,"("}, ResL, Stack) -> {ResL, [{0,"("} | Stack]};
write_sign({0,")"}, ResL, Stack) ->
%	io:format("~p",[Stack]), 
	[H | T]=Stack,
	case H of
		{0,"("} -> {ResL, T};
		{_, S} -> write_sign({0,")"}, [S | ResL], T)
	end; 
write_sign(Sign, ResL, Stack) ->
	{P1, _} = Sign,
	[H | T] = Stack, 
        {P2, S2} = H,
	if
		P1>P2 -> {ResL, [Sign | Stack]};
		true -> write_sign(Sign, [S2 | ResL], T)
	end.

sign_priority("+") -> {1,"+"};
sign_priority("-") -> {1,"-"};
sign_priority("*") -> {2,"*"};
sign_priority("/") -> {2,"/"};
sign_priority("(") -> {0,"("};
sign_priority(")") -> {0,")"};
sign_priority("\r") -> bin_end;
sign_priority(" ") -> space;
sign_priority(E) -> {error, E}.

write_number(empty, ResL) -> ResL;
write_number(Number, ResL) -> [Number | ResL].
	
	
read_number(Head, Rest) ->
	Size=1,
	<<B:Size/binary,Rest_new/binary>> = Rest,
	B_S=binary_to_list(B),
	try list_to_integer(B_S) of
        	_ -> read_number(<<Head/binary,B/binary>>, Rest_new)
        catch
        	error:_ ->  
			case size(Head) of
				0 -> {empty, B_S, Rest_new};
				_ -> {binary_to_integer(Head), B_S, Rest_new}
			end
	end.

