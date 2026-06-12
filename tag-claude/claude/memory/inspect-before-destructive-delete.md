---
name: inspect-before-destructive-delete
description: Always inspect untracked/modified files before force-deleting worktrees or running rm -rf; get explicit OK
metadata:
  type: feedback
---

Before any destructive deletion — `git worktree remove --force`, `rm -rf`, `git clean -fd`, force-deleting branches with unmerged work — STOP and inspect what would be lost (untracked + modified files), then surface it to Andrew and get explicit confirmation. NEVER pass `--force` to bypass a "contains modified or untracked files" warning without first listing those files.

**Why:** In the readlog repo I hit a `git worktree remove` that failed with "contains modified or untracked files," and I re-ran it with `--force` without checking — destroying untracked working-tree files (`--force` does not use Trash, and `git fsck` cannot recover files that were never committed/staged). They turned out to be generated artifacts (`.envrc`, `__pycache__`, `uv.lock`), but I couldn't prove that because I deleted before looking. Andrew's rule: "if there are UNTRACKED FILES you need to tell me."

**How to apply:** When a git command refuses to delete because of untracked/modified content, run a read-only diff/status first (e.g. `git status`, or `diff -rq` of the worktree against a clean checkout), report exactly what's there, and only delete after Andrew confirms. Treat the `--force` flag as requiring explicit permission.
