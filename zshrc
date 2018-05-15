# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

source $HOME/.zshrc.personal
#source $HOME/.zshrc.prompt
source $HOME/.zshrc.computer


#
## Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
#export PATH="$PATH:$HOME/.rvm/bin"
#
#OLD OHMYZSH CONFIG
## Path to your oh-my-zsh configuration.
#ZSH=$HOME/soft/repositories/oh-my-zsh
#
## Uncomment following line if you want to disable autosetting terminal title.
#DISABLE_AUTO_TITLE="true"
#ENABLE_CORRECTION="true"
#HIST_STAMPS="mm/dd/yyyy"
##ZSH_CUSTOM=$HOME/.zsh_plugins
#
##plugins for oh-my-zsh
##source $HOME/.plugins.zsh
##plugins+=(git colored-man-pages zsh-syntax-highlighting)
#
## Load personal and computer specific preferences
#source $ZSH/oh-my-zsh.sh
#source $HOME/.zshrc.personal
#source $HOME/.zshrc.prompt
#source $HOME/.zshrc.computer
#source ~/.iterm2_shell_integration.`basename $SHELL`
