-module(aws_log_ffi).
-include_lib("kernel/include/logger.hrl").
-export([emit_debug/1, emit_warning/1, emit_error/1]).

%% Thin pass-through to OTP `logger` for `aws/internal/log`. Verbosity and
%% destination are the operator's to configure the standard BEAM way — there
%% is no SDK-specific knob. The logger's primary level decides what is shown
%% (default `notice`: `error` + `warning` are visible, `debug` is hidden), and
%% its handler decides where (default `logger_std_h` -> standard_io, i.e.
%% stdout). The SDK installs no handler and mutates no global logger config;
%% it only emits events, so SDK lines flow through whatever handler/formatter
%% the host has set up. Turn on the debug firehose the usual way, e.g.
%% `logger:set_primary_config(level, debug)` or a sys.config `kernel` entry.
%%
%% Messages carry no `domain`: OTP's default handler drops events whose domain
%% is not under `[otp, sasl]`, so a custom domain would silently swallow even
%% the error line out of the box. SDK lines are identified by an `aws ...`
%% message prefix instead.

%% Debug is the firehose. The message is a 0-arity Gleam thunk; `logger:allow/2`
%% is consulted first so the thunk — and the string it builds — runs only when
%% a debug event would actually be logged. A logging call must never crash the
%% caller.
emit_debug(Thunk) when is_function(Thunk, 0) ->
    case logger:allow(debug, ?MODULE) of
        true -> ?LOG_DEBUG(Thunk());
        false -> ok
    end,
    nil.

%% `warning` / `error` are sparse and on by default (both outrank the default
%% `notice` primary level). The message is a UTF-8 binary logged as an
%% unstructured string.
emit_warning(Message) ->
    ?LOG_WARNING(Message),
    nil.

emit_error(Message) ->
    ?LOG_ERROR(Message),
    nil.
