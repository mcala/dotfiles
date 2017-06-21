# Path to your oh-my-zsh configuration.
ZSH=$HOME/soft/repositories/oh-my-zsh

# Uncomment following line if you want to disable autosetting terminal title.
 DISABLE_AUTO_TITLE="true"

#plugins for oh-my-zsh
plugins=(git colored-man-pages)

# Load personal and computer specific preferences
source $ZSH/oh-my-zsh.sh
source $HOME/.zshrc.personal
source $HOME/.zshrc.prompt
source $HOME/.zshrc.computer

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
