#!/usr/bin/env bash
# Bootstrap a fresh Debian/Ubuntu host (e.g. a cloud VM) to use this
# dotfiles repo. Picks up tag-base/ (cross-host baseline) plus the
# host-default/ profile by default.
#
# Idempotent: re-running won't reinstall already-installed pieces.
#
# Usage (generic remote, picks up host-default):
#   curl -fsSL https://raw.githubusercontent.com/mcala/dotfiles/main/host-default/setup.sh | bash
# or, if you've already cloned:
#   ~/.dotfiles/host-default/setup.sh
#
# To bootstrap a remote that needs its own host directory, override the
# hostname tag and ship a sibling host-<name>/:
#   HOSTNAME_TAG=<name> ~/.dotfiles/host-default/setup.sh

set -euo pipefail

# ---- Config (override via env) ----------------------------------------------
REPO_URL="${REPO_URL:-https://github.com/mcala/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
HOSTNAME_TAG="${HOSTNAME_TAG:-default}"
NVIM_VERSION="${NVIM_VERSION:-stable}"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*" >&2; }

if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null; then
  SUDO="sudo"
else
  SUDO=""
fi

# ---- 1. apt packages --------------------------------------------------------
if ! command -v apt-get >/dev/null; then
  warn "apt-get not found; this script targets Debian/Ubuntu hosts."
  exit 1
fi

log "Updating apt and installing core packages"
export DEBIAN_FRONTEND=noninteractive
$SUDO apt-get update -y
$SUDO apt-get install -y --no-install-recommends \
  zsh tmux git curl wget ca-certificates gnupg \
  build-essential pkg-config \
  rcm locales ncurses-bin \
  ripgrep fd-find bat fzf \
  unzip xz-utils less \
  figlet

# Generate UTF-8 locale (avoids the "perl: warning: Setting locale failed" noise)
log "Ensuring en_US.UTF-8 locale exists"
$SUDO sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen || true
$SUDO locale-gen en_US.UTF-8 >/dev/null || true

# bat/fd on Debian ship under different binary names — symlink them so configs
# that say `bat`/`fd` Just Work.
if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
  $SUDO ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi
if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
  $SUDO ln -sf "$(command -v fdfind)" /usr/local/bin/fd
fi

# eza isn't reliably in apt across Ubuntu versions; install from upstream repo
# if missing.
if ! command -v eza >/dev/null; then
  log "Installing eza from upstream apt repo"
  $SUDO mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | $SUDO gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | $SUDO tee /etc/apt/sources.list.d/gierens.list >/dev/null
  $SUDO chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  $SUDO apt-get update -y
  $SUDO apt-get install -y eza || warn "eza install failed; you can drop the eza aliases or install manually."
fi

# ---- 2. Neovim from official tarball ----------------------------------------
need_nvim_install=1
if command -v nvim >/dev/null; then
  current="$(nvim --version | head -n1 | awk '{print $2}')"
  log "Existing nvim found: $current"
  case "$current" in
    v0.[0-8].*) warn "nvim is older than 0.9 — replacing for LazyVim";;
    *) need_nvim_install=0;;
  esac
fi

if [ "$need_nvim_install" -eq 1 ]; then
  case "$(uname -m)" in
    x86_64) nvim_arch="x86_64" ;;
    aarch64|arm64) nvim_arch="arm64" ;;
    *) warn "Unsupported arch $(uname -m); skipping nvim tarball install"; nvim_arch="" ;;
  esac
  if [ -n "$nvim_arch" ]; then
    log "Installing Neovim $NVIM_VERSION ($nvim_arch) to /opt/nvim"
    tmp="$(mktemp -d)"
    tarball="nvim-linux-${nvim_arch}.tar.gz"
    curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${tarball}" \
      -o "$tmp/$tarball"
    $SUDO rm -rf /opt/nvim
    $SUDO tar -C /opt -xzf "$tmp/$tarball"
    $SUDO mv "/opt/nvim-linux-${nvim_arch}" /opt/nvim
    $SUDO ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm -rf "$tmp"
  fi
fi

# ---- 3. Clone dotfiles ------------------------------------------------------
if [ ! -d "$DOTFILES_DIR" ]; then
  log "Cloning $REPO_URL -> $DOTFILES_DIR"
  git clone "$REPO_URL" "$DOTFILES_DIR"
else
  log "Dotfiles already at $DOTFILES_DIR (skipping clone)"
fi

# ---- 4. Bootstrap rcm and run rcup -----------------------------------------
log "Writing bootstrap ~/.rcrc"
cat > "$HOME/.rcrc" <<EOF
DOTFILES_DIRS="$DOTFILES_DIR"
HOSTNAME="$HOSTNAME_TAG"
TAGS="base claude"
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

