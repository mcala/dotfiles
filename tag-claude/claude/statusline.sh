#!/bin/bash

# Read Claude Code session data
input=$(cat)


# Extract data from input
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
output_style=$(echo "$input" | jq -r '.output_style.name // empty')
context_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
agent_name=$(echo "$input" | jq -r '.agent.name // empty')
total_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
total_duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')

# Colors (standard ANSI to match oh-my-posh named colors)
CYAN=$'\033[36m'
BLUE=$'\033[34m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
ORANGE=$'\033[33m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

# Start building status line
output=""

# Model and output style (blue for model)
if [ -n "$model_name" ]; then
    short_model=$(echo "$model_name" | sed 's/Claude //' | sed 's/ (.*)//')
    output="${output}${BLUE}${short_model}${RESET}"
fi

if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    output="${output}${DIM}:${RESET}${YELLOW}${output_style}${RESET}"
fi

# Agent name (if present)
if [ -n "$agent_name" ]; then
    output="${output} ${DIM}[${RESET}${YELLOW}${agent_name}${RESET}${DIM}]${RESET}"
fi

output="${output} ${DIM}│${RESET}"

# Path with folder icon (cyan, matching oh-my-posh)
if [ -n "$current_dir" ]; then
    dir_name=$(basename "$current_dir")
    output="${output} ${CYAN} ${dir_name}${RESET}"
fi

# Python environment (green, matching oh-my-posh python segment)
if [ -n "$VIRTUAL_ENV" ]; then
    venv_name=$(basename "$VIRTUAL_ENV")
    if command -v python >/dev/null 2>&1; then
        python_version=$(python --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
        output="${output} ${GREEN} ${venv_name} ${python_version}${RESET}"
    else
        output="${output} ${GREEN} ${venv_name}${RESET}"
    fi
elif command -v python3 >/dev/null 2>&1; then
    python_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
    output="${output} ${GREEN} ${python_version}${RESET}"
fi

# Vim mode indicator (if present)
if [ -n "$vim_mode" ]; then
    if [ "$vim_mode" = "INSERT" ]; then
        output="${output} ${GREEN}[I]${RESET}"
    elif [ "$vim_mode" = "NORMAL" ]; then
        output="${output} ${BLUE}[N]${RESET}"
    fi
fi

# Git information (cached to avoid running git on every refresh)
GIT_CACHE="/tmp/statusline-git-cache"
GIT_CACHE_MAX_AGE=5

git_cache_is_stale() {
    [ ! -f "$GIT_CACHE" ] || \
    [ $(($(date +%s) - $(stat -f %m "$GIT_CACHE" 2>/dev/null || echo 0))) -gt $GIT_CACHE_MAX_AGE ]
}

if [ -n "$current_dir" ] && cd "$current_dir" 2>/dev/null; then
    if git_cache_is_stale; then
        if git -c "core.fsmonitor=" rev-parse --git-dir >/dev/null 2>&1; then
            branch=$(git -c "core.fsmonitor=" branch --show-current 2>/dev/null)
            w_added=0; w_modified=0; w_deleted=0
            s_added=0; s_modified=0; s_deleted=0
            while IFS= read -r line; do
                [ -z "$line" ] && continue
                staging="${line:0:1}"
                working="${line:1:1}"
                case "$staging" in
                    A) s_added=$((s_added + 1)) ;;
                    M|R) s_modified=$((s_modified + 1)) ;;
                    D) s_deleted=$((s_deleted + 1)) ;;
                esac
                case "$working" in
                    \?) w_added=$((w_added + 1)) ;;
                    M) w_modified=$((w_modified + 1)) ;;
                    D) w_deleted=$((w_deleted + 1)) ;;
                esac
            done <<< "$(git -c "core.fsmonitor=" status --porcelain 2>/dev/null)"
            echo "${branch}|${w_added}|${w_modified}|${w_deleted}|${s_added}|${s_modified}|${s_deleted}" > "$GIT_CACHE"
        else
            echo "" > "$GIT_CACHE"
        fi
    fi

    IFS='|' read -r branch w_added w_modified w_deleted s_added s_modified s_deleted < "$GIT_CACHE"

    if [ -n "$branch" ]; then
        output="${output} ${DIM}on${RESET} ${YELLOW} ${branch}${RESET}"

        if [ $((w_added + w_modified + w_deleted)) -gt 0 ]; then
            counts=""
            [ "$w_added" -gt 0 ] && counts="${counts}+${w_added} "
            [ "$w_modified" -gt 0 ] && counts="${counts}~${w_modified} "
            [ "$w_deleted" -gt 0 ] && counts="${counts}-${w_deleted} "
            output="${output} ${RED}● ${counts% }${RESET}"
        fi

        if [ $((s_added + s_modified + s_deleted)) -gt 0 ]; then
            counts=""
            [ "$s_added" -gt 0 ] && counts="${counts}+${s_added} "
            [ "$s_modified" -gt 0 ] && counts="${counts}~${s_modified} "
            [ "$s_deleted" -gt 0 ] && counts="${counts}-${s_deleted} "
            output="${output} ${GREEN}● ${counts% }${RESET}"
        fi
    fi
fi


# === Line 2: context bar, context %, cost, session time ===
line2=""

# Context bar
if [ -n "$context_used" ]; then
    bar_width=10
    used_int=$(echo "$context_used" | cut -d'.' -f1)
    filled=$(( used_int * bar_width / 100 ))
    empty=$(( bar_width - filled ))

    # Color the bar based on usage
    if [ "$used_int" -lt 50 ]; then
        bar_color="$GREEN"
    elif [ "$used_int" -lt 75 ]; then
        bar_color="$YELLOW"
    else
        bar_color="$RED"
    fi

    bar="${bar_color}"
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    bar="${bar}${DIM}"
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    bar="${bar}${RESET}"

    line2="${line2}${bar} ${bar_color}${used_int}%${RESET}"
fi

# Cost
if [ -n "$total_cost" ]; then
    cost_fmt=$(printf '$%.2f' "$total_cost")
    line2="${line2} ${DIM}│${RESET} ${CYAN}${cost_fmt}${RESET}"
fi

# Session duration
if [ -n "$total_duration_ms" ]; then
    total_secs=$(( total_duration_ms / 1000 ))
    hours=$(( total_secs / 3600 ))
    mins=$(( (total_secs % 3600) / 60 ))
    secs=$(( total_secs % 60 ))
    if [ "$hours" -gt 0 ]; then
        duration="${hours}h${mins}m"
    elif [ "$mins" -gt 0 ]; then
        duration="${mins}m${secs}s"
    else
        duration="${secs}s"
    fi
    line2="${line2} ${DIM}│${RESET} ${BLUE}${duration}${RESET}"
fi

printf "%s\n%s" "$output" "$line2"