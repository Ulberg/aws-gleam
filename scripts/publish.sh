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

rewrite_aws_path_deps_to_hex() {
  # Hex publish rejects path deps. For the duration of the publish,
  # rewrite every `aws_gleam_<x> = { path = "..." }` line to a hex
  # version constraint pointed at the same $VERSION we're publishing
  # (lock-step versioning across the workspace). Stash the original
  # so we can restore it once the publish finishes — local dev
  # workflows (./scripts/test.sh) depend on the path deps.
  local toml="$1"
  cp "$toml" "$toml.unpublished"
  if [ -n "$VERSION" ]; then
    awk -v v="$VERSION" '
      /^aws_gleam_[a-z0-9_]+ *= *\{ *path *=/ {
        # Pull the package name (everything before the first space or =).
        match($0, /^aws_gleam_[a-z0-9_]+/)
        name = substr($0, RSTART, RLENGTH)
        print name " = \">= " v "\""
        next
      }
      { print }
    ' "$toml" > "$toml.tmp"
    mv "$toml.tmp" "$toml"
  fi
}

restore_path_deps() {
  # Undo rewrite_aws_path_deps_to_hex.
  local toml="$1"
  if [ -f "$toml.unpublished" ]; then
    mv "$toml.unpublished" "$toml"
  fi
}

publish_one() {
  local pkg_dir="$1"
  echo
  echo "→ $(basename "$pkg_dir") @ ${VERSION:-(current)}"
  # `trap` inside a subshell wires the restore for any exit path
  # (success, fail, ^C) so a failed publish doesn't leave the
  # gleam.toml on hex-style deps. Path-dep restore is a no-op for
  # the runtime package (no aws_gleam_* deps to rewrite).
  ( cd "$pkg_dir" \
    && set_version gleam.toml \
    && rewrite_aws_path_deps_to_hex gleam.toml \
    && trap "restore_path_deps '$pkg_dir/gleam.toml'" EXIT \
    && \
    # Force a fresh dep resolution. The previous local build left
    # build/packages/aws_gleam_runtime symlinked at the path dep;
    # after we rewrite the toml to a hex version, gleam needs to
    # fetch the package from hex but won't until manifest.toml + the
    # cached build/packages/ are gone.
    rm -rf build manifest.toml \
    && if [ "$DRY_RUN" -eq 1 ]; then
         # `gleam publish` doesn't ship a --dry-run flag yet.
         # Stand in with `gleam build` so we still surface any
         # compile / metadata errors that would block a real
         # publish — just without the upload step.
         gleam build 2>&1 | tail -5
         echo "(dry-run: skipped gleam publish)"
       else
         # Drive the interactive prompts non-interactively. The
         # first prompt (pre-1.0 versions only) wants the literal
         # 'I am not using semantic versioning'; the rest are y/n
         # confirmations. Feed a fixed-length sequence rather than
         # `yes y` — `yes` gets SIGPIPE'd when gleam closes stdin,
         # which `pipefail` propagates as a non-zero pipeline exit,
         # which `set -e` interprets as a loop-killing failure even
         # when the publish itself succeeded.
         #
         # 6 extra `y` lines is more than gleam currently asks for
         # — excess input is harmlessly discarded.
         printf 'I am not using semantic versioning\ny\ny\ny\ny\ny\ny\n' \
           | gleam publish --replace
       fi
  )
}

if [ "$WHAT" = "runtime" ] || [ "$WHAT" = "both" ]; then
  publish_one "$ROOT/runtime"
fi

if [ "$WHAT" = "services" ] || [ "$WHAT" = "both" ]; then
  # Curated set of services we publish to hex. The services/
  # directory contains more (regenerated for local test coverage)
  # but those aren't user-facing on hex. Add a name here when a
  # service has been validated as wanting a release.
  PUBLISHED_SERVICES="${PUBLISHED_SERVICES:-s3 sqs dynamodb rds sesv2}"
  for svc in $PUBLISHED_SERVICES; do
    pkg_dir="$ROOT/services/$svc"
    if [ ! -d "$pkg_dir" ]; then
      echo "warning: $pkg_dir missing; run ./scripts/regen.sh $svc first" >&2
      continue
    fi
    publish_one "$pkg_dir"
  done
fi

echo
echo "done."
