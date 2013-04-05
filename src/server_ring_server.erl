-module (server_ring_server).

-export([start_link/4]).
-export([init/4]).

-record(state, {table, size, pos=0}).

start_link(Module, Opts, Size, Name) ->
  {ok, spawn_link(?MODULE, init, [Module, Opts, Size, Name])}.

init(Module, Opts, Size, Name)->
  Tid = ets:new(Name, [ordered_set]),
  [ets:insert(Tid, {N, start_server(Module, Opts)}) || N <- lists:seq(0, Size)],
  loop(#state{table=Tid, size=Size}).

start_server(Module, Opts)->
  {ok, Pid} = Module:start_link(Opts),
  Pid.

loop(#state{table=Tid, size=Size, pos=Pos}=State)->
  receive
    {use, From} ->
      LocalPos = Pos rem Size,
      {_, Pid} = hd(ets:lookup(Tid, LocalPos)),
      From ! {ok, Pid},
      loop(State#state{pos=Pos+1});
    _ ->
      loop(State)
  end.
