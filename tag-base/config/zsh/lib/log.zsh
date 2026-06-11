# ABOUTME: Logging helpers (log_info/log_warn/log_error/log_die) for zsh scripts.
# ABOUTME: Sourced, not executed; deployed by rcm to ~/.config/zsh/lib/log.zsh.

# Gate color on stderr being a terminal, so redirected logs aren't full of escapes
if [[ -t 2 ]]; then
  _log_color=1
else
  _log_color=0
fi

_log() {
  local label=$1; shift
  if (( _log_color )); then
    print -P "$label $*" >&2
  else
    # strip the %F{...}/%f by printing without -P
    print -r -- "${label//\%[Ff]*([{]*[}])/} $*" >&2
  fi
}

log_info()  { _log "%F{green}==>%f"        "$@" }
log_warn()  { _log "%F{yellow}warning:%f" "$@" }
log_error() { _log "%F{red}error:%f"      "$@" }
log_die()   { log_error "$@"; exit 1 }
