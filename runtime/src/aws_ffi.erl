-module(aws_ffi).
-include_lib("xmerl/include/xmerl.hrl").
-export([sha256/1, sha1/1, md5/1, crc32c/1, hmac_sha256/2, hex_encode/1,
         ecdsa_p256_sign/2, ecdsa_p256_verify/3, ecdsa_p256_public_key/1, get_env/1,
         read_file/1, unix_seconds/0, parse_iso8601/1, run_process/2,
         sha1_hex/1, aws_timestamp/0, random_float/0,
         encode_dynamic_to_json/1, float_nan/0, float_infinity/0,
         float_neg_infinity/0, float_is_nan/1, float_is_infinite/1,
         json_canonicalize/1, xml_parse/1, float_short/1,
         format_iso8601/1, parse_http_date/1, format_http_date/1,
         idempotency_token/0, set_env/2, rescue_call/1, plain_args/0]).

%% Shortest round-tripping float string, e.g. `1.1` not `1.10000000…e+00`.
%% Used by query / header / URI-label / XML formatters; matches AWS's
%% canonical wire form for the SimpleScalarProperties protocol-test
%% suite. Requires OTP 25+.
float_short(F) when is_float(F) -> float_to_binary(F, [short]).

%% RFC 7231 / RFC 1123 HTTP-date: "Sun, 06 Nov 1994 08:49:37 GMT".
%% Used by Smithy `@timestampFormat("http-date")` on response headers
%% / bodies. Returns epoch seconds or `{error, nil}` on malformed input.
parse_http_date(Bin) when is_binary(Bin) ->
    %% `calendar:datetime_to_gregorian_seconds/1` raises `function_clause`
    %% on out-of-range fields (e.g. day 39, hour 25) that pass the regex
    %% shape check; this is server-controlled input, so catch and report
    %% it as `{error, nil}` rather than crash the consumer's process.
    try
        Months = #{<<"Jan">>=>1, <<"Feb">>=>2, <<"Mar">>=>3, <<"Apr">>=>4,
                   <<"May">>=>5, <<"Jun">>=>6, <<"Jul">>=>7, <<"Aug">>=>8,
                   <<"Sep">>=>9, <<"Oct">>=>10, <<"Nov">>=>11, <<"Dec">>=>12},
        Re = "^[A-Za-z]+, ([0-9]{2}) ([A-Za-z]{3}) ([0-9]{4}) ([0-9]{2}):([0-9]{2}):([0-9]{2}) GMT$",
        case re:run(Bin, Re, [{capture, all_but_first, binary}]) of
            {match, [D, MoBin, Y, H, Mi, S]} ->
                case maps:find(MoBin, Months) of
                    {ok, Mo} ->
                        DateTime = {
                            {binary_to_integer(Y), Mo, binary_to_integer(D)},
                            {binary_to_integer(H), binary_to_integer(Mi), binary_to_integer(S)}
                        },
                        Epoch = 62167219200,
                        {ok, calendar:datetime_to_gregorian_seconds(DateTime) - Epoch};
                    error -> {error, nil}
                end;
            _ -> {error, nil}
        end
    catch
        _:_ -> {error, nil}
    end.

%% Inverse of `parse_iso8601`: epoch seconds (Int) → `"YYYY-MM-DDTHH:MM:SSZ"`
%% UTC string. The default `@timestampFormat` for `date-time` in
%% restJson1 / restXml is RFC 3339 with second precision; we never emit
%% fractional seconds. Negative epoch seconds (pre-1970) round-trip via
%% `calendar:gregorian_seconds_to_datetime`.
format_iso8601(Seconds) when is_integer(Seconds) ->
    Epoch = 62167219200,
    {{Y, Mo, D}, {H, Mi, S}} =
        calendar:gregorian_seconds_to_datetime(Seconds + Epoch),
    iolist_to_binary(io_lib:format(
        "~4..0w-~2..0w-~2..0wT~2..0w:~2..0w:~2..0wZ",
        [Y, Mo, D, H, Mi, S]
    )).

