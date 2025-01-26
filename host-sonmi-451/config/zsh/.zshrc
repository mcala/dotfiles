# ZIM Initialization
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi
source ${ZIM_HOME}/init.zsh

source $XDG_CONFIG_DIR/zsh/zshrc.personal
source $XDG_CONFIG_DIR/zsh/zshrc.computer

if [[ "$TERM_PROGRAM" != "Apple_Terminal" ]]; then
    eval "$(oh-my-posh init zsh --config $XDG_CONFIG_DIR/oh-my-posh/mcala.omp.toml)"
fi

# >>> COMPLETIONS
#
# >>> nvm initialize >>>
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/Users/mcala/.bun/_bun" ] && source "/Users/mcala/.bun/_bun"

# procs completions
source <(procs --gen-completion-out zsh)

# atuin
eval "$(atuin init zsh)"
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# rbenv
eval "$(rbenv init - --no-rehash bash)"

# fzf
#source <(fzf --zsh)
