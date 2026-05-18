---
active: true
iteration: 125
session_id: e0fadb0b-b4a3-4659-a128-707f2bdfb985
max_iterations: 0
completion_promise: null
started_at: "2026-05-17T15:33:51Z"
---

Keep all tests green. Write new tests for everything implemented. Do red, green, refactor with the simplify reviewer on every iteration. No shortcuts, no removing tests, no cutting corners. Make strong architectural choices, like typed AST over string concats. When uncertain, pick the long-term better option.

The goal is to complete every remaining item in next_steps.md v0.2: streaming bodies, event streams, S3 transfer manager, SigV4a, rpcv2Cbor, HTTP slash 2, the multi-algorithm checksum middleware wiring, and codegen-side opt-in to the precise Timestamp type. All on the SAME PR feat slash all-services, PR number 8. If a sub-branch is needed for a chunk, merge it back to feat slash all-services before moving to the next chunk so the work accumulates on one PR rather than fragmenting. Push the cumulative state to origin feat slash all-services after each merge so the PR description and CI stay current.

When a genuine blocker hits, like a locked signing agent or a missing OTP primitive that needs a NIF, flag it in the response, keep working on whatever else does not depend on the blocker, and let the user resolve it. Do not pause iterations waiting for the user. Keep going.
