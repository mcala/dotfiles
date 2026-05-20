# ZIM Initialization
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

source $XDG_CONFIG_HOME/zsh/zshrc.personal
source $XDG_CONFIG_HOME/zsh/zshrc.computer

# nvm if installed
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# atuin / zoxide if installed
command -v atuin >/dev/null && eval "$(atuin init zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init --cmd cd zsh)"

# --- Path Configuration
typeset -U PATH path
path=(
  $HOME/.local/bin
  $HOME/software/bin
  /opt/nvim/bin
  $path
)
export PATH
