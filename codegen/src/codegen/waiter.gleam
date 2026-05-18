//// Per-op waiter emitter for `smithy.waiters#waitable`.
////
//// Each waiter in the trait emits one `wait_until_<snake_name>`
//// Gleam function. The function takes a client + the operation's
//// typed input + `max_attempts`, then delegates to the
//// `aws/waiter.wait` polling helper. The step closure invokes the
//// underlying op, pattern-matches the result against the
//// configured acceptors, and returns
//// `Settled` / `Continue` / `FailedNow` per the matched acceptor.
////
//// v1 covers the `success: true|false` and `errorType: "..."`
//// matchers — together they account for `BucketExists`,
//// `TableNotExists`, `FunctionExists`, etc. JMESPath matchers
//// (`output`, `inputOutput`, `outputCount`, `errorContains`) are
//// dropped at trait-parse time so the generator never sees them.
////
//// Emitted AST shape:
////
////   pub fn wait_until_<w>(client, input, max_attempts) ->
////       Result(Nil, waiter.WaiterError(<Op>Error)) {
////     waiter.wait(
////       step: fn(_attempt) {
////         case <op>(client, input) {
////           Ok(_) -> <step from success-matcher acceptor>
////           Error(e) -> case e {
////             <Op>Error<X>(_) -> <step from errorType-X acceptor>
////             _ -> waiter.Continue
////           }
////         }
////       },
////       max_attempts: max_attempts,
////       min_delay_ms: <from trait>,
////       max_delay_ms: <from trait>,
////     )
////   }

import codegen/code.{
  type Code, Blank, Block, Branch, Call, Case, CodeSome, Fn, Ident, IntLit,
  Labelled, Module, Param,
}
import codegen/trait_helpers.{
  type WaiterAcceptor, type WaiterDef, MatchErrorType, MatchSuccess,
  WaiterAcceptor, WaiterDef, WaiterFailure, WaiterRetry, WaiterSuccess,
}
import gleam/list
import gleam/set.{type Set}
import gleam/string
import internal/stringutils

/// One-shot emission of every waiter on a single operation. Empty
/// when the op has no `@waitable` trait (or every waiter on it had
/// an unsupported matcher and was dropped at extraction time).
///
/// `known_error_locals` is the set of error-shape local names the
/// op explicitly declared (Smithy `errors:`). The emitter uses it
/// to decide whether an `errorType: "X"` acceptor matches a typed
/// variant (`<Op>ErrorX(_)`) or falls through to the catch-all
/// `<Op>ErrorUnknown(error_type: "X", ..)`. Without this check,
/// the emitter could reference a variant that doesn't exist —
/// AWS waiter traits routinely name error types the operation
/// doesn't carry in its declared `errors:` list.
pub fn emit(
  op_snake op_snake: String,
  input_type input_type: String,
  error_type error_type: String,
  waiters waiters: List(WaiterDef),
  known_error_locals known_error_locals: Set(String),
) -> String {
  case waiters {
    [] -> ""
    _ ->
      waiters
      |> list.map(fn(w) {
        code.render(
          Module(items: [
            render(
              op_snake: op_snake,
              input_type: input_type,
              error_type: error_type,
              error_prefix: error_type,
              waiter: w,
              known_error_locals: known_error_locals,
            ),
            Blank,
          ]),
        )
      })
      |> string.concat
  }
}

/// Render one waiter — `pub fn wait_until_<snake>(client, input,
/// max_attempts)`. `error_prefix` is the `<Op>Error` string used
/// to prepend the matched errorType local name (so
/// `errorType: "NotFound"` becomes the variant pattern
/// `BucketExistsError... NotFound(_)`, depending on the operation
/// the waiter belongs to — for `HeadBucket.BucketExists` it's
/// `HeadBucketErrorNotFound(_)`).
pub fn render(
  op_snake op_snake: String,
  input_type input_type: String,
  error_type error_type: String,
  error_prefix error_prefix: String,
  waiter waiter: WaiterDef,
  known_error_locals known_error_locals: Set(String),
) -> Code {
  let WaiterDef(
    name: name,
    acceptors: acceptors,
    min_delay_ms: min_delay,
    max_delay_ms: max_delay,
  ) = waiter
  let snake = stringutils.pascal_to_snake(name)
  let return_type =
    string.concat(["Result(Nil, waiter.WaiterError(", error_type, "))"])
  Fn(
    public: True,
    name: string.concat(["wait_until_", snake]),
    params: [
      Param(name: "client", type_: "Client"),
      Param(name: "input", type_: input_type),
      Param(name: "max_attempts", type_: "Int"),
    ],
    return: CodeSome(return_type),
    body: Block(items: [
      Call(head: Ident(name: "waiter.wait"), args: [
        Labelled(
          label: "step",
          value: step_closure(
            op_snake,
            error_prefix,
            acceptors,
            known_error_locals,
          ),
        ),
        Labelled(label: "max_attempts", value: Ident(name: "max_attempts")),
        Labelled(label: "min_delay_ms", value: IntLit(value: min_delay)),
        Labelled(label: "max_delay_ms", value: IntLit(value: max_delay)),
      ]),
    ]),
  )
}

