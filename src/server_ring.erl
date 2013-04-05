-module(server_ring).

-export ([start_link/1]).
-export ([start_link/2]).
-export ([start_link/3]).
-export ([start_link/4]).

-export ([use/1]).
-export ([transaction/2]).

start_link(Module) ->
  start_link(Module, []).
start_link(Module, Opts) ->
  start_link(Module, Opts, 100).
start_link(Module, Opts, Size) ->
  start_link(Module, Opts, Size, ?MODULE).
start_link(Module, Opts, Size, Name) ->
  server_ring_server:start_link(Module, Opts, Size, Name).

%%%----------------------------------------------------------------------
%%% Usable Functions
%%%----------------------------------------------------------------------

use(Server) ->
  Server ! {use, self()},
  receive
    {ok, Pid} ->
      {ok, Pid};
    _ ->
      error
  end.

transaction(Server, Fun)->
  {ok, Pid} = use(Server),
  try
    Fun(Pid)
  after
    %% TODO Notify the ring that we're done
    ok
  end.
