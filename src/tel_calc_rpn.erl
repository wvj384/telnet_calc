-module(tel_calc_rpn).
-export([rpn/1]).
rpn(L) ->
    [Result] = lists:foldl(fun rpn/2, [], L),
    Result.
 
rpn("+", [A, B | T]) -> [A + B | T];
rpn("-", [A, B | T]) -> [B - A | T];
rpn("*", [A, B | T]) -> [A * B | T];
rpn("/", [A, B | T]) -> [B / A | T];
rpn(N, T) -> [read(N) | T].
 
read(N) when is_list(N)->
	{error,unknown};
read(N) ->
	N.


