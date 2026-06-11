#!/usr/bin/env bash
# Bootstrap a fresh macOS workstation to use this dotfiles repo. The Mac
# analog of host-default/setup.sh: MacPorts (not Homebrew) for packages,
# the macOS `defaults write` scripts, then `rcup`. Picks up tag-base/
# (universal) + tag-claude + tag-workstation (cross-OS interactive) + the
# host-<name>/ profile.
#
# Two-pass design: the core pass installs the bare minimum for a working
# shell; the extras pass installs the big, slow packages (pandoc, the
# cargo and node toolchains, and packages built with them).
#
# Idempotent: re-running won't reinstall already-installed pieces.
#
# Usage (after cloning the repo to ~/.dotfiles):
#   ~/.dotfiles/tag-mac/setup.sh           # pass 1: core (minimal working shell)
#   ~/.dotfiles/tag-mac/setup.sh extras    # pass 2: heavy packages (pandoc etc.)
#   ~/.dotfiles/tag-mac/setup.sh apps      # pass 3: GUI apps into /Applications
#   ~/.dotfiles/tag-mac/setup.sh all       # all passes back to back
#
# The host tag defaults to the short hostname (so `kern` -> host-kern/).
# Override for a host whose machine name doesn't match its host-<name> dir:
#   HOSTNAME_TAG=<name> ~/.dotfiles/tag-mac/setup.sh

set -euo pipefail

STAGE="${1:-core}"
case "$STAGE" in
core | extras | apps | all) ;;
*)
    echo "Usage: ${0##*/} [core|extras|apps|all]   (default: core)" >&2
    exit 2
    ;;
esac

# ---- Config (override via env) ----------------------------------------------
REPO_URL="${REPO_URL:-https://github.com/mcala/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
HOSTNAME_TAG="${HOSTNAME_TAG:-$(hostname -s)}"
TAGS="${TAGS:-base claude workstation mac}"
# macOS `defaults write` scripts are aggressive; opt in explicitly.
RUN_MACOS_DEFAULTS="${RUN_MACOS_DEFAULTS:-0}"

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*" >&2; }

# ---- Preflight: this is a Mac with Xcode CLT + MacPorts ---------------------
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

