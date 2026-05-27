//// End-to-end test for the codegen-emitted `<op>_event_stream`
//// wrapper. Verifies the full pipeline through the typed API:
////
////   * Build a `StartStreamTranscriptionRequest` (input struct).
////   * Stub the streaming sender on the Client via the codegen-
////     emitted `with_streaming_http_send`.
////   * Have the stub return a `streaming.Response` whose body is
////     event-stream framed bytes (built via the
////     `event_stream.events_to_streaming_body` helper).
////   * Call `transcribe_streaming.start_stream_transcription_event_stream`
////     — the codegen-emitted wrapper that routes through
////     `runtime.invoke_streaming`.
////   * Decode the response body via `event_stream.fold_events` and
////     assert each event round-trips intact.
////
//// This closes the loop on the streaming codegen: the wrapper is
//// callable through the typed API, the wire body is framed bytes,
//// and the consumer-side decoder produces the events the server
//// sent. Real Transcribe responses carry `TranscriptResultStream`
//// union frames; this test uses simpler synthetic events so the
//// assertion can pin the round-trip without invoking the per-
//// event-union decoder (which is the next codegen pass).

import aws/config
import aws/credentials
import aws/internal/client/runtime
import aws/internal/codec/event_stream.{Event, Header, StringValue}
import aws/internal/http_send as aws_http
import aws/services/transcribe_streaming
import aws/streaming
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None, Some}
import gleeunit/should

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

/// Stub streaming sender that always returns the canned response —
/// drops the request entirely.
fn fixed_streaming_send(
  resp: Result(response.Response(streaming.StreamingBody), aws_http.HttpError),
) -> aws_http.StreamingSend {
  fn(_req: Request(BitArray)) { resp }
}

fn empty_request() -> transcribe_streaming.StartStreamTranscriptionRequest {
  transcribe_streaming.StartStreamTranscriptionRequest(
    audio_stream: None,
    content_identification_type: None,
    content_redaction_type: None,
    enable_channel_identification: None,
    enable_partial_results_stabilization: None,
    identify_language: None,
    identify_multiple_languages: None,
    language_code: None,
    language_model_name: None,
    language_options: None,
    media_encoding: None,
    media_sample_rate_hertz: None,
    number_of_channels: None,
    partial_results_stability: None,
    pii_entity_types: None,
    preferred_language: None,
    session_id: None,
    session_resume_window: None,
    show_speaker_label: None,
    vocabulary_filter_method: None,
    vocabulary_filter_name: None,
    vocabulary_filter_names: None,
    vocabulary_name: None,
    vocabulary_names: None,
  )
}

pub fn start_stream_transcription_event_stream_round_trips_frames_test() {
  // Three synthetic events: each is one StringValue header
  // (`:event-type`) + a small UTF-8 payload. Encoder + decoder
  // round-trip per the existing event_stream tests; this exercises
  // the same framing through the codegen-emitted wrapper.
  let events = [
    Event(
      headers: [
        Header(name: ":event-type", value: StringValue("TranscriptEvent")),
      ],
      payload: <<"transcript-1":utf8>>,
    ),
    Event(
      headers: [
        Header(name: ":event-type", value: StringValue("TranscriptEvent")),
      ],
      payload: <<"transcript-2":utf8>>,
    ),
    Event(
      headers: [
        Header(name: ":event-type", value: StringValue("TranscriptEvent")),
      ],
      payload: <<"transcript-3":utf8>>,
    ),
  ]
  let framed_body = event_stream.events_to_streaming_body(events)

  let streaming_send =
    fixed_streaming_send(
      Ok(response.Response(
        status: 200,
        headers: [
          #("content-type", "application/vnd.amazon.eventstream"),
        ],
        body: framed_body,
      )),
    )
  let assert Ok(client) =
    transcribe_streaming.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        streaming_http_send: Some(streaming_send),
      ),
      transcribe_streaming.default_endpoint_params(),
    )

  let assert Ok(resp) =
    transcribe_streaming.start_stream_transcription_event_stream(
      client,
      empty_request(),
    )
  resp.status |> should.equal(200)

  // Now decode the framed body — the round-trip pins both the
  // codegen wrapper's body-passthrough AND the event_stream
  // consumer-side decoder.
  let result =
    event_stream.fold_events(resp.body, [], fn(acc, e) { [e, ..acc] })
  case result {
    Ok(rev) -> rev |> list.reverse |> should.equal(events)
    Error(_) -> panic as "expected events to decode cleanly"
  }
  transcribe_streaming.shutdown(client)
}

pub fn start_stream_transcription_event_stream_surfaces_transport_error_test() {
  // Stubbed sender returns an HttpError; the codegen-emitted wrapper
  // must propagate it as `runtime.TransportError`, identical to the
  // streaming-blob `_streaming` path.
  let streaming_send = fixed_streaming_send(Error(aws_http.Timeout))
  let assert Ok(client) =
    transcribe_streaming.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        streaming_http_send: Some(streaming_send),
      ),
      transcribe_streaming.default_endpoint_params(),
    )

  case
    transcribe_streaming.start_stream_transcription_event_stream(
      client,
      empty_request(),
    )
  {
    Error(runtime.TransportError(_)) -> Nil
    other -> panic as { "expected TransportError, got: " <> describe(other) }
  }
  transcribe_streaming.shutdown(client)
}

fn describe(r: Result(streaming.Response, runtime.ClientError)) -> String {
  case r {
    Ok(_) -> "Ok(_)"
    Error(runtime.ServiceError(..)) -> "ServiceError(_)"
    Error(runtime.TransportError(_)) -> "TransportError(_)"
    Error(runtime.CredentialsError(_)) -> "CredentialsError(_)"
    Error(runtime.DecodeError(_)) -> "DecodeError(_)"
  }
}
