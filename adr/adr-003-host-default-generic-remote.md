# ADR 003: host-default is the generic remote-host bootstrap

## Context

Bringing up a fresh Linux remote (a cloud VM, a droplet) involves a
substantial set of defaults that have nothing to do with any one host:
install zsh, neovim, Zim, oh-my-posh, tmux/TPM via apt and upstream
tarballs; ensure a UTF-8 locale; set the login shell; run `rcup` against
this repo; set Linux-remote-flavored shell defaults like `BAT_THEME=ansi`
and `/opt/nvim/bin` on `PATH`.

A previous iteration tied this bootstrap to a single host directory,
which implied the content was host-specific. It wasn't. The script and
its companion shell-level defaults generalize cleanly to any fresh
Debian/Ubuntu remote.

## Decision

1. Introduce `host-default/` as the canonical bootstrap for any new
   remote. It contains:
   - `setup.sh` — idempotent Debian/Ubuntu bootstrap (apt deps, neovim
     tarball, Zim install, oh-my-posh install, TPM clone, `chsh` to zsh,
     `rcup` with `HOSTNAME=default`).
   - `config/zsh/zshrc.computer` — cross-remote Linux defaults
     (`BAT_THEME`, `/opt/nvim/bin` on PATH, `UV_PYTHON_PREFERENCE`, …).
   - Any other defaults that should apply to "a fresh Linux remote" but
     not to a Mac host.
2. The script's `HOSTNAME_TAG` defaults to `default` and is overridable
   via env var. A remote that needs unique config bootstraps with
   `HOSTNAME_TAG=<name>` and a sibling `host-<name>/` containing only
   the diff against `host-default`.
3. Mac hosts (`host-sonmi-451`) do not consume `host-default`. The split:
   - `tag-base` is cross-host — applies to Mac and Linux remotes.
   - `host-default` is "remote-Linux defaults" — applies only when a
     remote bootstraps with `HOSTNAME=default`.

## Status

2026-05-21: Accepted.

## Consequences

- Bringing up a new remote is one `curl … | bash` away with no new
  directory required.
- A remote that needs unique config creates `host-<name>/` with only the
  diff and overrides `HOSTNAME_TAG` at bootstrap time.
- `host-default/` is sized to be the smallest meaningful per-host:
  `setup.sh` plus computer-level overrides. Genuinely cross-host content
  (cf. ADR-002) lives in `tag-base/`.
- `host-default` does not symlink into other host directories. If
  `host-default` and a `host-<name>/` would need the same content, that
  content belongs in `tag-base/`; otherwise each host carries its own
  copy.