# ==============================================================================
# Pass 1: core — the bare minimum for a working shell
# ==============================================================================
run_core() {
    # ---- 1. MacPorts packages --------------------------------------------------
    # The apt list from host-default mapped to MacPorts, plus the GNU userland that
    # the workstation aliases expect (ggrep, gsed, gshred via coreutils). Grows as
    # we install more — verify any new name with `port search <name>` first.
    ports=(
        zsh oh-my-posh tmux git gh wget neovim
        ripgrep fd fzf figlet
        coreutils gsed grep gawk # GNU userland: gshred/gsed/ggrep/gawk
        jq direnv                # shell/dev tooling
    )
    # atuin/bat/zoxide are cargo-owned (extras pass); their shell inits are
    # command -v guarded, so the pass-1 shell works without them.

    log "Running port selfupdate"
    sudo port selfupdate
    log "Installing MacPorts packages: ${ports[*]}"
    sudo port -N install "${ports[@]}"

    # ---- 2. rcm (dotfiles manager) ---------------------------------------------
    # rcm is a MacPorts port (installs rcup/lsrc/mkrc/rcdn into $PORT_PREFIX/bin).
    if ! command -v rcup >/dev/null; then
        log "Installing rcm via MacPorts"
        sudo port -N install rcm
    fi

    # ---- 3. Clone dotfiles -------------------------------------------------------
    if [ ! -d "$DOTFILES_DIR" ]; then
        log "Cloning $REPO_URL -> $DOTFILES_DIR"
        git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        log "Dotfiles already at $DOTFILES_DIR (skipping clone)"
    fi

    # ---- 4. Bootstrap rcm and run rcup -------------------------------------------
    log "Writing bootstrap ~/.rcrc (HOSTNAME=$HOSTNAME_TAG, TAGS=\"$TAGS\")"
    cat >"$HOME/.rcrc" <<EOF
DOTFILES_DIRS="$DOTFILES_DIR"
HOSTNAME="$HOSTNAME_TAG"
TAGS="$TAGS"
EXCLUDES="README* setup.sh macos-defaults.sh harden-remote.sh *.terminfo LICENSE* *.swp *.un~ .git .gitignore adr docs"
EOF

    log "Running rcup -v"
    rcup -v

    # The repo's managed rcrc lives at $XDG_CONFIG_HOME/rcm/rcrc; once rcup has run
    # the bootstrap ~/.rcrc is redundant.
    [ -L "$HOME/.config/rcm/rcrc" ] && rm -f "$HOME/.rcrc" && log "Removed bootstrap ~/.rcrc (managed copy is in place)"

    # ---- 5. Zim framework --------------------------------------------------------
    ZIM_HOME="${ZIM_HOME:-$HOME/.config/zim}"
    if [ ! -f "$ZIM_HOME/zimfw.zsh" ]; then
        log "Installing Zim framework to $ZIM_HOME"
        mkdir -p "$ZIM_HOME"
        curl -fsSL --output "$ZIM_HOME/zimfw.zsh" \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    fi
    log "Installing Zim modules"
    zsh -c "export ZIM_HOME='$ZIM_HOME' ZDOTDIR='$HOME/.config/zsh' XDG_CONFIG_HOME='$HOME/.config' XDG_CACHE_HOME='$HOME/.cache'; source '$ZIM_HOME/zimfw.zsh' install" || warn "zimfw install failed; run \`zimfw install\` after first login"

    # ---- 6. tmux plugin manager ---------------------------------------------------
    TPM_DIR="$HOME/.config/tmux/plugins/tpm"
    if [ ! -d "$TPM_DIR" ]; then
        log "Installing tmux plugin manager"
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
    fi

    # ---- 7. Claude Code -----------------------------------------------------------
    if ! command -v claude >/dev/null; then
        log "Installing Claude Code via official installer"
        curl -fsSL https://claude.ai/install.sh | bash || warn "Claude Code install failed"
    fi

    # ---- 8. uv (official standalone installer) -------------------------------------
    # Installs to ~/.local/bin; self-updates via `uv self update`. UV_NO_MODIFY_PATH
    # because rcm owns the shell config. uv tools come in the extras pass.
    if ! command -v uv >/dev/null && [ ! -x "$HOME/.local/bin/uv" ]; then
        log "Installing uv via astral.sh installer"
        curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh || warn "uv install failed"
    fi

    # ---- 9. macOS defaults (opt-in: RUN_MACOS_DEFAULTS=1) -------------------------
    # Sets system prefs via `defaults write` (Dock, Finder, Safari, screenshots,
    # etc.). Aggressive, so opt in explicitly. Curated script lives beside this one.
    if [ "$RUN_MACOS_DEFAULTS" = "1" ]; then
        src="$DOTFILES_DIR/tag-mac/macos-defaults.sh"
        if [ -f "$src" ]; then
            log "Applying macOS defaults"
            bash "$src" || warn "macos-defaults.sh exited non-zero"
        fi
    else
        log "Skipping macOS defaults (set RUN_MACOS_DEFAULTS=1 to apply)"
    fi

    # ---- 10. Change login shell to the MacPorts zsh -------------------------------
    zsh_bin="$PORT_PREFIX/bin/zsh"
    if [ -x "$zsh_bin" ] && [ "${SHELL:-}" != "$zsh_bin" ]; then
        log "Changing default shell to $zsh_bin"
        grep -qxF "$zsh_bin" /etc/shells || echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null
        chsh -s "$zsh_bin" || warn "chsh failed; run it manually"
    fi

    cat <<'EOF'

==> Core bootstrap complete.

Next steps:
  1. Log out and back in (or `exec zsh -l`) to land in zsh.
  2. Inside tmux, run prefix + I (capital i) to install tmux plugins.
  3. Open `nvim` once — LazyVim will install plugins on first run.
  4. Sign in to 1Password so the SSH agent socket is available.
  5. When you have time, run the slow second pass:
       ~/.dotfiles/tag-mac/setup.sh extras

EOF
}

