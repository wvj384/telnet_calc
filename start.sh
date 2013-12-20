#!/bin/sh
erl -pa ebin deps/*/ebin -s ranch_start \
        -eval "io:format(\"Run: telnet localhost 5555~n\")."