# ---- 6. oh-my-posh ----------------------------------------------------------
if ! command -v oh-my-posh >/dev/null; then
  log "Installing oh-my-posh to /usr/local/bin"
  if [ -n "$SUDO" ]; then
    curl -fsSL https://ohmyposh.dev/install.sh | $SUDO bash -s -- -d /usr/local/bin
  else
    curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin
  fi
fi

# ---- 7. atuin (shell history sync + up-arrow search) -----------------------
if ! command -v atuin >/dev/null; then
  case "$(uname -m)" in
    x86_64) atuin_arch="x86_64" ;;
    aarch64|arm64) atuin_arch="aarch64" ;;
    *) warn "Unsupported arch $(uname -m); skipping atuin install"; atuin_arch="" ;;
  esac
  if [ -n "$atuin_arch" ]; then
    log "Installing atuin (${atuin_arch}) to /usr/local/bin"
    tmp="$(mktemp -d)"
    tarball="atuin-${atuin_arch}-unknown-linux-gnu.tar.gz"
    curl -fsSL "https://github.com/atuinsh/atuin/releases/latest/download/${tarball}" \
      -o "$tmp/$tarball"
    tar -C "$tmp" -xzf "$tmp/$tarball"
    atuin_bin="$(find "$tmp" -maxdepth 3 -type f -name atuin -perm -u+x | head -n1)"
    if [ -n "$atuin_bin" ]; then
      $SUDO install -m 755 "$atuin_bin" /usr/local/bin/atuin
    else
      warn "atuin binary not found in unpacked tarball; skipping"
    fi
    rm -rf "$tmp"
  fi
fi

# ---- 8. tmux plugin manager -------------------------------------------------
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  log "Installing tmux plugin manager"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# ---- 9. uv + Astral tools (ruff, ty) ---------------------------------------
# uv goes in /usr/local/bin so every user gets it. Tools live in /opt/uv/tools
# with binaries linked into /usr/local/bin, so `ruff` / `ty` work for all users.
if ! command -v uv >/dev/null; then
  log "Installing uv to /usr/local/bin"
  $SUDO mkdir -p /usr/local/bin
  curl -LsSf https://astral.sh/uv/install.sh \
    | $SUDO env UV_INSTALL_DIR=/usr/local/bin INSTALLER_NO_MODIFY_PATH=1 sh
fi

if command -v uv >/dev/null; then
  $SUDO mkdir -p /opt/uv/tools
  for tool in ruff ty; do
    if ! command -v "$tool" >/dev/null; then
      log "Installing $tool via uv tool"
      $SUDO env UV_TOOL_DIR=/opt/uv/tools UV_TOOL_BIN_DIR=/usr/local/bin \
        uv tool install "$tool" || warn "uv tool install $tool failed"
    fi
  done
fi

# ---- 10. Claude Code (installs for the user running this script) -----------
if ! command -v claude >/dev/null; then
  log "Installing Claude Code via official installer"
  curl -fsSL https://claude.ai/install.sh | bash || warn "Claude Code install failed"
fi

# ---- 11. Ghostty terminfo (TUIs misbehave without it when SSH'd from Ghostty/tmux)
TERMINFO_SRC="$DOTFILES_DIR/host-default/xterm-ghostty.terminfo"
if [ -f "$TERMINFO_SRC" ] && ! infocmp xterm-ghostty >/dev/null 2>&1; then
  log "Installing Ghostty terminfo (xterm-ghostty)"
  $SUDO tic -x "$TERMINFO_SRC" || warn "tic failed; check ncurses-bin"
fi

# ---- 12. Change login shell to zsh -----------------------------------------
zsh_bin="$(command -v zsh)"
if [ -n "$zsh_bin" ] && [ "${SHELL:-}" != "$zsh_bin" ]; then
  log "Changing default shell to $zsh_bin"
  $SUDO chsh -s "$zsh_bin" "$USER" || warn "chsh failed; run it manually"
fi

# ---- 13. Done ---------------------------------------------------------------
cat <<'EOF'

==> Bootstrap complete.

Next steps:
  1. Log out and back in (or `exec zsh -l`) to land in zsh.
  2. Inside tmux, run prefix + I (capital i) to install tmux plugins.
  3. Open `nvim` once — LazyVim will install plugins on first run.
  4. Make sure ~/.ssh/authorized_keys has your public key.
  5. (Optional) Run ./harden-remote.sh to put sshd on :443 (via sslh)
     and disable password auth. Read the script header first.
  6. `claude` is installed for the user that ran this script. Any other
     user that wants it should run:
       curl -fsSL https://claude.ai/install.sh | bash

EOF
