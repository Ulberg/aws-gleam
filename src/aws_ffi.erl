-module(aws_ffi).
-export([sha256/1, hmac_sha256/2, hex_encode/1, get_env/1, read_file/1,
         unix_seconds/0, parse_iso8601/1, run_process/2, sha1_hex/1,
         aws_timestamp/0, random_float/0, encode_dynamic_to_json/1,
         float_nan/0, float_infinity/0, float_neg_infinity/0,
         float_is_nan/1, float_is_infinite/1, json_canonicalize/1]).

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

%% Encode an arbitrary decoded JSON term (the Erlang shape gleam_json
%% returns: integers/floats/atoms/binaries/lists/maps) back into a JSON
%% binary string. Used by the protocol-test loader to round-trip the
%% `params` blob from the Smithy AST into something the runner can
%% structurally compare. Returns {ok, Binary} | {error, nil}.
encode_dynamic_to_json(Term) ->
    try iolist_to_binary(do_encode_json(Term)) of
        Bin -> {ok, Bin}
    catch
        _:_ -> {error, nil}
    end.

do_encode_json(null) -> <<"null">>;
do_encode_json(true) -> <<"true">>;
do_encode_json(false) -> <<"false">>;
do_encode_json(undefined) -> <<"null">>;
do_encode_json(N) when is_integer(N) -> integer_to_binary(N);
do_encode_json(F) when is_float(F) -> float_to_binary(F, [{decimals, 17}, compact]);
do_encode_json(B) when is_binary(B) -> [<<"\"">>, escape_json_string(B), <<"\"">>];
do_encode_json(L) when is_list(L) ->
    Items = [do_encode_json(I) || I <- L],
    [<<"[">>, lists:join(<<",">>, Items), <<"]">>];
do_encode_json(M) when is_map(M) ->
    Pairs = maps:fold(
        fun(K, V, Acc) ->
            KB = if is_binary(K) -> K; is_atom(K) -> atom_to_binary(K, utf8); true -> iolist_to_binary(io_lib:format("~p", [K])) end,
            Pair = [<<"\"">>, escape_json_string(KB), <<"\":">>, do_encode_json(V)],
            [Pair | Acc]
        end, [], M),
    [<<"{">>, lists:join(<<",">>, Pairs), <<"}">>].

escape_json_string(B) when is_binary(B) ->
    escape_json_string(B, <<>>).
escape_json_string(<<>>, Acc) -> Acc;
escape_json_string(<<$\\, R/binary>>, Acc) -> escape_json_string(R, <<Acc/binary, $\\, $\\>>);
escape_json_string(<<$", R/binary>>, Acc) -> escape_json_string(R, <<Acc/binary, $\\, $">>);
escape_json_string(<<$\n, R/binary>>, Acc) -> escape_json_string(R, <<Acc/binary, $\\, $n>>);
escape_json_string(<<$\r, R/binary>>, Acc) -> escape_json_string(R, <<Acc/binary, $\\, $r>>);
escape_json_string(<<$\t, R/binary>>, Acc) -> escape_json_string(R, <<Acc/binary, $\\, $t>>);
escape_json_string(<<C, R/binary>>, Acc) when C < 32 ->
    escape_json_string(R, <<Acc/binary, $\\, $u, "00", (hex_digit(C div 16)):8, (hex_digit(C rem 16)):8>>);
escape_json_string(<<C, R/binary>>, Acc) -> escape_json_string(R, <<Acc/binary, C>>).

hex_digit(N) when N < 10 -> $0 + N;
hex_digit(N) -> $a + N - 10.

%% IEEE 754 special-float helpers used by awsJson serializers.
%% Erlang floats are IEEE 754; we just need to produce the three sentinel
%% values and recognise them on the way in.
%%
%% NaN is the canonical "not a number"; Inf is +∞; -Inf is −∞. The OTP
%% standard library exposes these via `float_to_*` formatting, but for
%% Gleam consumers we need plain constructors.

