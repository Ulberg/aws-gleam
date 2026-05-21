%% Codegen-side Erlang FFI.
%%
%% Smithy 2.0 model JSON encodes structure / union / intEnum / enum
%% members as a JSON object keyed by member name. OTP's json:decode/1
%% loses key insertion order (Erlang maps are unordered, and the
%% built-in JSON decoder sorts by binary comparison). Several
%% protocols — awsQuery, ec2Query, restXml — require the wire
%% serialization to follow the *declared* member order from the
%% Smithy model. This module re-walks the raw model JSON through
%% json:decode/3 with order-preserving callbacks, then returns a
%% `#{ShapeId => [MemberName]}` map the Gleam codegen can consult.

-module(aws_codegen_ffi).
-export([extract_member_orders/1]).

%% Returns `#{<<"namespace#Name">> => [<<"Member1">>, <<"Member2">>, ...]}`
%% for every shape in the model that has a `members` field. Shapes
%% without members (simple shapes, services, operations, etc.) are
%% omitted.
extract_member_orders(JsonBinary) when is_binary(JsonBinary) ->
    Decs = #{
        object_start  => fun object_start/1,
        object_push   => fun object_push/3,
        object_finish => fun object_finish/2
    },
    {Decoded, _, _} = json:decode(JsonBinary, ok, Decs),
    case Decoded of
        {ordered, TopPairs} ->
            case lists:keyfind(<<"shapes">>, 1, TopPairs) of
                {_, {ordered, ShapePairs}} ->
                    lists:foldl(fun extract_one_shape/2, #{}, ShapePairs);
                _ ->
                    #{}
            end;
        _ ->
            #{}
    end.

object_start(Acc) ->
    {[], Acc}.

object_push(K, V, {Pairs, OldAcc}) ->
    {[{K, V} | Pairs], OldAcc}.

object_finish({Pairs, OldAcc}, _UpperAcc) ->
    {{ordered, lists:reverse(Pairs)}, OldAcc}.

extract_one_shape({ShapeId, {ordered, ShapeFields}}, Acc) when is_binary(ShapeId) ->
    case lists:keyfind(<<"members">>, 1, ShapeFields) of
        {_, {ordered, MemberPairs}} ->
            Names = [N || {N, _} <- MemberPairs],
            Acc#{ShapeId => Names};
        _ ->
            Acc
    end;
extract_one_shape(_, Acc) -> Acc.
