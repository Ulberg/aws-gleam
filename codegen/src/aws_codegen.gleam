//// `aws_codegen` entry point. Run as:
////
////   gleam run -m aws_codegen -- <protocol> <input.json> <output.gleam>
////
//// Example for the protocol-test corpus:
////
////   gleam run -m aws_codegen -- awsJson1_0 \
////     ../test/fixtures/protocol-tests/awsJson1_0.json \
////     ../src/aws/services/protocoltests/json10.gleam

import argv
import codegen/awsjson
import codegen/awsquery
import codegen/restjson
import codegen/restxml
import gleam/dict
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import simplifile
import smithy/model
import smithy/shape
import smithy/shape_id.{ShapeId}

pub fn main() {
  case argv.load().arguments {
    [proto_name, in_path, out_path] -> run(proto_name, in_path, out_path)
    _ -> {
      io.println(
        "usage: gleam run -m aws_codegen -- <protocol> <input.json> <output.gleam>",
      )
      io.println("supported protocols: awsJson1_0, awsJson1_1")
    }
  }
}

fn run(proto_name: String, in_path: String, out_path: String) -> Nil {
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
    use #(source, ops) <- result.try(emit(m, svc_id, proto_name))
    use _ <- result.try(
      simplifile.write(out_path, source)
      |> result.replace_error("cannot write " <> out_path),
    )
    Ok(ops)
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

fn emit(
  m: model.Model,
  svc_id: String,
  proto_name: String,
) -> Result(#(String, List(String)), String) {
  case proto_name {
    "awsJson1_0" -> {
      use r <- result.try(awsjson.emit_service(m, svc_id, awsjson.AwsJson10))
      Ok(#(r.source, r.operations_emitted))
    }
    "awsJson1_1" -> {
      use r <- result.try(awsjson.emit_service(m, svc_id, awsjson.AwsJson11))
      Ok(#(r.source, r.operations_emitted))
    }
    "restJson1" -> {
      use r <- result.try(restjson.emit_service(m, svc_id))
      Ok(#(r.source, r.operations_emitted))
    }
    "restXml" -> {
      use r <- result.try(restxml.emit_service(m, svc_id))
      Ok(#(r.source, r.operations_emitted))
    }
    "awsQuery" -> {
      use r <- result.try(awsquery.emit_service(m, svc_id, awsquery.AwsQuery))
      Ok(#(r.source, r.operations_emitted))
    }
    "ec2Query" -> {
      use r <- result.try(awsquery.emit_service(m, svc_id, awsquery.Ec2Query))
      Ok(#(r.source, r.operations_emitted))
    }
    other -> Error("unsupported protocol: " <> other)
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
