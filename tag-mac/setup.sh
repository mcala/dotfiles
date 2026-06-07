#!/usr/bin/env bash
# Bootstrap a fresh macOS workstation to use this dotfiles repo. The Mac
# analog of host-default/setup.sh: MacPorts (not Homebrew) for packages,
# the macOS `defaults write` scripts, then `rcup`. Picks up tag-base/
# (universal) + tag-claude + tag-workstation (cross-OS interactive) + the
# host-<name>/ profile.
#
# Idempotent: re-running won't reinstall already-installed pieces.
#
# Usage (after cloning the repo to ~/.dotfiles):
#   ~/.dotfiles/tag-mac/setup.sh
#
# The host tag defaults to the short hostname (so `kern` -> host-kern/).
# Override for a host whose machine name doesn't match its host-<name> dir:
#   HOSTNAME_TAG=<name> ~/.dotfiles/tag-mac/setup.sh

set -euo pipefail

# ---- Config (override via env) ----------------------------------------------
REPO_URL="${REPO_URL:-https://github.com/mcala/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
HOSTNAME_TAG="${HOSTNAME_TAG:-$(hostname -s)}"
TAGS="${TAGS:-base claude workstation mac}"
# macOS `defaults write` scripts are aggressive; opt in explicitly.
RUN_MACOS_DEFAULTS="${RUN_MACOS_DEFAULTS:-0}"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*" >&2; }

# ---- 0. Preflight: this is a Mac with Xcode CLT + MacPorts ------------------
if [ "$(uname -s)" != "Darwin" ]; then
  warn "This script targets macOS. For a Linux remote use host-default/setup.sh."
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  warn "Xcode Command Line Tools missing. Install them, then re-run:"
  warn "  xcode-select --install"
  exit 1
fi

if ! command -v port >/dev/null; then
  warn "MacPorts not found. Install it first (we use MacPorts, not Homebrew):"
  warn "  https://www.macports.org/install.php"
  exit 1
fi

# MacPorts prefix (kern: /opt/local; sonmi-451: /Users/mcala/MacPorts). Derived
# from where `port` actually lives so the script works on either layout.
PORT_PREFIX="$(dirname "$(dirname "$(command -v port)")")"
log "MacPorts prefix: $PORT_PREFIX"

# ---- 1. MacPorts packages ---------------------------------------------------
# The apt list from host-default mapped to MacPorts, plus the GNU userland that
# the workstation aliases expect (ggrep, gsed, gshred via coreutils). Grows as
# we install more — verify any new name with `port search <name>` first.
ports=(
  zsh tmux git wget neovim
  ripgrep fd bat fzf eza figlet
  coreutils gsed grep gawk      # GNU userland: gshred/gsed/ggrep/gawk
  jq direnv zoxide              # shell/dev tooling
  atuin uv                      # MacPorts-preferred over their curl installers
)
# Candidates to add as you actually use them on kern (uncomment / verify name):
#   lazygit yazi btop sesh gh miller tokei procs fastfetch

log "Running port selfupdate"
sudo port selfupdate
log "Installing MacPorts packages: ${ports[*]}"
sudo port -N install "${ports[@]}"

# ---- 2. rcm (dotfiles manager) ---------------------------------------------
# NOTE: rcm may not be in MacPorts — verify on first run. If `port install rcm`
# fails, install from upstream (https://github.com/thoughtbot/rcm) and we'll
# bake the working method back into this block.
if ! command -v rcup >/dev/null; then
  log "Installing rcm via MacPorts"
  sudo port -N install rcm || warn "rcm not available via port; install from https://github.com/thoughtbot/rcm and re-run"
fi

# ---- 3. Clone dotfiles ------------------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
  log "Cloning $REPO_URL -> $DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
else
  log "Dotfiles already at $DOTFILES_DIR (skipping clone)"
fi

# ---- 4. Bootstrap rcm and run rcup -----------------------------------------
log "Writing bootstrap ~/.rcrc (HOSTNAME=$HOSTNAME_TAG, TAGS=\"$TAGS\")"
cat > "$HOME/.rcrc" <<EOF
DOTFILES_DIRS="$DOTFILES_DIR"
HOSTNAME="$HOSTNAME_TAG"
TAGS="$TAGS"
EXCLUDES="README* setup.sh harden-remote.sh *.terminfo LICENSE* *.swp *.un~ .git .gitignore adr"
EOF

log "Running rcup -v"
rcup -v

# The repo's managed rcrc lives at $XDG_CONFIG_HOME/rcm/rcrc; once rcup has run
# the bootstrap ~/.rcrc is redundant.
[ -L "$HOME/.config/rcm/rcrc" ] && rm -f "$HOME/.rcrc" && log "Removed bootstrap ~/.rcrc (managed copy is in place)"

# ---- 5. Zim framework -------------------------------------------------------
ZIM_HOME="${ZIM_HOME:-$HOME/.config/zim}"
if [ ! -f "$ZIM_HOME/zimfw.zsh" ]; then
  log "Installing Zim framework to $ZIM_HOME"
  mkdir -p "$ZIM_HOME"
  curl -fsSL --output "$ZIM_HOME/zimfw.zsh" \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi
log "Installing Zim modules"
zsh -c "export ZIM_HOME='$ZIM_HOME' ZDOTDIR='$HOME/.config/zsh' XDG_CONFIG_HOME='$HOME/.config' XDG_CACHE_HOME='$HOME/.cache'; source '$ZIM_HOME/zimfw.zsh' install" || warn "zimfw install failed; run \`zimfw install\` after first login"

# ---- 6. oh-my-posh (no MacPorts port; official installer) -------------------
if ! command -v oh-my-posh >/dev/null; then
  log "Installing oh-my-posh to ~/.local/bin"
  curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
fi

# ---- 7. tmux plugin manager -------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  log "Installing tmux plugin manager"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# ---- 8. Claude Code ---------------------------------------------------------
if ! command -v claude >/dev/null; then
  log "Installing Claude Code via official installer"
  curl -fsSL https://claude.ai/install.sh | bash || warn "Claude Code install failed"
fi

# ---- 9. macOS defaults (opt-in: RUN_MACOS_DEFAULTS=1) -----------------------
# These set system prefs via `defaults write` and are aggressive. They live in
# tag-macos/ for now (TODO: relocate the curated ones into tag-mac/).
if [ "$RUN_MACOS_DEFAULTS" = "1" ]; then
  for script in actualMacOS macos2; do
    src="$DOTFILES_DIR/tag-macos/$script"
    if [ -f "$src" ]; then
      log "Applying macOS defaults: $script"
      bash "$src" || warn "$script exited non-zero"
    fi
  done
else
  log "Skipping macOS defaults (set RUN_MACOS_DEFAULTS=1 to apply)"
fi

# ---- 10. Change login shell to the MacPorts zsh -----------------------------
zsh_bin="$PORT_PREFIX/bin/zsh"
if [ -x "$zsh_bin" ] && [ "${SHELL:-}" != "$zsh_bin" ]; then
  log "Changing default shell to $zsh_bin"
  grep -qxF "$zsh_bin" /etc/shells || echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$zsh_bin" || warn "chsh failed; run it manually"
fi

# ---- 11. Done ---------------------------------------------------------------
cat <<'EOF'

==> Bootstrap complete.

Next steps:
  1. Log out and back in (or `exec zsh -l`) to land in zsh.
  2. Inside tmux, run prefix + I (capital i) to install tmux plugins.
  3. Open `nvim` once — LazyVim will install plugins on first run.
  4. Sign in to 1Password so the SSH agent socket is available.

EOF
