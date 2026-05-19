%% Erlang FFI for the LocalStack test harness. Lives under test/ so
%% it only compiles during `gleam test` — production builds never
%% pull docker-compose helpers into their loaded modules.
%%
%% Boot uses `erlang:open_port({spawn, ...}, [exit_status, ...])` so
%% the harness sees the real exit code rather than guessing from
%% stdout text. Teardown is unconditional via `try ... after`.

-module(aws_test_support_ffi).
-export([
    with_teardown/1,
    capture_new/0, capture_put/1, capture_get/1,
    send_stream_start/2, send_stream_chunk/2, send_stream_end/2,
    send_sync_response/4, send_stream_error/2
]).

%% Synthetic httpc stream messages addressed to `self()`. The
%% Gleam-side `aws_streaming_ffi:collect_stream/2` test then drains
%% those messages without a real HTTP server, asserting the loop's
%% message-shape contract.
send_stream_start(ReqId, Headers) ->
    self() ! {http, {ReqId, stream_start, Headers}},
    nil.

send_stream_chunk(ReqId, Chunk) ->
    self() ! {http, {ReqId, stream, Chunk}},
    nil.

send_stream_end(ReqId, Trailers) ->
    self() ! {http, {ReqId, stream_end, Trailers}},
    nil.

%% Non-streaming response path — what httpc sends for 4xx / 5xx
%% even when the request asked for `{stream, self}` (per OTP docs,
%% it only streams 2xx).
send_sync_response(ReqId, Status, Headers, Body) ->
    self() ! {http, {ReqId, {{"HTTP/1.1", Status, "Reason"}, Headers, Body}}},
    nil.

send_stream_error(ReqId, Reason) ->
    self() ! {http, {ReqId, {error, Reason}}},
    nil.

%% Trivial per-test request capture — lets a Gleam test that hands a
%% stub `Send` to provider code retrieve the dispatched request after
%% the fact, to assert e.g. that the right SigV4 signing key was
%% used. Backed by the process dictionary because gleeunit runs each
%% test in its own process, so the key namespace doesn't leak across
%% tests. capture_new returns 0 because the protocol only supports
%% one in-flight capture per test process.
capture_new() -> 0.
capture_put(Req) -> erlang:put(aws_capture, Req), nil.
capture_get(_Ref) ->
    case erlang:get(aws_capture) of
        undefined -> erlang:error(no_captured_request);
        Req -> Req
    end.

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
