#!/usr/bin/env zsh
# ABOUTME: Workstation toolchain updater (MacPorts, rust/cargo, uv, sesh, npm, TeX).
# ABOUTME: Host-portable: every section is capability-guarded, so absent tools no-op.

# Log helpers (tag-base); inline fallbacks survive a partial deploy.
_log="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/lib/log.zsh"
if [[ -r $_log ]]; then
  source "$_log"
else
  log_info()  { print -P "%F{blue}[INFO]%f  $*" }
  log_error() { print -P "%F{red}[ERROR]%f $*" >&2 }
fi

typeset -a fails=()

section () {
    print -P "%B%F{$1}=== $2 ===%f%b"
}

run () {
    "$@" || fails+=("$*")
}

have () { command -v "$1" >/dev/null }

# --- MACPORTS -----------------------------------------------------------------
if have port; then
  section blue MACPORTS
  # sonmi's MacPorts is a user-prefix install: no sudo if the prefix is ours.
  typeset -a port_cmd=(sudo port)
  [[ -w ${$(command -v port):h:h} ]] && port_cmd=(port)
  log_info "--- Updating MacPorts..."
  run $port_cmd selfupdate
  if [[ -n "$(port -q echo outdated 2>/dev/null)" ]]; then
    run $port_cmd upgrade outdated
  else
    log_info "--- No outdated ports"
  fi
fi

# --- RUST -----------------------------------------------------------------------
if have rustup; then
  section red RUST
  log_info "--- Updating rustup..."
  run rustup update

  if have cargo-install-update; then
    log_info "--- Updating/installing cargo packages..."
    run cargo install-update -i --locked \
      atuin \
      bat \
      broot \
      cargo-update \
      du-dust \
      eza \
      just \
      onefetch \
      procs \
      rumdl \
      tokei \
      tree-sitter-cli \
      typst-cli \
      zoxide

    log_info "--- Updating jj-vcs"
    run cargo install-update --locked jj-cli
  else
    log_error "cargo-update crate missing: cargo install --locked cargo-update"
  fi
fi

# --- UV ---------------------------------------------------------------------------
if have uv; then
  section green UV
  if [[ "$(command -v uv)" == "$HOME/.cargo/bin/uv" ]]; then
    # cargo --git build (sonmi)
    log_info "--- Updating uv (cargo --git build)..."
    run cargo install --git https://github.com/astral-sh/uv --locked uv
  else
    # standalone installer (kern)
    log_info "--- Updating uv (standalone installer)..."
    run uv self update
  fi
  log_info "--- Upgrading uv tools..."
  run uv tool upgrade --all
fi

# --- SESH -------------------------------------------------------------------------
if have go; then
  section green SESH
  # GOBIN: ~/go/bin isn't on PATH; ~/.local/bin is.
  run env GOBIN="$HOME/.local/bin" go install -v github.com/joshmedeski/sesh/v2@latest
fi

# --- NPM --------------------------------------------------------------------------
if have npm; then
  section orange NPM
  run npm install -g npm@latest
  run npm update -g
fi

# --- AMP --------------------------------------------------------------------------
if have amp; then
  section purple AMP
  run amp update
fi

# --- LATEX (MacTeX is installed manually; bootstrap skips it) ----------------------
if [[ -x /Library/TeX/texbin/tlmgr ]]; then
  section white LATEX
  log_info "--- Updating tlmgr and all TeX Live packages..."
  # Full path + sudo: sudo can reset PATH, and the root-owned TeX Live tree needs root to write.
  run sudo /Library/TeX/texbin/tlmgr update --self --all
fi

if (( ${#fails} )); then
  log_error "Failed: ${(j:, :)fails}"
  exit 1
fi
log_info "All updates completed."
