//// Shared paginator emitter for Smithy `@paginated` operations.
////
//// Each of the per-protocol emitters extracts the trait, resolves
//// the cursor / items field snake-names against the typed
//// input / output members, and calls `render` to produce the
//// `paginate_<op>` function body. The function is a thin wrapper
//// over `aws/pagination.fold` — it builds the per-page step
//// closure, then delegates the loop.
////
//// The trait carries Smithy member names (`NextToken`,
//// `LastEvaluatedTableName`, ...); the codegen maps those to the
//// snake_case record fields the typed input / output records
//// expose, so the emitted source references real Gleam
//// identifiers, not wire names.

import codegen/code.{
  type Code, Blank, Block, Branch, Call, Case, CodeNone, CodeSome, Fn, Ident,
  Labelled, Let, ListLit, Module, Param, RecordUpdate,
}
import codegen/trait_helpers.{type PaginatedTrait, PaginatedTrait}
import codegen/types.{type MemberDef, RList}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

/// Snake-cased Gleam field references + item type resolved from the
/// `@paginated` trait against the typed input + output members.
/// The codegen builds one of these per paginated operation and
/// passes it into `render` to produce the `paginate_<op>` function.
pub type PaginationInfo {
  PaginationInfo(
    input_token_snake: String,
    output_token_snake: String,
    items_snake: String,
    item_gleam_type: String,
    /// `True` when the input struct has exactly one member (the
    /// cursor itself). Used by `render` to pick between
    /// record-creation (`Input(cursor: c)`) and record-update
    /// (`Input(..input, cursor: c)`) syntax — the latter is what
    /// Gleam warns about as "Redundant record update" when there's
    /// nothing else to preserve.
    single_field_input: Bool,
  )
}

