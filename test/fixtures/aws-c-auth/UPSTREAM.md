# aws-c-auth test vectors

Vendored from https://github.com/awslabs/aws-c-auth at commit `4b5cf14`
(release tag `v0.9.92`).

Only the SigV4 / SigV4a test vector directories are kept:

- `tests/aws-sig-v4-test-suite/` — legacy AWS SigV4 test suite. Each case is a
  directory with `context.json` (inputs), `header-canonical-request.txt`
  (expected canonical request) and `header-signature.txt` (expected
  authorization header signature).
- `tests/aws-signing-test-suite/v4/` and `v4a/` — newer format. Each case has
  `request.txt` (raw request), `canonical-request.txt`, `string-to-sign.txt`,
  `signed-request.txt`, and `public-key.json` (v4a).

The original `aws-c-auth` C source, build files, and unrelated test code have
been removed — only the test data is needed for this project. `LICENSE` and
`NOTICE` are preserved per Apache 2.0 attribution requirements.

To refresh:

```bash
git clone --depth 1 --branch v0.9.92 https://github.com/awslabs/aws-c-auth /tmp/aws-c-auth
rsync -a --delete /tmp/aws-c-auth/tests/aws-sig-v4-test-suite/ tests/aws-sig-v4-test-suite/
rsync -a --delete /tmp/aws-c-auth/tests/aws-signing-test-suite/ tests/aws-signing-test-suite/
cp /tmp/aws-c-auth/LICENSE /tmp/aws-c-auth/NOTICE .
```
