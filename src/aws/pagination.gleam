//// Fold-style paginator helper for Smithy `@paginated` operations.
////
//// The codegen-emitted `paginate_<op>` functions are thin wrappers
//// over `fold`. Each generated paginator:
////
////   1. Builds a `step(cursor) -> Result(#(items, next_cursor), e)`
////      closure that injects the cursor into the typed input via
////      the `inputToken` field, invokes the operation, and projects
////      the `items` + `outputToken` fields out of the typed output.
////   2. Calls `fold(acc, step, reducer)` to drive the loop until
////      the step returns `None` for the next cursor.
////
//// The helper deliberately doesn't depend on `gleam_yielder` or any
//// lazy-stream package: a fold over a typed accumulator handles
//// every paginated-list use case (count, collect, find-first, ...)
//// without forcing a runtime dependency or special evaluation
//// strategy.

import gleam/option.{type Option, None, Some}
import gleam/result

/// Drive a Smithy `@paginated` operation to completion, folding each
/// page's items into `acc` via `reducer`. The `step` closure receives
/// the cursor returned by the previous page (or `None` on the first
/// call) and must return `#(items, next_cursor)` for the page it just
/// fetched. The loop stops when `step` returns `None` for the
/// next-cursor — the canonical Smithy signal that pagination is
/// exhausted. Errors from `step` propagate verbatim.
///
/// `cursor` is parametric: most AWS services use `String` (`NextToken`,
/// `Marker`, ...) but some carry richer values (DynamoDB's
/// `LastEvaluatedKey` is a `Dict(String, AttributeValue)`). The helper
/// stays agnostic — the codegen-emitted `paginate_<op>` wrapper
/// instantiates `cursor` to match the operation's input/output token
/// types.
pub fn fold(
  acc acc: a,
  step step: fn(Option(cursor)) -> Result(#(List(item), Option(cursor)), error),
  reducer reducer: fn(a, List(item)) -> a,
) -> Result(a, error) {
  loop(acc, None, step, reducer)
}

fn loop(
  acc: a,
  token: Option(cursor),
  step: fn(Option(cursor)) -> Result(#(List(item), Option(cursor)), error),
  reducer: fn(a, List(item)) -> a,
) -> Result(a, error) {
  use #(items, next) <- result.try(step(token))
  let acc = reducer(acc, items)
  case next {
    None -> Ok(acc)
    Some(_) -> loop(acc, next, step, reducer)
  }
}