/// `fn(_attempt) { case <op>(client, input) { ... } }` — invokes
/// the op and dispatches on result.
fn step_closure(
  op_snake: String,
  error_prefix: String,
  acceptors: List(WaiterAcceptor),
  known_error_locals: Set(String),
) -> Code {
  let ok_step = first_ok_step(acceptors)
  let error_inner_case =
    error_inner_case(error_prefix, acceptors, known_error_locals)
  let dispatch =
    Case(
      scrutinee: Call(head: Ident(name: op_snake), args: [
        Ident(name: "client"),
        Ident(name: "input"),
      ]),
      branches: [
        Branch(pattern: "Ok(_)", body: ok_step),
        Branch(pattern: "Error(e)", body: error_inner_case),
      ],
    )
  code.Lambda(params: ["_attempt"], body: Block(items: [dispatch]))
}

/// Step to take when the operation returned `Ok(_)`. First
/// `success: true` matcher wins, mapping the acceptor's state to
/// the right step expression.
fn first_ok_step(acceptors: List(WaiterAcceptor)) -> Code {
  case
    list.find(acceptors, fn(a) {
      case a {
        WaiterAcceptor(matcher: MatchSuccess(value: True), ..) -> True
        _ -> False
      }
    })
  {
    Ok(WaiterAcceptor(state: WaiterSuccess, ..)) ->
      Ident(name: "waiter.Settled")
    // `state: failure` paired with `success: true` doesn't appear in
    // any real-world AWS waiter (verified against
    // vendor/aws-sdk-rust/aws-models); treat as the safe default
    // `Continue` if it ever shows up, letting the wait time out
    // rather than crash.
    Ok(_) -> Ident(name: "waiter.Continue")
    Error(_) -> Ident(name: "waiter.Continue")
  }
}

/// Inner `case e { <Op>Error<X>(_) -> <step>, _ -> Continue }`.
/// Synthesises one branch per `errorType` matcher in the acceptor
/// list; the catch-all is always `Continue` so unanticipated error
/// types simply keep polling.
///
/// When the acceptor names an `errorType` the operation doesn't
/// declare in its `errors:` list, the typed variant doesn't exist
/// — we fall through to the `<Op>ErrorUnknown(error_type: "<X>",
/// ..)` catch-all variant, which carries the wire `error_type` and
/// is present on every typed-error sum the codegen emits.
fn error_inner_case(
  error_prefix: String,
  acceptors: List(WaiterAcceptor),
  known_error_locals: Set(String),
) -> Code {
  let typed_branches =
    list.filter_map(acceptors, fn(a) {
      case a {
        WaiterAcceptor(state: s, matcher: MatchErrorType(local: t)) -> {
          let pattern = case set.contains(known_error_locals, t) {
            True -> string.concat([error_prefix, t, "(_)"])
            False ->
              string.concat([
                error_prefix,
                "Unknown(error_type: \"",
                t,
                "\", ..)",
              ])
          }
          Ok(Branch(pattern: pattern, body: step_for_error_state(s)))
        }
        _ -> Error(Nil)
      }
    })
  let default_branch =
    Branch(pattern: "_", body: Ident(name: "waiter.Continue"))
  Case(
    scrutinee: Ident(name: "e"),
    branches: list.append(typed_branches, [default_branch]),
  )
}

/// Step expression for an `Error` branch given an acceptor state.
/// `Failure` propagates the typed error via `waiter.FailedNow(e)`
/// — `e` is the outer-case binding from `Error(e)`.
fn step_for_error_state(state: trait_helpers.WaiterState) -> Code {
  case state {
    WaiterSuccess -> Ident(name: "waiter.Settled")
    WaiterFailure ->
      Call(head: Ident(name: "waiter.FailedNow"), args: [Ident(name: "e")])
    WaiterRetry -> Ident(name: "waiter.Continue")
  }
}
