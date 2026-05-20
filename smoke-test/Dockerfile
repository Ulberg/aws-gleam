# Lambda container image for the aws-gleam smoke test.
#
# Mirrors the shiny_hunter pattern: use the official Gleam image
# (`ghcr.io/gleam-lang/gleam:VERSION-erlang-alpine`), which ships
# Gleam + a matching Erlang/OTP. Compiling and running in the same
# image guarantees the BEAM bytecode targets the OTP version that
# runs it — without that pairing the BEAM rejects modules with
# `undef`.
#
# Single-stage on purpose: leaves the Gleam binary in the runtime
# image (~30 MB cost) so the image rebuilds and runs without any
# multi-stage glue. Lambda's pull cost amortises across cold starts;
# the simplicity wins here.

FROM ghcr.io/gleam-lang/gleam:v1.16.0-erlang-alpine

# --- Bring the repo in and build the shipment ---
#
# Docker build context is the REPO ROOT (set by smoke-test/build.sh:
# `docker buildx build ... ../`), so we get the full SDK tree under
# /build/aws-gleam/ alongside the smoke-test project itself.
COPY . /build/aws-gleam/

WORKDIR /build/aws-gleam/smoke-test

# `+t` lifts the BEAM atom-table ceiling for the SDK's 409-service
# codegen run.
ENV ERL_FLAGS="+t 4194304"

# Build dependencies of `./scripts/regen.sh`. The script is a bash
# shell pipeline; alpine ships `ash` as /bin/sh, so we need bash + the
# usual coreutils for `find -regex` etc.
RUN apk add --no-cache bash coreutils findutils grep sed

# 1. Resolve Gleam deps (incl. the path dep to ../).
# 2. Regenerate the per-service SDK code from the Smithy models.
# 3. `gleam export erlang-shipment` produces a self-contained OTP
#    release under build/erlang-shipment/. Compiled here against
#    THIS image's OTP, so it'll load cleanly at runtime.
RUN gleam deps download \
    && bash -c '(cd .. && ./scripts/regen.sh)' \
    && gleam export erlang-shipment \
    && mv build/erlang-shipment /app

# Slim the shipment: drop service beams the smoke test doesn't use
# + compile-time-only Erlang record headers. KEEP_SERVICES is a
# space-separated list set via --build-arg from build.sh.
ARG KEEP_SERVICES="s3 sqs"
RUN set -eu \
    && rm -rf /app/aws/include \
    && KEEP_ALT=$(echo "$KEEP_SERVICES" | tr ' ' '|') \
    && find /app/aws/ebin -name 'aws@services@*.beam' \
        -not -regex ".*aws@services@\\($KEEP_ALT\\)\\.beam" -delete \
    && rm -rf /build

# --- Runtime ---
WORKDIR /app

# Runtime atom-table — the slim step trims to KEEP_SERVICES so the
# real allocation is well below this in practice; cheap headroom.
ENV ERL_FLAGS="+t 16777216"

# `entrypoint.sh run` boots the BEAM with the OTP release's ebin/
# dirs on the code path and calls `aws_gleam_smoke@@main:run/1`,
# which enters the Lambda Runtime API polling loop implemented in
# runtime_api.gleam.
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
