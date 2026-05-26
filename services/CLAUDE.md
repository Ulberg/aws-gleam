# Services — rules

Loaded when working under `services/`. These packages are **generated**. Project-wide conventions live in [`../RULES.md`](../RULES.md) and [`../PHILOSOPHY.md`](../PHILOSOPHY.md).

## Don't hand-edit — it's generated
- `services/<svc>/src/aws/services/<svc>.gleam` is generated and git-ignored. Editing it directly is wasted work — the next `scripts/regen.sh` overwrites it.
- To change a service, change the codegen under [`../codegen/`](../codegen/) and regenerate: `scripts/regen.sh <svc>`.
- Only the package skeleton (`gleam.toml`, `LICENSE`, `.gitignore`) is committed per service; `src/` is regenerated, not tracked.

## Logging
- A service's logging comes from the emitter plus the runtime logger ([`../RULES.md`](../RULES.md)) — not from edits here.
