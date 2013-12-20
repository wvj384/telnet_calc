%% Feel free to use, reuse and abuse the code in this file.

-module(ranch_start).

%% API.
-export([start/0]).

%% API.

start() ->
        ok = application:start(ranch),
        ok = application:start(tel_calc).
