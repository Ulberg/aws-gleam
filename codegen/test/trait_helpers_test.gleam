//// Tests for the `trait_helpers` Smithy-trait extractors. The
//// `paginated_trait` and `waitable_traits` helpers normalise a
//// raw `shape.Traits` dict into the typed records the emitters
//// consume; bugs here surface as silently-missing paginators /
//// waiters on real services. Each test exercises a small,
//// hand-built `Traits` dict so the parser path is decoupled from
//// any specific AWS model.

import codegen/trait_helpers.{
  MatchErrorType, MatchSuccess, PaginatedTrait, WaiterAcceptor, WaiterDef,
  WaiterFailure, WaiterRetry, WaiterSuccess,
}
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleeunit/should
import smithy/shape_id.{type ShapeId, ShapeId}
import smithy/trait

fn traits(
  entries: List(#(String, trait.Trait)),
) -> dict.Dict(ShapeId, option.Option(trait.Trait)) {
  dict.from_list(list.map(entries, fn(p) { #(ShapeId(p.0), Some(p.1)) }))
}

fn paginated_dict_value(
  input_token: String,
  output_token: String,
  items: String,
) -> trait.Trait {
  trait.Dict(
    dict.from_list([
      #(ShapeId("inputToken"), trait.String(input_token)),
      #(ShapeId("outputToken"), trait.String(output_token)),
      #(ShapeId("items"), trait.String(items)),
    ]),
  )
}

pub fn paginated_trait_extracts_required_fields_test() {
  let t =
    traits([
      #(
        "smithy.api#paginated",
        paginated_dict_value("NextToken", "NextToken", "Items"),
      ),
    ])
  trait_helpers.paginated_trait(t)
  |> should.equal(
    Some(PaginatedTrait(
      input_token: "NextToken",
      output_token: "NextToken",
      items: "Items",
      page_size: None,
    )),
  )
}

pub fn paginated_trait_picks_up_page_size_test() {
  let t =
    traits([
      #(
        "smithy.api#paginated",
        trait.Dict(
          dict.from_list([
            #(ShapeId("inputToken"), trait.String("Marker")),
            #(ShapeId("outputToken"), trait.String("NextMarker")),
            #(ShapeId("items"), trait.String("Buckets")),
            #(ShapeId("pageSize"), trait.String("MaxKeys")),
          ]),
        ),
      ),
    ])
  case trait_helpers.paginated_trait(t) {
    Some(PaginatedTrait(page_size: Some("MaxKeys"), ..)) -> Nil
    other -> {
      other |> should.equal(Some(PaginatedTrait(
        input_token: "Marker",
        output_token: "NextMarker",
        items: "Buckets",
        page_size: Some("MaxKeys"),
      )))
      Nil
    }
  }
}

pub fn paginated_trait_returns_none_when_required_fields_missing_test() {
  let t =
    traits([
      #(
        "smithy.api#paginated",
        trait.Dict(
          dict.from_list([
            #(ShapeId("inputToken"), trait.String("NextToken")),
          ]),
        ),
      ),
    ])
  trait_helpers.paginated_trait(t) |> should.equal(None)
}

pub fn paginated_trait_returns_none_when_absent_test() {
  let t = traits([])
  trait_helpers.paginated_trait(t) |> should.equal(None)
}

fn make_acceptor(state: String, matcher: trait.Trait) -> trait.Trait {
  trait.Dict(
    dict.from_list([
      #(ShapeId("state"), trait.String(state)),
      #(ShapeId("matcher"), matcher),
    ]),
  )
}

fn waitable_trait_value(
  name: String,
  acceptors: List(trait.Trait),
) -> trait.Trait {
  trait.Dict(
    dict.from_list([
      #(
        ShapeId(name),
        trait.Dict(
          dict.from_list([
            #(ShapeId("acceptors"), trait.List(acceptors)),
            #(ShapeId("minDelay"), trait.Int(5)),
            #(ShapeId("maxDelay"), trait.Int(120)),
          ]),
        ),
      ),
    ]),
  )
}

pub fn waitable_traits_parses_success_and_error_type_test() {
  let success_matcher =
    trait.Dict(dict.from_list([#(ShapeId("success"), trait.Bool(True))]))
  let not_found_matcher =
    trait.Dict(dict.from_list([
      #(ShapeId("errorType"), trait.String("NotFound")),
    ]))
  let t =
    traits([
      #(
        "smithy.waiters#waitable",
        waitable_trait_value("BucketExists", [
          make_acceptor("success", success_matcher),
          make_acceptor("retry", not_found_matcher),
        ]),
      ),
    ])
  trait_helpers.waitable_traits(t)
  |> should.equal([
    WaiterDef(
      name: "BucketExists",
      acceptors: [
        WaiterAcceptor(state: WaiterSuccess, matcher: MatchSuccess(value: True)),
        WaiterAcceptor(
          state: WaiterRetry,
          matcher: MatchErrorType(local: "NotFound"),
        ),
      ],
      min_delay_ms: 5000,
      max_delay_ms: 120_000,
    ),
  ])
}

pub fn waitable_traits_drops_waiter_with_unsupported_matcher_test() {
  // `output` is a JMESPath matcher — unsupported by the v1
  // codegen, so the entire waiter must be dropped rather than
  // partially emitted.
  let success_matcher =
    trait.Dict(dict.from_list([#(ShapeId("success"), trait.Bool(True))]))
  let output_matcher =
    trait.Dict(dict.from_list([
      #(
        ShapeId("output"),
        trait.Dict(dict.from_list([
          #(ShapeId("path"), trait.String("Status")),
        ])),
      ),
    ]))
  let t =
    traits([
      #(
        "smithy.waiters#waitable",
        waitable_trait_value("TableActive", [
          make_acceptor("success", success_matcher),
          make_acceptor("retry", output_matcher),
        ]),
      ),
    ])
  trait_helpers.waitable_traits(t) |> should.equal([])
}

pub fn waitable_traits_parses_failure_state_test() {
  let error_matcher =
    trait.Dict(dict.from_list([
      #(ShapeId("errorType"), trait.String("FatalError")),
    ]))
  let t =
    traits([
      #(
        "smithy.waiters#waitable",
        waitable_trait_value("OpDone", [
          make_acceptor("failure", error_matcher),
        ]),
      ),
    ])
  case trait_helpers.waitable_traits(t) {
    [WaiterDef(acceptors: [WaiterAcceptor(state: WaiterFailure, ..)], ..)] ->
      Nil
    other -> other |> should.equal([])
  }
}

pub fn waitable_traits_empty_when_absent_test() {
  trait_helpers.waitable_traits(traits([])) |> should.equal([])
}
