//// `aws_codegen` entry point. Run as:
////
////   gleam run -m aws_codegen -- <protocol> <input.json> <output.gleam>
////     [--dispatcher-out <dispatchers.gleam>]
////
//// Example for the protocol-test corpus:
////
////   gleam run -m aws_codegen -- awsJson1_0 \
////     ../test/fixtures/protocol-tests/awsJson1_0.json \
////     ../src/aws/services/protocoltests/json10.gleam \
////     --dispatcher-out ../test/protocol_tests/awsjson10_dispatchers.gleam
////
//// The optional `--dispatcher-out` arg replaces what
//// `scripts/emit-dispatchers.py` used to do via regex-scraping the
//// generated module — see `codegen/dispatcher.gleam`.

import argv
import codegen/awsjson
import codegen/awsquery
import codegen/dispatcher
import codegen/restjson
import codegen/restxml
import gleam/dict
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile
import smithy/model
import smithy/shape
import smithy/shape_id.{ShapeId}

pub fn main() {
  let args = argv.load().arguments
  case parse_args(args) {
    Ok(parsed) ->
      run(parsed.proto_name, parsed.in_path, parsed.out_path, parsed.disp_out)
    Error(msg) -> {
      io.println("error: " <> msg)
      io.println(
        "usage: gleam run -m aws_codegen -- <protocol> <input.json> <output.gleam> [--dispatcher-out <path>]",
      )
    }
  }
}

type ParsedArgs {
  ParsedArgs(
    proto_name: String,
    in_path: String,
    out_path: String,
    disp_out: Option(String),
  )
}

fn parse_args(args: List(String)) -> Result(ParsedArgs, String) {
  let #(positional, disp_out) = extract_dispatcher_flag(args, [], None)
  case list.reverse(positional) {
    [proto_name, in_path, out_path] ->
      Ok(ParsedArgs(proto_name, in_path, out_path, disp_out))
    _ ->
      Error("expected 3 positional args (protocol, input.json, output.gleam)")
  }
}

fn extract_dispatcher_flag(
  remaining: List(String),
  positional: List(String),
  disp_out: Option(String),
) -> #(List(String), Option(String)) {
  case remaining {
    [] -> #(positional, disp_out)
    ["--dispatcher-out", path, ..rest] ->
      extract_dispatcher_flag(rest, positional, Some(path))
    [arg, ..rest] ->
      case string.split_once(arg, "=") {
        Ok(#("--dispatcher-out", path)) ->
          extract_dispatcher_flag(rest, positional, Some(path))
        _ -> extract_dispatcher_flag(rest, [arg, ..positional], disp_out)
      }
  }
}

fn run(
  proto_name: String,
  in_path: String,
  out_path: String,
  disp_out: Option(String),
) -> Nil {
  let result = {
    use text <- result.try(
      simplifile.read(in_path)
      |> result.replace_error("cannot read " <> in_path),
    )
    use m <- result.try(
      json.parse(text, model.decoder())
      |> result.replace_error("cannot parse Smithy AST"),
    )
    use svc_id <- result.try(find_service(m, proto_name))
    use emitted <- result.try(emit(m, svc_id, proto_name))
    use _ <- result.try(
      simplifile.write(out_path, emitted.source)
      |> result.replace_error("cannot write " <> out_path),
    )
    use _ <- result.try(maybe_write_dispatcher(
      disp_out,
      svc_id,
      out_path,
      emitted.dispatcher_specs,
    ))
    Ok(emitted.operations_emitted)
  }
  case result {
    Ok(ops) -> {
      io.println(
        "wrote "
        <> out_path
        <> " ("
        <> int.to_string(list.length(ops))
        <> " operations: "
        <> string.join(ops, ", ")
        <> ")",
      )
    }
    Error(reason) -> io.println("error: " <> reason)
  }
}

type Emitted {
  Emitted(
    source: String,
    operations_emitted: List(String),
    dispatcher_specs: List(dispatcher.DispatcherSpec),
  )
}

