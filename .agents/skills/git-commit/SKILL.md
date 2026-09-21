---
name: git-commit
description: Create safe, logically grouped Git commits in the Sedaia Web Platform monorepo. Use when asked to commit, stage a logical change, prepare a commit message, or run a commit workflow without disturbing unrelated work.
---

# Create a Git Commit

Commit only when explicitly requested and operate only in the current repository.

## Subject Format

Use `[Type: module]: Description`, or `[Type]: Description` when a change spans the repository or has no meaningful single module.

- Choose a short module such as `ktor`, `solidjs`, `gradle`, `docs`, or `git`.
- Use an appropriate capitalized type such as `Add`, `Fix`, `Update`, `Refactor`, `Test`, `Docs`, `Build`, or `Chore`.
- Write an imperative, sentence-case description without a trailing period.
- Keep the complete subject at or below 150 characters.

## Workflow

1. Read the repository-root and relevant nested `AGENTS.md` files.
2. Inspect recent subjects, the current branch, `git status --short`, staged changes, and unstaged changes.
3. Identify the requested logical change and preserve unrelated work across all workspace packages.
4. Stage explicit paths only; never use a broad add around unrelated changes.
5. Review the staged stat, complete staged diff, and `git diff --staged --check`.
6. Run checks required by every affected package or surface.
7. Commit without bypassing hooks. Report the hash, subject, checks, and remaining worktree state.

Never change Git configuration, discard changes, amend, push, tag, publish, force an operation, or combine independent repositories without explicit authorization.
