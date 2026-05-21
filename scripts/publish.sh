#!/usr/bin/env bash
# Publish aws_runtime + every services/<svc>/ to hex.pm.
#
# Usage:
#   ./scripts/publish.sh <version> [runtime|services|both]
#   ./scripts/publish.sh --dry-run [runtime|services|both]
#
# Examples:
#   ./scripts/publish.sh 0.2.0-rc.1
#   ./scripts/publish.sh --dry-run
#   ./scripts/publish.sh 0.2.0 services       # publish just the per-service packages
#
# Drives `gleam publish` from each package directory in dep order
# (runtime first so service packages can resolve it on hex during
# their own publish). The version override is wired by patching
# `gleam.toml`'s `version = "..."` line in-place; CI commits the
# patched gleam.toml back to the tagged ref via the workflow.
#
# Requires `HEXPM_API_KEY` in the environment when not dry-running.

set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

DRY_RUN=0
VERSION=""
WHAT="both"

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    runtime|services|both) WHAT="$1"; shift ;;
    *)
      if [ -z "$VERSION" ]; then
        VERSION="$1"
      else
        echo "unexpected argument: $1" >&2
        exit 2
      fi
      shift
      ;;
  esac
done

if [ "$DRY_RUN" -eq 0 ] && [ -z "$VERSION" ]; then
  echo "version required (or pass --dry-run)" >&2
  exit 2
fi
if [ "$DRY_RUN" -eq 0 ] && [ -z "${HEXPM_API_KEY:-}" ]; then
  echo "HEXPM_API_KEY env var required" >&2
  exit 2
fi

set_version() {
  # Replaces the `version = "..."` line in $1's gleam.toml with
  # the new $VERSION. Idempotent: if VERSION is empty (--dry-run
  # path with no override) this is a no-op.
  local toml="$1"
  if [ -n "$VERSION" ]; then
    # macOS BSD sed needs an empty `-i ''`; GNU sed accepts `-i`
    # alone. Workaround: tmp file shuffle so we don't depend on
    # platform.
    awk -v v="$VERSION" '/^version *= */ { print "version = \"" v "\""; next } { print }' "$toml" > "$toml.tmp"
    mv "$toml.tmp" "$toml"
  fi
}

publish_one() {
  local pkg_dir="$1"
  echo
  echo "→ $(basename "$pkg_dir") @ ${VERSION:-(current)}"
  ( cd "$pkg_dir" \
    && set_version gleam.toml \
    && if [ "$DRY_RUN" -eq 1 ]; then
         # `gleam publish` doesn't ship a --dry-run flag yet.
         # Stand in with `gleam build` so we still surface any
         # compile / metadata errors that would block a real
         # publish — just without the upload step.
         gleam build 2>&1 | tail -5
         echo "(dry-run: skipped gleam publish)"
       else
         # CI is non-interactive; `yes y` answers gleam's
         # confirmation prompts ("Continue?", "Publish?") until a
         # --no-confirm / --yes flag lands upstream.
         yes y | gleam publish --replace
       fi
  )
}

if [ "$WHAT" = "runtime" ] || [ "$WHAT" = "both" ]; then
  publish_one "$ROOT/runtime"
fi

if [ "$WHAT" = "services" ] || [ "$WHAT" = "both" ]; then
  # Sort so the publish order is deterministic; service packages
  # don't depend on each other so any order works.
  for svc_dir in $(ls -d "$ROOT"/services/*/ | sort); do
    publish_one "$svc_dir"
  done
fi

echo
echo "done."
