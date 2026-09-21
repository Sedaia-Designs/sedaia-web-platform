# Sedaia Web Platform Agent Guidelines

These instructions apply to the entire repository. More specific `AGENTS.md`
files may add project-level guidance but must not weaken these rules.

## Operations

- `mcp.cua_repl.js` (also exposed as `mcp__cua_repl.js`) and all other
  computer-use or GUI-automation tools are off limits.
- Do not take control of the user's screen, mouse, keyboard, browser, IDE, or
  other graphical applications. Do not click through user interfaces.
- Perform all agent operations through standard shell interactions and
  repository file-editing tools.
- If a task cannot be completed through the shell, stop and explain what the
  user must do manually instead of attempting graphical automation.


## Git Guidelines

### Staging

- Inspect `git status` and the relevant diffs before staging anything.
- Stage only files that belong to the requested change; never include unrelated user work or generated files.
- Prefer explicit file paths over `git add .` or `git add -A`.
- Review the staged diff with `git diff --staged` before committing.
- Do not discard, overwrite, reset, or otherwise alter existing user changes to produce a clean working tree.

### Commits

- Create a commit only when the user explicitly requests one.
- Keep each commit focused on one cohesive change and ensure its staged contents match its description.
- Use the required format `[Type: module]: Description`.
- Use a short, meaningful module name identifying the affected area, such as `ktor`, `solidjs`, `gradle`, `docs`, or `git`.
- The module may be omitted when the change spans the entire repository, has no meaningful single module, or including it would prevent the message from meeting the length limit. The resulting format is `[Type]: Description`.
- Use an appropriate, consistently capitalized type such as `Add`, `Fix`, `Update`, `Refactor`, `Test`, `Docs`, `Build`, or `Chore`.
- Write the description in the imperative mood, start it with a capital letter, and do not end it with a period.
- Limit the complete commit message to 150 characters, including the prefix, spaces, and punctuation.
- Do not amend, squash, rewrite, or otherwise modify existing commits unless the user explicitly requests it.

Examples:

```text
[Add: solidjs]: Configure the frontend development proxy
[Fix: gradle]: Run pnpm installs in a non-interactive environment
[Docs]: Explain the production build workflow
```

### Pushing

- Push only when the user explicitly requests it.
- Before pushing, verify the current branch, configured remote, intended upstream, and commits that will be sent.
- Use a normal push by default; never force-push unless the user explicitly requests it and the exact target has been verified.
- Report the destination remote and branch after a successful push, or clearly report any failure without repeatedly retrying unsafe alternatives.
- When writing in the Obsidian Vault, do not separate paragraphs, list items, etc onto multiple lines. Obsidian has Word Wrapping, and Newlines break Checkboxes rendering

## Record Keeping/Note-Taking

All information and notes not needed for README, LICENSE, CONTRIBUTING, or other necessary GitHub Metadata must go into `/ObsidianVault/`

### Feature and Refactor Planning

Avoid putting planning information directly into the Readme, always put planning information in into `cd ./ObsidianVault/Plans` as Obsidian Markdown
- Each Phase of the plan should be in a separate note
- The plan itself will be nested in a subfolder named accordingly, example being `/ObsidianVault/Plans/PlanToExecute1/note.md`.
- Add a top level orchestration note which provides the recommended order of operation, description summary, key context, and other multi-phase steps.
- The last step will always be final verification
- Plans are intended for a Human SWE to follow and operate with, and must be written clearly.
- When Clarification is asked regarding a Plan, Phase, or Step, always apply the clarifications to the document itself.

## Repository Skills

- Use `.agents/skills/code-style` for SolidJS, TypeScript/TSX, Sass, Vite, or frontend configuration work in either web application.
- Use `.agents/skills/ui-accessibility` for frontend components, interactions, layouts, and accessibility reviews.
- Use `.agents/skills/integrate-brand-icons` when adding or normalizing SVG brand marks.
- Use `.agents/skills/git-commit` for staging, commit-message preparation, or commits.
- Use `.agents/skills/edit-changelog` for changelog entries and release notes.
- Use `.agents/skills/cross-repository-release` for releases coordinated with independent Sedaia repositories.
- Use `.agents/skills/cross-site-content-migration` when adapting public content among applications or Sedaia properties.
