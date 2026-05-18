#!/usr/bin/env bash
# Run `gleam test` with the BEAM atom-table bumped to 4M. Generating
# all ~409 AWS services creates several million atoms across the
# generated source (type names, function names, record field labels,
# etc.) which blows past Erlang's default 1M-atom ceiling. Without
# `+t 4194304` the BEAM crashes mid-compile with
# `no more index entries in atom_tab`.
#
# Pass any additional flags through to `gleam test` — e.g.
# `scripts/test.sh --include live` to opt into the live AWS suite.

set -euo pipefail

cd "$(dirname "$0")/.."

export ERL_FLAGS="${ERL_FLAGS:-+t 4194304}"

exec gleam test "$@"
