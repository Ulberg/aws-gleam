//// Unit tests for the `pagination.fold` helper.
////
//// The codegen-emitted `paginate_<op>` functions are thin wrappers
//// over this helper — they pass in a `step` closure that calls the
//// underlying typed operation, threads the cursor through, and
//// projects the items field out of the response. These tests
//// exercise the helper in isolation so a regression here surfaces
//// without having to drive a full HTTP transport.

import aws/pagination
import gleam/list
import gleam/option.{None, Some}
import gleeunit/should

pub fn fold_single_page_test() {
  let pages = [#(["a", "b", "c"], None)]
  let result =
    pagination.fold(
      acc: [],
      step: lookup_step(pages),
      reducer: fn(acc, items) { list.append(acc, items) },
    )
  result |> should.equal(Ok(["a", "b", "c"]))
}

pub fn fold_multi_page_advances_cursor_test() {
  let pages = [
    #(["a", "b"], Some("cursor-1")),
    #(["c", "d"], Some("cursor-2")),
    #(["e"], None),
  ]
  let result =
    pagination.fold(
      acc: [],
      step: lookup_step(pages),
      reducer: fn(acc, items) { list.append(acc, items) },
    )
  result |> should.equal(Ok(["a", "b", "c", "d", "e"]))
}

pub fn fold_propagates_step_error_test() {
  let result =
    pagination.fold(
      acc: 0,
      step: fn(_token) { Error("boom") },
      reducer: fn(acc, _items: List(Int)) { acc + 1 },
    )
  result |> should.equal(Error("boom"))
}

pub fn fold_zero_pages_returns_initial_acc_test() {
  // The helper always calls `step` at least once (the first request
  // has no cursor). An empty first page with no next-cursor still
  // exits cleanly.
  let result =
    pagination.fold(
      acc: 42,
      step: fn(_token) { Ok(#([], None)) },
      reducer: fn(acc, items: List(String)) { acc + list.length(items) },
    )
  result |> should.equal(Ok(42))
}

/// Build a `step` closure that returns pages from a fixed list,
/// threading the cursor through the (current, next) tuple. The
/// first call sees `None`; subsequent calls receive the previous
/// page's next-cursor and the helper drives them in order.
fn lookup_step(
  pages: List(#(List(String), option.Option(String))),
) -> fn(option.Option(String)) ->
  Result(#(List(String), option.Option(String)), String) {
  fn(token: option.Option(String)) {
    case token, pages {
      None, [first, ..] -> Ok(first)
      None, [] -> Error("no pages")
      Some(t), _ ->
        case
          list.drop_while(pages, fn(p) {
            case p.1 {
              Some(c) -> c != t
              None -> True
            }
          })
        {
          [_, next, ..] -> Ok(next)
          _ -> Error("unexpected end")
        }
    }
  }
}