/// Resolve a `@paginated` trait against the typed input + output
/// member lists. Returns `None` when:
///   * the input trait is `None` (the operation isn't paginated), or
///   * the trait names a field the generator doesn't surface (e.g.
///     an `inputToken` on a member that isn't on the actual input
///     struct, or an `items` member whose target isn't a list).
/// Defensive: a misconfigured trait must NOT crash the emitter —
/// we just skip the paginator for that op.
pub fn info_for(
  members_in members_in: List(MemberDef),
  members_out members_out: List(MemberDef),
  trait trait: Option(PaginatedTrait),
) -> Option(PaginationInfo) {
  case trait {
    None -> None
    Some(PaginatedTrait(
      input_token: it,
      output_token: ot,
      items: i,
      page_size: _,
    )) ->
      case
        find_snake(members_in, it),
        find_snake(members_out, ot),
        find_list_member(members_out, i)
      {
        Some(in_snake), Some(out_snake), Some(#(items_snake, items_type)) ->
          Some(PaginationInfo(
            input_token_snake: in_snake,
            output_token_snake: out_snake,
            items_snake: items_snake,
            item_gleam_type: items_type,
            single_field_input: list.length(members_in) == 1,
          ))
        _, _, _ -> None
      }
  }
}

fn find_snake(members: List(MemberDef), member_name: String) -> Option(String) {
  case list.find(members, fn(m) { m.member_name == member_name }) {
    Ok(m) -> Some(m.snake_name)
    Error(_) -> None
  }
}

fn find_list_member(
  members: List(MemberDef),
  member_name: String,
) -> Option(#(String, String)) {
  case list.find(members, fn(m) { m.member_name == member_name }) {
    Ok(m) ->
      case m.target {
        RList(element: e, ..) -> Some(#(m.snake_name, types.gleam_type(e)))
        _ -> None
      }
    Error(_) -> None
  }
}


/// One-shot string emission for the per-protocol emitters: if
/// `info` is `Some(_)`, render the `paginate_<op>` function (with a
/// trailing blank line so it lays out cleanly inside the generated
/// module); if `None`, return the empty string. Lets the three
/// emitters call a single helper instead of each branching on the
/// `Option(PaginationInfo)` themselves.
pub fn emit(
  snake snake: String,
  input_type input_type: String,
  error_type error_type: String,
  info info: Option(PaginationInfo),
) -> String {
  case info {
    None -> ""
    Some(i) ->
      code.render(
        Module(items: [
          render(
            snake: snake,
            input_type: input_type,
            error_type: error_type,
            info: i,
          ),
          Blank,
        ]),
      )
  }
}

/// Render the `pub fn paginate_<op>(...)` function for a single
/// paginated operation. The caller is responsible for emitting it
/// only when `info_for` returned `Some(_)` — see `emit` for the
/// `Option`-handling wrapper.
pub fn render(
  snake snake: String,
  input_type input_type: String,
  error_type error_type: String,
  info info: PaginationInfo,
) -> Code {
  let PaginationInfo(
    input_token_snake: it,
    output_token_snake: ot,
    items_snake: is,
    item_gleam_type: item_type,
    single_field_input: single,
  ) = info
  let return_type = string.concat(["Result(acc, ", error_type, ")"])
  let reducer_type = string.concat(["fn(acc, List(", item_type, ")) -> acc"])
  Fn(
    public: True,
    name: string.concat(["paginate_", snake]),
    params: [
      Param(name: "client", type_: "Client"),
      Param(name: "input", type_: input_type),
      Param(name: "acc", type_: "acc"),
      Param(name: "reducer", type_: reducer_type),
    ],
    return: CodeSome(return_type),
    body: Block(items: [
      Let(
        name: "step",
        value: step_closure(snake, input_type, it, ot, is, single),
      ),
      Call(head: Ident(name: "pagination.fold"), args: [
        Labelled(label: "acc", value: Ident(name: "acc")),
        Labelled(label: "step", value: Ident(name: "step")),
        Labelled(label: "reducer", value: Ident(name: "reducer")),
      ]),
    ]),
  )
}

/// `fn(cursor) { let input = ...; case <op>(client, input) { ... } }`
/// — the inner closure passed to `pagination.fold`. Pure AST: no
/// string templates, so a future reader sees the actual control
/// flow rather than reconstructing it from a `Raw` blob.
fn step_closure(
  snake: String,
  input_type: String,
  input_token_field: String,
  output_token_field: String,
  items_field: String,
  single_field_input: Bool,
) -> Code {
  // When the input has additional members beyond the cursor, use
  // record-update syntax to preserve their user-set values. When
  // the cursor is the only member, Gleam warns about the
  // `..input` as redundant — fall back to record-creation in that
  // case. Both forms produce identical runtime behaviour.
  let cursored_input = case single_field_input {
    True ->
      Call(head: Ident(name: input_type), args: [
        Labelled(label: input_token_field, value: Ident(name: "cursor")),
      ])
    False ->
      RecordUpdate(
        record: Ident(name: "input"),
        type_: input_type,
        fields: [
          Labelled(label: input_token_field, value: Ident(name: "cursor")),
        ],
      )
  }
  let input_with_cursor =
    Let(
      name: "input",
      value: Case(
        scrutinee: Ident(name: "cursor"),
        branches: [
          Branch(pattern: "option.Some(_)", body: cursored_input),
          Branch(pattern: "option.None", body: Ident(name: "input")),
        ],
      ),
    )
  let project_ok =
    Call(head: Ident(name: "Ok"), args: [
      Call(head: Ident(name: "#"), args: [
        Call(head: Ident(name: "option.unwrap"), args: [
          Ident(name: string.concat(["out.", items_field])),
          ListLit(items: [], tail: CodeNone),
        ]),
        Ident(name: string.concat(["out.", output_token_field])),
      ]),
    ])
  let dispatch =
    Case(
      scrutinee: Call(head: Ident(name: snake), args: [
        Ident(name: "client"),
        Ident(name: "input"),
      ]),
      branches: [
        Branch(pattern: "Ok(out)", body: project_ok),
        Branch(
          pattern: "Error(e)",
          body: Call(head: Ident(name: "Error"), args: [Ident(name: "e")]),
        ),
      ],
    )
  code.Lambda(
    params: ["cursor"],
    body: Block(items: [input_with_cursor, dispatch]),
  )
}
