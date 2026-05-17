%% Erlang FFI for the LocalStack test harness. Lives under test/ so
%% it only compiles during `gleam test` — production builds never
%% pull docker-compose helpers into their loaded modules.
%%
%% Two entry points:
%%   start_localstack/0  — runs `docker compose up --wait` against
%%                          test/support/docker-compose.yml. Crashes
%%                          (and so fails the test) on non-zero exit
%%                          from docker.
%%   run_with_teardown/1 — runs the supplied 0-arg fun, returning its
%%                          value. On every exit path (Ok or
%%                          exception) it shells out to
%%                          `docker compose down -v` to clear the
%%                          container; exceptions are re-raised after
%%                          the teardown so the failure surfaces.

-module(aws_test_support_ffi).
-export([start_localstack/0, run_with_teardown/1]).

-define(COMPOSE_FILE, "test/support/docker-compose.yml").

start_localstack() ->
    Cmd = "docker compose -f " ++ ?COMPOSE_FILE ++ " up -d --wait 2>&1",
    Output = os:cmd(Cmd),
    %% `docker compose up --wait` exits non-zero on failure, but
    %% os:cmd/1 discards exit codes. The output's last line usually
    %% reports "Healthy" / "Started" on success — accept anything
    %% that doesn't include "ERR" or "Error" as a successful boot.
    case string:find(Output, "ERR", trailing) of
        nomatch ->
            case string:find(Output, "Error", trailing) of
                nomatch -> nil;
                _ -> erlang:error({localstack_boot_failed, Output})
            end;
        _ ->
            erlang:error({localstack_boot_failed, Output})
    end.

run_with_teardown(Fun) ->
    try
        Result = Fun(),
        teardown(),
        Result
    catch
        Class:Reason:Stacktrace ->
            teardown(),
            erlang:raise(Class, Reason, Stacktrace)
    end.

teardown() ->
    Cmd = "docker compose -f " ++ ?COMPOSE_FILE ++ " down -v 2>&1",
    _ = os:cmd(Cmd),
    nil.
