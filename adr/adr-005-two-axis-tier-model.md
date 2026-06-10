# ADR 005: Tiers split on two axes (OS × workstation/remote)

## Context

ADR-002 introduced `tag-base` for the cross-host baseline and `host-*`
for machine-specific config. ADR-003 made `host-default` the generic
remote-Linux bootstrap and established that Mac hosts do not consume it.

That left "Linux" implicitly equal to "remote VPS": `host-default`
bundles both *Linux package installation* (apt, the neovim tarball) and
*headless remote* concerns (sslh/hardening, `BAT_THEME=ansi`, `/opt/nvim`
on PATH). The arrangement works while every non-Mac is a headless server,
but it has no home for a personal Linux workstation (a dual-boot, or a
future Linux laptop): such a machine wants apt like the VPS but the full
interactive toolset like a Mac.

Separately, bringing up a second Mac (`kern`, alongside `sonmi-451`)
forced the question of where shared Mac config lives. Per ADR-002 the
shared content belongs in a tag, not copied between `host-*` dirs. But
"shared between my Macs" conflates two different things: config that is
genuinely Mac-specific (ghostty, aerospace, sketchybar, karabiner,
MacPorts, `defaults write`) and config that is merely
interactive-workstation and happens to also run on Linux (yazi, btop,
lazygit, sesh, atuin, the startup banner).

## Decision

Organize tiers on two orthogonal axes rather than one:

1. **OS axis** — `tag-mac` (macOS-only). A `tag-linux` is reserved for
   Linux-desktop-only config but is **not created until a personal Linux
   machine exists** (ADR-002 §4: defer the split until the pain shows up).
2. **Role axis** — `tag-workstation` holds cross-OS interactive/TUI
   config: the tools used on a machine you sit in front of, regardless of
   OS. Headless remotes simply do not list this tag.
3. `tag-base` and `tag-claude` remain universal — every host, including
   VPSes.
4. `host-default` remains the remote-Linux profile and bootstrap; it does
   not gain workstation content. A VPS may opt into `tag-workstation` by
   listing it, but does not by default.
5. Each host composes the tiers via its `rcrc` `TAGS`:
   - Mac (`kern`, `sonmi-451`): `base claude workstation mac`
   - future personal Linux: `base claude workstation linux`
   - VPS: `base claude` (+ `workstation` if wanted) + `host-default`
6. The macOS bootstrap is `tag-mac/setup.sh`, the Mac analog of
   `host-default/setup.sh`: MacPorts (never Homebrew) for packages, the
   `defaults write` scripts, then `rcup`.

## Status

2026-06-10: Accepted.

## Consequences

- A personal Linux workstation, when it arrives, is `base claude
  workstation linux` plus a thin `host-<name>/`; the interactive config
  it needs already lives in `tag-workstation`, lifted out of
  `host-sonmi-451`.
- The workstation-vs-mac split is made now (while lifting `sonmi-451`'s
  config into tags) so the content is filed correctly once; `tag-linux`
  and the personal-Linux host are deferred so no empty scaffolding is
  created.
- macOS uses MacPorts, not Homebrew; the Mac bootstrap and any package
  step use `port`. The MacPorts prefix is host-specific (`kern`:
  `/opt/local`, `sonmi-451`: `/Users/mcala/MacPorts`) and lives in each
  host's `zshenv`/`zshrc.computer`, not a shared tier.
- `host-default`'s dual role (Linux packages + headless concerns) is left
  intact. If a Linux workstation later needs its apt steps without the
  hardening, that script gets factored then — not preemptively.
