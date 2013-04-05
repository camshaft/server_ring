-module (server_ring_benchmark).
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-export ([test/1]).

start_link(Opts) ->
  gen_server:start_link(?MODULE, Opts, []).

init(State) ->
  {ok, State}.

handle_call(Request, _From, State) ->
  {reply, Request, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Msg, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

test(Limit)->
  Case = <<"Hello World">>,

  {ok, Server} = server_ring:start_link(?MODULE),

  Cases = [fun(Worker) -> gen_server:call(Worker, Case) end || _ <- lists:seq(1,Limit)],

  {Time, _} = timer:tc(fun()-> loop(Cases, Server) end),

  io:format("~p iterations in ~ps~n", [Limit, Time/1000000]),
  io:format("~p frames/sec~n", [Limit/(Time/1000000)]).

loop(Cases, Server) ->
  lists:foreach(fun(Case) ->
    server_ring:transaction(Server, Case)
  end, Cases).
