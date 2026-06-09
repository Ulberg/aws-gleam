%% Erlang FFI for tests. Lives under test/ so production builds never
%% pull these helpers into their loaded modules.

-module(aws_test_support_ffi).
-export([
    capture_new/0, capture_put/1, capture_get/1,
    send_stream_start/2, send_stream_chunk/2, send_stream_end/2,
    send_sync_response/4, send_stream_error/2,
    start_chunked_echo/1, ensure_inets/0
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

%% ---------------------------------------------------------------------
%% Tiny one-shot HTTP server for streaming-transport integration tests.
%%
%% Spawns a process that listens on a random local port, accepts a
%% single TCP connection, drains the request bytes, then writes a
%% canned `Transfer-Encoding: chunked` response with three chunks of
%% caller-supplied bodies. Returns the listening port number so the
%% Gleam test can build `http://127.0.0.1:<port>/`.
%%
%% Why this instead of inets httpd / cowboy: zero application start
%% cost, no extra deps, no docker. The server lives just long enough
%% to satisfy one request and exits — there's no shutdown plumbing
%% to leak between tests.

ensure_inets() ->
    _ = application:ensure_all_started(inets),
    nil.

start_chunked_echo(Chunks) when is_list(Chunks) ->
    {ok, Listen} = gen_tcp:listen(0, [
        binary, {packet, raw}, {active, false}, {reuseaddr, true}
    ]),
    {ok, Port} = inet:port(Listen),
    Parent = self(),
    spawn_link(fun() ->
        Parent ! ready,
        case gen_tcp:accept(Listen, 5000) of
            {ok, Conn} ->
                _ = drain_request(Conn),
                ok = write_chunked_response(Conn, Chunks),
                gen_tcp:close(Conn),
                gen_tcp:close(Listen);
            _ ->
                gen_tcp:close(Listen)
        end
    end),
    receive ready -> ok after 1000 -> error(server_did_not_arm) end,
    Port.

%% Drain the request bytes until we see the end-of-headers marker.
%% We don't parse — the server's job is to ship a known response;
%% the request shape is the SDK's concern.
drain_request(Conn) ->
    case gen_tcp:recv(Conn, 0, 1000) of
        {ok, Bin} ->
            case binary:match(Bin, <<"\r\n\r\n">>) of
                nomatch -> drain_request(Conn);
                _ -> ok
            end;
        _ -> ok
    end.

write_chunked_response(Conn, Chunks) ->
    Status = <<"HTTP/1.1 200 OK\r\n">>,
    Headers = <<
        "Content-Type: application/octet-stream\r\n",
        "Transfer-Encoding: chunked\r\n",
        "\r\n"
    >>,
    ok = gen_tcp:send(Conn, Status),
    ok = gen_tcp:send(Conn, Headers),
    lists:foreach(fun(Chunk) -> write_chunk(Conn, Chunk) end, Chunks),
    %% Final zero-length chunk + trailer terminator.
    gen_tcp:send(Conn, <<"0\r\n\r\n">>).

write_chunk(Conn, Chunk) when is_binary(Chunk) ->
    HexLen = list_to_binary(string:to_lower(erlang:integer_to_list(byte_size(Chunk), 16))),
    gen_tcp:send(Conn, <<HexLen/binary, "\r\n", Chunk/binary, "\r\n">>).

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
