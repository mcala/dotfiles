#!/usr/bin/env bash
# ABOUTME: PostToolUse hook that runs ruff (fix + format) then ty (report-only) on an
# ABOUTME: edited Python file, preferring the project's venv tools over the global install.
set -uo pipefail

payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

case "$file" in
  *.py|*.pyi) ;;
  *) exit 0 ;;
esac
[ -f "$file" ] || exit 0

# Prefer an active venv, then the project's ./.venv, then whatever is on PATH.
resolve() {
  if [ -n "${VIRTUAL_ENV:-}" ] && [ -x "$VIRTUAL_ENV/bin/$1" ]; then
    printf '%s' "$VIRTUAL_ENV/bin/$1"
  elif [ -x "./.venv/bin/$1" ]; then
    printf '%s' "./.venv/bin/$1"
  else
    command -v "$1" 2>/dev/null
  fi
}

ruff=$(resolve ruff)
ty=$(resolve ty)
nl=$'\n'
msg=""

# ruff: auto-fix safe lint issues, then format. Re-check (no --fix) to capture anything it
# could not auto-fix, with accurate post-format line numbers. Fixes show in the diff.
# F401 (unused import) is left unfixable: during a multi-step edit an import is briefly unused
# before its first use is added, and auto-removing it clobbers the import. It is still reported.
if [ -n "$ruff" ]; then
  "$ruff" check --fix --unfixable F401 "$file" >/dev/null 2>&1
  "$ruff" format "$file"     >/dev/null 2>&1
  ruff_out=$("$ruff" check "$file" 2>&1)
  if [ $? -ne 0 ] && [ -n "$ruff_out" ]; then
    msg="ruff:${nl}${ruff_out}"
  fi
fi

# ty: report-only type check.
if [ -n "$ty" ]; then
  ty_out=$("$ty" check "$file" 2>&1)
  if [ $? -ne 0 ] && [ -n "$ty_out" ]; then
    [ -n "$msg" ] && msg="${msg}${nl}${nl}"
    msg="${msg}ty:${nl}${ty_out}"
  fi
fi

# Surface combined ruff + ty findings to the user only; never block, never feed back to the model.
if [ -n "$msg" ]; then
  jq -n --arg m "$msg" '{systemMessage: $m, suppressOutput: true}'
fi
exit 0