# ==============================================================================
# Pass 2: extras — big, slow packages and the cargo/npm toolchains
# ==============================================================================
run_extras() {
    # ---- E1. Heavy MacPorts packages ---------------------------------------------
    # Curated from the sonmi-451 inventory (docs/macports-sonmi-451.csv, R rows).
    # pandoc pulls the Haskell toolchain; nodejs24 is the current LTS with its
    # matching npm. Verify new names with `port search`.
    ports_extras=(
        #pandoc                        # document conversion (Haskell; slow build)
        lazygit        # TUI git client (aliased: lg)
        nodejs24 npm11 # node LTS + npm, for npm_pkgs below
        go             # toolchain for go-installed tools (sesh)
        git-delta      # syntax-highlighting git pager
        gnupg2         # signing/encryption
        gum            # glamorous shell-script prompts
        miller         # CSV/JSON processor (mlr)
        ripgrep-all    # rga: rg inside PDFs/archives/etc
        rsync          # macOS ships openrsync; want real rsync
        sqlite3 sqlite3-tools
        dos2unix
        doctl # DigitalOcean CLI
    )
    # Candidates from the sonmi-451 inventory — add when actually used on kern:
    #   ffmpeg yt-dlp ImageMagick7 tesseract tesseract-eng   # media/OCR (heavy)
    #   zig rbenv curl less pinentry-mac btop fastfetch
    #   bat-extras   # WARNING: depends on the bat PORT — conflicts with cargo bat
    # Deliberately omitted (sonmi-specific): nyxt lagrange m1ddc macfuse msmtp libpst

    log "Running port selfupdate"
    sudo port selfupdate
    log "Installing MacPorts extras: ${ports_extras[*]}"
    sudo port -N install "${ports_extras[@]}"

    # ---- E2. Rust toolchain (rustup, not the MacPorts cargo) ----------------------
    # Official rustup keeps the toolchain self-managed in ~/.rustup (~600 MB for
    # the minimal profile: rustc/cargo/std, no clippy/rustfmt/docs).
    # --no-modify-path because rcm owns the shell config; host-kern/zshenv
    # already sources ~/.cargo/env.
    if [ ! -x "$HOME/.cargo/bin/rustup" ]; then
        log "Installing rust toolchain via rustup (minimal profile)"
        curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs |
            sh -s -- -y --no-modify-path --profile minimal || warn "rustup install failed"
    fi

    # ---- E3. Cargo packages --------------------------------------------------------
    # Built from source into ~/.cargo/bin (on PATH via zshrc.computer). Entries are
    # crate names; where the installed binary differs, use crate=binary so the
    # idempotency check looks for the right file.
    cargo_pkgs=(
        atuin bat zoxide # cargo-owned, not MacPorts (see core pass note)
        eza              # ls replacement (zshrc.personal aliases)
        broot just onefetch procs rumdl tokei
        du-dust=dust
        typst-cli=typst
        tree-sitter-cli=tree-sitter
        cargo-update=cargo-install-update # provides `cargo install-update` for update.zsh
        jj-cli=jj
    )

    if [ -n "${cargo_pkgs[*]:-}" ]; then
        for entry in "${cargo_pkgs[@]}"; do
            crate="${entry%%=*}"
            bin="${entry##*=}"
            if [ -x "$HOME/.cargo/bin/$bin" ]; then
                log "cargo: $crate already installed (skipping)"
            else
                log "cargo install $crate"
                "$HOME/.cargo/bin/cargo" install --locked "$crate"
            fi
        done
    fi

    # ---- E4. npm global packages ----------------------------------------------------
    # Globals go to ~/.local (bin already on PATH) so no sudo is needed; the
    # matching NPM_CONFIG_PREFIX lives in host-kern/zshenv.
    export NPM_CONFIG_PREFIX="$HOME/.local"
    npm_pkgs=(
        tldr    # community man-page summaries
        ccusage # Claude Code usage tracker
    )

    if [ -n "${npm_pkgs[*]:-}" ]; then
        log "npm install -g: ${npm_pkgs[*]}"
        npm install -g "${npm_pkgs[@]}"
    else
        log "No npm globals listed yet (edit npm_pkgs in setup.sh)"
    fi

    # ---- E5. uv tools -----------------------------------------------------------------
    # uv itself comes from the core pass (astral.sh installer). Explicit binary
    # path: this bash session's PATH may not include ~/.local/bin yet.
    uv_bin="$HOME/.local/bin/uv"
    command -v uv >/dev/null && uv_bin="$(command -v uv)"
    uv_tools=(ty ruff cookiecutter marimo llm gallery-dl batrachian-toad aider-chat)

    if [ -x "$uv_bin" ]; then
        for tool in "${uv_tools[@]}"; do
            if "$uv_bin" tool list 2>/dev/null | grep -q "^$tool "; then
                log "uv tool: $tool already installed (skipping)"
            else
                log "uv tool install $tool"
                "$uv_bin" tool install "$tool" || warn "uv tool install $tool failed"
            fi
        done
    else
        warn "uv missing — run the core pass first"
    fi

    # ---- E6. go-installed tools ---------------------------------------------------------
    # GOBIN: ~/go/bin isn't on PATH; ~/.local/bin is.
    if [ ! -x "$HOME/.local/bin/sesh" ]; then
        log "go install sesh -> ~/.local/bin"
        GOBIN="$HOME/.local/bin" "$PORT_PREFIX/bin/go" install github.com/joshmedeski/sesh/v2@latest || warn "sesh install failed"
    fi

    log "Extras pass complete. (LaTeX = MacTeX, installed manually: https://www.tug.org/mactex/)"
}

