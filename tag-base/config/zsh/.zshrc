# Canonical cross-host .zshrc. Deployed by rcm via tag-base.
# Per-host overrides live in host-<name>/config/zsh/zshrc.computer.

# Zim
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

# Shared (cross-host) aliases, options, key bindings
[[ -f $XDG_CONFIG_HOME/zsh/zshrc.personal ]] && source $XDG_CONFIG_HOME/zsh/zshrc.personal
# Per-host overrides
[[ -f $XDG_CONFIG_HOME/zsh/zshrc.computer ]] && source $XDG_CONFIG_HOME/zsh/zshrc.computer

# Prompt (oh-my-posh, installed by host bootstrap; config in tag-base)
if command -v oh-my-posh >/dev/null && [[ "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
  eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/oh-my-posh/mcala.omp.toml)"
fi

# Cross-host CLI integrations (gated; degrade gracefully if missing)
command -v atuin  >/dev/null && eval "$(atuin init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# NVM (per-host zshrc.computer may set NVM_DIR before this runs)
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Don't install packages newer than 14 days. Unset UV_EXCLUDE_NEWER to bypass.
if date -u -v-14d +%Y-%m-%dT%H:%M:%SZ >/dev/null 2>&1; then
  export UV_EXCLUDE_NEWER="$(date -u -v-14d +%Y-%m-%dT%H:%M:%SZ)"
else
  export UV_EXCLUDE_NEWER="$(date -u -d '14 days ago' +%Y-%m-%dT%H:%M:%SZ)"
fi

# Path dedup; per-host zshrc.computer owns the actual PATH entries.
typeset -U PATH path
export PATH
