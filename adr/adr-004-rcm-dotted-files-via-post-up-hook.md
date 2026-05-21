# ADR 004: Dotted files in subdirectories are deployed via a post-up hook

## Context

`rcm`'s deployment algorithm treats leading-dot files specially:

- A non-dotted file at the dotfiles root (e.g. `zshrc`) is symlinked to a
  dotted path in `$HOME` (`~/.zshrc`).
- A leading-dot file anywhere in the dotfiles tree is skipped entirely
  by `rcup`. This is documented in `rcm(7)` ("Common Problem: Dotted
  Filenames in Dotfiles Directory") and confirmed empirically: with the
  canonical zsh entry stored as `tag-base/config/zsh/.zshrc`, `lsrc` did
  not include it in the deploy plan while the sibling `zshrc.personal`
  was included.

This is awkward for nested config files that zsh and other tools insist
on finding under dotted names. `$ZDOTDIR/.zshrc` is the only path zsh
will load on startup; `$ZDOTDIR/.zimrc` is the only path Zim will read.
A subdirectory file named `zshrc` (no dot) is deployed by `rcm` to
`$ZDOTDIR/zshrc` (no dot), where neither tool looks.

The status-quo workaround had been to manually `ln -s zshrc .zshrc`
inside `$ZDOTDIR` on each host after deploy. That works but is invisible,
manual, and one missed step away from a host where the canonical
`.zshrc` doesn't load.

## Decision

1. Canonical zsh-and-similar configs live in the repo without leading
   dots (e.g. `tag-base/config/zsh/zshrc`, `zimrc`).
2. `hooks/post-up/01-zsh-dotfile-symlinks` runs after every `rcup` and
   creates the dotted symlinks (`$ZDOTDIR/.zshrc -> zshrc`, etc.). It is
   executable, idempotent, and a no-op on hosts where the no-dot files
   are not deployed.
3. The same pattern is used for any future config whose tool insists on
   a dotted name in a subdirectory: ship under the no-dot name, add a
   line to (or a new file in) `hooks/post-up/`.

## Status

2026-05-21: Accepted.

## Consequences

- Adding cross-host zsh config no longer requires per-host manual
  symlink steps.
- The repo's canonical name for these files is the no-dot version; the
  dotted name only exists as a deploy-time symlink. References from
  scripts in this repo (e.g. `loaddots` in `zshrc.personal`) should use
  the no-dot path so they don't depend on a hook having already run.
- Adding new tools that share this pattern means editing `hooks/post-up/`.
  The hook is idempotent so re-running `rcup` is always safe.
