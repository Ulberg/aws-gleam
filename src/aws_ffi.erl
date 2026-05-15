-module(aws_ffi).
-export([sha256/1, hmac_sha256/2, hex_encode/1]).

sha256(Data) ->
    crypto:hash(sha256, Data).

hmac_sha256(Key, Data) ->
    crypto:mac(hmac, sha256, Key, Data).

hex_encode(Bin) ->
    binary:encode_hex(Bin, lowercase).
