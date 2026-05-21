#!/usr/bin/env bash
# Harden a freshly bootstrapped Debian/Ubuntu remote.
#
# Run AFTER host-default/setup.sh, while logged in as root over the
# existing SSH connection. Uses `systemctl reload` (not restart) for
# sshd so an active session survives a misconfig — but you MUST verify
# in a separate terminal before logging out.
#
# What it does (in order):
#   1. Install + configure sslh so sshd is reachable on :443 in addition
#      to :22 (lets you SSH from networks that block 22 outbound).
#   2. Drop /etc/ssh/sshd_config.d/99-harden.conf:
#        PasswordAuthentication no
#        KbdInteractiveAuthentication no
#        PubkeyAuthentication yes
#        PermitRootLogin prohibit-password   (root still allowed via key)
#   3. (Opt-in, NEW_USER=name) Create a sudo-group user with the same
#      authorized_keys file you're logged in with. A 20-char random sudo
#      password is generated and printed (override with NEW_USER_PASSWORD).
#   4. (Opt-in, LOCK_ROOT=1) Flip PermitRootLogin to `no`. Refuses unless
#      a non-root sudoer exists.
#
# Pre-flight: $HOME/.ssh/authorized_keys must be non-empty. The script
# refuses to harden a host that has no key-based access set up.
#
# Usage:
#   ssh -p 443 root@new-host
#   # baseline hardening (sslh + sshd key-only, root still allowed)
#   ~/.dotfiles/host-default/harden-remote.sh
#
#   # plus create a non-root sudoer
#   NEW_USER=andrew ~/.dotfiles/host-default/harden-remote.sh
#
#   # AFTER you've confirmed NEW_USER can log in and sudo, finish the job
#   LOCK_ROOT=1 ~/.dotfiles/host-default/harden-remote.sh
#
# Env knobs:
#   NEW_USER          create + key-provision this user, add to sudo group
#   NEW_USER_PASSWORD if NEW_USER is set, use this as their sudo password
#                     instead of a generated random one
#   LOCK_ROOT         "1" → PermitRootLogin no (requires a non-root sudoer)
#   SSLH_LISTEN_PORT  default 443
#   SSLH_TLS_TARGET   where sslh routes TLS traffic; default 127.0.0.1:4443
#                     (put your HTTPS server here, or leave it pointing
#                     nowhere if you only care about SSH on 443)

set -euo pipefail

NEW_USER="${NEW_USER:-}"
LOCK_ROOT="${LOCK_ROOT:-0}"
SSLH_LISTEN_PORT="${SSLH_LISTEN_PORT:-443}"
SSLH_TLS_TARGET="${SSLH_TLS_TARGET:-127.0.0.1:4443}"

