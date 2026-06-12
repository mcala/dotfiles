# dotfiles

Personal dotfiles, managed with
[`rcm`](https://github.com/thoughtbot/rcm). Configuration is
split into **tags** (shared across machines) and **hosts**
(machine-specific). A given machine is the sum of a few tags
plus its own host directory.

If you're reading this to set up a new machine, jump to
[Setting up a new machine](#setting-up-a-new-machine). The
design rationale for the tag/host split lives in
[`adr/`](adr/).

## How rcm composes a machine

`rcup` reads `~/.config/rcm/rcrc`, which defines two things:

```sh
HOSTNAME="kern"                         # which host-<name>/ to apply
TAGS="base claude workstation mac"      # which tag-<name>/ dirs to apply
```

It then symlinks the contents of each `tag-<TAG>/` and
`host-<HOSTNAME>/` into `$HOME`. Tiers are layered
**tags first, host last**, so a host can override anything a
tag provides. Each host ships its own `rcrc` at
`host-<name>/config/rcm/rcrc`, which is itself deployed to
`~/.config/rcm/rcrc` — the bootstrap scripts write a
temporary one to break the chicken-and-egg.

Two rcm quirks worth remembering:

- **Dot-files in subdirectories are skipped by `rcup`.**
  Canonical configs that a tool insists on finding under a
  dotted name (`.zshrc`, `.zimrc`) are stored *without* the
  dot, and `hooks/post-up/01-zsh-dotfile-symlinks` creates
  the dotted symlink after every `rcup`. See
  [ADR-004](adr/adr-004-rcm-dotted-files-via-post-up-hook.md).
- **`EXCLUDES`** (in each `rcrc`) keeps non-config files out
  of `$HOME`: `setup.sh`, `macos-defaults.sh`,
  `harden-remote.sh`, `README*`, `adr`, `docs`, terminfo,
  etc. These live in the tree but are never symlinked.

## Tiers (two axes)

Tags are organized on two orthogonal axes — operating
system, and whether the machine is interactive or headless —
so each piece of config is filed once and inherited by every
machine that needs it. See
[ADR-005](adr/adr-005-two-axis-tier-model.md).

| Tag                | Scope                                            | Applies to |
| ------------------ | ------------------------------------------------ | ---------- |
| `tag-base`         | Universal baseline (shell, git, nvim, prompt)    | every host |
| `tag-claude`       | Claude Code config (`~/.claude`)                 | every host |
| `tag-workstation`  | Cross-OS interactive/TUI tools (sit-in-front-of) | workstations |
| `tag-mac`          | macOS-only setup + defaults                      | Macs |
| `tag-linux`        | Reserved for a personal Linux desktop            | *not yet created* |

A headless remote simply omits `tag-workstation`. A personal
Linux laptop, when one exists, would be
`base claude workstation linux`.

## Tags

- **`tag-base`** — the cross-host baseline that every
  machine gets: zsh (`zshrc`, `zimrc`, `zshrc.personal`),
  git, the LazyVim-based `nvim-lazy` config, oh-my-posh
  prompt, and a shared `ssh/config`. A new alias or nvim
  plugin goes here, in exactly one place. See
  [ADR-002](adr/adr-002-tag-base-vs-host.md).
- **`tag-claude`** — Claude Code's `~/.claude`:
  `settings.json`, `CLAUDE.md`, `docs/`, `skills/`, and the
  statusline script.
- **`tag-workstation`** — cross-OS interactive tooling for
  any machine you sit in front of, regardless of OS: tmux,
  sesh, ghostty, and `local/bin` helpers (`update.zsh`,
  `sesh-picker`). Headless remotes don't list it.
- **`tag-mac`** — macOS-only. Currently the bootstrap
  (`setup.sh`) and the curated `macos-defaults.sh`. Over
  time the genuinely Mac-specific config (aerospace,
  sketchybar, karabiner, MacPorts settings) migrates here
  out of the host directories.

## Hosts

A host directory holds only what's specific to that one
machine — most commonly `config/zsh/zshrc.computer` (machine
paths and overrides), `zshenv` (e.g. the MacPorts prefix,
which differs per Mac), and its `rcrc`. The canonical
`.zshrc` sources `zshrc.personal` (shared) then
`zshrc.computer` (per-host), so host overrides win.

| Host              | Type                | `TAGS`                          |
| ----------------- | ------------------- | ------------------------------- |
| `host-default`    | generic Linux remote| `base claude`                   |
| `host-kern`       | Mac                 | `base claude workstation mac`   |
| `host-sonmi-451`  | Mac                 | `base claude workstation`       |

- **`host-default`** — the generic remote-Linux bootstrap,
  *not* a specific machine. `setup.sh` brings up any fresh
  Debian/Ubuntu host (apt deps, neovim tarball, Zim,
  oh-my-posh, TPM, `chsh` to zsh, `rcup`). A remote that
  needs unique config bootstraps with `HOSTNAME_TAG=<name>`
  and a thin sibling `host-<name>/` holding only its diff.
  `harden-remote.sh` (sslh on :443, sshd hardening) is run
  separately afterward. See
  [ADR-003](adr/adr-003-host-default-generic-remote.md).
- **`host-kern`** — a Mac built to the current model: nearly
  everything comes from the tags, so the host dir is thin
  (`zshenv`, `zshrc.computer`, sesh configs). MacPorts
  prefix `/opt/local`.
- **`host-sonmi-451`** — the older primary Mac. It predates
  `tag-mac`/ `tag-workstation`, so it still carries a large
  `config/` tree of Mac app config directly in the host dir
  (which is why it doesn't yet list `mac`). This content
  migrates into the tags as it's touched. MacPorts prefix
  `/Users/mcala/MacPorts`.

## Not deployed by rcm

These directories live in the repo but are **not** in any
host's `TAGS`, so `rcup` ignores them. They're macOS GUI-app
config that has to be **copied, not symlinked** (the apps
rewrite the files in place), so they're a hand-managed
stash, restored manually when setting up a Mac.

- **`tag-macos`** — Bookends formats, Alfred preferences,
  karabiner, iterm2 plist, color palettes, and assorted
  automation scripts. See `tag-macos/notes.md`.
- **`tag-microsoft-templates`** — Office templates under
  `Library/Group Containers`.

## Supporting directories

- **`hooks/post-up/`** — runs after every `rcup`. Currently
  the zsh dotfile symlink hook (ADR-004).
- **`adr/`** — architecture decision records explaining
  *why* the tree is shaped this way. Start here if a layout
  choice is unclear.
- **`docs/`** — misc reference (e.g. a MacPorts package list
  for sonmi-451).

## Setting up a new machine

**Fresh Linux remote** (Debian/Ubuntu) — one command, clones
the repo and runs `rcup`:

```sh
curl -fsSL https://raw.githubusercontent.com/mcala/dotfiles/main/host-default/setup.sh | bash
# then, while still logged in as root, harden it:
~/.dotfiles/host-default/harden-remote.sh
```

For a remote that needs its own host dir, create
`host-<name>/` and bootstrap with `HOSTNAME_TAG=<name>`.

**Fresh Mac** — clone, then run the staged bootstrap
(MacPorts, never Homebrew). The host tag defaults to the
short hostname, so a machine named `kern` picks up
`host-kern/`:

```sh
git clone git@github.com:mcala/dotfiles.git ~/.dotfiles
~/.dotfiles/tag-mac/setup.sh core      # minimal working shell
~/.dotfiles/tag-mac/setup.sh extras    # heavy packages (pandoc, toolchains)
~/.dotfiles/tag-mac/setup.sh apps      # GUI apps into /Applications
~/.dotfiles/tag-mac/setup.sh all       # all passes back to back
```

The aggressive `defaults write` scripts are opt-in: re-run
with `RUN_MACOS_DEFAULTS=1`, or run
`tag-mac/macos-defaults.sh` directly. Restore the
hand-managed `tag-macos` / `tag-microsoft-templates` app
config by copying it into place afterward.

**Day-to-day**, after editing a config in the repo:

```sh
rcup        # re-link everything for this host
lsrc        # preview what rcup would deploy, without doing it
```
