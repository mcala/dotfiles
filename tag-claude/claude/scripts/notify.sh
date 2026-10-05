#!/bin/bash

# Claude Code Desktop Notifications for macOS
#
# This script can be used in two ways:
#
# 1. DIRECT CALL (from command line or simple hooks):
#    notify.sh <event> [custom_message]
#    Example: notify.sh commit "Initial commit"
#
# 2. HOOK INPUT (from PostToolUse hooks with stdin JSON):
#    Configure your hook with matcher "Bash", and this script will automatically
#    detect and parse the JSON input from Claude Code hooks to filter commands.
#    Example hook configuration:
#    {
#      "PostToolUse": [{
#        "matcher": "Bash",
#        "hooks": [{"type": "command", "command": "~/.claude/scripts/notify.sh"}]
#      }]
#    }
#
# IMPORTANT: Hook matchers only match tool names (e.g., "Bash", "Write"),
# not command contents. To filter specific bash commands like "git commit" or
# "npm test", use matcher "Bash" and filter inside this script.

# Check if command-line arguments were provided first (highest priority)
if [ $# -gt 0 ]; then
    # Direct call mode: use command-line arguments
    # This handles both direct calls and hooks that pass explicit event types
    # Example: notify.sh search, notify.sh commit "message"
    EVENT="$1"
    CUSTOM_MSG="$2"
# Check if we're receiving hook input via stdin (non-interactive mode, no args)
elif [ ! -t 0 ]; then
    # Read JSON input from stdin (from Claude Code hook)
    INPUT=$(cat)

    # Check if jq is available for JSON parsing
    if command -v jq &>/dev/null; then
        # Extract the bash command from the hook JSON input
        # Hook JSON structure: {"tool": "Bash", "tool_input": {"command": "..."}, ...}
        COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

        # Filter based on bash command content and set event type
        if [[ $COMMAND == *"git commit"* ]]; then
            EVENT="commit"
            CUSTOM_MSG=""
        elif [[ $COMMAND == *"git push"* ]]; then
            EVENT="finished"
            CUSTOM_MSG="Pushed to remote"
        elif [[ $COMMAND == *"npm test"* ]]; then
            EVENT="tool"
            CUSTOM_MSG="Tests executed"
        elif [[ $COMMAND == *"npm run build"* ]]; then
            EVENT="tool"
            CUSTOM_MSG="Build completed"
        else
            # Exit silently for other bash commands we don't want to notify about
            exit 0
        fi
    else
        # If jq is not installed, warn and exit
        # Install jq: brew install jq (macOS) or apt-get install jq (Linux)
        echo "Warning: jq is required for parsing hook JSON input" >&2
        exit 0
    fi
else
    # No args and no stdin: use default
    EVENT="finished"
    CUSTOM_MSG=""
fi

PROJECT="${PWD##*/}"
REPO_NAME=$(git rev-parse --show-toplevel 2>/dev/null | xargs basename 2>/dev/null)
BRANCH=$(git branch --show-current 2>/dev/null)
TITLE="${REPO_NAME:-$PROJECT}"
[[ -n "$BRANCH" ]] && TITLE="$TITLE ($BRANCH)"

case "$EVENT" in
commit)
    ICON="✓"
    MESSAGE="${CUSTOM_MSG:-Committed changes}"
    ;;
approval | input)
    ICON="⏸"
    MESSAGE="${CUSTOM_MSG:-Waiting for input}"
    ;;
finished | done | stop)
    ICON="🚀"
    MESSAGE="${CUSTOM_MSG:-Finished!}"
    ;;
subagent | agent)
    ICON="🔀"
    MESSAGE="${CUSTOM_MSG:-Spawning subagent}"
    ;;
search | web)
    ICON="🔍"
    MESSAGE="${CUSTOM_MSG:-Searching the web}"
    ;;
error)
    ICON="❌"
    MESSAGE="${CUSTOM_MSG:-An error occurred}"
    ;;
start)
    ICON="▶️"
    MESSAGE="${CUSTOM_MSG:-Session started}"
    ;;
tool)
    ICON="🔧"
    MESSAGE="${CUSTOM_MSG:-Tool executed}"
    ;;
*)
    ICON="📌"
    MESSAGE="${CUSTOM_MSG:-$EVENT}"
    ;;
esac

# Detach alerter's output so the hook returns immediately instead of waiting on the timeout
alerter --title "$ICON $TITLE" --message "$MESSAGE" --app-icon /Applications/Claude.app/Contents/Resources/electron.icns --timeout 5 >/dev/null 2>&1 &
