#!/usr/bin/env bash
# Run `gleam test` with the BEAM atom-table bumped. Generating all
# ~409 AWS services creates several million atoms across the
# generated source (type names, function names, record field labels,
# etc.) which blows past Erlang's default 1M-atom ceiling. Without
# `+t <large>` the BEAM crashes mid-compile with
# `no more index entries in atom_tab` (macOS prints the line; the
# Linux CI BEAM segfaults silently with the same root cause).
#
# 16M (16777216) is comfortable headroom — a recent local run uses
# ~2.4M atoms. ERL_AFLAGS is also exported so escripts spawned by
# `gleam` (Rust binary) inherit the bump even if they construct
# their `erl` argv from scratch — ERL_AFLAGS is *appended* by the
# emulator init and survives an explicit `-args_file`.
#
# Pass any additional flags through to `gleam test` — e.g.
# `scripts/test.sh --include live` to opt into the live AWS suite.

set -euo pipefail

cd "$(dirname "$0")/.."

# Always overwrite — CI's previous bump-attempts left a too-small
# value in the env and the `:-` default never fired. Idempotent
# locally either way.
export ERL_FLAGS="+t 16777216"
export ERL_AFLAGS="+t 16777216"

echo "test.sh: ERL_FLAGS=$ERL_FLAGS ERL_AFLAGS=$ERL_AFLAGS"

exec gleam test "$@"