log()  { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!! \033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mFAIL\033[0m %s\n' "$*" >&2; exit 1; }

if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null || die "Need root or sudo."
  SUDO="sudo"
else
  SUDO=""
fi

command -v apt-get >/dev/null || die "This script targets Debian/Ubuntu."

# ---- Pre-flight: must have a working authorized_keys -----------------------
if [ ! -s "$HOME/.ssh/authorized_keys" ]; then
  die "$HOME/.ssh/authorized_keys is missing or empty. Install your public key and retry."
fi

# Modern Debian/Ubuntu sshd_config sources /etc/ssh/sshd_config.d/*.conf
# via an Include line. If that's missing, our drop-in is silently a no-op.
if ! $SUDO grep -qE '^\s*Include\s+/etc/ssh/sshd_config\.d/\*\.conf' /etc/ssh/sshd_config; then
  die "/etc/ssh/sshd_config does not Include sshd_config.d/. Add 'Include /etc/ssh/sshd_config.d/*.conf' near the top of the file and retry."
fi

# ---- Phase 1: sslh on :443 -------------------------------------------------
log "Installing sslh"
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get update -y
$SUDO env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends sslh

log "Writing /etc/default/sslh (listen on :${SSLH_LISTEN_PORT})"
$SUDO tee /etc/default/sslh >/dev/null <<EOF
# Managed by host-default/harden-remote.sh
RUN=yes
DAEMON_OPTS="--user sslh --listen 0.0.0.0:${SSLH_LISTEN_PORT} --ssh 127.0.0.1:22 --tls ${SSLH_TLS_TARGET}"
EOF

for svc in apache2 nginx; do
  if $SUDO systemctl is-active --quiet "$svc" 2>/dev/null; then
    warn "$svc is running and may collide with sslh on :${SSLH_LISTEN_PORT}. Stop/move it before sslh restarts."
  fi
done

$SUDO systemctl enable sslh >/dev/null
$SUDO systemctl restart sslh
log "sslh up on :${SSLH_LISTEN_PORT} (SSH → 127.0.0.1:22, TLS → ${SSLH_TLS_TARGET})"

# ---- Phase 2: sshd key-only -----------------------------------------------
DROPIN=/etc/ssh/sshd_config.d/99-harden.conf
log "Writing $DROPIN"
$SUDO mkdir -p /etc/ssh/sshd_config.d
$SUDO tee "$DROPIN" >/dev/null <<'EOF'
# Managed by host-default/harden-remote.sh
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
PermitRootLogin prohibit-password
EOF

log "Validating sshd config"
$SUDO sshd -t || die "sshd config did not validate; inspect $DROPIN"

log "Reloading sshd (existing sessions stay alive)"
$SUDO systemctl reload ssh 2>/dev/null || $SUDO systemctl reload sshd

# ---- Phase 3 (optional): create non-root sudoer ---------------------------
if [ -n "$NEW_USER" ]; then
  if id "$NEW_USER" >/dev/null 2>&1; then
    log "User $NEW_USER already exists; ensuring sudo + key"
  else
    log "Creating user $NEW_USER"
    $SUDO adduser --disabled-password --gecos "" "$NEW_USER"
  fi

  $SUDO usermod -aG sudo "$NEW_USER"

  user_home=$(getent passwd "$NEW_USER" | cut -d: -f6)
  log "Installing authorized_keys for $NEW_USER (copied from $HOME/.ssh/authorized_keys)"
  $SUDO install -d -m 700 -o "$NEW_USER" -g "$NEW_USER" "$user_home/.ssh"
  $SUDO install -m 600 -o "$NEW_USER" -g "$NEW_USER" \
    "$HOME/.ssh/authorized_keys" "$user_home/.ssh/authorized_keys"

  # adduser --disabled-password leaves a `*` in /etc/shadow so `sudo` can't
  # authenticate the user. Set a password (honors NEW_USER_PASSWORD env var;
  # otherwise generates a 20-char random one and prints it).
  if $SUDO grep -qE "^${NEW_USER}:[!*]" /etc/shadow; then
    user_password="${NEW_USER_PASSWORD:-$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 20)}"
    echo "${NEW_USER}:${user_password}" | $SUDO chpasswd
    if [ -z "${NEW_USER_PASSWORD:-}" ]; then
      printf '\n\033[1;33m================================================================\033[0m\n'
      printf '\033[1;33m   Sudo password for %s:\033[0m  \033[1;36m%s\033[0m\n' "$NEW_USER" "$user_password"
      printf '\033[1;33m   RECORD THIS NOW — it will not be shown again.\033[0m\n'
      printf '\033[1;33m================================================================\033[0m\n\n'
    fi
  else
    log "User $NEW_USER already has a password; leaving it alone"
  fi

  cat <<EOF

  Before going further, in a NEW terminal:
    ssh -p ${SSLH_LISTEN_PORT} ${NEW_USER}@<this-host>
    sudo -v   # should prompt for password and succeed

  Once that works, rerun with LOCK_ROOT=1 to set PermitRootLogin no.

EOF
fi

# ---- Phase 4 (optional): block root login ---------------------------------
if [ "$LOCK_ROOT" = "1" ]; then
  sudo_members=$(getent group sudo | awk -F: '{print $4}')
  if [ -z "$sudo_members" ]; then
    die "LOCK_ROOT=1 refused: no members in the sudo group. Set NEW_USER=… or add a sudoer first."
  fi
  log "Setting PermitRootLogin no (sudo group members: $sudo_members)"
  $SUDO sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' "$DROPIN"
  $SUDO sshd -t || die "sshd config did not validate after locking root"
  $SUDO systemctl reload ssh 2>/dev/null || $SUDO systemctl reload sshd
  warn "Root login is now disabled. Use a sudoer from here on."
fi

cat <<EOF

==> Hardening complete.

Verify in a NEW terminal BEFORE logging out of this one:
  ssh -p ${SSLH_LISTEN_PORT} root@<this-host>                                  # should work via key
  ssh -p ${SSLH_LISTEN_PORT} -o PreferredAuthentications=password root@<this-host>  # should fail

EOF