fn emit(
  m: model.Model,
  svc_id: String,
  proto_name: String,
) -> Result(Emitted, String) {
  case proto_name {
    "awsJson1_0" -> {
      use r <- result.try(awsjson.emit_service(m, svc_id, awsjson.AwsJson10))
      Ok(Emitted(r.source, r.operations_emitted, r.dispatcher_specs))
    }
    "awsJson1_1" -> {
      use r <- result.try(awsjson.emit_service(m, svc_id, awsjson.AwsJson11))
      Ok(Emitted(r.source, r.operations_emitted, r.dispatcher_specs))
    }
    "restJson1" -> {
      use r <- result.try(restjson.emit_service(m, svc_id))
      Ok(Emitted(r.source, r.operations_emitted, r.dispatcher_specs))
    }
    "restXml" -> {
      use r <- result.try(restxml.emit_service(m, svc_id))
      Ok(Emitted(r.source, r.operations_emitted, r.dispatcher_specs))
    }
    "awsQuery" -> {
      use r <- result.try(awsquery.emit_service(m, svc_id, awsquery.AwsQuery))
      Ok(Emitted(r.source, r.operations_emitted, r.dispatcher_specs))
    }
    "ec2Query" -> {
      use r <- result.try(awsquery.emit_service(m, svc_id, awsquery.Ec2Query))
      Ok(Emitted(r.source, r.operations_emitted, r.dispatcher_specs))
    }
    other -> Error("unsupported protocol: " <> other)
  }
}

/// Write a `<protocol>_dispatchers.gleam` for protocol-test models.
/// `disp_out` is the absolute / relative path the CLI was given;
/// `out_path` is where the service module was written — its trailing
/// suffix gives us the Gleam-import path the dispatcher will use as
/// `import <module> as svc`.
fn maybe_write_dispatcher(
  disp_out: Option(String),
  svc_id: String,
  svc_out_path: String,
  specs: List(dispatcher.DispatcherSpec),
) -> Result(Nil, String) {
  case disp_out {
    None -> Ok(Nil)
    Some(path) -> {
      use namespace <- result.try(dispatcher.namespace_of(svc_id))
      use label <- result.try(dispatcher.label_for_namespace(namespace))
      let service_module = derive_service_module_path(svc_out_path)
      let source = dispatcher.render(label, service_module, specs)
      simplifile.write(path, source)
      |> result.replace_error("cannot write " <> path)
    }
  }
}

/// `../src/aws/services/protocoltests/json10.gleam` →
/// `aws/services/protocoltests/json10`. The codegen always writes
/// service modules under `src/...`, so we look for that segment and
/// take everything after it. Falls back to the basename when the
/// pattern doesn't match — produces invalid Gleam, but the error is
/// visible immediately on compile.
fn derive_service_module_path(out_path: String) -> String {
  let trimmed = case string.ends_with(out_path, ".gleam") {
    True -> string.drop_end(out_path, 6)
    False -> out_path
  }
  case string.split_once(trimmed, "/src/") {
    Ok(#(_, rest)) -> rest
    Error(_) ->
      case string.split_once(trimmed, "src/") {
        Ok(#(_, rest)) -> rest
        Error(_) -> trimmed
      }
  }
}

/// Find the (unique) `service` shape that carries the matching protocol
/// trait.
fn find_service(m: model.Model, proto_name: String) -> Result(String, String) {
  let trait_id = case proto_name {
    "awsJson1_0" -> ShapeId("aws.protocols#awsJson1_0")
    "awsJson1_1" -> ShapeId("aws.protocols#awsJson1_1")
    "restJson1" -> ShapeId("aws.protocols#restJson1")
    "restXml" -> ShapeId("aws.protocols#restXml")
    "awsQuery" -> ShapeId("aws.protocols#awsQuery")
    "ec2Query" -> ShapeId("aws.protocols#ec2Query")
    _ -> ShapeId("")
  }
  let candidates =
    dict.to_list(m.shapes)
    |> list.filter_map(fn(pair) {
      let #(id, sh) = pair
      case sh {
        shape.Service(traits: t, ..) ->
          case dict.has_key(t, trait_id) {
            True -> Ok(shape_id.to_string(id))
            False -> Error(Nil)
          }
        _ -> Error(Nil)
      }
    })
  // Pick the service with the most operations — for protocol-test
  // corpora this avoids tiny "query-compat" test services taking
  // precedence over the canonical one. Real AWS service models have
  // exactly one service shape per file so it's a no-op there.
  let with_op_counts =
    list.map(candidates, fn(id) {
      case model.lookup(m, id) {
        Ok(shape.Service(operations: ops, ..)) -> #(id, list.length(ops))
        _ -> #(id, 0)
      }
    })
  case with_op_counts {
    [] -> Error("no service has trait " <> shape_id.to_string(trait_id))
    [#(id, _)] -> Ok(id)
    multiple ->
      multiple
      |> list.fold(#("", -1), fn(best, pair) {
        let #(_, best_count) = best
        let #(_, this_count) = pair
        case this_count > best_count {
          True -> pair
          False -> best
        }
      })
      |> fn(p: #(String, Int)) { Ok(p.0) }
  }
}
