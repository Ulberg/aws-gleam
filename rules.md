# Rules for working on this repo

These are non-negotiable operational rules for any agent (human or AI)
working on this codebase. They exist because each one was learned the
hard way — most recently, a session where stale `gleam run -m
aws_codegen` instances accumulated and ate ~9% of system memory each
for hours.

## Process hygiene — don't kill the machine

### Never run `./scripts/regen.sh` more than once concurrently

`regen.sh` invokes `gleam run -m aws_codegen` six times in series. Each
invocation spawns a fresh `beam.smp` (~700 MB resident). If a second
`regen.sh` launches while the first is mid-flight, both fight over the
same Smithy CLI lockfile and the same output paths, and neither
terminates cleanly. Result: orphan `beam.smp` processes that linger
until `pkill -9`.

**Before launching `regen.sh`:**

```sh
pgrep -af 'regen.sh|aws_codegen|beam.smp' | head
```

If anything matches, kill it (or wait), don't fire a second one.

### Don't `run_in_background: true` for long-running codegen

The Bash-tool `run_in_background` flag is for commands you can
genuinely afford to forget about (a build whose log you'll grep later).
`regen.sh` is **not** that — it can take 60–120 s, holds a Smithy CLI
lock, and the output matters. Run it foreground or use a single
`Monitor` tail. If you do background it, **always `pkill` before
re-launching** so a stale instance can't outlive its parent shell.

### No retry-on-failure loops without an exit condition

If a command fails, debug it before re-running. A loop like
`while true; do ./scripts/regen.sh; done` will pile up Erlang VMs in
seconds. Same for sleep-poll-retry shells. Use `Monitor` with an
explicit `until <check>; do sleep N; done` predicate so the loop has a
defined termination, not a wall-clock cap.

### Memory budget per launched process

If a command is expected to use >1 GB resident, it gets one launch per
session unless you've already killed prior instances. This includes:

  - `gleam test` (full pass uses ~1.5 GB peak)
  - `gleam run -m aws_codegen` (~700 MB per invocation × 6 in `regen.sh`)
  - `gleam build` from a cold cache (~800 MB)
  - The Smithy CLI (`smithy ast …`) (~1 GB)

### Spawned-shell discipline

When the user notices "is the shell that's running abandoned?" — the
answer is almost certainly yes, and the answer is `pkill -9`. There is
no scenario in this repo where leaving a `gleam` / `beam.smp` /
`aws_codegen` process hanging is the right thing. Reap immediately
when you notice one.

## Codegen workflow — fast path

For interactive iteration on the codegen, **don't run `regen.sh`** —
it builds protocol-test ASTs (Smithy CLI, slow) + endpoint fixtures +
six codegen targets + a full `gleam format` pass. That's 1–2 minutes
per cycle.

Instead, run the single target you're iterating on:

```sh
cd codegen
gleam run -m aws_codegen -- restXml \
  ../test/fixtures/protocol-tests/restXml.json \
  ../src/aws/services/protocoltests/restxml.gleam \
  --dispatcher-out ../test/protocol_tests/restxml_dispatchers.gleam
cd ..
gleam format src/aws/services/protocoltests/restxml.gleam \
             test/protocol_tests/restxml_dispatchers.gleam
gleam test
```

Use `./scripts/regen.sh` only when (a) the Smithy fixtures or the
vendor models changed, or (b) you're verifying a fresh-clone build
before pushing.

## Plan.md is a planning artefact, not a contract

`plan.md` was written at a specific point in time. The codegen has
moved since then — any inventory in the plan ("here are the remaining
string concats", "here is the per-op LOC", etc.) is stale the moment
the next pass lands. When picking up a pass, **regrep the repo** for
the actual current state before working from the plan's snapshot.

Specifically for **Pass 7** (kill string concats): the inventory in
plan.md lists call sites as they existed before Passes 2–6 landed. The
real set is whatever `grep -rn '"\n' codegen/src/codegen` returns at
the time you start. Don't blindly chase the plan's list.
