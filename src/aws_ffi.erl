-module(aws_ffi).
-export([sha256/1, hmac_sha256/2, hex_encode/1, get_env/1, read_file/1,
         unix_seconds/0, parse_iso8601/1, run_process/2, sha1_hex/1,
         aws_timestamp/0, random_float/0]).

sha256(Data) ->
    crypto:hash(sha256, Data).

hmac_sha256(Key, Data) ->
    crypto:mac(hmac, sha256, Key, Data).

hex_encode(Bin) ->
    binary:encode_hex(Bin, lowercase).

%% Lowercase-hex SHA-1 of the input binary. Used by the SSO provider to
%% derive the cache-file name from a session name / start URL.
sha1_hex(Bin) ->
    binary:encode_hex(crypto:hash(sha, Bin), lowercase).

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

%% Current UTC time formatted as a SigV4 `X-Amz-Date` value, e.g.
%% "20240315T143022Z". The signer uses opts.timestamp verbatim in both the
%% Authorization scope and the X-Amz-Date header, so they're guaranteed to
%% agree.
aws_timestamp() ->
    {{Y, Mo, D}, {H, Mi, S}} = calendar:universal_time(),
    iolist_to_binary(
        io_lib:format(
            "~4..0w~2..0w~2..0wT~2..0w~2..0w~2..0wZ",
            [Y, Mo, D, H, Mi, S]
        )
    ).

%% Uniform random float in [0.0, 1.0). The default backoff jitter source for
%% the retry strategy. Real callers can substitute a deterministic RNG in
%% tests so synthetic 429/5xx sequences produce reproducible sleep amounts.
random_float() ->
    rand:uniform().

%% Parse an AWS-style ISO 8601 UTC timestamp ("2023-11-30T15:30:00Z" or with
%% fractional seconds like "2023-11-30T15:30:00.000Z") into unix seconds.
%% Returns {ok, Seconds} | {error, nil}. Used by IMDS/STS/SSO providers to
%% turn the Expiration field of a credentials response into expires_at.
parse_iso8601(Bin) when is_binary(Bin) ->
    %% Strip fractional seconds and trailing Z, then leverage calendar.
    Re = "^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\\.[0-9]+)?Z$",
    case re:run(Bin, Re, [{capture, all_but_first, binary}]) of
        {match, [Y, Mo, D, H, Mi, S]} ->
            DateTime = {
                {binary_to_integer(Y), binary_to_integer(Mo), binary_to_integer(D)},
                {binary_to_integer(H), binary_to_integer(Mi), binary_to_integer(S)}
            },
            %% gregorian seconds (year 0) minus epoch offset = unix seconds
            Epoch = 62167219200,
            {ok, calendar:datetime_to_gregorian_seconds(DateTime) - Epoch};
        _ ->
            {error, nil}
    end.

%% Run an external command and capture its stdout + exit status.
%% Args is a list of binary arguments (not interpolated through a shell, so
%% there's no shell-injection surface). Returns {ok, {ExitCode, Stdout}} on
%% success, {error, nil} if the command could not be launched.
run_process(Command, Args) when is_binary(Command), is_list(Args) ->
    CmdStr = binary_to_list(Command),
    ArgStrs = [binary_to_list(A) || A <- Args],
    try
        Port = open_port(
            {spawn_executable, os:find_executable(CmdStr)},
            [
                {args, ArgStrs},
                binary,
                exit_status,
                stderr_to_stdout,
                use_stdio,
                stream
            ]
        ),
        collect_port(Port, <<>>)
    catch
        _:_ -> {error, nil}
    end.

collect_port(Port, Acc) ->
    receive
        {Port, {data, Data}} -> collect_port(Port, <<Acc/binary, Data/binary>>);
        {Port, {exit_status, Status}} -> {ok, {Status, Acc}}
    after 30000 ->
        try port_close(Port) catch _:_ -> ok end,
        {error, nil}
    end.