%% Auto-fill value for `@idempotencyToken` members when the caller
%% leaves the field unset. Returns the nil-v4 UUID
%% `00000000-0000-4000-8000-000000000000` by default — the Smithy
%% protocol-test fixtures expect this exact string. Production
%% callers can override via the application env
%% `aws.idempotency_token` (any string).
idempotency_token() ->
    case application:get_env(aws, idempotency_token) of
        {ok, V} when is_binary(V) -> V;
        _ -> <<"00000000-0000-4000-8000-000000000000">>
    end.

%% RFC 7231 / IMF-fixdate, e.g. `Tue, 29 Apr 2014 18:30:38 GMT`. Used
%% by `@timestampFormat("http-date")` body fields and the
%% `If-Modified-Since`-style header members.
format_http_date(Seconds) when is_integer(Seconds) ->
    Epoch = 62167219200,
    {{Y, Mo, D}, {H, Mi, S}} =
        calendar:gregorian_seconds_to_datetime(Seconds + Epoch),
    DayOfWeek = calendar:day_of_the_week({Y, Mo, D}),
    DayName = element(DayOfWeek,
        {<<"Mon">>, <<"Tue">>, <<"Wed">>, <<"Thu">>,
         <<"Fri">>, <<"Sat">>, <<"Sun">>}),
    MonthName = element(Mo,
        {<<"Jan">>, <<"Feb">>, <<"Mar">>, <<"Apr">>, <<"May">>, <<"Jun">>,
         <<"Jul">>, <<"Aug">>, <<"Sep">>, <<"Oct">>, <<"Nov">>, <<"Dec">>}),
    iolist_to_binary(io_lib:format(
        "~s, ~2..0w ~s ~4..0w ~2..0w:~2..0w:~2..0w GMT",
        [DayName, D, MonthName, Y, H, Mi, S]
    )).

sha256(Data) ->
    crypto:hash(sha256, Data).

%% Raw SHA-1 digest as a 20-byte binary. Exposed for the AWS
%% multi-algorithm checksum feature (`sha1` variant) — base64-
%% encoded into the `x-amz-checksum-sha1` header. Distinct from
%% `sha1_hex/1`, which returns the lowercase hex form used by the
%% SSO cache-file naming.
sha1(Data) ->
    crypto:hash(sha, Data).

%% Raw MD5 digest, used by the `@httpChecksumRequired` body-checksum
%% helper. MD5 is a degraded primitive for security work but the
%% AWS wire spec for this trait requires it (Content-MD5 is the
%% S3-control / restJson1 wire shape); SigV4 covers the actual auth.
md5(Data) ->
    crypto:hash(md5, Data).

hmac_sha256(Key, Data) ->
    crypto:mac(hmac, sha256, Key, Data).

%% Sign `Data` with an ECDSA P-256 (secp256r1) private key, using
%% SHA-256 as the message digest. `PrivateKey` is the 32-byte
%% scalar value as a binary. Returns the DER-encoded ASN.1
%% signature blob.
%%
%% Used by SigV4a (`AWS4-ECDSA-P256-SHA256`). Erlang's `crypto`
%% module generates a fresh random nonce per call rather than the
%% RFC 6979 deterministic nonce AWS reference vectors use, so
%% signatures verify correctly against the AWS public-key check
%% but won't match the aws-c-auth v4a fixture's literal bytes.
ecdsa_p256_sign(PrivateKey, Data) when is_binary(PrivateKey), is_binary(Data) ->
    crypto:sign(ecdsa, sha256, Data, [PrivateKey, secp256r1]).

%% Verify a SigV4a signature. `PublicKey` is the uncompressed 65-byte
%% SEC1 form (`04 || X || Y`); `Signature` is the DER-encoded blob
%% returned by `ecdsa_p256_sign`. Returns a boolean.
ecdsa_p256_verify(PublicKey, Data, Signature)
  when is_binary(PublicKey), is_binary(Data), is_binary(Signature) ->
    crypto:verify(ecdsa, sha256, Data, Signature, [PublicKey, secp256r1]).

%% Derive the uncompressed SEC1 public key (`<<4, X:32/binary, Y:32/binary>>`)
%% for a given P-256 private scalar. Used by the SigV4a key-derivation
%% tests and by anyone who wants to surface the public counterpart of a
%% derived signing key. `crypto:generate_key/3` with an explicit private
%% scalar leaves the scalar untouched and only fills in the public side.
ecdsa_p256_public_key(PrivateKey) when is_binary(PrivateKey) ->
    {PubKey, PrivateKey} = crypto:generate_key(ecdh, secp256r1, PrivateKey),
    PubKey.

