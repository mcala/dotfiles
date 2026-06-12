---
name: gh-cli-via-1password
description: Run gh through 1Password (op plugin run -- gh ...); plain gh uses a stale token and fails auth
metadata:
  type: reference
---

On Andrew's machine, GitHub auth for both `gh` and `git` is brokered by the **1Password `gh` shell plugin**, not by a token stored in `gh`'s own config.

- Run gh as: `op plugin run -- gh <args>` (e.g. `op plugin run -- gh pr list`, `op plugin run -- gh api ...`). Plain `gh` reads `~/.config/gh/hosts.yml`, whose stored `oauth_token` is stale → `HTTP 401 Requires authentication` / "token in default is invalid."
- `git push`/`fetch` over HTTPS work with **plain git** — the global credential helper is `!op plugin run -- gh auth git-credential`, so git pulls the live token automatically. (A spurious `fatal: failed to get: -128` from the osxkeychain helper may print first, but the op/gh helper still succeeds — check for the actual `->` push line.)
- Do NOT wrap git itself as `op plugin run -- git` — there is no `git` op plugin ("unknown plugin: git"). Only `gh` is a plugin.
- `op` v2.x is installed (`/usr/local/bin/op`), signed into `mcallister-zimmermann.1password.com` (maraduke90@gmail.com).
- Inside a sandboxed Bash session, even op-brokered gh fails with a TLS cert error (`OSStatus -26276`) because the sandbox proxy MITMs TLS and gh's Go runtime won't trust the intercept cert. Disable the sandbox for GitHub network calls. See [[inspect-before-destructive-delete]] for the related local-git caution.
