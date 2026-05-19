---
active: true
iteration: 683
session_id: 7c901b96-6013-4dd6-846d-ce92bcb60d82
max_iterations: 0
completion_promise: null
started_at: "2026-05-18T19:57:55Z"
---
We're picking up an in-progress AWS SDK for Gleam, branch feat/all-services (PR #8).
  The project root is here; CLAUDE.md carries all conventions — Erlang target only, OTP-
  native, typed AST over string concats, gleam format after every edit. Read it before
  making decisions.

  ## Current state

  - git status shows ~13 modified + ~5 untracked files. These are *tested and green*
    but uncommitted because the prior machine's SSH signing agent was locked. First job
    is to flush them as logical commits, then push to origin feat/all-services.
  - ./scripts/test.sh should report 306 passed, no failures in the main suite, plus
    the protocol-test corpus with fail=0 across all eight protocols (awsJson1_0/1,
    restJson1, restXml, restXmlWithNamespace, awsQuery, ec2Query, rpcv2Cbor).
  - ERL_FLAGS="+t 4194304" is set inside scripts/test.sh to lift Erlang's 1M-atom
    ceiling — the 409 generated services together allocate several million atoms. Don't
    remove it.

  ## What's already landed in the uncommitted working tree

  Commit each as its own commit, in this order, before doing anything else:

  1. **M12 part 1 — CBOR codec**: src/aws/internal/codec/cbor.gleam + test/cbor_test.gleam
     (16 round-trip tests from RFC 8949 App. A; canonical bytewise key sort).
  2. **M13 part 1 — StreamingBody type**: src/aws/streaming.gleam + test/streaming_test.gleam.
     v1 is buffered-only; the API is the forward-compatible shape for a future chunked
     transport.
  3. **M18 — algorithm-member dispatch for aws.protocols#httpChecksum**:
     src/aws/internal/codec/rest.gleam (checksum_algorithm_from_wire +
     with_checksum_header_for_wire), codegen/src/codegen/rest_request.gleam
     (build_checksum_step helper), test/checksum_header_test.gleam, plus end-to-end
     test/http_checksum_smoke_test.gleam using s3.put_bucket_accelerate_configuration.
  4. **M12 part 2 — rpcv2Cbor protocol emitter**:
     codegen/src/codegen/cbor_rpc.gleam (new), codegen/src/codegen/dispatcher.gleam
     (new is_error_shape field on DispatcherSpec + error-shape build_request body
     that returns Error), the four other protocol emitters' DispatcherSpec
     constructors updated to pass is_error_shape: False,
     codegen/src/aws_codegen.gleam (rpcv2Cbor arm in emit and find_service),
     scripts/regen.sh (rpcv2Cbor codegen line),
     test/protocol_tests_test.gleam (rpcv2cbor dispatcher import + run_with), and
     the generated test/protocol_tests/rpcv2cbor_dispatchers.gleam. Flips
     [rpcv2Cbor] from 0/4 to 4/4 passing.
  5. .claude/ralph-loop.local.md — shell-safe rewrite of the loop prompt.

  After each commit, ./scripts/test.sh must still pass. After commit 4 push to
  origin feat/all-services. Use gh pr view 8 for PR context.

  ## Goal (don't deviate)

  streaming HTTP send+recv transport, event streams, S3 transfer manager, HTTP/2,
  codegen-side opt-in to the precise Timestamp type (the json_timestamp.Timestamp
  type with seconds+nanos already exists; the codegen still emits Int), plus any
  restJson1 edge cases that surface as the suite grows. SigV4a, rpcv2Cbor (4/4),
  multi-algorithm checksum middleware, paginators, waiters, and presigned URLs are
  already done — see next_steps.md "DONE (2026-05-18)" markers for the trail.

  ## Discipline per iteration (non-negotiable)

  - Red → green → refactor. Write the failing test first, make it green, then run
    /simplify on the touched files and fix anything flagged.
  - Never remove a test to make the suite green.
  - Tests for everything new. Use the AWS test vectors at
    test/fixtures/aws-c-auth/tests/aws-sig-v4-test-suite/ for SigV4 work and the
    Smithy corpus at test/fixtures/protocol-tests/ for codec work.
  - gleam format after every edit. The CI step checks formatting on
    src/aws/services and test/protocol_tests so the generated output has to
    format-clean from the codegen too.
  - Typed AST over string concats — see codegen/src/codegen/code.gleam and the
    existing emitters for the pattern.

  ## Known blockers / pitfalls

  - 1Password SSH-signing agent: if ssh-add -l returns "no identities" the user
    needs to unlock the 1Password app (Settings → Developer → "Use the SSH agent").
    CLAUDE.md forbids --no-verify / --no-gpg-sign — never bypass.
  - The CLAUDE.md references graphify MCP servers (graph-aws-sdk-rust etc.). They
    may not be configured on this machine. If an MCP query fails, fall back to
    reading vendor/aws-sdk-rust/ directly — the repo is vendored locally.
  - Generated services are not in git. ./scripts/regen.sh rebuilds them; it takes
    bare name (body not _body).

  ## First action

  1. ssh-add -l — confirm the agent has identities. If not, flag it and continue
     on non-commit work.
  2. ./scripts/test.sh — confirm 306 passing.
  3. Commit the five chunks above in order, push when (4) lands.
  4. Pick up M13 part 2 (codegen-side @streaming blob opt-in to StreamingBody)
     as the next chunk — src/aws/streaming.gleam is the runtime side already in
     place; the codegen-side flip is the next move. There are 31 services with
     @streaming blob shapes (`grep -l 'smithy.api#streaming'
     vendor/aws-sdk-rust/aws-models/*.json`). The protocol-test corpus already
     dispatches StreamingTraits / HttpPayloadTraits ops so a type-level flip
     that keeps wire bytes identical should stay green.

  Keep going. Don't pause iterations waiting for me — flag blockers, work around
  them, leave a clear note for me to resolve.

Remember use /simplify  and use /ralph-loop:ralph-loop