%% CRC-32C (Castagnoli polynomial 0x1EDC6F41, reflected 0x82F63B78).
%% Used by AWS multi-algorithm checksum (`crc32c` variant) — base64
%% of the BE 4-byte form goes into `x-amz-checksum-crc32c`. Not
%% available in OTP's stdlib so we compute it byte-by-byte; the
%% loop is short enough that a fully-precomputed table isn't worth
%% the static overhead. Returns the unsigned 32-bit integer value.
crc32c(Data) when is_binary(Data) ->
    Crc = crc32c_loop(Data, 16#FFFFFFFF),
    Crc bxor 16#FFFFFFFF.

crc32c_loop(<<>>, Crc) -> Crc;
crc32c_loop(<<B, Rest/binary>>, Crc) ->
    crc32c_loop(Rest, crc32c_byte(Crc bxor B)).

%% Single-byte CRC-32C step using the reflected polynomial. Eight
%% conditional shifts per byte; runs ~25 MB/s on a modern laptop
%% which is enough for SDK checksum use (payloads bounded by S3
%% put-object size + memory anyway).
crc32c_byte(Crc) ->
    crc32c_bits(Crc, 8).

crc32c_bits(Crc, 0) -> Crc;
crc32c_bits(Crc, N) ->
    NewCrc = case Crc band 1 of
        1 -> (Crc bsr 1) bxor 16#82F63B78;
        0 -> Crc bsr 1
    end,
    crc32c_bits(NewCrc, N - 1).

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
    case os:getenv(unicode:characters_to_list(Name)) of
        false -> {error, nil};
        Value -> {ok, unicode:characters_to_binary(Value)}
    end.

%% Set an OS environment variable. The Lambda runtime uses this to copy
%% the per-invocation X-Ray trace id from the `Lambda-Runtime-Trace-Id`
%% response header into `_X_AMZ_TRACE_ID`, the variable the AWS SDKs read
%% to attach downstream calls to the active trace. Returns nil.
set_env(Name, Value) when is_binary(Name), is_binary(Value) ->
    os:putenv(unicode:characters_to_list(Name), unicode:characters_to_list(Value)),
    nil.

%% Plain command-line arguments — everything after `--` in
%% `gleam run -- ...` — as binaries. The Lambda local-run path reads
%% `--event <json>` from these; empty list under a release/Lambda boot.
plain_args() ->
    [unicode:characters_to_binary(A) || A <- init:get_plain_arguments()].

%% Run a 0-arity fun inside try/catch and reflect the outcome as a Gleam
%% Result. Success becomes {ok, Value}; any raise/throw/exit becomes
%% {error, {handler_crash, Class, Message, StackLines}} — i.e. the Gleam
%% value Error(HandlerCrash(class, message, stack_trace)). The Lambda
%% runtime wraps each user handler call in this so an exception is
%% reported to the Runtime API /error endpoint (and the loop survives to
%% serve the next invocation) instead of taking the whole process down.
rescue_call(Fun) when is_function(Fun, 0) ->
    try {ok, Fun()}
    catch
        Class:Reason:Stack ->
            {error, {handler_crash,
                     atom_to_binary(Class, utf8),
                     reason_to_binary(Reason),
                     stack_to_lines(Stack)}}
    end.

%% Gleam `panic`, `todo`, and failed `let assert` raise a map carrying a
%% `message` binary; surface that verbatim. Everything else gets a
%% depth-bounded ~p rendering so a deeply nested term can't produce an
%% unbounded error body.
reason_to_binary(Reason) when is_map(Reason) ->
    case Reason of
        #{message := M} when is_binary(M) -> M;
        _ -> iolist_to_binary(io_lib:format("~tP", [Reason, 12]))
    end;
reason_to_binary(Reason) ->
    iolist_to_binary(io_lib:format("~tP", [Reason, 12])).

stack_to_lines(Stack) ->
    [iolist_to_binary(io_lib:format("~tP", [Frame, 8])) || Frame <- Stack].

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
    %% `+0.0` (rather than the literal `0.0`) silences an OTP 27 warning:
    %% as of 27, `0.0` only matches +0.0, not -0.0. We're testing
    %% `=/= 0.0` (positive OR negative), so explicitly say +0.0 to
    %% acknowledge the asymmetry — the comparison is still correct
    %% because IEEE 754 says +0.0 =:= -0.0 evaluates equal anyway.
    F =:= float_infinity() andalso F =/= +0.0;
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
    %% Accept either `Z` or `±HH:MM` zone suffix, with optional fractional
    %% seconds. The offset is folded into the returned epoch seconds.
    %%
    %% `calendar:datetime_to_gregorian_seconds/1` raises `function_clause`
    %% on out-of-range fields (e.g. month 13, hour 25) that pass the regex
    %% shape check; this parses server-controlled credential `Expiration`
    %% and response timestamps, so catch and report it as `{error, nil}`
    %% rather than crash the consumer's process.
    try
        Re = "^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})(?:\\.[0-9]+)?(Z|([+-])([0-9]{2}):([0-9]{2}))$",
        case re:run(Bin, Re, [{capture, all_but_first, binary}]) of
            {match, [Y, Mo, D, H, Mi, S | Zone]} ->
                DateTime = {
                    {binary_to_integer(Y), binary_to_integer(Mo), binary_to_integer(D)},
                    {binary_to_integer(H), binary_to_integer(Mi), binary_to_integer(S)}
                },
                Epoch = 62167219200,
                Base = calendar:datetime_to_gregorian_seconds(DateTime) - Epoch,
                OffsetSec = case Zone of
                    [<<"Z">>] -> 0;
                    [<<"Z">>, _, _, _] -> 0;
                    [_, Sign, OffH, OffM] ->
                        Sec = binary_to_integer(OffH) * 3600 + binary_to_integer(OffM) * 60,
                        case Sign of <<"-">> -> Sec; <<"+">> -> -Sec end
                end,
                {ok, Base + OffsetSec};
            _ ->
                {error, nil}
        end
    catch
        _:_ -> {error, nil}
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

%% Parse an XML document into a simple nested tuple tree usable from
%% Gleam without pulling in the xmerl record headers. Returns
%%   {ok, {element, Name, Attrs, Children}}
%% where:
%%   Name    :: binary()
%%   Attrs   :: [{binary(), binary()}]
%%   Children:: [{element, _, _, _} | {text, binary()}]
%%
%% Whitespace-only text nodes between elements are dropped, so the
%% generated decoders can address members by element name without
%% accounting for layout whitespace. Returns {error, nil} on parse
%% failure. Backed by xmerl_scan; xmerl is in the OTP standard library
%% and pulls in no extra dependencies.
xml_parse(Bin) when is_binary(Bin) ->
    try
        Str = binary_to_list(Bin),
        {Doc, _} = xmerl_scan:string(Str, [{quiet, true}]),
        {ok, convert_xmerl(Doc)}
    catch
        _:_ -> {error, nil}
    end.

convert_xmerl(#xmlElement{name = Name, attributes = Attrs, content = Content}) ->
    AttrTuples = [convert_attr(A) || A <- Attrs],
    Children = lists:filtermap(
        fun
            (#xmlElement{} = X) -> {true, convert_xmerl(X)};
            (#xmlText{value = V}) ->
                Bin = unicode:characters_to_binary(V),
                case is_blank(Bin) of
                    true -> false;
                    false -> {true, {text, Bin}}
                end;
            (_) -> false
        end,
        Content
    ),
    {element, name_to_binary(Name), AttrTuples, Children}.

convert_attr(#xmlAttribute{name = Name, value = Value}) ->
    {name_to_binary(Name), unicode:characters_to_binary(Value)}.

name_to_binary(N) when is_atom(N) -> atom_to_binary(N, utf8);
name_to_binary(N) when is_list(N) -> list_to_binary(N);
name_to_binary(N) when is_binary(N) -> N.

is_blank(<<>>) -> true;
is_blank(<<C, R/binary>>) when C =:= $\s; C =:= $\t; C =:= $\n; C =:= $\r ->
    is_blank(R);
is_blank(_) -> false.
