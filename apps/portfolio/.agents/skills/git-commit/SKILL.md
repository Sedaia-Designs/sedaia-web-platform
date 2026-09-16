---
name: git-commit
description: Create safe, logically grouped Git commits in this Sedaia repository. Use when asked to commit, stage a logical change, prepare a commit message, or run a commit workflow without disturbing unrelated work or crossing repository boundaries.
---

# Create a Git commit

Commit only when explicitly requested and operate in this repository only.

## Subject format

Use `[Type -> module] Description` for one or two affected modules and
`[Type] Description` for broader changes.

- Use an established repository-local format when it differs.
- Common types include `Feature`, `Fix`, `Docs`, `UI/UX`, `Refactor`, `Test`,
  `Build`, `CI`, `Chore`, `Release`, and `Revert`.
- Write an imperative, sentence-case description without a trailing period.
- Keep the complete subject concise, ideally at or below 150 characters.

## Workflow

1. Read the repository-root `AGENTS.md`.
2. Inspect recent subjects, `git status --short --branch`, staged changes, and
   unstaged changes.
3. Identify the requested logical change and preserve unrelated work.
4. Stage explicit paths only; never use a broad add around unrelated changes.
5. Review the staged stat, full staged diff, and `git diff --staged --check`.
6. Run checks required by the changed surface.
7. Commit without bypassing hooks. Report the hash, subject, checks, and
   remaining worktree state.

Never change Git configuration, discard changes, amend, push, tag, publish,
force an operation, or combine independent repositories without explicit
authorization.
