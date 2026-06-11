## Manual Pages
export MANPATH=$MANPATH:$HOME/software/man
export MANWIDTH=80

## Colorizes less manpages. Stolen from YSAP: https://www.youtube.com/watch?v=D0sG2fj0G4Y
export MANPAGER='less'

# I just use bold blue here since my terminal has blinking disabled
export LESS_TERMCAP_mb=$'\e[1;34m'
# Begin bold text mode
export LESS_TERMCAP_md=$'\e[1;34m'
# End all special formatting started by mb/md/etc. export LESS_TERMCAP_me=$'\e[0m'
# End standout mode
export LESS_TERMCAP_se=$'\e[0m'
# Begin standout mode--dark on light ansi
export LESS_TERMCAP_so=$'\e[30;47m'
# End underline mode
export LESS_TERMCAP_ue=$'\e[0m'
# Begin underline mode
# underline and bold green
export LESS_TERMCAP_us=$'\e[4;1;35m'
# Begin reverse-video mode
export LESS_TERMCAP_mr=$'\e[7m'
# Begin dim/half-bright mode
export LESS_TERMCAP_mh=$'\e[2m'
# Begin subscript mode (probably isn't supported)
export LESS_TERMCAP_ZN=$'\e[74m'
# End subscript mode (probably isn't supported)
export LESS_TERMCAP_ZV=$'\e[75m'
# Begin superscript mode (probably isn't supported)
export LESS_TERMCAP_ZO=$'\e[73m'
# End superscript mode (probably isn't supported)
export LESS_TERMCAP_ZW=$'\e[75m'

