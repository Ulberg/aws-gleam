%% Erlang FFI for the LocalStack test harness. Lives under test/ so
%% it only compiles during `gleam test` — production builds never
%% pull docker-compose helpers into their loaded modules.
%%
%% Boot uses `erlang:open_port({spawn, ...}, [exit_status, ...])` so
%% the harness sees the real exit code rather than guessing from
%% stdout text. Teardown is unconditional via `try ... after`.

-module(aws_test_support_ffi).
-export([with_teardown/1]).

-define(COMPOSE_FILE, "test/support/docker-compose.yml").

%% Boot LocalStack, run Fun, tear down. Teardown fires on every
%% exit path — Ok return, panic, or exit signal — by virtue of the
%% `after` clause. If boot itself fails we still run teardown so a
%% partially-started compose project (e.g. healthcheck timed out
%% after the containers spawned) doesn't leak.
with_teardown(Fun) ->
    try
        ok = boot(),
        Fun()
    after
        teardown()
    end.

boot() ->
    Cmd = "docker compose -f " ++ ?COMPOSE_FILE ++ " up -d --wait 2>&1",
    case run(Cmd) of
        {0, _Output} -> ok;
        {Code, Output} ->
            erlang:error({localstack_boot_failed, Code, lists:flatten(Output)})
    end.

teardown() ->
    Cmd = "docker compose -f " ++ ?COMPOSE_FILE ++ " down -v 2>&1",
    _ = run(Cmd),
    ok.

%% Spawn the given shell command via a port, drain stdout/stderr,
%% and wait for the exit_status message. Returns {Code, Output}.
run(Cmd) ->
    Port = erlang:open_port(
        {spawn, Cmd},
        [exit_status, stderr_to_stdout, in, binary, hide]
    ),
    collect(Port, []).

collect(Port, Acc) ->
    receive
        {Port, {data, Bytes}} -> collect(Port, [Bytes | Acc]);
        {Port, {exit_status, Code}} ->
            {Code, lists:reverse(Acc)}
    end.
