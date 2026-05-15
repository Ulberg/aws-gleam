-module(aws_ffi).
-export([sha256/1, hmac_sha256/2, hex_encode/1, get_env/1, read_file/1,
         unix_seconds/0]).

sha256(Data) ->
    crypto:hash(sha256, Data).

hmac_sha256(Key, Data) ->
    crypto:mac(hmac, sha256, Key, Data).

hex_encode(Bin) ->
    binary:encode_hex(Bin, lowercase).

%% Return {ok, Value} if the env var is set, {error, nil} otherwise.
%% os:getenv/1 returns the string value or the atom false; we coerce to the
%% Gleam Result(String, Nil) shape that the credentials module expects.
get_env(Name) ->
    case os:getenv(binary_to_list(Name)) of
        false -> {error, nil};
        Value -> {ok, list_to_binary(Value)}
    end.

%% Read a file as text. Path is a binary; return {ok, Binary} | {error, nil}.
%% Used by the default profile-provider reader so the runtime doesn't take
%% on simplifile as a transitive dependency just to read ~/.aws/credentials.
read_file(Path) ->
    case file:read_file(binary_to_list(Path)) of
        {ok, Bin} -> {ok, Bin};
        {error, _} -> {error, nil}
    end.

%% Unix seconds since epoch. Default production clock for the credentials
%% cache. system_time(second) is monotonic-corrected and matches AWS's
%% credential-expiration timestamps (also unix seconds).
unix_seconds() ->
    erlang:system_time(second).
