# CI Linux SIGSEGV — investigation summary

Status: **mitigated, not fixed.** CI runs on `macos-latest` where
the workspace builds cleanly. The Linux x86_64 failure remains
unresolved and is documented here for future work.

## Symptom

`gleam build` on `src/aws/` with 409 generated service modules in
one package, on Linux x86_64:

- Local colima x86_64 VM with 8 GB RAM: SIGKILL (exit 137) at peak
  memory around 7.5 GB. Classic OOM.
- GitHub Actions `ubuntu-latest` (4 vCPU, 16 GB): SIGSEGV (exit 139)
  at the same `Compiling aws` step, ~2 min in. strace captured
  `SIGSEGV {si_code=SEGV_ACCERR, si_addr=0x7fdf5bb4aec8}` —
  si_addr is in the pthread stack region.
- macOS local + macos-latest CI: builds cleanly.

The fact that more memory delays the failure and changes its shape
(OOM → SEGV_ACCERR) strongly suggests **memory pressure is the root
cause**, not stack overflow per se. The SEGV_ACCERR is the kernel
failing to map a stack guard page under heavy address-space pressure.

## What was tried in `fix/ci`

17 commits worth of probes documented in the branch history. None
fixed the underlying issue:

- OTP versions: 27.0, 27.3.4, 28.0, 28.0.4 — all SIGSEGV.
- BEAM flags: `+t 16M`, `+S 1/2:2`, `+sss 8192`, `+sssdcpu 8192`,
  `+sssdio 8192`, `+a 8192`, `+JMsingle true`, `+e 65536`,
  `+P 4194304` — applied as designed (verified via CI echo), no
  effect on the crash.
- OS-level: `ulimit -s 131072`, `ulimit -c unlimited`, `GLIBC_TUNABLES=
  glibc.pthread.stacksize=67108864` (and 256 MB). None of these
  reach BEAM scheduler threads (BEAM calls `pthread_create` with
  an explicit `pthread_attr_setstacksize`).
- Rust-side: `RUST_MIN_STACK=64M`, `RAYON_NUM_THREADS=1`,
  `TOKIO_WORKER_THREADS=1`. No effect.
- Runner image: ubuntu-22.04 and ubuntu-24.04 — both fail identically.

The dead-end conclusion: BEAM's compile pipeline has a memory-usage
profile that doesn't fit comfortably in 16 GB when given 400+ Gleam
modules in one package. No combination of BEAM tuning knobs makes
the peak fit.

## Current mitigation

CI runs on `macos-latest`, which builds the same workspace cleanly.
The codegen-output and build-artefact caches mean the slow regen +
compile only happens on a true cache miss (commits touching
`vendor/`, `codegen/`, `scripts/regen.sh` & friends, or hand-written
src/test code).

## What didn't work

Adding 8 GB swap to a Linux runner (commit `80cfbb4` on fix/ci) was
the cheapest first try after the colima OOM evidence. It did NOT
clear the SIGSEGV — same crash at the same 2:08 wall-clock mark.
So either:

- Peak memory exceeds 24 GB effective (16 RAM + 8 swap), OR
- Memory isn't the actual root cause and the colima OOM was a
  coincidence — both crashes happen at the point in the compile
  pipeline where the workspace would naturally peak on whatever
  resource the runner is short on

Going to a paid GHA larger-runner tier (32+ GB RAM) might clear it
but the org would have to enable that label and pay per-minute.
macOS works today, no extra setup, so we're routing there.

## Real fix: architectural split

The `aws` Gleam package currently contains 517 modules (409 generated
services + a few generated protocol-test surrogates + ~100 hand-
written runtime modules). One package = one BEAM-compile blast radius.

Split the 409 services into their own Gleam sub-package:

```
aws-gleam/
├── gleam.toml             # the main `aws` package
├── src/aws/               # hand-written runtime + the helpers callers actually use
├── test/                  # tests of the runtime
└── services/
    ├── gleam.toml         # `aws_services` package, depends on `aws` for runtime types
    └── src/aws_services/
        └── *.gleam        # the 409 generated services
```

Then the main `aws` package compile shrinks back to ~100 modules
and trivially fits in any runner. The `aws_services` package builds
separately and can be sharded across multiple jobs if its own peak
becomes a problem.

Cost: ~1-2 hours of focused work. Mostly an `import` path shuffle
in the codegen (`aws/services/*` → `aws_services/*`) and a one-line
path dependency in `gleam.toml`. Tests that reference services
(`service_smoke_test.gleam`, etc.) need their imports updated.

Benefit beyond CI: real callers consuming the SDK pay for compile
time of services they import, not all 409. A user who only needs
DynamoDB doesn't recompile S3 + 407 other services on every change
to their app.

## When to do this

When the cold-CI cost (or the swap-based mitigation breaking on a
runner-image change, or a developer running out of swap room locally)
becomes annoying enough. Not blocking anything today.

## Related Gleam issues

- gleam-lang/gleam#5353 — large decoders crash the compiler. Same
  family of failures; ours hits at the package level rather than
  the single-declaration level.
- gleam-lang/gleam#5653 — support for shared build directory across
  packages. Would make the split cleaner once it lands.

## Cold-cache CI baseline

First successful macOS run (commit 343bf4e):
- Total: 28 min
- Regen: 11m 27s
- Tests: 14m 15s
- Setup + cache upload: ~2 min

## Hot-cache validation

After commit 93fb474 (git-ls-tree-based cache keys), the previous
hashFiles drift between docs-only commits should be gone. This
commit is the validation push: identical hash-key inputs to
93fb474, so both codegen + build caches should hit and CI should
drop to ~3-5 min total.
