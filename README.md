# aws

Native Gleam AWS SDK targeting Erlang. Pre-v0.1; not published.

See [docs/v0.1-plan.md](docs/v0.1-plan.md) for the milestone plan.

## Status

Pre-M1 in progress. The SigV4 module compiles but is not yet verified
against the AWS test suite — the vector-driven test runner has not been
written yet. See the plan for the M1 gate.

## Building

Requires Gleam and Erlang/OTP.

```
gleam deps download
gleam build
gleam test
```

## Test fixtures

`test/fixtures/aws-c-auth/tests/aws-sig-v4-test-suite/v4/` is a vendored
copy of the v4 header-signing cases from
[awslabs/aws-c-auth](https://github.com/awslabs/aws-c-auth) (the
`aws-signing-test-suite` directory). Query-string presigning vectors
are present in the case folders but not yet exercised.

The pre-existing `test/fixtures/protocol-tests` symlink (to a Mac-local
path) and the orphan submodule pointer at `test/fixtures/aws-c-auth/`
have been removed; M5 will reintroduce protocol-tests as a proper
git submodule.
