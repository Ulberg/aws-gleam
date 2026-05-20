//// Regression for the codegen-emitted `parse_<op>_event` decoders.
//// Builds a synthetic raw event-stream frame against
//// `aws/services/transcribe_streaming` (restJson1's flagship
//// event-stream op) and verifies the parser dispatches on the
//// `:event-type` header into the matching typed variant.

import aws/internal/codec/event_stream
import aws/services/transcribe_streaming as ts
import gleam/option.{None, Some}
import gleeunit/should

fn evt(event_type: String, payload: BitArray) -> event_stream.Event {
  event_stream.Event(
    headers: [
      event_stream.Header(
        name: ":message-type",
        value: event_stream.StringValue("event"),
      ),
      event_stream.Header(
        name: ":event-type",
        value: event_stream.StringValue(event_type),
      ),
    ],
    payload: payload,
  )
}

pub fn parses_transcript_event_into_typed_variant_test() {
  // TranscriptEvent payload is `{"Transcript": null}` (every nested
  // field is optional; we don't need real content to verify the
  // dispatch + variant constructor).
  let event = evt("TranscriptEvent", <<"{\"Transcript\":null}":utf8>>)
  case ts.parse_start_stream_transcription_event(event) {
    Ok(ts.TranscriptResultStreamTranscriptEvent(te)) -> {
      te.transcript |> should.equal(None)
    }
    other -> {
      let _ = other
      should.fail()
    }
  }
}

pub fn parses_bad_request_exception_into_typed_variant_test() {
  let event =
    evt(
      "BadRequestException",
      <<"{\"Message\":\"oops\"}":utf8>>,
    )
  case ts.parse_start_stream_transcription_event(event) {
    Ok(ts.TranscriptResultStreamBadRequestException(e)) -> {
      e.message |> should.equal(Some("oops"))
    }
    other -> {
      let _ = other
      should.fail()
    }
  }
}

pub fn unknown_event_type_returns_typed_error_test() {
  let event = evt("FutureEvent", <<"{}":utf8>>)
  case ts.parse_start_stream_transcription_event(event) {
    Error(reason) -> {
      case reason {
        "unknown :event-type: FutureEvent" -> Nil
        _ -> should.fail()
      }
    }
    Ok(_) -> should.fail()
  }
}

pub fn missing_event_type_header_returns_typed_error_test() {
  let event =
    event_stream.Event(
      headers: [
        event_stream.Header(
          name: ":message-type",
          value: event_stream.StringValue("event"),
        ),
      ],
      payload: <<"{}":utf8>>,
    )
  case ts.parse_start_stream_transcription_event(event) {
    Error(reason) -> {
      case reason {
        "missing :event-type header" -> Nil
        _ -> should.fail()
      }
    }
    Ok(_) -> should.fail()
  }
}
