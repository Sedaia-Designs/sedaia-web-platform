---
name: code-style
description: Apply Sedaia Portfolio conventions when creating, editing, formatting, or reviewing SolidJS 2, TypeScript/TSX, Sass, Vite, or frontend configuration.
---

# Apply code style

Read `../../../../AGENTS.md` and nearby code before editing.

- Use strict TypeScript, `.tsx` for JSX, and `.ts` otherwise.
- Use SolidJS primitives and fine-grained reactivity; do not import React
  conventions. Use `class` for JSX classes and never React's `className`. Use
  accessors, `For`, `Show`, and `createMemo` where appropriate.
- Keep `src/App.tsx` focused on page composition. Extract reusable UI to
  `src/components/` and nonvisual logic to `src/lib/`.
- Use typed props, semantic HTML, and explicit loading, empty, error, and stale
  states for API-backed content.
- Guard browser-only APIs during static document generation.
- Use Sass for authored styles and preserve nearby conventions. Prefer semantic
  tokens and `hsl()` or `oklch()` for new authored colors.

Validate with focused tests when present, then run `pnpm build` and
`git diff --check` as appropriate to the change.
