# Fargate container image for the aws-gleam smoke test.
#
# Mirrors the shiny_hunter pattern: use the official Gleam image
# (Gleam + matching Erlang/OTP), compile the OTP shipment, drop
# straight into the runtime. No multi-stage and no slim trick —
# Fargate's pull-once amortization makes image size much less
# important than for Lambda.

FROM ghcr.io/gleam-lang/gleam:v1.16.0-erlang-alpine

# Docker context = repo root (set by smoke-test/build.sh). Bring
# the entire SDK tree in so the smoke-test's `aws = { path = "../" }`
# dep resolves and `scripts/regen.sh` can read the Smithy models.
COPY . /build/aws-gleam/

WORKDIR /build/aws-gleam/smoke-test

# regen.sh is a bash pipeline; alpine ships ash as /bin/sh.
RUN apk add --no-cache bash coreutils findutils grep sed

# `+t` lifts the BEAM atom-table for the 409-service codegen run.
ENV ERL_FLAGS="+t 4194304"

RUN gleam deps download \
    && bash -c '(cd .. && ./scripts/regen.sh)' \
    && gleam export erlang-shipment \
    && mv build/erlang-shipment /app \
    && rm -rf /build

WORKDIR /app

# Same atom-table headroom at runtime — defense in depth in case
# of a future case where more services are loaded.
ENV ERL_FLAGS="+t 16777216"

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
