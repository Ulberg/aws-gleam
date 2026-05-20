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

# `docker buildx` doesn't allocate a TTY; on OTP 27+ the kernel
# tries to attach the `user` IO process and crashes with
# `failed_to_start_child,user,nouser`. `-noinput` skips the
# attach. Implies -noshell. Safe for compile-time `gleam build`
# / `gleam export` which never read stdin.
ENV ERL_AFLAGS="-noinput"

RUN gleam deps download \
    && bash -c '(cd .. && ./scripts/regen.sh s3 sqs)' \
    && gleam export erlang-shipment \
    && mv build/erlang-shipment /app \
    && rm -rf /build

WORKDIR /app

# Headroom for the BEAM atom table. With only s3 + sqs generated,
# the actual count is comfortably under 1 M, but raising the cap
# costs nothing and keeps the door open for `KEEP_SERVICES`-style
# expansion later.
ENV ERL_FLAGS="+t 4194304"

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
