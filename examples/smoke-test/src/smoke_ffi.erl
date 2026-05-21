%% Tiny Erlang FFI for the Gleam smoke test.
%%
%% `os:getenv/1` returns `string() | false`, but Gleam's
%% `@external(erlang, "os", "getenv")` with a `Result(String, Nil)`
%% return type emits a pattern match against `{ok, X} | {error, _}`
%% — which `false` doesn't match. That's the `Badarg` writer + reader
%% were crashing on at boot.
%%
%% Wrap once here so the Gleam side stays clean.

-module(smoke_ffi).
-export([get_env/1]).

get_env(Name) when is_binary(Name) ->
    case os:getenv(binary_to_list(Name)) of
        false -> {error, nil};
        Value -> {ok, unicode:characters_to_binary(Value)}
    end.
