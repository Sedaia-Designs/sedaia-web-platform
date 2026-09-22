---
name: code-style
description: Apply Sedaia Web Platform frontend conventions when creating, editing, formatting, or reviewing SolidJS 2, TypeScript/TSX, Sass, Vite, or frontend configuration in the portfolio or business applications.
---

# Apply Frontend Code Style

Read the repository-root `AGENTS.md`, the target application's `AGENTS.md`, and nearby code before editing. Treat app-specific guidance as authoritative for differences between `apps/portfolio` and `apps/business`.

- Use strict TypeScript, `.tsx` for JSX, and `.ts` otherwise.
- Use SolidJS primitives and fine-grained reactivity; do not import React conventions. Use `class`, not `className`, and prefer accessors, `For`, `Show`, and `createMemo` where they improve Solid behavior.
- Keep application entry components focused on composition. Extract reusable UI and nonvisual behavior according to the target application's existing structure.
- Use typed props, semantic HTML, and explicit loading, empty, error, and stale states for API-backed content.
- Guard browser-only APIs during static document generation.
- Use Sass for authored styles and preserve nearby conventions. Prefer existing semantic tokens and use `hsl()` or `oklch()` for new authored colors.
- Preserve package boundaries. Shared code belongs in `packages/` only when more than one application has a concrete need for it.

Use the target package's scripts for focused checks. Run the relevant filtered test, lint, format-check, and build commands, then `git diff --check`, in proportion to the change.
