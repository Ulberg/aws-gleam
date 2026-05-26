-module(aws_log_ffi).
-include_lib("kernel/include/logger.hrl").
-export([emit/2, cached_level/0, cache_level/1]).

%% Leveled-logger FFI for `aws/internal/log`. The SDK owns its own verbosity
%% gate (resolved from the `LOGLEVEL` environment variable on the Gleam side);
%% OTP `logger` is just the sink. To keep that gate authoritative we route
%% every SDK event through this one module and lift the module's log level to
%% `all`, so a `debug` event we *choose* to emit is not re-suppressed by the
%% logger's primary level (which defaults to `notice`). Errors and warnings
%% would pass the default primary level anyway; lifting the module level also
%% lets them through when an operator has otherwise raised the primary level,
%% which matches the SDK's "errors are always-on" contract. The escape hatch
%% is `LOGLEVEL=silent`, which makes the Gleam side stop calling `emit/2` at
%% all.
%%
%% Deliberately no `domain` metadata: OTP's *default* handler drops events
%% whose domain is not under `[otp, sasl]` (its `filter_default` is `stop`),
%% so tagging a custom `[aws]` domain would silently swallow even the
%% always-on error line under the out-of-the-box configuration. Emitting with
%% no domain lets the default handler's `no_domain` filter pass the event —
%% the SDK identifies its own lines by an `aws ...` message prefix instead.

-define(LEVEL_KEY, {aws_log, level}).

%% The resolved level cached by `cache_level/1`, or `{error, nil}` before the
%% first resolution. The Gleam side resolves `LOGLEVEL` once and stores the
%% parsed value here so the hot path is a single persistent_term read.
cached_level() ->
    case persistent_term:get(?LEVEL_KEY, undefined) of
        undefined -> {error, nil};
        Level -> {ok, Level}
    end.

%% Cache the resolved level and make this module's events bypass the logger
%% primary-level filter. Called once, on first log. `Level` is an opaque
%% Gleam `Level` value — stored and returned verbatim, never inspected here.
cache_level(Level) ->
    _ = logger:set_module_level(?MODULE, all),
    persistent_term:put(?LEVEL_KEY, Level),
    nil.

%% Emit one event. `Tag` is the binary the Gleam side passes once the caller
%% has cleared the `LOGLEVEL` gate (`<<"debug">>` | `<<"warning">>` |
%% `<<"error">>`); `Message` is a UTF-8 binary logged as an unstructured
%% string. A logging call must never crash the caller, so an unrecognised tag
%% is dropped rather than left to fail a function clause.
emit(<<"error">>, Message) ->
    ?LOG_ERROR(Message),
    nil;
emit(<<"warning">>, Message) ->
    ?LOG_WARNING(Message),
    nil;
emit(<<"debug">>, Message) ->
    ?LOG_DEBUG(Message),
    nil;
emit(_Tag, _Message) ->
    nil.
