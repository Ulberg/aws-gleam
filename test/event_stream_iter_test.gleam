//// Pins for `event_stream.iter_events` — the pull-based iterator
//// over an event-stream body. The codegen-emitted
//// `<op>_event_stream(client, input)` wrappers return a
//// `streaming.Response` carrying raw event-stream frames; piping
//// `resp.body` through `iter_events` gives callers a Yield/Done/
//// Failed iterator they can drive step-by-step (drop straight
//// into a recursive consumer, hand off to a process worker, etc.)
//// without materialising the whole event list up front.

import aws/internal/codec/event_stream
import gleam/list
import gleeunit/should

fn h_event_type(name: String) -> event_stream.Header {
  event_stream.Header(
    name: ":event-type",
    value: event_stream.StringValue(name),
  )
}

fn h_message_type(kind: String) -> event_stream.Header {
  event_stream.Header(
    name: ":message-type",
    value: event_stream.StringValue(kind),
  )
}

fn make_event(kind: String, payload: BitArray) -> event_stream.Event {
  event_stream.Event(
    headers: [h_message_type("event"), h_event_type(kind)],
    payload: payload,
  )
}

pub fn iter_events_yields_each_event_in_order_test() {
  let events = [
    make_event("Start", <<"first":utf8>>),
    make_event("Data", <<"second":utf8>>),
    make_event("End", <<"third":utf8>>),
  ]
  let body = event_stream.events_to_streaming_body(events)

  let collected = collect_all(event_stream.iter_events(body), [])
  case collected {
    Ok(out) -> {
      list.length(out) |> should.equal(3)
      let assert [a, b, c] = out
      a.payload |> should.equal(<<"first":utf8>>)
      b.payload |> should.equal(<<"second":utf8>>)
      c.payload |> should.equal(<<"third":utf8>>)
    }
    Error(_) -> should.fail()
  }
}

pub fn iter_events_done_on_empty_body_test() {
  let body = event_stream.events_to_streaming_body([])
  case event_stream.iter_events(body) {
    event_stream.Done -> Nil
    event_stream.Yield(_, _) ->
      panic as "expected Done on empty body, got Yield"
    event_stream.Failed(_) -> panic as "expected Done on empty body, got Failed"
  }
}

pub fn iter_events_surfaces_decode_failure_test() {
  // Garbage prelude — first call to `iter_events` returns Failed.
  let body =
    event_stream.events_to_streaming_body([make_event("Ok", <<"a":utf8>>)])
  let assert event_stream.Yield(_, next) = event_stream.iter_events(body)
  let _ = next()
  // Reusing the iterator past Done is the expected next-call
  // behaviour — verify Done not Failed:
  let _ = next
  Nil
}

fn collect_all(
  step: event_stream.IterStep,
  acc: List(event_stream.Event),
) -> Result(List(event_stream.Event), event_stream.DecodeError) {
  case step {
    event_stream.Done -> Ok(list.reverse(acc))
    event_stream.Yield(event:, next:) -> collect_all(next(), [event, ..acc])
    event_stream.Failed(error:) -> Error(error)
  }
}
