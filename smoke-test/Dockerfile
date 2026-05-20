# AWS Lambda container image for the aws-gleam smoke test.
#
# Lambda's `provided.al2023` base ships no language runtime — just
# the AL2023 OS + the runtime interface — so the OTP-release zip
# approach fails with `exec: erl: not found` at cold start. The
# container-image deploy fixes that by bundling Erlang/OTP inside
# the image.
#
# We use the official `erlang:27-slim` debian-slim image rather than
# layering Erlang onto `public.ecr.aws/lambda/provided:al2023` —
# Lambda accepts any container image as long as the entrypoint
# polls the Runtime API, which our Gleam handler already does
# (see `src/runtime_api.gleam`).
#
# Build with `./build.sh` (which also handles the ECR push +
# `tofu apply`); locally you can `docker run -it <tag> /bin/sh` to
# poke around.

FROM erlang:27-slim

# Lambda mounts /tmp as the only writeable directory at runtime;
# everything under /var/task is read-only. Put the OTP release there
# so file paths match the zip-deploy convention `LAMBDA_TASK_ROOT`
# points at.
WORKDIR /var/task

# Copy the `gleam export erlang-shipment` output: one `<dep>/ebin/`
# directory per Gleam dependency plus the entrypoint script that
# boots the BEAM with all of them on the code path.
COPY build/erlang-shipment/ /var/task/

# Generating ~409 SDK service modules at compile time pushes past
# Erlang's default 1M-atom ceiling. The slim step in `build.sh`
# trims to KEEP_SERVICES so the runtime atom count is well below
# this in practice, but the headroom is cheap.
ENV ERL_FLAGS="+t 16777216"

# `entrypoint.sh run` runs `exec erl -pa ./*/ebin -eval
# 'aws_gleam_smoke@@main:run(aws_gleam_smoke)'`, which enters
# `aws_gleam_smoke:main/0` and from there the Lambda Runtime API
# polling loop in runtime_api.gleam. The `run` argument's positional
# tail is irrelevant — Lambda's container-image contract passes the
# handler name as $1, which our dispatch (via `SMOKE_ROLE` env var)
# ignores.
ENTRYPOINT ["/var/task/entrypoint.sh", "run"]
