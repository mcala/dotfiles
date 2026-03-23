---
name: git-commit
description: Create a git commit following the conventional commit specification with AI attribution tagging. Use when making a git commit, committing changes, or when the user says "commit".
disable-model-invocation: false
argument-hint: [--draft | --finalize | optional message hint]
allowed-tools: Bash(git *), Read, Write, Glob
---

# Git Commit Skill

Create a git commit that follows the conventional commit specification with AI attribution tagging.

## Modes

This skill operates in three modes based on `$ARGUMENTS`:

- **Default** (no flag): commit immediately as described in the standard process below.
- **`--draft`**: write draft commit files instead of committing. Remaining arguments are used as a hint.
- **`--finalize`**: read existing draft files, validate them, and execute the commits in order.

## Standard Process

1. Run `git status` to review staged and unstaged changes. Never use the `-uall` flag.
2. Run `git diff --cached` to inspect staged changes. If nothing is staged, review unstaged changes and stage coherent, logically related changes to form an atomic commit. If you are unsure what belongs together, ask the user before staging anything.
3. Run `git log --oneline -5` to review recent commit style for consistency.
4. Compose the commit message following the format and rules below.
5. Present the draft commit message to the user for approval before committing. If the user requests changes, revise and re-present before committing.
6. Create the commit. Use a HEREDOC to pass the message to `git commit -m`. Never use `--no-verify`.

If `$ARGUMENTS` is provided (and is not a flag), use it as a hint for the commit description but still follow all formatting rules.

## Draft Mode (`--draft`)

Instead of committing, write one or more `DRAFT_COMMIT_#.md` files to the working directory. The `#` is a sequential integer (starting at 1) indicating the order commits should be made in.

### Draft process

1. Run `git status` to review all staged and unstaged changes. Never use the `-uall` flag.
2. Run `git diff` (unstaged) and `git diff --cached` (staged) to understand the full set of changes.
3. Run `git log --oneline -5` to review recent commit style for consistency.
4. Plan how to split the changes into logical, atomic commits. Each draft represents one commit.
5. For each planned commit, write a `DRAFT_COMMIT_#.md` file using the format below.
6. Present a summary of the draft files to the user (number of drafts, brief description of each).

If draft files already exist in the working directory (e.g., `DRAFT_COMMIT_1.md`), number new drafts starting after the highest existing number.

### Draft file format

Each draft file uses the following structure. The commit message block uses a `text` fenced code block so the message content is preserved exactly.

    # Draft Commit #

    ## Files to stage

    - path/to/file_a.py
    - path/to/file_b.py

    ## Commit message

    ```text
    <full commit message, including body and trailers, following all formatting rules>
    ```

The "Files to stage" section lists the paths that should be `git add`-ed before this commit. The "Commit message" section contains the complete commit message exactly as it should be passed to `git commit -m`.

## Finalize Mode (`--finalize`)

Read existing `DRAFT_COMMIT_#.md` files, validate them, and execute the commits in sequence.

### Finalize process

1. Glob for `DRAFT_COMMIT_*.md` in the working directory. If none are found, inform the user and stop.
2. Sort the files by their number to determine commit order.
3. For each draft file, in order:
   a. Read the file and parse the files-to-stage list and commit message.
   b. **Validate** the commit message against all rules in this skill (conventional commit format, AI tag present, trailers present and correctly ordered). If validation fails, report the issue to the user and stop — do not skip or auto-fix.
   c. Stage the listed files with `git add`.
   d. Present the commit message to the user for approval before committing.
   e. Create the commit using a HEREDOC. Never use `--no-verify`.
4. After all drafts are successfully committed, delete the `DRAFT_COMMIT_*.md` files from the working directory.

## Commit Message Format

Follow the conventional commit spec. Header: `type(scope)!: [AI-tag] description`

- Aim for 80 characters or less for the full header line; 100 characters is the hard maximum (the AI tag may consume some of this budget)
- Use imperative mood, present tense; do not capitalize or end with a period
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `data`, `revert`, `chore`

```text
<type>(<optional scope>): [AI-tag] <description>

<optional body>

<optional footer(s)>
Co-Authored-By: Claude <noreply@anthropic.com>
AI-assisted: <what AI did and what the human did>
```

## AI Attribution Tagging

Every commit MUST include an AI tag in the description and the `Co-Authored-By` + `AI-assisted` trailers as the last footers.

### AI Tags

Place the tag **after** the colon-space and **before** the description text:

| Tag           | When to use                                                                 |
| ------------- | --------------------------------------------------------------------------- |
| `[AI]`        | AI generated the substantial or core work (functions, features, algorithms) |
| `[AI-minor]`  | AI made minor contributions (formatting, boilerplate, small fixes)          |
| `[AI-review]` | Human wrote the code; AI reviewed, suggested improvements, or debugged      |

### Trailers

Always end with `Co-Authored-By` then `AI-assisted`. Be specific and honest in the `AI-assisted` line.

Examples:

- `AI-assisted: Core logic generated by Claude, tests human-written.`
- `AI-assisted: Human wrote the implementation, AI suggested error handling.`
- `AI-assisted: Human-written code, AI reviewed for correctness.`

## Examples

### Feature with substantial AI contribution

```text
feat(parser): [AI] add recursive JSON parser for nested objects

Implements a recursive descent parser that handles arbitrarily
nested JSON objects with proper error recovery and position
tracking.

Co-Authored-By: Claude <noreply@anthropic.com>
AI-assisted: Core parsing logic generated by Claude, edge case
tests and error messages written by human.
```

### Bug fix with minor AI help

```text
fix(auth): [AI-minor] correct token refresh race condition

Closes #247
Co-Authored-By: Claude <noreply@anthropic.com>
AI-assisted: Human diagnosed and fixed the bug, AI helped with mutex syntax.
```

### Breaking change with AI contribution

```text
feat(api)!: [AI] redesign authentication to use OAuth 2.0

Replaces the custom token-based auth system with standard
OAuth 2.0 authorization code flow. All API endpoints now
require Bearer tokens obtained through the /oauth/token endpoint.

BREAKING CHANGE: The X-Auth-Token header is no longer accepted.
All clients must migrate to OAuth 2.0 Bearer tokens.
Co-Authored-By: Claude <noreply@anthropic.com>
AI-assisted: Full implementation generated by Claude, security
review and configuration done by human.
```