# ==============================================================================
# Pass 3: apps — GUI applications installed into /Applications
# ==============================================================================

# github_latest_asset <owner/repo> <asset regex>: print the download URL of the
# first matching asset of the latest release (empty on failure; caller warns).
github_latest_asset() {
    curl -fsSL "https://api.github.com/repos/$1/releases/latest" |
        jq -r --arg re "$2" '.assets[].browser_download_url | select(test($re))' |
        head -n 1
}

# install_dmg <App> <url>: download a dmg and copy <App>.app into /Applications.
# Skips if already installed; every failure warns instead of aborting the pass.
install_dmg() {
    local app="$1" url="$2" tmp_dmg mount_dir src
    if [ -d "/Applications/$app.app" ]; then
        log "$app already installed (skipping)"
        return 0
    fi
    if [ -z "$url" ]; then
        warn "$app: no download URL resolved"
        return 0
    fi
    log "Installing $app"
    tmp_dmg="$(mktemp -t "$app.dmg")"
    if ! curl -fsSL --output "$tmp_dmg" "$url"; then
        warn "$app: download failed ($url)"
        rm -f "$tmp_dmg"
        return 0
    fi
    mount_dir="$(mktemp -d -t "$app.mount")"
    if hdiutil attach "$tmp_dmg" -mountpoint "$mount_dir" -nobrowse -quiet; then
        src="$(/bin/ls -d "$mount_dir"/*.app 2>/dev/null | head -n 1)"
        if [ -n "$src" ]; then
            ditto "$src" "/Applications/$(basename "$src")" || warn "$app: copy failed"
        else
            warn "$app: no .app found in dmg"
        fi
        hdiutil detach "$mount_dir" -quiet || warn "$app: detach failed"
    else
        warn "$app: dmg mount failed"
    fi
    rm -f "$tmp_dmg"
}

# install_zip <App> <url>: same as install_dmg for apps shipped as .app.zip.
install_zip() {
    local app="$1" url="$2" tmp_zip unpack_dir src
    if [ -d "/Applications/$app.app" ]; then
        log "$app already installed (skipping)"
        return 0
    fi
    if [ -z "$url" ]; then
        warn "$app: no download URL resolved"
        return 0
    fi
    log "Installing $app"
    tmp_zip="$(mktemp -t "$app.zip")"
    if ! curl -fsSL --output "$tmp_zip" "$url"; then
        warn "$app: download failed ($url)"
        rm -f "$tmp_zip"
        return 0
    fi
    unpack_dir="$(mktemp -d -t "$app.unpack")"
    if ditto -xk "$tmp_zip" "$unpack_dir"; then
        src="$(/bin/ls -d "$unpack_dir"/*.app 2>/dev/null | head -n 1)"
        if [ -n "$src" ]; then
            ditto "$src" "/Applications/$(basename "$src")" || warn "$app: copy failed"
        else
            warn "$app: no .app found in zip"
        fi
    else
        warn "$app: unzip failed"
    fi
    rm -rf "$tmp_zip" "$unpack_dir"
}

run_apps() {
    # All of these self-update once installed, so this pass only seeds them.
    # Bear is deliberately absent: Mac App Store only (install by hand).
    if ! command -v jq >/dev/null; then
        warn "jq missing (needed to resolve GitHub release URLs) — run the core pass first"
    fi

    # ---- A1. GitHub-released apps -------------------------------------------------
    install_dmg Ghostty "$(github_latest_asset ghostty-org/ghostty 'Ghostty\.dmg$')"
    install_dmg Obsidian "$(github_latest_asset obsidianmd/obsidian-releases 'universal\.dmg$')"

    # ---- A2. Vendor direct downloads ------------------------------------------------
    install_dmg Claude "https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest/Claude.dmg"
    install_dmg Todoist "https://todoist.com/mac_app"

    # ---- A3. DEVONthink (ships as .app.zip; resolve from the download page) ----------
    dt_url="$(curl -fsSL https://www.devontechnologies.com/download/products |
        grep -oE 'https://download\.devontechnologies\.com/download/devonthink/[^"]+\.app\.zip' |
        head -n 1)"
    install_zip DEVONthink "$dt_url"

    log "Apps pass complete."
}

case "$STAGE" in
core) run_core ;;
extras) run_extras ;;
apps) run_apps ;;
all)
    run_core
    run_extras
    run_apps
    ;;
esac