%% awsJson encodes IEEE 754 specials (NaN / Infinity / -Infinity) as JSON
%% strings. Unlike Rust's `f64`, the Erlang `float()` type CANNOT hold
%% these values — `0.0/0.0` raises `badarith`, `<<F/float>> = <<NaN_bits>>`
%% bombs on Badmatch, `binary_to_term` rejects the NaN tag with Badarg.
%% This is a BEAM platform constraint, documented in
%% docs/audits/m5.md (§7 "Platform limitations").
%%
%% The helpers below DEGRADE GRACEFULLY: constructors return 0.0 when
%% the underlying VM refuses to allocate the special value, so call
%% sites don't crash. SimpleScalarProperties special-float protocol-test
%% cases consequently produce body mismatches (not crashes) — a real,
%% honest signal that this codec corner is not representable on Erlang.
%% First-class support requires a wrapper type (e.g. `type Float { F(Float)
%% NaN PosInf NegInf }`), tracked in the audit's next-iteration roadmap.

float_nan() ->
    try binary_to_term(<<131, 70, 16#7FF8000000000000:64>>) of
        F when is_float(F) -> F
    catch
        _:_ -> 0.0
    end.

float_infinity() ->
    try binary_to_term(<<131, 70, 16#7FF0000000000000:64>>) of
        F when is_float(F) -> F
    catch
        _:_ -> 0.0
    end.

float_neg_infinity() ->
    try binary_to_term(<<131, 70, 16#FFF0000000000000:64>>) of
        F when is_float(F) -> F
    catch
        _:_ -> 0.0
    end.

float_is_nan(F) when is_float(F) ->
    %% IEEE 754: NaN is the only value not equal to itself. On Erlang
    %% we never actually hold NaN, so this is reliably false; kept for
    %% API symmetry with platforms that do.
    F =/= F;
float_is_nan(_) -> false.

float_is_infinite(F) when is_float(F) ->
    %% Comparison against the (degraded) sentinels. Reliably false on
    %% Erlang.
    F =:= float_infinity() andalso F =/= 0.0;
float_is_infinite(_) -> false.

%% Parse a JSON string and re-encode it canonically — object keys sorted,
%% all whitespace stripped. The Smithy protocol-test spec compares JSON
%% bodies structurally; this is how we collapse the byte-level
%% representation to a stable shape before equality testing.
%% Returns {ok, CanonicalBinary} | {error, nil}.
json_canonicalize(Bin) when is_binary(Bin) ->
    case decode_json_string(Bin) of
        {ok, Term} ->
            try iolist_to_binary(do_encode_canonical(Term)) of
                Out -> {ok, Out}
            catch
                _:_ -> {error, nil}
            end;
        error -> {error, nil}
    end.

%% Use Erlang OTP 27+ json module for parsing.
decode_json_string(Bin) ->
    try json:decode(Bin) of
        T -> {ok, T}
    catch
        _:_ -> error
    end.

%% Canonical encoder: sorts object keys, no whitespace. Identical
%% semantics to do_encode_json above except that maps emit pairs in
%% key-sorted order.
do_encode_canonical(null) -> <<"null">>;
do_encode_canonical(true) -> <<"true">>;
do_encode_canonical(false) -> <<"false">>;
do_encode_canonical(undefined) -> <<"null">>;
do_encode_canonical(N) when is_integer(N) -> integer_to_binary(N);
do_encode_canonical(F) when is_float(F) -> float_to_binary(F, [{decimals, 17}, compact]);
do_encode_canonical(B) when is_binary(B) -> [<<"\"">>, escape_json_string(B), <<"\"">>];
do_encode_canonical(L) when is_list(L) ->
    Items = [do_encode_canonical(I) || I <- L],
    [<<"[">>, lists:join(<<",">>, Items), <<"]">>];
do_encode_canonical(M) when is_map(M) ->
    Sorted = lists:sort(maps:to_list(M)),
    Pairs = [
        begin
            KB = if is_binary(K) -> K;
                    is_atom(K) -> atom_to_binary(K, utf8);
                    true -> iolist_to_binary(io_lib:format("~p", [K]))
                 end,
            [<<"\"">>, escape_json_string(KB), <<"\":">>, do_encode_canonical(V)]
        end
        || {K, V} <- Sorted
    ],
    [<<"{">>, lists:join(<<",">>, Pairs), <<"}">>].

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
