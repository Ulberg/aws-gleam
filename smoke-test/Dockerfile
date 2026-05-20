# Multi-stage Lambda container image for the aws-gleam smoke test.
#
# Stage 1 (`builder`) installs Gleam on top of erlang:27, copies the
# repo in, regenerates the SDK services, and runs
# `gleam export erlang-shipment` so the BEAM bytecode is produced
# with the same OTP version that will run it. Skipping this step
# (i.e. compiling on the host and copying the shipment in) gives
# `undef` errors at boot when the host's OTP version differs from
# the image's, because BEAM bytecode is not fully cross-OTP-version
# compatible.
#
# Stage 2 (the runtime image) starts fresh from erlang:27-slim and
# copies just the slimmed shipment over. Lambda accepts any
# container image whose entrypoint polls the Runtime API, which our
# Gleam handler does via runtime_api.gleam.

FROM erlang:27 AS builder

# --- Install Gleam ---
ARG GLEAM_VERSION=1.7.0
RUN curl -fsSL "https://github.com/gleam-lang/gleam/releases/download/v${GLEAM_VERSION}/gleam-v${GLEAM_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
      | tar xz -C /usr/local/bin gleam \
    && chmod +x /usr/local/bin/gleam

# --- Build the shipment ---
WORKDIR /build

# Bring the SDK in so the smoke test's `aws = { path = "../" }`
# dep resolves. The .dockerignore keeps the build context tight.
COPY . /build/aws-gleam/

WORKDIR /build/aws-gleam/smoke-test

# `regen.sh` produces src/aws/services/<service>.gleam from the
# Smithy models bundled under vendor/. `+t` lifts the BEAM atom
# table for the 409-service codegen.
ENV ERL_FLAGS="+t 4194304"
RUN gleam deps download
RUN ( cd .. && ./scripts/regen.sh )
RUN gleam export erlang-shipment

# Slim — drop service beams the smoke test doesn't use + compile-
# time-only Erlang record headers.
ARG KEEP_SERVICES="s3 sqs"
RUN set -eu \
    && rm -rf build/erlang-shipment/aws/include \
    && KEEP_ALT=$(echo "$KEEP_SERVICES" | tr ' ' '|') \
    && find build/erlang-shipment/aws/ebin -name 'aws@services@*.beam' \
        -not -regex ".*aws@services@\\($KEEP_ALT\\)\\.beam" -delete

# --- Runtime image ---
FROM erlang:27-slim

WORKDIR /var/task
COPY --from=builder /build/aws-gleam/smoke-test/build/erlang-shipment/ /var/task/

# Atom-table headroom (the slim step trims to s3 + sqs; this is
# defense-in-depth in case anyone bumps KEEP_SERVICES).
ENV ERL_FLAGS="+t 16777216"

ENTRYPOINT ["/var/task/entrypoint.sh", "run"]
