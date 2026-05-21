# ADR 002: tag-base for shared baseline; host-* for machine-specific

## Context

`rcm` distinguishes two ways of scoping a dotfiles directory:

- `host-<name>/` — applied only when the bootstrap `HOSTNAME` matches.
- `tag-<name>/` — applied to every host that lists the tag.

The dotfiles repo had been using `host-*` for everything, including
configuration that is identical across hosts. As a result the same content
existed in multiple `host-*` directories and drifted:

- Each host carried its own `zshrc.personal` (aliases, key bindings, shell
  options) that was meant to be cross-host. The three copies diverged.
- Each host carried its own copy or symlink of `oh-my-posh`, `nvim-lazy`,
  and other tool configs that are functionally identical across hosts.

Storing cross-host content under `host-*` defeats `rcm`'s host/tag
distinction.

## Decision

1. Introduce `tag-base/` for cross-host baseline configuration. Every host
   applies it.
2. Move the canonical cross-host config into `tag-base/config/`:
   - `zsh/` — `.zshrc`, `.zimrc`, `zshrc.personal`
   - `oh-my-posh/` — prompt config
   - `nvim-lazy/` — neovim config
   - any other configuration that is the same across hosts
3. `host-<name>/config/zsh/zshrc.computer` continues to hold the
   machine-specific overrides: paths, host-only env vars, machine-only
   aliases. The canonical `.zshrc` sources `zshrc.personal` first and
   `zshrc.computer` second, so per-host overrides win.
4. `tag-base/` is an intentional catch-all baseline. If it grows past the
   point of being a single coherent baseline it gets split into narrower
   tags (`tag-zsh`, `tag-git`, `tag-cli-tools`, …). That split is deferred
   until the pain shows up.
5. In-project symlinks (one directory in this repo linking to another) are
   not used. Cross-host configuration lives in `tag-base/`; configuration
   that really is host-specific is duplicated by copy, not by symlink.
   Symlinks within the repo make it ambiguous which file is canonical and
   surprise `rcm`, git, and the next person reading the tree.

## Status

2026-05-21: Accepted.

## Consequences

- A new alias, prompt tweak, or nvim plugin is added in exactly one place
  (`tag-base`), not N.
- A host-specific override goes in `zshrc.computer` (or a host-only config
  directory) for that host only.
- A new host is mostly `host-<name>/config/zsh/zshrc.computer` plus any
  host-only configs (hammerspoon, karabiner, iterm2, etc.); everything
  else is inherited from `tag-base`.
- Anything still under `host-*` that is genuinely cross-host should be
  migrated into `tag-base` when next touched.
- The previous practice of symlinking from one `host-*` directory into
  another (e.g. `host-abu/config/nvim-lazy -> ../../host-sonmi-451/...`)
  is gone. The content moves into `tag-base/`, or it's duplicated where
  needed.
