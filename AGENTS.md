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
