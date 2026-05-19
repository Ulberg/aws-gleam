%% Streaming HTTP send via OTP's `httpc` async-self mode. The
%% caller asks for a request; we set `{sync, false}, {stream, self}`,
%% block on the resulting stream messages, and return the assembled
%% response as `{Status, Headers, [Chunk]}` so the SDK runtime can
%% wrap it as a `streaming.StreamingBody`.
%%
%% Why a dedicated FFI rather than extending `gleam_httpc`:
%% `gleam_httpc` only exposes synchronous (buffer-all-bytes) mode.
%% Streaming mode needs `{sync, false} + {stream, self}` which
%% gleam_httpc doesn't surface; the caller controls the receive
%% loop. That loop lives here so it can be unit-tested by sending
%% synthetic stream messages to a known request id, without booting
%% a real HTTP server.
%%
%% Why we collect synchronously instead of returning a lazy yielder:
%% v1 keeps the existing call-site contract (synchronous Result of
%% Response). Once the SDK gets a streaming consumer API, this loop
%% can be split so chunks reach the caller incrementally — the same
%% `collect_stream/2` becomes the per-chunk handler hook.
%%
%% Status code provenance: OTP's `{stream, self}` only streams for
%% 2xx responses. The first message in that case is `stream_start`
%% which carries only headers — there's no explicit status field.
%% We default Status = 200 because the contract guarantees a 2xx
%% to even get this far; the SDK runtime's success-path code only
%% checks `>= 200 && < 300`, so the exact 200 vs 206 distinction
%% doesn't change error handling. For non-2xx responses httpc sends
%% the synchronous-mode message which carries the full status line;
%% we surface that verbatim.

-module(aws_streaming_ffi).
-export([request_streaming/4, collect_stream/2]).

%% Issue Method to the URL embedded in Request, drive httpc in
%% async-self stream mode, collect every stream message until end-
%% of-stream or error, and return the assembled response.
%%
%% Returns `{ok, {Status, Headers, [Chunk]}}` on success or
%% `{error, Reason}` on transport failure / timeout. Status is an
%% Int, Headers is the raw list of `{Name, Value}` tuples httpc
%% delivers, Chunk is a binary.
request_streaming(Method, Request, HttpOptions, Timeout) when
    is_atom(Method),
    is_tuple(Request),
    is_list(HttpOptions),
    is_integer(Timeout)
->
    Options = [
        {sync, false},
        {stream, self},
        {body_format, binary},
        {receiver, self()}
    ],
    case httpc:request(Method, Request, HttpOptions, Options) of
        {ok, RequestId} -> collect_stream(RequestId, Timeout);
        {error, Reason} -> {error, normalise_error(Reason)}
    end.

%% Message-collection loop. Exposed so tests can drive it by
%% sending synthetic messages to `self()` and calling this with
%% the matching request id — no HTTP server required.
%%
%% Returns the same shape as `request_streaming/4`.
collect_stream(RequestId, Timeout) ->
    collect_stream(RequestId, Timeout, 200, [], []).

collect_stream(RequestId, Timeout, Status, Headers, Chunks) ->
    receive
        {http, {RequestId, stream_start, ResponseHeaders}} ->
            %% Streaming-mode start: pin headers, status defaults to
            %% 200 per the OTP `{stream, self}` contract (it only
            %% streams 2xx). Subsequent stream / stream_end frames
            %% append chunks and finalise.
            collect_stream(
                RequestId,
                Timeout,
                Status,
                ResponseHeaders,
                Chunks
            );
        {http, {RequestId, stream, BinPart}} ->
            collect_stream(
                RequestId,
                Timeout,
                Status,
                Headers,
                [BinPart | Chunks]
            );
        {http, {RequestId, stream_end, FinalHeaders}} ->
            %% stream_end may carry trailer headers; concatenate to
            %% the response headers so trailers are visible to the
            %% caller. Order is FinalHeaders ++ Headers because
            %% trailers are a tail of the conceptual header list.
            {ok, {Status, FinalHeaders ++ Headers, lists:reverse(Chunks)}};
        {http, {RequestId, {{_HTTPVersion, RespStatus, _Reason}, RespHeaders, RespBody}}} ->
            %% Non-streaming response: httpc only streams 2xx, so a
            %% 4xx/5xx arrives as the synchronous-mode `Result`
            %% tuple. Body is already buffered as a single binary;
            %% surface it as a one-element chunk list so the caller
            %% can treat both paths uniformly.
            {ok, {RespStatus, RespHeaders, [RespBody]}};
        {http, {RequestId, {error, Reason}}} ->
            {error, normalise_error(Reason)}
    after Timeout ->
        {error, timeout}
    end.

%% Map httpc's varied error tuples to a single atom the Gleam side
%% can pattern-match on. Mirrors the cases in
%% `aws/internal/http_send.do_send` so streaming and non-streaming
%% transports surface identical errors for the same root cause.
%% Anything we don't recognise that's already an atom passes
%% through verbatim; anything more exotic (a tuple etc.) collapses
%% to `unknown_transport_error` so the Gleam-side type signature
%% (`Atom`) stays satisfied.
normalise_error({failed_connect, _}) -> failed_to_connect;
normalise_error(timeout) -> response_timeout;
normalise_error(Reason) when is_atom(Reason) -> Reason;
normalise_error(_) -> unknown_transport_error.
